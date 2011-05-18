//
//  SingleGameOptionScene.h
//  FrankZoo
//
//  Created by wang chenzhong on 4/18/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "cocos2d.h"
#import "CCRadioMenu.h"

@interface SingleGameOptionScene : CCScene {
  
}

@end

@interface SingleGameOptionLayer : CCLayer {

@private
  CCSprite *background_;
  
  CCLabelTTF *usernameLable_;
  UITextField * textFieldCtl;
  
  CCLabelTTF *playerLable_;
  CCSprite *sliderBar_;
  CCSprite *slider_;
  CCLabelTTF *playerNumLable_;
  BOOL sliderMoveFlag_;
  
  CCLabelTTF *aiLable_;
  CCRadioMenu *aiMenu_;
  
  CCMenu *playMenu_;
  CCMenu *backMenu_;
  
  int mode_;
  int playerNum_;
  int aiLevle_;

}


- (void) arrangeUI;
@end
