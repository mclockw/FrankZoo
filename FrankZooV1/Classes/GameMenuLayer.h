//
//  GameMenuLayer.h
//  FrankZoo
//
//  Created by wang chenzhong on 4/12/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "cocos2d.h"

@protocol GameMenuDelegate <NSObject>
- (void)GameMenuLayerResumeButtonClick;
- (void)GameMenuLayerStartNewGameButtonClick;
- (void)GameMenuQuitButtonClick;
@end

@interface GameMenuLayer : CCLayer {
  CCMenu *menu_;
  id<GameMenuDelegate> delegate_;
}

@property(nonatomic,retain) id<GameMenuDelegate>  delegate_;


- (void)resumeButtonClick:(id)sender;
- (void)startNewGameButtonClick:(id)sender;
- (void)quitButtonClick:(id)sender;
+ (CCMenuItemFont *) getSpacerItem;
@end



