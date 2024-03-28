//
//  Player.swift
//  Invaders
//
//  Created by Siddharth Subramanian on 3/28/24.
//

import SpriteKit

class Player: SKShapeNode {
    
    required override init() {
        super.init()
        
        let thePath = CGMutablePath()
        thePath.move(to: CGPoint(x: 0, y: 0))
        thePath.addLine(to: CGPoint(x: 32, y: 0))
        thePath.addLine(to: CGPoint(x: 16, y: 32))
        thePath.closeSubpath()
        
        path = thePath
        strokeColor = .white
        lineWidth = 4
        position = CGPoint(x: 304, y: 4)
        name = "player"
        
        setupPhysics()
    }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(polygonFrom: path!)
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 2
        
        physicsBody?.categoryBitMask = Sprite.player.rawValue
        physicsBody?.collisionBitMask = Sprite.wall.rawValue
        physicsBody?.contactTestBitMask = Sprite.alienBullet.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(touching touch: CGPoint?) {
        guard let touch = touch else { return }
        
        var speed = touch.x - position.x
//        if speed < -16 {
//            speed = -16
//        } else if speed > 16 {
//            speed = 16
//        }
        speed = min(max(speed, -16), 16)
        
        physicsBody?.velocity = CGVector(dx: speed * 24, dy: 0)
    }
}
