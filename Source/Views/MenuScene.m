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

#define TEST_NOTIFICATION @"test_notification"
#define TEST_KEY @"test_key"

@implementation MenuScene

- (void)didLoadFromCCB {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseNote:) name:TEST_NOTIFICATION object:nil];
    
    dispatch_async(dispatch_queue_create("com.xj.test", NULL), ^{
        for (NSInteger i = 0; i < 100; ++i) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TEST_NOTIFICATION object:nil userInfo:@{TEST_KEY : @(i)}];
            });
            sleep(1);
        }
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)responseNote:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    CCLOG(@"%@, msg : %@", NSStringFromSelector(_cmd), userInfo[TEST_KEY]);
}

- (void)onSelectALevel:(CCNode *)button {
    PuzzleDifficulty level = [button.name integerValue];
    [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithDifficutyLevel:level]];
}

- (void)onSolverScene:(CCNode *)button {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"SolverScene"]];
}
@end
