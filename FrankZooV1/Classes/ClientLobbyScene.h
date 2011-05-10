//
//  ClientLobbyScene.h
//  FrankZooV1
//
//  Created by wang chenzhong on 5/6/11.
//  Copyright 2011 company. All rights reserved.
//

#import "cocos2d.h"
#import "FZSessionManager.h"

@interface ClientLobbyScene : CCScene {
    
}

@end


@interface ClientLobbyLayer : CCLayer<GKSessionDelegate> {
  GKSession *gkSession_;
  
  //UITableView *tableView_;
  CCMenu *menu_;
  CCLabelTTF *menuItem_;
  
  NSString *serverPeerId_;
  
  
  FZSessionManager *sessionManager_;

  
}
- (void)clickMenuConnect:(id) sender;
@end
