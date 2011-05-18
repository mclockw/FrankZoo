//
//  FZGameLogicServer.h
//  FrankZooV1
//
//  Created by wang chenzhong on 5/11/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZGameLogic.h"

/*  
 做为服务器的GameLogic:
 1，为本机玩家提供游戏逻辑
 2，为整个游戏提供AI
 3, 生成每个玩家的手牌
 4， 把每个玩家的手牌通过Session发到他们手里
 5， 生成随机的第一个出牌的玩家序号，并通过Session把这一序号告诉每个远程玩家
 */
@interface FZGameLogicServer : FZGameLogic {
    
}

@end
