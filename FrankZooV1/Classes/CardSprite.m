//
//  CardSprite.m
//  FrankZoo
//
//  Created by wang chenzhong on 4/21/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "CardSprite.h"


@implementation CardSprite 
@synthesize pickFlag;

- (void)dealloc{
  
  [super dealloc];
}
- (id)init{
  if ([super init]) {
    pickFlag = 0;
  }
  return self;
}
-(id) initWithFile:(NSString*)filename{
  if ([super initWithFile:filename]) {
    pickFlag = 0;
  }
  
  return self;
}


@end
