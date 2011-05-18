//
//  ResultLayer.h
//  FrankZoo
//
//  Created by wang chenzhong on 4/11/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//


#import "cocos2d.h"

@protocol GameResultLayerDelegate <NSObject>
- (void) resultLayerOkButtonClick;
@end

@class FZGameLogic;
@interface ResultLayer : CCLayer {
  NSMutableArray * lableArray_;
  CCMenu *menu_;
  
  id delegate_;
}

@property(nonatomic,retain) id delegate_;

- (void)drawRoundResult:(FZGameLogic*)gamelogic;
- (void)drawGameResult:(FZGameLogic*)gamelogic;
- (void)showResult;
- (void)hideResult;

- (void)okButtonClick:(id)sender;
@end
