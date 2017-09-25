//
//  DiamondSprite.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class DiamondSprite:SKShapeNode {
    // ivars
    var fwd:CGPoint = CGPoint(x:0.0, y:1.0) // north/up
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    var delta:CGFloat = 300.0 // magnitude of the vector per second
    var hit:Bool = false
    
    // init
    init(size:CGSize, lineWidth:CGFloat, strokeColor:SKColor, fillColor:SKColor) {
        super.init()
        let halfHeight = size.height/2.0
        let halfWidth = size.height/2.0
        let top = CGPoint(x:0, y:halfHeight)
        let right = CGPoint(x:halfWidth, y:0)
        let bottom = CGPoint(x:0, y:-halfHeight)
        let left = CGPoint(x:-halfWidth, y:0)
        
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: top)
        pathToDraw.addLine(to: right)
        pathToDraw.addLine(to: bottom)
        pathToDraw.addLine(to: left)
        pathToDraw.closeSubpath()
        path = pathToDraw
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.fillColor = fillColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // methods
    func update(dt:CGFloat) {
        velocity = fwd * delta
        position = position + velocity * dt
    }
    
    func reflectX() {
        fwd.x *= CGFloat(-1.0)
    }
    
    func reflecyY() {
        fwd.y *= CGFloat(-1.0)
    }
}
