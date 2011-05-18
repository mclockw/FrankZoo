//
//  SingleGameOptionScene.m
//  FrankZoo
//
//  Created by wang chenzhong on 4/18/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "SingleGameOptionScene.h"
#import "GamePlayingSceneIpad.h"
#import "AppConfig.h"
#import "MainMenuScene.h"
#import "CCUIViewWrapper.h"

extern ST_APPCONFIG g_stAppConfing; // Global Config


#define SLIDER_BAR_LENGTH 450
#define SLIDER_BAR_WIDTH  60

@implementation SingleGameOptionScene
- (id)init{
  if ([self init]) {
    [self addChild:[SingleGameOptionLayer node]]; 
  }
  
  return self;
}
@end

@interface SingleGameOptionLayer(Private)
- (void) arrangeUI;
@end

@implementation SingleGameOptionLayer
#pragma mark -
#pragma mark Life Cycle
- (void)dealloc{
  [textFieldCtl release];
  
  [super dealloc];
}

-(id) init
{
	self = [super init];
	
	if (self)
	{
    //background
    background_ = [CCSprite spriteWithFile:@"singleGameOptionBackgound.png"];
    background_.anchorPoint=ccp(0,0);
    [self addChild:background_];
    
    //user name
    usernameLable_ = [CCLabelTTF labelWithString:@"Mode: " fontName:@"Arial" fontSize:52];
    [usernameLable_ setColor:ccBLACK];
    [self addChild:usernameLable_];
    //输入框
    
    
    textFieldCtl=[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 25.0f)];
    [textFieldCtl addTarget:self action:@selector(textFieldAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    textFieldCtl.backgroundColor = [UIColor whiteColor];
    textFieldCtl.textColor=[UIColor blueColor];
    textFieldCtl.frame = CGRectMake(655, 300, 50, 400);

    CCUIViewWrapper *wrapper = [CCUIViewWrapper wrapperForUIView:textFieldCtl];
    wrapper.contentSize = CGSizeMake(50, 400);
    wrapper.position = ccp(750, 400);
    [wrapper setRotation:90];
    [self addChild:wrapper];
    
    
    //    textFieldCtl.transform = CGAffineTransformMakeRotation(M_PI * (90.0 / 180.0));

 //   textFieldCtl.
   // [[[[CCDirector sharedDirector] openGLView] window] addSubview: textFieldCtl];
    
    
    //Player Number
    playerLable_ = [CCLabelTTF labelWithString:@"Player Number: " fontName:@"Arial" fontSize:42];
    [playerLable_ setColor:ccBLACK];
    [self addChild:playerLable_];
    sliderBar_ = [CCSprite spriteWithFile:@"SliderBar.png"];
    [self addChild:sliderBar_];
    slider_ = [CCSprite spriteWithFile:@"Slider.png"];
    [self addChild:slider_];
    playerNumLable_ = [CCLabelTTF labelWithString:@"4" fontName:@"Arial" fontSize:42];
    [playerNumLable_ setColor:ccBLACK];
    [self addChild:playerNumLable_];
    sliderMoveFlag_ = NO;
    
    
    //AI Setup
    aiLable_ = [CCLabelTTF labelWithString:@"AI Level: " fontName:@"Arial" fontSize:52];
    [aiLable_ setColor:ccBLACK];
    [self addChild:aiLable_];
    CCMenuItem *menuItemEasy = [CCMenuItemImage itemFromNormalImage:@"btnEasy.png" 
                                                      selectedImage:@"btnEasySel.png" 
                                                             target:self 
                                                           selector:@selector(btnEasyTapped:)];
    CCMenuItem *menuItemNormal = [CCMenuItemImage itemFromNormalImage:@"btnNormal.png" 
                                                        selectedImage:@"btnNormalSel.png" 
                                                               target:self 
                                                             selector:@selector(btnNormalTapped:)];
    CCMenuItem *menuItemHard = [CCMenuItemImage itemFromNormalImage:@"btnHard.png" 
                                                      selectedImage:@"btnHardSel.png" 
                                                             target:self 
                                                           selector:@selector(btnHardTapped:)];
    aiMenu_ =  [CCRadioMenu menuWithItems:menuItemEasy, menuItemNormal, menuItemHard, nil];
    [aiMenu_ alignItemsHorizontally];
    [aiMenu_ setSelectedItem_:menuItemNormal];
    [menuItemNormal selected];
    aiLevle_ = AI_LEVEL_NORMAL;
    [self addChild:aiMenu_];
    
    //back and play
    CCMenuItem *back = [CCMenuItemImage itemFromNormalImage:@"btnBack.png" 
                                              selectedImage:@"btnBackSel.png" 
                                                     target:self 
                                                   selector:@selector(btnBackTapped:)];
    backMenu_ = [CCMenu menuWithItems:back, nil];
    [self addChild:backMenu_];
    
    CCMenuItem *play = [CCMenuItemImage itemFromNormalImage:@"btnPlay.png" 
                                              selectedImage:@"btnPlaySel.png" 
                                                     target:self 
                                                   selector:@selector(btnPlayTapped:)];
    playMenu_ = [CCMenu menuWithItems:play, nil];
    [self addChild:playMenu_];
    
    
    
    //arrange ui
    [self arrangeUI];
  }
  
	
	return self;
}

-(void)textFieldAction:(id)sender
{
  NSLog(@"textFieldAction");
}

#pragma mark -
#pragma mark UI Layout
- (void) arrangeUI{
  CGPoint point;
  //mode
  usernameLable_.position = ccp(150, 680);
  point = ccp(550, 400);
  
  

  
  //player number
  playerLable_.position = ccp(150, 500);
  sliderBar_.position = ccp(550, 500);
  point.x = sliderBar_.position.x - SLIDER_BAR_LENGTH / 2;
  point.y = 500;
  slider_.position = point;
  playerNumLable_.position = ccp(820, 500);
  
  //ai
  aiLable_.position = ccp(150, 320);
  aiMenu_.position = ccp(580, 320);
  
  //play and back
  playMenu_.position = ccp(850, 80);
  backMenu_.position = ccp(200, 80);
  
  
}



#pragma mark -
#pragma mark controller event
- (void)btnBasicTapped:(id)sender {
  mode_ = SINGLE_GAME_MODE_BASIC;
}
- (void)btnAdvanceTapped:(id)sender {
  mode_ = SINGLE_GAME_MODE_ADVANCE;
}

- (void)btnEasyTapped:(id)sender {
  aiLevle_ = AI_LEVEL_EASY;
}
- (void)btnNormalTapped:(id)sender {
  aiLevle_ = AI_LEVEL_NORMAL;
}
- (void)btnHardTapped:(id)sender {
  aiLevle_ = AI_LEVEL_HARD;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:[touch view]];
  point = [[CCDirector sharedDirector] convertToGL:point];
  
  if (sliderBar_.position.x - SLIDER_BAR_LENGTH/2 <= point.x 
      && point.x <= sliderBar_.position.x + SLIDER_BAR_LENGTH/2 
      && sliderBar_.position.y - SLIDER_BAR_WIDTH/2 <= point.y 
      && point.y <=sliderBar_.position.y + SLIDER_BAR_WIDTH/2 ) {
    CGPoint moveto;
    moveto.x = point.x;
    moveto.y = slider_.position.y;
    slider_.position = moveto;
    
    sliderMoveFlag_ = YES;
    
    int l = moveto.x - (sliderBar_.position.x - SLIDER_BAR_LENGTH / 2);
    playerNum_ = 4 + l * 3 / SLIDER_BAR_LENGTH  ;
    [playerNumLable_ setString:[NSString stringWithFormat:@"%d", playerNum_]];
  }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:[touch view]];
  point = [[CCDirector sharedDirector] convertToGL:point];
  
  if (sliderMoveFlag_) {
    if (point.x < sliderBar_.position.x - SLIDER_BAR_LENGTH/2) {
      point.x = sliderBar_.position.x - SLIDER_BAR_LENGTH/2;
    }else if (point.x > sliderBar_.position.x + SLIDER_BAR_LENGTH/2 ) {
      point.x = sliderBar_.position.x + SLIDER_BAR_LENGTH/2;
    }
    
    CGPoint moveto;
    moveto.x = point.x;
    moveto.y = slider_.position.y;
    slider_.position = moveto;
    
    int l = moveto.x - (sliderBar_.position.x - SLIDER_BAR_LENGTH / 2);
    playerNum_ = 4 + l * 3/ SLIDER_BAR_LENGTH  ;
    [playerNumLable_ setString:[NSString stringWithFormat:@"%d", playerNum_]];
  }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  sliderMoveFlag_ = NO;
}

#pragma mark -
#pragma mark delegate

- (void)btnBackTapped:(id)sender {
  [[CCDirector sharedDirector]replaceScene: [MainMenuScene node]];
}

- (void)btnPlayTapped:(id)sender {
  g_stAppConfing.iAiLevel = aiLevle_;
  g_stAppConfing.iSingleGameMode = mode_;
  g_stAppConfing.iPlayerNum = playerNum_;
  
  textFieldCtl.hidden = YES;
  [[CCDirector sharedDirector]pushScene: [GamePlayingSceneIpad node]];
  
}


@end
