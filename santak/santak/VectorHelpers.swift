//
//  VectorHelpers.swift
//  santak
//
//  Created by Edward Williams on 2/20/17.
//  Copyright © 2017 Edward Clem Williams. All rights reserved.
//

import Foundation
import UIKit
import Darwin

//implementation of various vector functions=

func degreesToRadians(deg: CGFloat) -> CGFloat {
    return deg*(CGFloat.pi/180.0)
}

func dotProd(_ vec1: CGVector, _ vec2: CGVector) -> CGFloat{
    return vec1.dx*vec2.dx + vec1.dy*vec2.dy
}

func vecLen(_ vec: CGVector) -> CGFloat{
    return sqrt(dotProd(vec, vec))
    
}

func vecBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGVector{
    return CGVector(dx: point1.x - point2.x, dy: point1.y - point2.y)
}

func normalize(_ vec: CGVector) -> CGVector{
    return CGVector(dx: vec.dx/vecLen(vec), dy: vec.dy/vecLen(vec))
}


//angle between points in radians
func angleBetween(_ vec1: CGVector, _ vec2:CGVector) -> CGFloat{
    return acos(dotProd(vec1, vec2)/(vecLen(vec1)*vecLen(vec2)))
}
