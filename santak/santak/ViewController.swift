//
//  ViewController.swift
//  santak
//
//  Created by Edward Williams on 2/20/17.
//  Copyright © 2017 Edward Clem Williams. All rights reserved.
//

import UIKit
import SwiftyJSON
import DATAStack
import Sync

class ViewController: UIViewController {
    
    var lastPoint = CGPoint(x: 0, y:0)
    var firstPoint = CGPoint(x: 0, y: 0)
    var brushWidth: CGFloat = 8
    var opacity: CGFloat = 1.0
    var swiped = false
    let xAxis = CGVector(dx: 1, dy:0)
    var sideLength = CGFloat(50.0)
    var touchInView = false
    
    var json_data: JSON = JSON.null //JSON for data loading
    
    var dataStack: DATAStack?
    
    //MARK - IB functions + properties
    
    @IBOutlet weak var primaryImageView: UIImageView!
    @IBOutlet weak var secondaryImageView: UIImageView! //used as temporary view
    @IBOutlet weak var titleText: UILabel!
    
    
    //clear image
    @IBAction func clear(_ sender: AnyObject){
        primaryImageView.image = nil
    }
    
    //search for closest matching glyph 
    //hahaha todo, man
    //next step is probably implementing this over the network?
    @IBAction func search(_ sender: AnyObject){
        print("Searching")
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
        
        //load JSON
        
//        if let file = Bundle.main.path(forResource: "json_images", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: file))
//                let json = JSON(data: data)
//                json_data = json
//            } catch {
//                json_data = JSON.null
//            }
//        } else {
//            json_data = JSON.null
//        }
//        
//        //Sync.changes(json_data[0] as Array, inEntityNamed: "Glyph", dataStack:self.dataStack)
//        
//        //playing around with DATAstack
//        
//        //save to object
//        let entity = NSEntityDescription.entity(forEntityName: "Glyph", in: (self.dataStack?.mainContext)!)
//        let object = NSManagedObject(entity: entity!, insertInto: self.dataStack?.mainContext)
//        let idnum = Int32(json_data[0]["id"].string!)
//        object.setValue(NSNumber(value: idnum!), forKey: "id")
//        //object.setValue(json_data[0]["vec"], forKey: "vec")
//        try! self.dataStack?.mainContext.save()
//        
//        
//        //fetching
//        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Glyph")
//        let items = (try! dataStack?.mainContext.fetch(request)) as! [NSManagedObject]
//        
//        print(items)
//        
//        try! self.dataStack!.drop()
    
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

