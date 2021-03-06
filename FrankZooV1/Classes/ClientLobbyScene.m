//
//  ClientLobbyScene.m
//  FrankZooV1
//
//  Created by wang chenzhong on 5/6/11.
//  Copyright 2011 company. All rights reserved.
//

#import "ClientLobbyScene.h"
#import "CCUIViewWrapper.h"
#import "FZGameConfig.h"
#import "GamePlayingSceneIpad.h"

#define SESSION_ID @"FrankZoo"

@implementation ClientLobbyScene
-(id)init{
  self = [super init];
  
  if (self) {
    [self addChild:[ClientLobbyLayer node]];
  }
  
  return self;
}
@end


@implementation ClientLobbyLayer
- (id)init{
  [super init];
  if (self) {
    
    menuItem_ = [CCLabelTTF labelWithString:@"Connect" fontName:@"Marker Felt" fontSize:25];
    CCMenuItem *m = [CCMenuItemLabel itemWithLabel:menuItem_ 
                                                  target:self 
                                                selector:@selector(clickMenuConnect:)];
		 menu_ = [CCMenu menuWithItems:m, nil];
    [menu_ alignItemsVertically];
    [self addChild:menu_];
    
    tableView_ = [[[UITableView alloc] init] autorelease];
    tableView_.dataSource = self;
    CCUIViewWrapper *wrapper = [CCUIViewWrapper wrapperForUIView:tableView_];
    wrapper.contentSize = CGSizeMake(300, 400);
    wrapper.rotation = 90;
    /* table view 并不知道屏幕横过来的消息， 它是以竖屏幕，左下角为ccp(0,0) */
    /* 同时，它的AncherPoint又是以屏幕中心来转的，所以位置比较难调  */
    wrapper.position = ccp(50, 800);
    [self addChild:wrapper];
    
    sessionManager_ = [[FZSessionManager alloc] initWithType:Client lobbyDelegate:self];
    
  }
  
  return self;
}


- (void)clickMenuConnect:(id) sender{
  
  [sessionManager_ connect:serverPeerId_];
  
}


- (void)serverListDidChange:(FZSessionManager *)session{
  for (NSString *peerId in session.serverPeerList_) {
    NSLog(@"%@: %@", peerId, [session displayNameForPeer:peerId]);
  }
  
  if ([session.serverPeerList_ count] > 0 ) {
    serverPeerId_ = [session.serverPeerList_ objectAtIndex:0];  
  }
  
  [tableView_ reloadData];
}

- (void)startGameWithSessionManager:(FZSessionManager*)session{
  FZGameConfig *config = [[FZGameConfig alloc] init];
  config.gameMode_ = FZGameModeMultiPlayerClient;
  config.sm_ = [sessionManager_ retain];
  
  config.localPlayerIndex_ = 2;
  
  FZPlayer* player0 = [[FZPlayer alloc] init];
  player0.playerControlType_ = FZPlayer_ControlType_RemotPlayer;
  player0.peerId_ = serverPeerId_;
  [config.players_ addObject:player0];
  
  FZPlayer* player1 = [[FZPlayer alloc] init];
  player1.playerControlType_ = FZPlayer_ControlType_RemotPlayer;
  player1.peerId_ = serverPeerId_;
  [config.players_ addObject:player1];
  
  FZPlayer* localPlayer = [[FZPlayer alloc] init];
  localPlayer.playerControlType_ = FZPlayer_ControlType_LocalPlayer;

  [config.players_ addObject:localPlayer];
  
  FZPlayer* player3 = [[FZPlayer alloc] init];
  player3.playerControlType_ = FZPlayer_ControlType_RemotPlayer;
  player3.peerId_ = serverPeerId_;
  [config.players_ addObject:player3];
  
  GamePlayingSceneIpad *scene = [[GamePlayingSceneIpad alloc] initWithGameConfig: config]; 
  [[CCDirector sharedDirector]replaceScene:scene];
  [scene release];
  [config release];
  
}


#pragma mark -------------------------------------------------------------------
#pragma mark Table View Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return [sessionManager_.serverPeerList_ count];
}

- (void)recieveConnect:(FZSessionManager*)session{
  [tableView_ reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *kSourceCellID = @"SourceCellID";
  
  UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:kSourceCellID];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCellID] autorelease];
  }
  
  cell.textLabel.text = [sessionManager_ displayNameForPeer:
                         
                         [sessionManager_.serverPeerList_ objectAtIndex:indexPath.row]];
  
  return cell;
  
}



//#pragma mark -
//#pragma mark GKSession Recieve Data Handle
//- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context{
//  
//  
//}
//
//#pragma mark -
//#pragma mark GKSessionDelegate Methods
//// Received an invitation.  If we aren't already connected to someone, open the invitation dialog.
//- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
//{
//  //如果还有位置则链接，不然不予理睬
////  if(1){
////    NSError *error = nil;
////    if (![session_ acceptConnectionFromPeer:peerID error:&error]) {
////      NSLog(@"%@",[error localizedDescription]);
////    }
////  }
////  else{
////    [session_ denyConnectionFromPeer:peerID];
////  }
////  
//}
//
//// Unable to connect to a session with the peer, due to rejection or exiting the app
//- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
//{
//  NSLog(@"%@",[error localizedDescription]);
//}
//
//// The running session ended, potentially due to network failure.
//- (void)session:(GKSession *)session didFailWithError:(NSError*)error
//{
//  NSLog(@"%@",[error localizedDescription]);
//  
//}
//
//// React to some activity from other peers on the network.
//- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
//{
//	switch (state) { 
//		case GKPeerStateAvailable:
//      // A peer became available by starting app, exiting settings, or ending a call.
//      NSLog(@"%@: %@", peerID, [gkSession_ displayNameForPeer:peerID]);
//      serverPeerId_ = [peerID retain];
//      
//			break;
//		case GKPeerStateUnavailable:
//			break;
//		case GKPeerStateConnected:
//      // Connection was accepted
//      // 显示用户信息， 准备开始游戏
//			break;				
//		case GKPeerStateDisconnected:
//      // The call ended either manually or due to failure somewhere.
//      break;
//    case GKPeerStateConnecting:
//      // Peer is attempting to connect to the session.
//      break;
//		default:
//			break;
//	}
//}



@end