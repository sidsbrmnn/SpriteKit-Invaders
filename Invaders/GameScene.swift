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
    
    func explodePlayer() {
        if player.alpha == 0 { 
            return
        }
        
        player.alpha = 0
        
        var pieces: [SKSpriteNode] = []
        for i in 0...2 {
            let name = String(format: "player_piece_%d", arguments: [i])
            let piece = SKSpriteNode(imageNamed: name)
            
            piece.name = "piece"
            
            piece.position = self.player.position
            piece.position.x += CGFloat.random(in: -32...32)
            piece.position.y += CGFloat.random(in: 16...32)
            
            piece.physicsBody = SKPhysicsBody(texture: piece.texture!, size: piece.size)
            piece.physicsBody?.angularVelocity = CGFloat.random(in: -3.14...3.14)
            piece.physicsBody?.categoryBitMask = Sprite.player.rawValue
            piece.physicsBody?.collisionBitMask = Sprite.wall.rawValue
            piece.physicsBody?.restitution = 0.98
            piece.physicsBody?.velocity = player.physicsBody!.velocity
            
            gameBorder.addChild(piece)
            pieces.append(piece)
        }
        
        // after 1.5 seconds, the player will reappear and rejoin the physics simulation
        player.run(SKAction.wait(forDuration: 1.5)) {
            self.player.alpha = 1
            self.player.setupPhysics()
        }
        
        // default the player to intial position
        player.position = CGPoint(x: 304, y: 4)
        // take the player out of simulation
        player.physicsBody = nil
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        for piece in pieces {
            piece.run(fadeOut) {
                piece.removeFromParent()
            }
        }
    }
    
    fileprivate func startWave() {
        aliens.removeAll()
        
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
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        backgroundColor = .blue
        
        addChild(gameBorder)
        gameBorder.addChild(player)
        
        startWave()
        
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
        if player.alpha == 1 {
            player.update(touching: lastTouch)
        }
        
        if reverseDirection {
            // increase speed
            if alienSpeed < 0 {
                alienSpeed -= 8
            } else {
                alienSpeed += 8
            }
            
            alienSpeed = min(max(alienSpeed, -1024), 1024)
            
            // invert speed
            alienSpeed = -alienSpeed
            
            // turn off direction
            reverseDirection = false
            
            // lower its position
            for alien in aliens {
                alien.position.y -= 8
            }
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
        
        if spriteA?.name == "alienBullet" && spriteB?.name == "player" {
            explodePlayer()
        }
        if spriteA?.name == "player" && spriteB?.name == "alienBullet" {
            explodePlayer()
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
        
        if player.alpha == 0 {
            return
        }
        
        let bullet = PlayerBullet()
        bullet.position.x = player.position.x + 16
        bullet.position.y = player.position.y + 24
        gameBorder.addChild(bullet)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
    }
}
