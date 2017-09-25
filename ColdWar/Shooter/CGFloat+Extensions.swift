//
//  CGFloat+Extensions.swift
//  Shooter
//
//  Created by jefferson on 9/18/16.
//  Copyright © 2016 tony. All rights reserved.
//

import CoreGraphics
extension CGFloat{
    /**
     * Returns a random floating point number between 0.0 and 1.0, inclusive.
     */
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    /**
     * Returns a random floating point number in the range min...max, inclusive.
     */
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}
