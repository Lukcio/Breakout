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
    var colorArray = [UIColor.red, UIColor.yellow, UIColor.green, UIColor.purple]
    var bricksArray = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createBackground()
        makeBall()
        makePaddle()
        createBlocks()
        makeLoseZone()
        addScoreLabel(score: score)
        addResetLabel(alpha: 0.0)
        //////////////
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20)) //dx - x magnitude, dy - y magnitude
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
        paddle = SKSpriteNode(color: .white, size: CGSize(width: frame.width/*/4*/, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)//middle of screen on bottom
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBrick(x: Int, y: Int, color: UIColor, name: String) {
        brick = SKSpriteNode(color: color, size: CGSize(width: 50, height: 20))
        brick.position = CGPoint(x: x, y: y) // top middle of screen
        brick.name = name
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
        //        brickX += 70
        //        if brickX > 250 {
        //            brickX = -290
        //            brickY -= 40
        //        }
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
        //for brick in bricksArray {
        if contact.bodyA.node?.name == "brick" ||
            contact.bodyB.node?.name == "brick" {
            for brick in bricksArray {
                
                var brickIndex = bricksArray.index(of: brick)
                
                if brick == contact.bodyA.node || brick == contact.bodyA.node {
                    
                    scoreLabel.text = "Score: \(score)"
                    
                    if brick.color == UIColor.purple {
                        brick.color = UIColor.green
                    } else if brick.color == UIColor.green {
                        brick.color = UIColor.yellow
                    } else if brick.color == UIColor.yellow {
                        brick.color = UIColor.red
                    } else {
                        score += 1
                        bricksArray[brickIndex!].removeFromParent()
                        bricksArray.remove(at: brickIndex!)
                        scoreLabel.text = "Score: \(score)"
                    }
                    
                    if score == 24 {
                        ball.removeFromParent()
                        addOutcomeLabel(outcome: "You Win!")
                        scoreLabel.text = "Score: \(score)"
                        resetLabel.alpha = 1.0
                        score = 0
                    }
                }
            }
        }
        if contact.bodyA.node?.name == "loseZone" ||
            contact.bodyB.node?.name == "loseZone" {
            resetLabel.alpha = 1.0
            bricksArray.removeAll()
            score = 0
            ball.removeFromParent()
            addOutcomeLabel(outcome: "You Lose!")
        }
    }
    
    func reset() {
        for child in self.children {
            child.removeFromParent()
        }
        resetLabel.alpha = 0.0
        outcomeLabel.alpha = 0.0
        addScoreLabel(score: score)
        createBackground()
        makeBall()
        makePaddle()
        createBlocks()
        makeLoseZone()
        removeFromParent()
        
        
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
        var brickX = Int(frame.minX + 45)
        var brickY = Int(frame.maxY - 30)
        var colorIndex = 0
        for i in 1...24 {
            makeBrick(x: Int(brickX), y: Int(brickY), color: colorArray[colorIndex], name: "brick")
            bricksArray.append(brick)
            brickX += 65
            if brickX >= Int(frame.maxX-30) {
                colorIndex += 1
                brickX = Int(frame.minX + 45)
                brickY -= 33
            }
        }
    }
}
