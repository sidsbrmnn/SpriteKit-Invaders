//
//  GameScene.swift
//  Invaders
//
//  Created by Siddharth Subramanian on 3/28/24.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameBorder = GameBorder()
    var player = Player()
    
    var lastTouch: CGPoint?
    var reverseDirection = false
    var aliens = Set<Alien>()
    var alienSpeed: Double = 64
    
    override required init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func explodeAlien() -> SKAction {
        var frames: [SKTexture] = []
        for i in 0...11 {
            let name = String(format: "alien_%02d", arguments: [i])
            frames.append(SKTexture(imageNamed: name))
        }
        
        return SKAction.animate(with: frames, timePerFrame: 1 / 24)
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        backgroundColor = .blue
        
        addChild(gameBorder)
        gameBorder.addChild(player)
        
        let margin = 24
        for xp in (0...10) {
            for yp in (0...4) {
                let alien = Alien()
                alien.position.x = CGFloat(margin + xp * 48)
                alien.position.y = CGFloat(432 - yp * 48)
                
                aliens.insert(alien)
                gameBorder.addChild(alien)
            }
        }
        
        let interval = SKAction.wait(forDuration: 0.5)
        let fire = SKAction.run {
            if let alien = self.aliens.randomElement() {
                let bullet = AlienBullet()
                bullet.position.x = alien.position.x + 16
                bullet.position.y = alien.position.y - 12
                
                self.gameBorder.addChild(bullet)
            }
        }
        
        let sequence = SKAction.sequence([interval, fire])
        gameBorder.run(SKAction.repeatForever(sequence))
    }
    
    override func update(_ currentTime: TimeInterval) {
        player.update(touching: lastTouch)
        
        if reverseDirection {
            // invert speed
            alienSpeed = -alienSpeed
            
            // turn off direction
            reverseDirection = false
        }
        
        for alien in aliens {
            alien.physicsBody?.velocity = CGVector(dx: alienSpeed, dy: 0)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let spriteA = contact.bodyA.node
        let spriteB = contact.bodyB.node
        
        if spriteA?.name == "bounds" {
            if spriteB?.name == "alien" {
                // if aliens touch the wall, change their direction
                reverseDirection = true
            }
            
            if spriteB?.name == "playerBullet" {
                spriteB?.removeFromParent()
            }
            
            if spriteB?.name == "alienBullet" {
                spriteB?.removeFromParent()
            }
        }
        
        if spriteA?.name == "playerBullet" {
            if spriteB?.name == "alien" {
                spriteA?.removeFromParent()
                
                spriteB?.physicsBody = nil
                spriteB?.run(explodeAlien()) {
                    spriteB?.removeFromParent()
                }
                self.aliens.remove(spriteB as! Alien)
            }
        }
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
        
        let bullet = PlayerBullet()
        bullet.position.x = player.position.x + 16
        bullet.position.y = player.position.y + 24
        gameBorder.addChild(bullet)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
    }
}
