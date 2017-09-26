//
//  FishProjectile.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class FishProjectile:SKSpriteNode {
    var projectileSpeed:CGFloat = 300.0
    var fwd:CGPoint = CGPoint(x:0.0, y:1.0) // north/up
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    var timer:CGFloat = 0;
    
    init(position:CGPoint, projectileSpeed:CGFloat, fwd:CGPoint, timer:CGFloat) {
        let texture = SKTexture(imageNamed: "fish")
        super.init(texture: texture, color: UIColor.clear, size: (texture.size()))

        self.timer = timer;
        self.position = position;
        self.projectileSpeed = projectileSpeed
        self.fwd = fwd
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // methods
    func update(dt:CGFloat) {
        velocity = fwd * projectileSpeed
        position = position + velocity * dt
        
        timer -= dt;
        print(fwd)
    }
    
    func reflectX() {
        fwd.x *= CGFloat(-1.0)
    }
    
    func reflectY() {
        fwd.y *= CGFloat(-1.0)
    }
}
