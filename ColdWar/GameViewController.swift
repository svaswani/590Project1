//
//  GameViewController.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    // ivars
    var gameScene: GameScene?
    var skView: SKView!
    let showDebugData = true
    let screenSize = CGSize(width: 1080, height: 1920)
    let scaleMode = SKSceneScaleMode.aspectFill
    
    // init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = self.view as! SKView
        loadHomeScreen()
        
        // debug stuff
        skView.ignoresSiblingOrder = true
        skView.showsFPS = showDebugData
        skView.showsNodeCount = showDebugData
        
    }
    
    // scene management
    func loadHomeScreen() {
        let scene = HomeScene(size:screenSize, scaleMode:scaleMode, sceneManager: self)
        let reveal = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: reveal)
    }
    
    func loadGameScene(levelNum:Int, totalScore:Int) {
        gameScene = GameScene(size:screenSize, scaleMode: scaleMode, levelNum: levelNum, totalScore: totalScore, sceneManager: self)
        
        //let reveal = SKTransition.flipHorizontal(withDuration: 1.0)
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1)
        //let reveal = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    func loadLevelFishedScene(results:LevelResults) {
        gameScene = nil
        let scene = LevelFinishScene(size:screenSize, scaleMode:scaleMode, results: results, sceneManager: self)
        let reveal = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: reveal)
    }
    
    func loadGameOverScene(results:LevelResults) {
        gameScene = nil
        let scene = GameOverScene(size:screenSize, scaleMode:scaleMode, results: results, sceneManager: self)
        let reveal = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: reveal)
    }
    
    // lifecycle
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
