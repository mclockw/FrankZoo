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
#import "CCUIViewWrapper.h"
#import "MultiplayerScene.h"

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
  [sessionManager_ release];
   
  [super dealloc];
}

- (id)init{
  [super init];
  if (self) {
    
    
    tableView_ = [[[UITableView alloc] init] autorelease];
    tableView_.dataSource = self;
    CCUIViewWrapper *wrapper = [CCUIViewWrapper wrapperForUIView:tableView_];
    wrapper.contentSize = CGSizeMake(300, 400);
    wrapper.rotation = 90;
    /* table view 并不知道屏幕横过来的消息， 它是以竖屏幕，左下角为ccp(0,0) */
    /* 同时，它的AncherPoint又是以屏幕中心来转的，所以位置比较难调  */
    wrapper.position = ccp(50, 800);
    [self addChild:wrapper];

    
    CCLabelTTF *lable = [CCLabelTTF labelWithString:@"start Game" fontName:@"Marker Felt" fontSize:25];
    CCMenuItem *m = [CCMenuItemLabel itemWithLabel:lable 
                                            target:self 
                                          selector:@selector(clickMenuStartGame:)];
    CCLabelTTF *backLable = [CCLabelTTF labelWithString:@"Back" fontName:@"Marker Felt" fontSize:25];
    CCMenuItem *back = [CCMenuItemLabel itemWithLabel:backLable 
                                            target:self 
                                          selector:@selector(clickMenuBack:)];
		CCMenu *menu_ = [CCMenu menuWithItems:m, back, nil];
    [menu_ alignItemsVertically];
    
    [self addChild:menu_];
    
       
//    UITableView *testView = [[[UITableView alloc] init] autorelease];
//    CCUIViewWrapper *wrapperTest = [CCUIViewWrapper wrapperForUIView:testView];
//    wrapperTest.contentSize = CGSizeMake(200, 200);
//    //    wrapper.anchorPoint = ccp(100, 100);
//    wrapperTest.position = ccp(200, 200);//TableView左下角 对 屏幕右下角的位置
//    [self addChild:wrapperTest];
    
//     cleanup
//    [self removeChild:wrapper cleanup:true];
//    wrapper = nil;

//    [wrapper runAction:[CCRotateTo actionWithDuration:.25f angle:180]];
//    wrapper.position = ccp(96,128);
//    wrapper.opacity = 127;
//    [wrapper runAction:[CCScaleBy actionWithDuration:.5f scale:.5f];
//     wrapper.visible = false;

    
    
    sessionManager_ = [[FZSessionManager alloc] initWithType:Server lobbyDelegate:self];
  }

  return self;
}

- (void)clickMenuStartGame:(id) sender{
  [sessionManager_ sendStartToAllClient];
  
  FZGameConfig *config = [[FZGameConfig alloc] init];
  config.gameMode_ = FZGameModeMultiPlayerServer;
  config.sm_ = [sessionManager_ retain];
  
  config.localPlayerIndex_ = 0;
  
  FZPlayer* localPlayer = [[FZPlayer alloc] init];
  localPlayer.playerControlType_ = FZPlayer_ControlType_LocalPlayer;
  [config.players_ addObject:localPlayer];

  FZPlayer* ai1 = [[FZPlayer alloc] init];
  ai1.playerControlType_ = FZPlayer_ControlType_AI;
  [config.players_ addObject:ai1];
  
  FZPlayer* remotePlayer = [[FZPlayer alloc] init];
  remotePlayer.playerControlType_ = FZPlayer_ControlType_RemotPlayer;
  remotePlayer.peerId_ = [sessionManager_.connectClientList_ objectAtIndex:0];
  [config.players_ addObject:remotePlayer];
  
  FZPlayer* ai2 = [[FZPlayer alloc] init];
  ai2.playerControlType_ = FZPlayer_ControlType_AI;
  [config.players_ addObject:remotePlayer];
  
  
  
  GamePlayingSceneIpad *scene = [[GamePlayingSceneIpad alloc] initWithGameConfig: config]; 
  [[CCDirector sharedDirector]replaceScene:scene];
  [scene release];
  [config release];
  
}

- (void)clickMenuBack:(id) sender{
  [[CCDirector sharedDirector]replaceScene:[MultiplayerScene node]];
}

#pragma mark -------------------------------------------------------------------
#pragma mark Table View Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return [sessionManager_.connectClientList_ count];
}

- (void)recieveConnect:(FZSessionManager*)session{
  [tableView_ reloadData];
}




// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *kSourceCellID = @"SourceCellID";
  
  UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:kSourceCellID];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCellID] autorelease];
    
  }
  
  cell.textLabel.text = [sessionManager_ displayNameForPeer: 
                         [sessionManager_.connectClientList_ objectAtIndex:indexPath.row]];

  return cell;

}

@end
