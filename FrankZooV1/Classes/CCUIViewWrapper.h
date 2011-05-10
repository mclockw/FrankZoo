//
//  CCUIViewWrapper.h
//  FrankZooV1
//
//  Created by wang chenzhong on 5/7/11.
//  Copyright 2011 company. All rights reserved.
//

#import "cocos2d.h"

@interface CCUIViewWrapper : CCSprite
{
	UIView *uiItem;
	float rotation;
}

@property (nonatomic, retain) UIView *uiItem;

+ (id) wrapperForUIView:(UIView*)ui;
- (id) initForUIView:(UIView*)ui;

- (void) updateUIViewTransform;

@end

                    /*usage*/
//UIView *myView	= [[[UIView alloc] init] autorelease];
//CCUIViewWrapper *wrapper = [CCUIViewWrapper wrapperForUIView:myView];
//wrapper.contentSize = CGSizeMake(320, 160);
//wrapper.position = ccp(64,64);
//[self addChild:wrapper];
// cleanup
//[self removeChild:wrapper cleanup:true];
//wrapper = nil;
//
//[wrapper runAction:[CCRotateTo actionWithDuration:.25f angle:180]];
//wrapper.position = ccp(96,128);
//wrapper.opacity = 127;
//[wrapper runAction:[CCScaleBy actionWithDuration:.5f scale:.5f];
// wrapper.visible = false;
