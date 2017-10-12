//
//  CGVector+Extensions.swift
//  ColdWar
//
//  Created by Student on 10/12/17.
//  Copyright © 2017 Tanat Boozayaangool. All rights reserved.
//

import Foundation
import CoreGraphics

func / (point: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: point.dx / scalar, dy: point.dy / scalar)
}

func * (point: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: point.dx * scalar, dy: point.dy * scalar)
}

extension CGVector {
    func magnitudeSqr() -> CGFloat {
        return (dx*dx + dy*dy)
    }
    
    func magnitude() -> CGFloat {
        return sqrt(magnitudeSqr())
    }
    
    func normalize() -> CGVector {
        return self / magnitude()
    }
}
