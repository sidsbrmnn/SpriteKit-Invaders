//
//  Alien.swift
//  SpriteKit Indavers
//
//  Created by Siddharth Subramanian on 3/28/24.
//

import SpriteKit

class Alien: SKSpriteNode {
    
    required override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.size.width = 32
        self.size.height = 32
        
        name = "alien"
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width)
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.collisionBitMask = 0
    }
    
    convenience init() {
        let theTexture = SKTexture(imageNamed: "alien")
        theTexture.filteringMode = .nearest
        
        self.init(texture: theTexture, color: .white, size: theTexture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
