//
//  Line.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 10/2/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class Line:SKShapeNode {
    // ivars
    
    // init
    init(size:CGSize, lineWidth:CGFloat, strokeColor:SKColor, fillColor:SKColor) {
        super.init()
        
        let topHalf = CGPoint(x:size.width/2, y:0)
        let bottomHalf = CGPoint(x:size.width/2, y:size.height)
        
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: topHalf)
        pathToDraw.addLine(to: bottomHalf)
        pathToDraw.closeSubpath()
        path = pathToDraw
 
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.fillColor = fillColor
        
        self.zPosition = SpriteLayer.HUD
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
