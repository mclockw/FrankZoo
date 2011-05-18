//
//  GameMenuLayer.m
//  FrankZoo
//
//  Created by wang chenzhong on 4/12/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "GameMenuLayer.h"
//#import "MenuLayer.h"

@implementation GameMenuLayer
@synthesize delegate_;

- (void)dealloc{
  if (menu_) {
    [menu_ release];
  }
  
  [super dealloc];
}

- (id)init{
  if ([super init]) {
    CGSize s;
    s.width = 800; s.height = 600;
    [self setContentSize:s];
    
    //BG
    CCSprite * bg = [[CCSprite alloc] initWithFile:@"ResultLayerBg.png"];    
    [self addChild:bg];
    
    //Title
    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Game Menu" 
                                     fontName:@"Arial" 
                                     fontSize:52];
    [title setColor:ccBLACK];
    title.position = ccp(0, 250);
    [self addChild:title];
    
    //menu
    [CCMenuItemFont setFontSize:25];
    [CCMenuItemFont setFontName:@"Marker Felt"];
		
    CCMenuItem *resume = [CCMenuItemFont itemFromString:@"Resume"
                                                       target:self
                                                     selector:@selector(resumeButtonClick:)];
		
		CCMenuItem *newGame = [CCMenuItemFont itemFromString:@"New Game"
                                                       target:self
                                                selector:@selector(startNewGameButtonClick:)];
		
		CCMenuItem *quit = [CCMenuItemFont itemFromString:@"quit"
                                                target:self
                                             selector:@selector(quitButtonClick:)];
		
		menu_ = [CCMenu menuWithItems:resume, 
             [GameMenuLayer getSpacerItem], 
             newGame, 
             [GameMenuLayer getSpacerItem], 
             quit, 
             nil];
		
    [menu_ alignItemsVertically];
    menu_.position = ccp(0,50);
    [self addChild:menu_];
  
  }
  
  return self;
}


- (void)resumeButtonClick:(id)sender{
	if ([delegate_ respondsToSelector:@selector(GameMenuLayerResumeButtonClick)]) 
	{
		[delegate_ GameMenuLayerResumeButtonClick];
	}
}

- (void)startNewGameButtonClick:(id)sender{
	if ([delegate_ respondsToSelector:@selector(GameMenuLayerStartNewGameButtonClick)]) 
	{
		[delegate_ GameMenuLayerStartNewGameButtonClick];
	}
}

- (void)quitButtonClick:(id)sender{
	if ([delegate_ respondsToSelector:@selector(GameMenuQuitButtonClick)]) 
	{
		[delegate_ GameMenuQuitButtonClick];
	}
}

+ (CCMenuItemFont *) getSpacerItem
{
	[CCMenuItemFont setFontSize:2];
	return [CCMenuItemFont itemFromString:@" " target:self selector:nil];
}
@end
