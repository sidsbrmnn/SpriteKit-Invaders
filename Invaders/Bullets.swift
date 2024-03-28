//
//  Bullets.swift
//  Invaders
//
//  Created by Siddharth Subramanian on 3/28/24.
//

import SpriteKit

class Bullet: SKShapeNode {
    
    required override init() {
        super.init()
        
        let thePath = CGMutablePath()
        thePath.addRect(CGRect(x: 0, y: 0, width: 4, height: 16))
        thePath.closeSubpath()
        
        path = thePath
        strokeColor = .white
        lineWidth = 4.0
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 4, height: 16))
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.collisionBitMask = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayerBullet: Bullet {
    
    required init() {
        super.init()
        
        name = "playerBullet"
        
        physicsBody?.velocity = CGVector(dx: 0, dy: 384)
        physicsBody?.contactTestBitMask = Sprite.wall.rawValue | Sprite.enemy.rawValue
        physicsBody?.categoryBitMask = Sprite.playerBullet.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EnemyBullet: Bullet {
    
    required init() {
        super.init()
        
        name = "enemyBullet"
        
        physicsBody?.velocity = CGVector(dx: 0, dy: -384)
        physicsBody?.contactTestBitMask = Sprite.wall.rawValue
        physicsBody?.categoryBitMask = Sprite.enemyBullet.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
