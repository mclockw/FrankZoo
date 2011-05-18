/*
 *  AppConfig.h
 *  FrankZoo
 *
 *  Created by wang chenzhong on 3/28/11.
 *  Copyright 2011 company. All rights reserved.
 *
 */

#ifndef APPCONFIG_H
#define APPCONFIG_H

/* ************************************************************************** */ 
/* *                                                                        * */ 
/* *                           DEFINITIONS AND MACROS                       * */ 
/* *                                                                        * */ 
/* ************************************************************************** */
#define SINGLE_GAME_MODE_BASIC 1
#define SINGLE_GAME_MODE_ADVANCE 2
#define AI_LEVEL_EASY  1
#define AI_LEVEL_NORMAL 2
#define AI_LEVEL_HARD  3

/* ************************************************************************** */ 
/* *                                                                        * */ 
/* *                           TYPEDEFS AND STRUCTURES                      * */ 
/* *                                                                        * */ 
/* ************************************************************************** */
typedef struct tagAppConfig
{
  int isIPad;
  
  int iSingleGameMode;  // 1:basic 2:advanced
  int iAiLevel;           // 1:easy 2:nomal 3:hard
  int iPlayerNum;         // 4 <= X <= 7
}ST_APPCONFIG;

//670 X 1024 原始图像
//134 X 204
#endif