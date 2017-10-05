//
//  IceProjectile.swift
//  ColdWar
//
//  Created by Daniel Giaime on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class IceProjectile : SKSpriteNode {
    var projectileSpeed:CGFloat = 300.0
    var fwd:CGPoint = CGPoint(x:0.0, y:1.0) // north/up
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    var isRed:Bool = false
    
    init(position:CGPoint, projectileSpeed:CGFloat, fwd:CGPoint, isRed:Bool) {
        let texture = SKTexture(imageNamed: "iceLaser")
        super.init(texture: texture, color: UIColor.clear, size: (texture.size()))
        
        self.position = position;
        self.projectileSpeed = projectileSpeed
        self.fwd = fwd
        self.isRed = isRed
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: texture.size().width,
                                                             height: texture.size().height))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.All
        self.physicsBody?.contactTestBitMask = PhysicsCategory.All
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // methods
    func update(dt:CGFloat) {
        velocity = fwd * projectileSpeed
        position = position + velocity * dt
        
        zRotation = -atan2(fwd.y, fwd.x)
    }
}
