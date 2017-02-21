//
//  ViewController.swift
//  santak
//
//  Created by Edward Williams on 2/20/17.
//  Copyright © 2017 Edward Clem Williams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var lastPoint = CGPoint(x: 0, y:0)
    var firstPoint = CGPoint(x: 0, y: 0)
    var brushWidth: CGFloat = 5
    var opacity: CGFloat = 1.0
    var swiped = false
    let xAxis = CGVector(dx: 1, dy:0)
    var sideLength = CGFloat(40.0)
    var touchInView = false
    
    @IBOutlet weak var primaryImageView: UIImageView!
    @IBOutlet weak var secondaryImageView: UIImageView! //used as temporary view
    
    
    //clear image
    @IBAction func clear(_ sender: AnyObject){
        primaryImageView.image = nil
    }
    
    //search for closest matching glyph 
    //TODO
    @IBAction func search(_ sender: AnyObject){
        print("Searching")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryImageView.layer.borderColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1).cgColor //black border
        secondaryImageView.layer.borderWidth = 2
        
        primaryImageView.layer.borderColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1).cgColor //black border
        primaryImageView.layer.borderWidth = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //input: UIImageView with a black and white RGBA image
    //output: UInt8 array of the alpha values for each pixel, flattened
    //TODO: error handling for null array
    //NOTE: I remember reading that the simulator and iOS devices handle this encoding differently, make sure that works
    func vectorizeImageView(fromImageView ImageView:UIImageView) -> [UInt8]{
        let width = Int((ImageView.image?.cgImage?.width)!)
        var ImageArray = Array(repeating: UInt8(0), count: width*width)
        let data = ImageView.image?.cgImage?.dataProvider?.data
        let pix: UnsafePointer<UInt8> = CFDataGetBytePtr(data)
        
        var pixelIndex: Int = 0
        
        for x in 0...width{
            for y in 0...width{
                pixelIndex = ((width * Int(y)) + Int(x)) * 4
                ImageArray[pixelIndex] = 255 - UInt8(pix[pixelIndex + 3]) //so 255 is high, 0 is low
            }
        }
        
        return ImageArray
        
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
        context?.addLine(to: point2)
        context?.addLine(to: point3)
        context?.addLine(to: point1) //back to tip
        
        context?.setFillColor(red: 255, green: 255, blue: 255, alpha: 1.0)
        context?.drawPath(using: .fillStroke) //fill path with all white, then stroke it
        
        //draw line
        
        context?.move(to: point1)
        
        //tail point in new coordinate frame
        
        let len = vecLen(vecBetween(tail, wedgeCenter))
        
        context?.addLine(to: CGPoint(x: len, y:0))
        context?.strokePath()
        
        secondaryImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        secondaryImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }


}

