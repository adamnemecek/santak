//
//  ViewController.swift
//  santak
//
//  Created by Edward Williams on 2/20/17.
//  Copyright © 2017 Edward Clem Williams. All rights reserved.
//

import UIKit
import Sync
import Metal
import MetalKit
import MetalPerformanceShaders
import MetalBender

class ViewController: UIViewController {
    
    var lastPoint = CGPoint(x: 0, y:0)
    var firstPoint = CGPoint(x: 0, y: 0)
    var brushWidth: CGFloat = 8
    var opacity: CGFloat = 1.0
    var swiped = false
    let xAxis = CGVector(dx: 1, dy:0)
    var sideLength = CGFloat(50.0)
    var touchInView = false
    var network : Network!
    var commandQueue: MTLCommandQueue!
    var device: MTLDevice!
    var textureLoader: MTKTextureLoader!
    
    //still broken?
    //OH it's 2x scaling because of retina I think?
    //greyscale image function does weirdness here. seems to work, though. hacky af.
    var targetSize = CGSize(width: 100, height: 100)
    
    //MARK - IB functions + properties
    
    @IBOutlet weak var primaryImageView: UIImageView!
    @IBOutlet weak var secondaryImageView: UIImageView! //used as temporary view
    @IBOutlet weak var titleText: UILabel!
    

    //clear image
    @IBAction func clear(_ sender: AnyObject){
        primaryImageView.image = nil
    }
    
