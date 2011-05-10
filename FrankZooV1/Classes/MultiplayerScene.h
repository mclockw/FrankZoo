//
//  MultiplayerScene.h
//  FrankZooV1
//
//  Created by wang chenzhong on 5/3/11.
//  Copyright 2011 company. All rights reserved.
//

#import "cocos2d.h"


@interface MultiplayerScene : CCScene {

}
@end

@interface MultiplayerLayer : CCLayer {
    CCMenu *menu_;
}


- (void)clickMenuServer:(id) sender;
- (void)clickMenuClient:(id) sender;

@end
