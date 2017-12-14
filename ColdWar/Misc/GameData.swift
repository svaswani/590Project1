//
//  GameData.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit

struct GameData{
    init(){
        fatalError("The GameData struct is a singleton")
    }

    struct font{
        static let mainFont = "SnowtopCaps"
    }
    
    struct hud{
        static let backgroundColor = SKColor(red: 0.2, green: 0.39, blue: 0.80, alpha: 1.0)

    }
    
    
    struct scene {
        static let backgroundColor = SKColor(red: 0.2, green: 0.39, blue: 0.80, alpha: 1.0)
    }
}
