//
//  AppDelegate.h
//  FrankZooV1
//
//  Created by wang chenzhong on 4/24/11.
//  Copyright company 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
