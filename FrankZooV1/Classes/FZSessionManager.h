//
//  FZSessionManager.h
//  FrankZooV1
//
//  Created by wang chenzhong on 5/9/11.
//  Copyright 2011 company. All rights reserved.
//

#import <GameKit/GameKit.h>

@class  FZSessionManager;

typedef enum {
  Server,
  Client
}SessionType ;
  
typedef enum{
  FZPacketHeaderGameStart,  //server => client follow by PlayerIndex, 
  FZPacketHeaderReady,      //client => server
  FZPacketHeaderPlayerIndex,
  FZPacketHeaderAction,
  FZPacketHeaderRoundStartNewGame,
  FZPacketHeaderRoundStartInfo
}FZPacketHeader;

typedef enum {
  ConnectionStateDisconnected,
  ConnectionStateConnecting,
  ConnectionStateConnected
} ConnectionState;

@protocol ClientLobbyDelegate
- (void)startGameWithSessionManager:(FZSessionManager*)session;
- (void)serverListDidChange:(FZSessionManager *)session;
@end

@protocol ServerLobbyDelegate
- (void)recieveConnect:(FZSessionManager*)session;
@end

@protocol GameDelegate
- (void)recieveRemotePlayerAction:(NSData*)data;
@end

@interface FZSessionManager : NSObject <GKSessionDelegate> {
  SessionType type_;
  GKSession *gkSession_;
  
  NSMutableArray *peerList_;
  int currentPalyer_;
  
  id<ClientLobbyDelegate> clientLobbyDelegate_;
  id<ServerLobbyDelegate> serverLobbyDelegate_;
  
  id<GameDelegate> gameDelegate_;
  
  int playerIndex_;

  NSMutableArray *serverPeerList_;
  NSMutableArray *connectClientList_;
  
  ConnectionState sessionState;

  NSString * currentConfPeerID;
}


@property (nonatomic) SessionType type_;
@property (nonatomic, retain) NSMutableArray *serverPeerList_;
@property (nonatomic, retain) NSMutableArray *connectClientList_;

- (id)initWithType:(SessionType)type lobbyDelegate:(id)delegate;
- (void)connect:(NSString *)peerID;
- (NSString *) displayNameForPeer:(NSString *)peerID;
- (void)sendPlayerIndexToPeer:(NSString*)peerId withPlayerIndex:(int)playerIndex;

- (void)sendReadyToServer: (NSString *) serverPeerID;
- (void)sendStartToAllClient;
- (void)sendToServer:(NSData*)data;

- (void)forwardActionToAllClint:(NSData*)data;

@end



