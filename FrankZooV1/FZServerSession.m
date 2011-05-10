//
//  FZServerSession.m
//  FrankZooV1
//
//  Created by wang chenzhong on 5/6/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZServerSession.h"

#define SESSION_ID @"FrankZoo"
@implementation FZServerSession


- (void) startServer
{
	session_ = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeServer];
  session_.available = YES;
  session_.delegate = self;
  NSLog(@"Server PeerId: %@", session_.peerID);
  [session_ setDataReceiveHandler:self withContext:nil]; //需要实现-receiveData:fromPeer:inSession:context:



}
#pragma mark -
#pragma mark GKSession Recieve Data Handle
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context{

    NSString *aStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSLog(@"%@", aStr);
}

#pragma mark -
#pragma mark GKSessionDelegate Methods
// Received an invitation.  If we aren't already connected to someone, open the invitation dialog.
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
  //如果还有位置则链接，不然不予理睬
  if(1){
    NSError *error = nil;
    NSLog(@"didReceiveConnectionRequestFromPeer: %@", peerID);
    if (![session_ acceptConnectionFromPeer:peerID error:&error]) {
      NSLog(@"%@",[error localizedDescription]);
    }
  }
  else{
    [session_ denyConnectionFromPeer:peerID];
  }
  
}

// Unable to connect to a session with the peer, due to rejection or exiting the app
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
  NSLog(@"%@",[error localizedDescription]);
}

// The running session ended, potentially due to network failure.
- (void)session:(GKSession *)session didFailWithError:(NSError*)error
{
  NSLog(@"%@",[error localizedDescription]);

}

// React to some activity from other peers on the network.
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	switch (state) { 
		case GKPeerStateAvailable:
			break;
		case GKPeerStateUnavailable:
			break;
		case GKPeerStateConnected:
      // Connection was accepted
      // 显示用户信息， 准备开始游戏
			break;				
		case GKPeerStateDisconnected:
      // The call ended either manually or due to failure somewhere.
      break;
    case GKPeerStateConnecting:
      // Peer is attempting to connect to the session.
      break;
		default:
			break;
	}
}


@end
