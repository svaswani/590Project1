//
//  CGPoint+Extensions.swift
//  SpriteKitSimpleGame
//
//  Created by jefferson on 9/14/16.
//  Copyright © 2016 tony. All rights reserved.
//

import CoreGraphics
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    public static func randomUnitVector()->CGPoint{
        let vector = CGPoint(x:CGFloat.random(min:-1.0,max:1.0),y:CGFloat.random(min:-1.0,max:1.0))
        return vector.normalized()
    }
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    func magnitudeSqr() -> CGFloat {
        return (x*x + y*y)
    }
    
}
