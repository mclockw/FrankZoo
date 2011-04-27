//
//  main.m
//  FrankZooV1
//
//  Created by wang chenzhong on 4/24/11.
//  Copyright company 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConfig.h"
ST_APPCONFIG g_stAppConfing = {0};

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]\
&& [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 

int main(int argc, char *argv[]) {
  
  if ( IS_IPAD )
    g_stAppConfing.iIsIPad = 1;
	else
    g_stAppConfing.iIsIPad = 0;
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
  [pool release];
  return retVal;
}
