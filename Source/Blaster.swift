//
//  Blaster.swift
//  AlientBlast
//
//  Created by Joey etamity on 29/03/2016.
//  Copyright © 2016 Innovation Apps. All rights reserved.
//

import Foundation

class Blaster: CCSprite {
    
    var bornRate :Int = 100;
    var hurtRate :Int = 0;
    var healthRate :Int = 1;
    var type: BlasterType! = nil;
    var subType: String! = "";
    func didLoadFromCCB(){
    
        self.userInteractionEnabled = false;
        self.physicsBody.collisionType = "shape";
        self.physicsBody.sensor = false
        self.physicsBody.collisionGroup = "blaster";
        self.physicsBody.affectedByGravity = true;
        self.type = BlasterType(rawValue: self.name)
    }
    
    func topUpAnimation(block:()->Void){
        self.physicsBody.affectedByGravity = false
        self.physicsBody.collisionType = ""
        let moveto = CCActionMoveBy.actionWithDuration(3, position: CGPointMake(-300, 300))
        let scaleToHeart = CCActionScaleTo.actionWithDuration(3, scale: 5)
        let fadeout = CCActionFadeTo.actionWithDuration(3, opacity: 0.0)
        let callback = CCActionCallBlock.actionWithBlock({
            block()
        })
        let spwan = CCActionSpawn.actionWithArray([moveto,scaleToHeart,fadeout])
        let sequene = CCActionSequence.actionWithArray([spwan,callback])
        self.runAction(sequene as! CCActionSequence)
    }

    func blast(){
        OALSimpleAudio.sharedInstance().playEffect(StaticData.getSoundFile(GameSoundType.BLAST.rawValue))

        var points: Int = StaticData.sharedInstance.points;
        points += 1 ;
        StaticData.sharedInstance.points = points
            
        if (self.type == BlasterType.Heart){
            var lives : Int = StaticData.sharedInstance.lives;
            lives -= self.hurtRate;
            StaticData.sharedInstance.lives = lives
            self.removeFromParentAndCleanup(true);
        }else
            if (self.type == BlasterType.Clock)
            {
                var touches : Int = StaticData.sharedInstance.touches;
                touches += 500;
                StaticData.sharedInstance.touches = touches
                self.removeFromParentAndCleanup(true);
                
            }
            else
            {
                var touches : Int = StaticData.sharedInstance.touches;
                touches += self.hurtRate;
                StaticData.sharedInstance.touches = touches
                if (self.parent != nil){
                    let pnode:CCParticleSystem = CCBReader.load(StaticData.getEffectFile(EffectType.BLAST.rawValue)) as! CCParticleSystem;
                    pnode.position = self.position;
                    pnode.autoRemoveOnFinish = true;
                    pnode.duration=0.5;
                    self.parent.addChild(pnode);
                }
                self.removeFromParentAndCleanup(true);
                
        }
    }
    
    override func update(delta: CCTime) {
        
        let rect : CGRect = CGRectMake(self.parent.position.x, self.parent.position.y,self.parent.contentSize.width, CCDirector.sharedDirector().viewSize().height + 200);
        
        let inRect : Bool = CGRectContainsPoint(rect,self.position);
        
        if (!inRect)
        {
            if (self.position.y < 0)
            {
                if (self.type != BlasterType.Heart){
                    var lives : Int = StaticData.sharedInstance.lives;
                    lives += self.hurtRate;
                    StaticData.sharedInstance.lives = lives
                    OALSimpleAudio.sharedInstance().playEffect(StaticData.getSoundFile(GameSoundType.HIT.rawValue))
                }
                if (self.parent != nil){
                    let pnode: CCParticleSystem = CCBReader.load(StaticData.getEffectFile(EffectType.HURT.rawValue)) as! CCParticleSystem;
                    pnode.position = self.position;
                    pnode.autoRemoveOnFinish = true;
                    pnode.duration = 0.5;
                    self.parent.addChild(pnode);
                }
            }
            self.removeFromParentAndCleanup(true);
            
        }
    }
}