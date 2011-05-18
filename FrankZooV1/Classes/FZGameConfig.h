//
//  FZGameConfig.h
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/7/11.
//  Copyright 2011 company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZPlayer.h"
#import "FZSessionManager.h"

typedef enum {
  FZGameModeSinglePlayer,
  FZGameModeMultiPlayerServer,
  FZGameModeMultiPlayerClient
}FZGameMode;

@interface FZGameConfig : NSObject {
  FZGameMode gameMode_;
    
  NSMutableArray *players_;
  int localPlayerIndex_;  
  
  FZSessionManager *sm_;

}

@property(nonatomic) FZGameMode gameMode_;
@property(nonatomic, retain) NSMutableArray *players_;
@property(nonatomic) int localPlayerIndex_;
@property(nonatomic, retain) FZSessionManager *sm_;



@end
