//
//  GameBorder.swift
//  Invaders
//
//  Created by Siddharth Subramanian on 3/28/24.
//

import SpriteKit

class GameBorder: SKShapeNode {
    
    required override init() {
        super.init()
        
        let thePath = CGMutablePath()
        let rect = CGRect(x: 0, y: 0, width: 640, height: 960)
        thePath.addRect(rect)
        
        path = thePath
        strokeColor = .white
        lineWidth = 4
        position = CGPoint(x: 0, y: 480)
        name = "bounds"
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: thePath)
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = Sprite.wall.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
