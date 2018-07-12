//
//  GameScene.swift
//  Breakout
//
//  Created by Lucas Leschynski on 7/12/18.
//  Copyright © 2018 Lucas Leschynski. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var brick = SKSpriteNode()
    var loseZone = SKSpriteNode()
    let scoreLabel = SKLabelNode()
    let outcomeLabel = SKLabelNode()
    let resetLabel = SKLabelNode()
    
    var outcome = String()
    var score = 0
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createBackground()
        makeBall()
        makePaddle()
        makeBrick()
        makeLoseZone()
        addScoreLabel(score: 0)
        addResetLabel(alpha: 0.0)
        //////////////
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 5)) //dx - x magnitude, dy - y magnitude
    }
    
    func createBackground() {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY) //positions ball in middle of screen
        ball.strokeColor = .black //ball colors: black(outline) and yellow
        ball.fillColor = .yellow
        ball.name = "ball"
        
        // physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        // ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        // use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        // no loss of energy from friction
        ball.physicsBody?.friction = 0
        // gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        // bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        // does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball) // add ball object to the view
    }
    
    func makePaddle() {
        paddle = SKSpriteNode(color: .white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)//middle of screen on bottom
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBrick() {
        brick = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 20))
        brick.position = CGPoint(x: frame.midX, y: frame.maxY - 30) // top middle of screen
        brick.name = "brick"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
    }
    
    func makeLoseZone() {
        loseZone = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
        
        let touch:UITouch = touches.first!
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        if let name = touchedNode.name {
            if name == "resetLabel" {
                reset()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "brick" ||
            contact.bodyB.node?.name == "brick" {
            score += 1
            print(score)
            brick.removeFromParent()
            ball.removeFromParent()
            addOutcomeLabel(outcome: "You Win!")
            scoreLabel.text = "Score: \(score)"
            resetLabel.alpha = 1.0
            score = 0
        }
        if contact.bodyA.node?.name == "loseZone" ||
            contact.bodyB.node?.name == "loseZone" {
            print("You lose!")
            ball.removeFromParent()
            addOutcomeLabel(outcome: "You Lose!")
        }
    }
    
    func reset() {
        for child in self.children {
                child.removeFromParent()
        }
        addResetLabel(alpha: 0.0)
        createBackground()
        makeBall()
        makePaddle()
        makeBrick()
        makeLoseZone()
        removeFromParent()
        addScoreLabel(score: 0)
        
        
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 5)) //dx - x magnitude, dy - y magnitude
    }
    
    func addScoreLabel(score: Int) {
        //scoreLabel = SKLabelNode()
        scoreLabel.text = "Score: \(score)"
        scoreLabel.name = "scoreLabel"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY + 15)
        
        addChild(scoreLabel)
    }
    func addOutcomeLabel(outcome: String) {
        let outcomeLabel = SKLabelNode()
        outcomeLabel.text = outcome
        outcomeLabel.fontSize = 30
        outcomeLabel.fontColor = .white
        outcomeLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(outcomeLabel)
    }
    
    func addResetLabel(alpha: CGFloat) {
        //scoreLabel = SKLabelNode()
        resetLabel.text = "Reset game"
        resetLabel.name = "resetLabel"
        resetLabel.fontSize = 30
        resetLabel.alpha = alpha
        resetLabel.fontColor = .white
        resetLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        
        addChild(resetLabel)
    }
    
    func createBlocks() {
        
    }
}
