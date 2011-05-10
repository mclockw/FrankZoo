//
//  ServerLobby.h
//  FrankZooV1
//
//  Created by wang chenzhong on 5/5/11.
//  Copyright 2011 company. All rights reserved.
//

#import "cocos2d.h"
#import "FZSessionManager.h"
@interface ServerLobbyScene : CCScene {
    
}

@end


@interface ServerLobbyLayer : CCLayer {
  FZSessionManager *serverSession_;
  
}

- (void)clickMenuStartGame:(id) sender;
  
@end
