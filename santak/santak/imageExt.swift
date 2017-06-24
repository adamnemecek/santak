//
//  resizeImage.swift
//  santak
//
//  Created by Edward Williams on 6/21/17.
//  Copyright © 2017 Edward Clem Williams. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x:0, y:0, width:newSize.width, height:newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func grayScaleImage() -> UIImage {
        //let imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
        let imageRect = CGRect(origin: CGPoint.zero, size: self.size)
        let colorSpace = CGColorSpaceCreateDeviceGray();
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: .allZeros)
        
        // set Fill Color to White (or some other color)
        context?.setFillColor(UIColor.white.cgColor)
        // Draw a white-filled rectangle before drawing your image
        context?.fill(imageRect)
        
        context?.draw(self.cgImage!, in: imageRect)
        
        let imageRef = context?.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        return newImage
    }
}
