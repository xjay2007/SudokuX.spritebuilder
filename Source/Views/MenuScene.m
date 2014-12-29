//
//  MenuScene.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-24.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "MenuScene.h"
#import "LoadingScene.h"
#import "MainScene.h"

@implementation MenuScene

- (void)onSelectALevel:(CCNode *)button {
    PuzzleDifficulty level = [button.name integerValue];
    [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithDifficutyLevel:level]];
}
@end
