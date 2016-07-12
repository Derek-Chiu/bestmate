//
//  GameScene.swift
//  bestmate
//
//  Created by Yu-Hsiang Lin on 7/12/16.
//  Copyright (c) 2016 jlvc. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case Init
    case Reveal
    case Play
    case Special
}

class GameScene: SKScene {
    
    var blocks:[CardNode]? = nil
    var btn:SKShapeNode? = nil
    var hiddenbtn:SKLabelNode? = nil
    var state = GameState.Init
    var score = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.whiteColor()
        initBlocks()
        btn = SKShapeNode(rectOfSize: CGSize(width: 100, height: 45))
        btn?.position = CGPoint(x: 600, y: 100)
        addChild(btn!)
        hiddenbtn = SKLabelNode(text: "Play")
        hiddenbtn?.fontColor = UIColor.blueColor()
        hiddenbtn?.position = CGPoint(x: 500, y:100)
        addChild(hiddenbtn!)
    }
    
    func initBlocks() {
        let cards = (1...12).map { return String($0) }
        let skeleton = ["X"]
        let names = cards + skeleton + cards
        let shuffledNames = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(names).map{ $0 as! String }
        blocks = shuffledNames.map {
            let node = CardNode()
            node.text = $0
            return node
        }
        let width:CGFloat = blocks![0].length + 5
        for (idx,b) in blocks!.enumerate() {
            let xIdx = (idx % 5) - 2
            let yIdx = 2 - (idx / 5)
            let x:CGFloat = CGRectGetMidX(self.frame) + width * CGFloat(xIdx)
            let y:CGFloat = CGRectGetMidY(self.frame) + width * CGFloat(yIdx)
            b.position = CGPoint(x: x, y: y)
            addChild(b)
        }
        toggledBlocks = []
    }
    
    func resetBlocks() {
        removeChildrenInArray(blocks!)
        initBlocks()
    }
    
    var toggledBlocks:[CardNode]? {
        didSet {
            if let ov = oldValue {
                for b in ov {
                    guard b.state != CardNodeState.Finished else { continue }
                    b.state = CardNodeState.Normal
                }
            }
            for b in toggledBlocks! {
                guard b.state != CardNodeState.Finished else { continue }
                b.state = CardNodeState.Selected
            }
        }
    }
    
    let specialScore = 2
    
    func blockTouched(touch: UITouch){
        guard state != .Init else { return }
        let location = touch.locationInNode(self)
        let idx = blocks?.indexOf{
            return $0.containsPoint(location)
        }
        guard let iidx = idx else { return }
        guard let block = blocks?[iidx] else { return }
        if state == .Special && score >= specialScore {
            for b in blocks! {
                guard b.state != CardNodeState.Finished else { continue }
                b.text = "❤️"
            }
        }
        if toggledBlocks!.count == 2 {
            toggledBlocks = [block]
            return
        } else if toggledBlocks!.count == 0{
            toggledBlocks = [block]
            return
        }
        let lastBlock = toggledBlocks![0]
        guard lastBlock != block else { return }
        toggledBlocks = [lastBlock,block]
        if lastBlock.text == block.text {
            lastBlock.state = CardNodeState.Finished
            block.state = CardNodeState.Finished
            score = score + 1
        }
        if state == .Special && score > specialScore {
            showHiddenText()
        }
    }
    
    func revealBlocks(){
        for b in blocks! {
            b.state = CardNodeState.Selected
        }
    }
    
    func hideBlocks() {
        for b in blocks! {
            b.state = CardNodeState.Normal
        }
    }
    
    func resetGame(initState:GameState){
        guard state != .Reveal else { return }
        state = .Reveal
        resetBlocks()
        score = 0
        let seq = SKAction.sequence([
            SKAction.runBlock{self.revealBlocks()},
            SKAction.waitForDuration(1),
            SKAction.runBlock{
                self.hideBlocks()
                self.state = initState
            },
            ])
        runAction(seq)
    }
    
    func btnTouched(touch:UITouch){
        let location = touch.locationInNode(self)
        guard btn!.containsPoint(location) else { return }
        resetGame(.Play)
    }
    
    func showHiddenText(){
        let text = "Stela"+"Will "+"you  "+"marry"+"me?❤️ "
        let actions:[SKAction] = blocks!.enumerate().map {
            let c = String(text[text.startIndex.advancedBy($0)])
            let action = $1.showTextAction(c)
            return action
        }
        let SequenceActions = SKAction.sequence(actions)
        runAction(SequenceActions)
    }
    
    func hiddenbtnTouched(touch:UITouch){
        let location = touch.locationInNode(self)
        guard hiddenbtn!.containsPoint(location) else { return }
        resetGame(.Special)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        blockTouched(touch)
        btnTouched(touch)
        hiddenbtnTouched(touch)
    }
    
}
