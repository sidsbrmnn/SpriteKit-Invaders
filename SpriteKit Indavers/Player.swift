//
//  Player.swift
//  SpriteKit Indavers
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
