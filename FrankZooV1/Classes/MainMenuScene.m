//
//  MainMenuScene.m
//  FrankZoo
//
//  Created by wang chenzhong on 4/18/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "MainMenuScene.h"
#import "GamePlayingSceneIpad.h"
#import "SingleGameOptionScene.h"
#import "AppConfig.h"
#import "MultiplayerScene.h"

extern ST_APPCONFIG g_stAppConfing;

@implementation MainMenuScene
-(id)init{
  self = [super init];
  
  if (self) {
    [self addChild:[MainMenuLayer node]];
  }
  
  return self;
}
@end


@implementation MainMenuLayer
- (void) dealloc
{
  [self removeChild:background_ cleanup:NO];
  [self removeChild:menu_ cleanup:NO];
	[background_ release];
	//[menu_ release];
	[super dealloc];
}

-(id) init
{
	self = [super init];
	
	if (self)
	{
    if (g_stAppConfing.iIsIPad) {
      background_= [[CCSprite alloc] initWithFile:@"menu_background_ipad.png"];
    }
    else {
      background_= [[CCSprite alloc] initWithFile:@"menu_background_iphone.png"];
    }
		background_.anchorPoint = ccp(0, 0);
		[self addChild:background_];
		
		[CCMenuItemFont setFontSize:25];
    [CCMenuItemFont setFontName:@"Marker Felt"];
		
    CCMenuItem *singlePlayer = [CCMenuItemFont itemFromString:@"Single Player"
                                                       target:self
                                                     selector:@selector(clickMenuSingleGame:)];
		
		CCMenuItem *multipPlyaer = [CCMenuItemFont itemFromString:@"Multiplayer"
                                                       target:self
                                                     selector:@selector(clickMenuMultiPlayer:)];
		
    
		CCMenuItem *option = [CCMenuItemFont itemFromString:@"Option"
                                                       target:self
                                                     selector:@selector(clickOption:)];

    
		CCMenuItem *about = [CCMenuItemFont itemFromString:@"About"
                                                target:self
                                              selector:nil];
		
		menu_ = [CCMenu menuWithItems:singlePlayer, 
             [MainMenuLayer getSpacerItem], 
             multipPlyaer, 
             [MainMenuLayer getSpacerItem], 
             option,
             [MainMenuLayer getSpacerItem], 
             about, 
             nil];
		
    [menu_ alignItemsVertically];

    [self addChild:menu_];
	}
	
	return self;
}

- (void)clickMenuSingleGame:(id) sender{
  FZGameConfig *config = [[FZGameConfig alloc] init];
  config.gameMode_ = FZGameModeSinglePlayer;
  config.localPlayerIndex_ = 0;
  
  FZPlayer* localPlayer = [[FZPlayer alloc] initWithControlType:FZPlayer_ControlType_LocalPlayer];
  [config.players_ addObject:localPlayer];
  [localPlayer release];
  
  NSString *name[3] = {@"Wesley", @"Penn", @"Jommy"};
  for (int i = 0; i < 3; i++) {
    FZPlayer* ai = [[FZPlayer alloc] initWithControlType:FZPlayer_ControlType_AI];
    [config.players_ addObject:ai];
    [ai release];
    ai.playerName_ = name[i];
  }

  GamePlayingSceneIpad *scene = [[GamePlayingSceneIpad alloc] initWithGameConfig:config];
  [[CCDirector sharedDirector]replaceScene:scene];
  [scene release];
  
  [config release];
}

- (void)clickMenuMultiPlayer:(id) sender{
  [[CCDirector sharedDirector]replaceScene:[MultiplayerScene node]];
}

- (void)clickOption:(id) sender{
  [[CCDirector sharedDirector]replaceScene:[SingleGameOptionLayer node]];
}


+ (CCMenuItemFont *) getSpacerItem
{
	[CCMenuItemFont setFontSize:2];
	return [CCMenuItemFont itemFromString:@" " target:self selector:nil];
}
@end