    //search for closest matching glyph 
    //run inference on Bender graph
    @IBAction func search(_ sender: AnyObject){
        
         print(String(describing: self.primaryImageView.image?.size))
        if primaryImageView.image != nil {
            //scale down image to 100 x 100
            print("preprocessing image")
            //let texture = self.textureLoader.newTexture(with: , options: [])
            
            let scaledImg = primaryImageView.image?.resizedImage(newSize: self.targetSize)
            
            print(String(describing: scaledImg?.size))
            
            //NOTE: the image isn't actually greyscale. 
            
            //converting to grayscale!
            
            print("converting to grayscale")
            
            let greyImg = scaledImg?.grayScaleImage()
            
            print(greyImg?.cgImage.debugDescription)
            //saving image to photo library for debug
//            UIImageWriteToSavedPhotosAlbum(scaledImg!, nil, nil,nil)
//
            let texture: MTLTexture
            do {
                texture = try textureLoader.newTexture(with: (greyImg?.cgImage)!, options: nil)
            } catch{
                fatalError("error loading image to MTLTexture")
            }

            //BOOM
            let input: MPSImage = MPSImage(texture: texture, featureChannels: 1)
            
            print(input.debugDescription)
            
            print("running inference")
            //TODO: wait until callback is completed
            network.run(inputImage: input, queue: commandQueue, callback: handleOutput)
            
        } else {
            let ac = UIAlertController(title: "Image Blank!", message: "No image is present.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    func handleOutput(output: MPSImage){
        print("inference completed!!")
        print(output.debugDescription)
        //20 feature channels
        let results = Texture(metalTexture: output.texture, size: LayerSize(f: 20, w: 1, h: 1))
        
        let flattened = results.data.flatMap({$0})
        let max = flattened.max()
        let index = flattened.index(of: max!)
        print(String(describing:flattened))
        print(index)
        

    }
    
    @IBAction func save(_ sender: AnyObject){
        if primaryImageView.image != nil {
            print("saving to photo library!")
            //TODO:figure out selector
            UIImageWriteToSavedPhotosAlbum(primaryImageView.image!, nil, nil,nil)
        } else{
            let ac = UIAlertController(title: "Image Blank!", message: "No image is present.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
            
            
        print("Saving to photos library!")
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Save to photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryImageView.layer.borderColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1).cgColor //black border
        secondaryImageView.layer.borderWidth = 2
        
        primaryImageView.layer.borderColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1).cgColor //black border
        primaryImageView.layer.borderWidth = 2
        
        
        //create MTLDevice
        print("initializing Metal device")
        self.device = MTLCreateSystemDefaultDevice()
        
        
        self.commandQueue = self.device.makeCommandQueue()
        
        self.textureLoader = MTKTextureLoader(device: self.device)
        
        
        self.network = Network(device: device!, inputSize: LayerSize(f: 1, w: 100), parameterLoader:nil)
        
        let url = Bundle.main.url(forResource: "santak-01", withExtension: "pb")
        
        //NOTE: I think the default converter's mappers will handle transposition. .
        let converter = TFConverter.default()
        
        self.network.convert(converter: converter, url: url!, type: .binary)
        
        //add softmax layer
        
        //self.network.addPostProcessing(layers: [Softmax()])
        
        self.network.initialize()
        
        print("loaded TF network")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        swiped = false
        touchInView  = false
        if let touch = touches.first {
            //only do anything if the touch is in the selected imageView
            firstPoint = touch.location(in: secondaryImageView)
            if secondaryImageView.bounds.contains(firstPoint){
                touchInView = true;
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        if touchInView {
            swiped = true
            if let touch = touches.first{
                lastPoint = touch.location(in: secondaryImageView)
                secondaryImageView.image = nil //reset temp image
                //wedge(center: firstPoint, tail: lastPoint)
                //drawLineFrom(from: firstPoint, to: lastPoint)
                wedge_and_line(wedgeCenter: firstPoint, tail: lastPoint)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event:UIEvent?){
        
        if touchInView {
            //merge secondaryImageView into primaryImageView
            UIGraphicsBeginImageContext(primaryImageView.frame.size)
            primaryImageView.image?.draw(in:secondaryImageView.bounds)
            secondaryImageView.image?.draw(in:primaryImageView.bounds)
            primaryImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            secondaryImageView.image = nil
        }
        
    }
    
    //draw a cuneiform stroke
    func wedge_and_line(wedgeCenter: CGPoint, tail: CGPoint){
        UIGraphicsBeginImageContext(secondaryImageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        secondaryImageView.image?.draw(in: secondaryImageView.bounds)
        
        let lineVec = normalize(vecBetween(tail, wedgeCenter))
        //if tail is below tip then invert angle
        let angle = tail.y > wedgeCenter.y ? angleBetween(lineVec, xAxis): -angleBetween(lineVec, xAxis)
        
        //for proper rotation, move origin to touch center, then rotate by angle between tail-tip vector and x axis
        context?.translateBy(x: wedgeCenter.x, y: wedgeCenter.y)
        context?.rotate(by:angle) //context now transformed
        
        //move context to tip
        let point1 = CGPoint(x: sideLength*CGFloat(sqrt(3)/4), y: 0)
        let point2 = CGPoint(x: -sideLength*CGFloat(sqrt(3)/4), y: sideLength/2)
        let point3 = CGPoint(x: -sideLength*CGFloat(sqrt(3)/4), y: -sideLength/2)
        
        context?.setLineWidth(brushWidth)
        context?.move(to: point1)
        
        //control points for quad bezier curves
        //let rotation = CGAffineTransform.init(rotationAngle: CGFloat(2.0 * Double.pi / 3.0))
        
        let cp2 = CGPoint(x:-6, y:0)
        
        //rotate to get point
        
        let cp1  = CGPoint(x:0, y:0)//cp2.applying(rotation)
        
        let cp3 = CGPoint(x:0, y:0) //cp1.applying(rotation)
        
        //let cp1 = CGPoint(x:0, y:0)
        //let cp3 = CGPoint(x:0, y:0)
        
        //experimenting with bezier curve
        context?.addQuadCurve(to: point2, control: cp1)
        
        //context?.addLine(to: point2)
        context?.addQuadCurve(to: point3, control: cp2)
        //context?.addLine(to: point3)
        //context?.addLine(to: point1) //back to tip
        context?.addQuadCurve(to: point1, control: cp3)
        
        context?.setFillColor(red: 255, green: 255, blue: 255, alpha: 1.0)
        context?.drawPath(using: .fillStroke) //fill path with all white, then stroke it
        
        //draw line, avoid overlap
        
        context?.move(to: CGPoint(x:point1.x - 5, y:point1.y))
        
        //tail point in new coordinate frame
        
        let len = vecLen(vecBetween(tail, wedgeCenter))
        
        context?.addLine(to: CGPoint(x: len, y:0))
        context?.strokePath()
        
        secondaryImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        secondaryImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }


}

