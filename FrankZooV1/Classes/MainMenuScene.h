//
//  MainMenuScene.h
//  FrankZoo
//
//  Created by wang chenzhong on 4/18/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "cocos2d.h"

@interface MainMenuScene : CCScene {
    
}

@end

@interface MainMenuLayer : CCLayer {
@private
  CCMenu *menu_;
  CCSprite *background_;
}

- (void)clickMenuSingleGame:(id) sender;
- (void)clickMenuMultiPlayer:(id) sender;

- (void)clickOption:(id) sender;

+ (CCMenuItemFont *) getSpacerItem;

@end