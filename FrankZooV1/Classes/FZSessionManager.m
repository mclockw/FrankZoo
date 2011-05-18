//
//  FZSessionManager.m
//  FrankZooV1
//
//  Created by wang chenzhong on 5/9/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZSessionManager.h"

#define SESSION_ID @"FrankZoo"


@implementation FZSessionManager
@synthesize type_;
@synthesize serverPeerList_;
@synthesize connectClientList_;

- (void)dealloc{
  [gkSession_ release];
  [peerList_ release];
  
  [super dealloc];
}

- (id)initWithType:(SessionType)type lobbyDelegate:(id)delegate{
  [super init];
  
  if (self) {
    type_ = type;
    
    if (type_ == Server) {
      gkSession_ = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeServer];
      gkSession_.available = YES;
      gkSession_.delegate = self;
      [gkSession_ setDataReceiveHandler:self withContext:nil];
      serverLobbyDelegate_ = delegate;
    }else if(type_ == Client){
      gkSession_ = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeClient];
      gkSession_.available = YES;
      gkSession_.delegate = self;
      [gkSession_ setDataReceiveHandler:self withContext:nil];

      clientLobbyDelegate_ = delegate;
    }else{
      assert(1);
    }
    
    peerList_ = [[NSMutableArray alloc] init];
    serverPeerList_ = [[NSMutableArray alloc] init]; 
    connectClientList_ = [[NSMutableArray alloc] init];
    currentPalyer_ = 1;
  }
  
  return self;
}

- (void)disconnectCurrentCall{
 // [gameDelegate willDisconnect:self];
  if (sessionState != ConnectionStateDisconnected) {
    // Don't leave a peer hangin'
    if (sessionState == ConnectionStateConnecting) {
      [gkSession_ cancelConnectToPeer:currentConfPeerID];
    }
    
    [gkSession_ disconnectFromAllPeers];
    gkSession_.available = YES;
  }

}

#pragma mark -------------------------------------------------------------------
#pragma mark GKSession Send Data
- (void) sendData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context{
  NSString *aStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSLog(@"%@", aStr);
}

- (void)forwardActionToAllClint:(NSData*)data{
   [gkSession_ sendData:data toPeers:connectClientList_
           withDataMode:GKSendDataReliable error:nil];
}


#pragma mark -------------------------------------------------------------------
#pragma mark GKSession Recieve Data Handle
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context{
  
  unsigned char *incomingPacket = (unsigned char *)[data bytes];

  FZPacketHeader packetHead = incomingPacket[0];

  switch (packetHead) {
    case FZPacketHeaderGameStart:{
      [clientLobbyDelegate_ startGameWithSessionManager:self];//client recieve
      break;
    }
    case FZPacketHeaderReady:
      //[self sendStartToAllClient];
      //[serverLobbyDelegate_ startGameWithSessionManager:self];//server send
      break;
    case FZPacketHeaderAction:
      [gameDelegate_ recieveRemotePlayerAction:data];
      break;
    case FZPacketHeaderPlayerIndex:{
      playerIndex_ = incomingPacket[1];
      [self sendReadyToServer:peer];
    }
    default:
      break;
  }

  
//  NSString *aStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//  NSLog(@"%@", aStr);
}


#pragma mark -------------------------------------------------------------------
#pragma mark GKSessionDelegate Methods
// Received an invitation.  If we aren't already connected to someone, open the invitation dialog.
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
 
  if (type_ == Client) {
    return;
  }
  
  //如果还有位置则链接，不然不予理睬
  if(currentPalyer_< 4){
    NSError *error = nil;
    if (![gkSession_ acceptConnectionFromPeer:peerID error:&error]) {
      NSLog(@"%@",[error localizedDescription]);
    }else{
      [connectClientList_ addObject:peerID];
      currentPalyer_++;
      NSLog(@"connect: %@:%@", peerID, [self displayNameForPeer:peerID]);
    }
    [serverLobbyDelegate_ recieveConnect:self];
    [self sendPlayerIndexToPeer: peerID withPlayerIndex: currentPalyer_];
  }
  else{
    [gkSession_ denyConnectionFromPeer:peerID];
  }
  
}
- (void)sendPlayerIndexToPeer:(NSString*)peerId withPlayerIndex:(int)playerIndex{
  unsigned char byte[4] = {0};
  byte[0] = FZPacketHeaderPlayerIndex;
  byte[1] = playerIndex;
  
  NSData *packet = [NSData dataWithBytes: byte length: 4];
  [gkSession_ sendData:packet toPeers:[NSArray arrayWithObject:peerId] 
          withDataMode:GKSendDataReliable error:nil];
  
  
}
// Unable to connect to a session with the peer, due to rejection or exiting the app
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
  if ([connectClientList_ containsObject: peerID]) {
    [connectClientList_ removeObject:peerID];
  }
       
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
      if (![serverPeerList_ containsObject:peerID]) {
				[serverPeerList_ addObject:peerID]; 
			}
      [clientLobbyDelegate_ serverListDidChange:self];
			break;
		case GKPeerStateUnavailable:
      [serverPeerList_ removeObject:peerID]; 
      [clientLobbyDelegate_ serverListDidChange:self]; 
			break;
		case GKPeerStateConnected:
      // Connection was accepted
      // 显示用户信息， 准备开始游戏
			break;				
		case GKPeerStateDisconnected:
      // The call ended either manually or due to failure somewhere.
//      if (Ingame) {
//    
//      }
      [self disconnectCurrentCall];
      [serverPeerList_ removeObject:peerID]; 
      [clientLobbyDelegate_ serverListDidChange:self];
      break;
    case GKPeerStateConnecting:
      // Peer is attempting to connect to the session.
      break;
		default:
			break;
	}
}

- (NSString *) displayNameForPeer:(NSString *)peerID
{
	return [gkSession_ displayNameForPeer:peerID];
}

// Initiates a GKSession connection to a selected peer.
-(void) connect:(NSString *) peerID
{
	[gkSession_ connectToPeer:peerID withTimeout:10.0];
  currentConfPeerID = [peerID retain];
  sessionState = ConnectionStateConnecting;
}

-(void)sendReadyToServer: (NSString *) serverPeerID{
  unsigned char byte[4] = {0};
  byte[0] = FZPacketHeaderReady;
  
  NSData *packet = [NSData dataWithBytes: byte length: 4];
  [gkSession_ sendData:packet toPeers:[NSArray arrayWithObject:serverPeerID] 
          withDataMode:GKSendDataReliable error:nil];

}

- (void)sendToServer:(NSData*)data{
  [gkSession_ sendData:data toPeers:serverPeerList_ 
          withDataMode:GKSendDataReliable error:nil];
}

- (void)sendStartToAllClient{
  unsigned char byte = {0};
  byte = FZPacketHeaderGameStart;
  
  NSData *packet = [NSData dataWithBytes: &byte length: 1];

  [gkSession_ sendData:packet toPeers:connectClientList_
            withDataMode:GKSendDataReliable error:nil];

}





@end
