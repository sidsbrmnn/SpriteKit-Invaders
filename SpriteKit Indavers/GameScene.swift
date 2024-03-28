//
//  GameScene.swift
//  SpriteKit Indavers
//
//  Created by Siddharth Subramanian on 3/28/24.
//

import SpriteKit

class GameScene: SKScene {
    
    var gameBorder = GameBorder()
    var player = Player()
    
    override required init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .blue
        
        addChild(gameBorder)
        gameBorder.addChild(player)
    }
}
