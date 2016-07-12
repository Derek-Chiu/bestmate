//
//  GameScene.swift
//  bestmate
//
//  Created by Yu-Hsiang Lin on 7/12/16.
//  Copyright (c) 2016 jlvc. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var blocks:[CardNode]? = nil
    var btn:SKLabelNode? = nil
    var hiddenbtn:SKLabelNode? = nil
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.whiteColor()
        initBlocks()
        btn = SKLabelNode(text: "run")
        btn?.fontColor = UIColor.blueColor()
        btn?.position = view.center
        addChild(btn!)
        hiddenbtn = SKLabelNode(text: "hidden run")
        hiddenbtn?.fontColor = UIColor.blueColor()
        hiddenbtn?.position = CGPoint(x: view.center.x, y: view.center.y - 600)
        addChild(hiddenbtn!)
    }
    
    func initBlocks() {
        let cards = (1...12).map { return String($0) }
        let names = cards + cards
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
    
    func blockTouched(touch: UITouch){
        let location = touch.locationInNode(self)
        let idx = blocks?.indexOf{
            return $0.containsPoint(location)
        }
        guard let iidx = idx else { return }
        guard let block = blocks?[iidx] else { return }
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
        }
    }
    
    func btnTouched(touch:UITouch){
        let location = touch.locationInNode(self)
        guard btn!.containsPoint(location) else { return }
        resetBlocks()
    }
    
    func hiddenbtnTouched(touch:UITouch){
        let location = touch.locationInNode(self)
        guard hiddenbtn!.containsPoint(location) else { return }
        let text = "Stela"+"Will "+"you  "+"marry"+"me?❤️ "
        let actions:[SKAction] = blocks!.enumerate().map {
            let c = String(text[text.startIndex.advancedBy($0)])
            let action = $1.showTextAction(c)
            return action
        }
        let SequenceActions = SKAction.sequence(actions)
        runAction(SequenceActions)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        blockTouched(touch)
        btnTouched(touch)
        hiddenbtnTouched(touch)
    }
    
}
