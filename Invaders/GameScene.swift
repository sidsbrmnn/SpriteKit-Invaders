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
    
    var livesSprite = SKSpriteNode(imageNamed: "lives_3")
    var livesTextures: [SKTexture] = []
    var lives = 3
    
    var sounds = Sounds()
    let pitches: [Float] = [0.0, 100.0, 200.0, 300.0, 400.0, 500.0, 600.0]
    
    var lastTouch: CGPoint?
    var reverseDirection = false
    var aliens = Set<Alien>()
    var alienSpeed: Double = 64
    
    var gameOver = false
    
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
        lives -= 1
        updateLives()
        
        sounds.play("explode1", speed: gameOver ? 0.25 : 0.5)
        
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
        if !gameOver {
            player.run(SKAction.wait(forDuration: 1.5)) {
                self.player.alpha = 1
                self.player.setupPhysics()
            }
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
        gameOver = false
        
        // reset the game
        for alien in aliens {
            alien.removeFromParent()
        }
        aliens.removeAll()
        
        player.alpha = 1
        player.setupPhysics()
        
        alienSpeed = 64
        
        // spawn aliens
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
        
        // pop up start screen
        let sprite = SKSpriteNode(imageNamed: "start")
        sprite.texture?.filteringMode = .nearest
        sprite.position = CGPoint(x: 304, y: 204)
        sprite.setScale(2)
        
        let wait = SKAction.wait(forDuration: 0.05)
        let invisible = SKAction.run {
            sprite.alpha = 0
        }
        let visible = SKAction.run {
            sprite.alpha = 1
        }
        
        let sequence = SKAction.sequence([invisible, wait, visible, wait])
        let blink = SKAction.repeat(sequence, count: 4)
        
        sprite.run(blink) {
            sprite.removeFromParent()
        }
        
        gameBorder.addChild(sprite)
    }
    
    fileprivate func updateLives() {
        if lives == 0 {
            livesSprite.texture = nil
            endGame()
            return
        }
        
        livesSprite.texture = livesTextures[lives]
        livesSprite.texture?.filteringMode = .nearest
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        backgroundColor = .blue
        
        addChild(gameBorder)
        gameBorder.addChild(player)
        
        livesSprite.position = CGPoint(x: 64, y: 448)
        livesSprite.setScale(2)
        addChild(livesSprite)
        
        livesTextures.append(SKTexture(imageNamed: "alien_11"))
        livesTextures.append(SKTexture(imageNamed: "lives_1"))
        livesTextures.append(SKTexture(imageNamed: "lives_2"))
        livesTextures.append(SKTexture(imageNamed: "lives_3"))
        
        sounds.preload("shoot")
        sounds.preload("explode1")
        
        updateLives()
        
        startWave()
        
        let interval = SKAction.wait(forDuration: 0.5)
        let fire = SKAction.run {
            // fire only if game not over
            if !self.gameOver {
                if let alien = self.aliens.randomElement() {
                    let bullet = AlienBullet()
                    bullet.position.x = alien.position.x + 16
                    bullet.position.y = alien.position.y - 12
                    
                    self.gameBorder.addChild(bullet)
                    self.sounds.play("shoot", pitch: self.pitches.randomElement()!)
                }
            }
        }
        
        let sequence = SKAction.sequence([interval, fire])
        gameBorder.run(SKAction.repeatForever(sequence))
    }
    
    fileprivate func endGame() {
        gameOver = true
        
        if lives > 0 {
            explodePlayer()
        }
        
        let sprite = SKSpriteNode(imageNamed: "gameover")
        sprite.texture?.filteringMode = .nearest
        sprite.position = CGPoint(x: 304, y: 240)
        sprite.setScale(2)
        
        let wait = SKAction.wait(forDuration: 0.05)
        let sizeDown = SKAction.scale(to: 1.5, duration: 0.5)
        let sizeUp = SKAction.scale(to: 2.5, duration: 0.5)
        
        let sequence = SKAction.sequence([sizeDown, wait, sizeUp, wait])
        let blink = SKAction.repeat(sequence, count: 6)
        
        sprite.run(blink) {
            sprite.removeFromParent()
            self.lives = 3
            self.updateLives()
            self.startWave()
        }
        
        gameBorder.addChild(sprite)
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
            
            // lower its position
            for alien in aliens {
                alien.position.y -= 8
                
                if alien.position.y < player.position.y {
                    endGame()
                }
            }
        }
        
        for alien in aliens {
            if gameOver {
                if reverseDirection {
                    if alienSpeed < 0 {
                        alien.position.x -= 8
                    } else {
                        alien.position.x += 8
                    }
                }
            }
            
            // if gameOver, stop alien movement
            alien.physicsBody?.velocity = CGVector(dx: gameOver ? 0 : alienSpeed, dy: 0)
        }
        
        reverseDirection = false
        
        if aliens.isEmpty {
            startWave()
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
                self.sounds.play("explode1", pitch: pitches.randomElement()!)
                self.aliens.remove(spriteB as! Alien)
            }
        }
        
        if (spriteA?.name == "alienBullet" && spriteB?.name == "player") || (spriteA?.name == "player" && spriteB?.name == "alienBullet") {
            explodePlayer()
        }
        
        if (spriteA?.name == "alien" && spriteB?.name == "player") || (spriteA?.name == "player" && spriteB?.name == "alien") {
            endGame()
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
        sounds.play("shoot")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
    }
}
