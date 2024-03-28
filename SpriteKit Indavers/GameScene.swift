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
    
    var lastTouch: CGPoint?
    
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
        
        let margin = 24
        for xp in (0...10) {
            for yp in (0...4) {
                let alien = Alien()
                alien.position.x = CGFloat(margin + xp * 48)
                alien.position.y = CGFloat(432 - yp * 48)
                
                gameBorder.addChild(alien)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        player.update(touching: lastTouch)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        lastTouch = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        lastTouch = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
    }
}
