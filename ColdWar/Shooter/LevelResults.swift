//
//  LevelResults.swift
//  Shooter
//
//  Created by Sneha Vaswani on 9/24/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation

class LevelResults{
    let levelNum:Int
    let levelScore:Int
    let totalScore:Int
    let msg:String
    init(levelNum:Int, levelScore:Int, totalScore:Int, msg:String) {
        self.levelNum = levelNum
        self.levelScore = levelScore
        self.totalScore = totalScore
        self.msg = msg
    }
}
