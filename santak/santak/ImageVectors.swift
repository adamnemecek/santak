//
//  ImageVectors.swift
//  santak
//
//  Created by Edward Williams on 2/20/17.
//  Copyright © 2017 Edward Clem Williams. All rights reserved.
//

import Foundation
import UIKit
import Darwin

//debug and helper functions for converting images to vectors

//DEPRECATED
func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int)
{
    var width = 0
    var height = 0
    var pixelValues: [UInt8]?
    if let imageRef = imageRef {
        width = imageRef.width
        height = imageRef.height
        let bitsPerComponent = imageRef.bitsPerComponent
        let bytesPerRow = imageRef.bytesPerRow
        let totalBytes = height * bytesPerRow
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var intensities = [UInt8](repeating: 0, count: totalBytes)
        
        let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
        contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
        
        pixelValues = intensities
    }
    
    return (pixelValues, width, height)
}

//debug function
func countNonzero(_ arr: [UInt8]) -> Int{
    var count = 0
    
    
    for val in arr{
        if val >  0{
            count += 1
        }
        
    }
    
    return count
}
