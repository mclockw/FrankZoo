//
//  FZServerSession.h
//  FrankZooV1
//
//  Created by wang chenzhong on 5/6/11.
//  Copyright 2011 company. All rights reserved.
//

#import <GameKit/GameKit.h> 

@interface FZServerSession : NSObject<GKSessionDelegate> {
  GKSession *session_;
    
}


- (void) startServer;
@end
