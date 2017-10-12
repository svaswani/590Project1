//
//  Shadow.swift
//  ColdWar
//
//  Created by Student on 10/12/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class Shadow:SKShapeNode {
    // init
    init(position: CGPoint) {
        super.init()
        self.position = position;
        
        let pathToDraw = CGMutablePath()
        pathToDraw.addArc(center: CGPoint(x: 0, y: 0), radius: 2, startAngle: 0, endAngle: 2 * 3.14159, clockwise: false)
        pathToDraw.closeSubpath()
        path = pathToDraw
        
        self.strokeColor = UIColor.black
        self.lineWidth = lineWidth
        self.fillColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
