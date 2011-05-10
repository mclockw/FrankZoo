//
//  MultiplayerScene.m
//  FrankZooV1
//
//  Created by wang chenzhong on 5/3/11.
//  Copyright 2011 company. All rights reserved.
//

#import "MultiplayerScene.h"
#import "ServerLobbyScene.h"
#import "ClientLobbyScene.h"

@implementation MultiplayerScene
-(id)init{
  self = [super init];
  
  if (self) {
    [self addChild:[MultiplayerLayer node]];
  }
  
  return self;
}
@end


@implementation MultiplayerLayer
- (id)init{
  [super init];
  if (self) {
    [CCMenuItemFont setFontSize:25];
    [CCMenuItemFont setFontName:@"Marker Felt"];
		
    CCMenuItem *server = [CCMenuItemFont itemFromString:@"Server"
                                                       target:self
                                                     selector:@selector(clickMenuServer:)];
		
		CCMenuItem *client = [CCMenuItemFont itemFromString:@"Client"
                                                       target:self
                                                     selector:@selector(clickMenuClient:)];

    
		menu_ = [CCMenu menuWithItems:server, 
             //[MainMenuLayer getSpacerItem], 
             client, 
             //[MainMenuLayer getSpacerItem], 
             nil];
    
    [menu_ alignItemsVertically];
    
    [self addChild:menu_];

    
  }

  return self;
}
- (void)clickMenuServer:(id) sender{
  [[CCDirector sharedDirector]replaceScene:[ServerLobbyScene node]];
}

- (void)clickMenuClient:(id) sender{
  [[CCDirector sharedDirector]replaceScene:[ClientLobbyScene node]];
}


@end