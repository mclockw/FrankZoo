//
//  ServerLobby.m
//  FrankZooV1
//
//  Created by wang chenzhong on 5/5/11.
//  Copyright 2011 company. All rights reserved.
//

#import "ServerLobbyScene.h"
#import "FZGameConfig.h"
#import "GamePlayingSceneIpad.h"

@implementation ServerLobbyScene
-(id)init{
  self = [super init];
  
  if (self) {
    [self addChild:[ServerLobbyLayer node]];
  }
  
  return self;
}

@end


@implementation ServerLobbyLayer
- (void)dealloc{
  [serverSession_ release];
   
  [super dealloc];
}

- (id)init{
  [super init];
  if (self) {
    
    CCLabelTTF *lable = [CCLabelTTF labelWithString:@"start Game" fontName:@"Marker Felt" fontSize:25];
    CCMenuItem *m = [CCMenuItemLabel itemWithLabel:lable 
                                            target:self 
                                          selector:@selector(clickMenuStartGame:)];
		CCMenu *menu_ = [CCMenu menuWithItems:m, nil];
    [menu_ alignItemsVertically];
    
    [self addChild:menu_];
    
    serverSession_ = [[FZSessionManager alloc] initWithType:Server lobbyDelegate:self];
  }

  return self;
}


- (void)clickMenuStartGame:(id) sender{
  [serverSession_ sendStartToAllClient];
  
  FZGameConfig *config = [[FZGameConfig alloc] init];
  config.gameMode_ = FZGameModeMultiPlayerServer;

  config.localPlayerIndex_ = 0;
  
  FZPlayer* localPlayer = [[FZPlayer alloc] init];
  localPlayer.playerControlType_ = FZPlayer_ControlType_LocalPlayer;
  [config.players_ addObject:localPlayer];

  FZPlayer* ai1 = [[FZPlayer alloc] init];
  ai1.playerControlType_ = FZPlayer_ControlType_AI;
  [config.players_ addObject:ai1];
  
  FZPlayer* remotePlayer = [[FZPlayer alloc] init];
  remotePlayer.playerControlType_ = FZPlayer_ControlType_RemotPlayer;
  remotePlayer.peerId_ = [serverSession_.connectClientList_ objectAtIndex:0];
  [config.players_ addObject:remotePlayer];
  
  FZPlayer* ai2 = [[FZPlayer alloc] init];
  ai2.playerControlType_ = FZPlayer_ControlType_AI;
  [config.players_ addObject:remotePlayer];
  
  
  
  GamePlayingSceneIpad *scene = [[GamePlayingSceneIpad alloc] initWithGameConfig: config]; 
  [[CCDirector sharedDirector]replaceScene:scene];
  [scene release];
  
}


@end
