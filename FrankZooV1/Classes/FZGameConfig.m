//
//  FZGameConfig.m
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/7/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZGameConfig.h"


@implementation FZGameConfig

@synthesize gameMode_;
@synthesize players_;
@synthesize localPlayerIndex_;
@synthesize sm_;

- (void)dealloc{
  [players_ release];
  [super dealloc];
}

- (id)init{
  [super init];
  
  if (self) {
    players_ = [[NSMutableArray alloc] init];
  }

  return self;
}


@end
