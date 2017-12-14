//
//  MyUtils.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import UIKit

func getRandomPowerUpType() -> PowerUpType {
    let randNum = arc4random_uniform(3)
    switch (randNum)
    {
    case 0:
        return PowerUpType.Fish
    case 1:
        return PowerUpType.Ice
    default:
        return PowerUpType.Shield
    }
}

enum PowerUpType {
    case Ice
    case Fish
    case Shield
}

struct PhysicsCategory {
    static let None      : UInt32 = 0x1 << 0
    static let Player    : UInt32 = 0x1 << 1
    static let RedProj   : UInt32 = 0x1 << 2
    static let BlueProj  : UInt32 = 0x1 << 3
    static let PowerUp   : UInt32 = 0x1 << 4
    static let Border    : UInt32 = 0x1 << 5
    static let All       : UInt32 = UINT32_MAX
}

struct SpriteLayer {
    static let Background     : CGFloat = 1
    static let BackParticles  : CGFloat = 2
    static let Entities       : CGFloat = 3
    static let FrontParticles : CGFloat = 4
    static let HUD            : CGFloat = 5
}
