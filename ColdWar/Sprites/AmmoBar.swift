//
//  AmmoBar.swift
//  ColdWar
//
//  Created by Student on 10/12/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class AmmoBar:SKShapeNode {
    // init
    init(position: CGPoint, isRed: Bool, width: CGFloat, height: CGFloat) {
        super.init()
        self.position = position;
        
        var effHeight = height;
        if (!isRed) {
            effHeight = -height;
        }
        
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: 0, y: 0))
        pathToDraw.addLine(to: CGPoint(x: 0, y: width / 2))
        pathToDraw.addLine(to: CGPoint(x: -effHeight, y: width / 2))
        pathToDraw.addLine(to: CGPoint(x: -effHeight, y: -width / 2))
        pathToDraw.addLine(to: CGPoint(x: 0, y: -width / 2))
        pathToDraw.addLine(to: CGPoint(x:0, y: 0))
        pathToDraw.closeSubpath()
        path = pathToDraw
        
        if (isRed)
        {
            self.strokeColor = UIColor.red
            self.fillColor = UIColor.red
        } else {
            self.strokeColor = UIColor.blue
            self.fillColor = UIColor.blue
        }
        
        self.lineWidth = 1

        self.zPosition = SpriteLayer.HUD
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
