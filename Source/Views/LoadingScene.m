//
//  LoadingScene.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-26.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "LoadingScene.h"
#import "MainScene.h"
#import "Game.h"

@implementation LoadingScene

+ (CCScene *)sceneWithDifficutyLevel:(PuzzleDifficulty)level {
    LoadingScene *node = (LoadingScene *)[CCBReader load:@"LoadingScene"];
    [node generateNewGameWithLevel:level];
    CCScene *scene = [CCScene node];
    [scene addChild:node];
    return scene;
}

- (void)generateNewGameWithLevel:(PuzzleDifficulty)level {
    dispatch_queue_t queue = dispatch_queue_create("com.xj.generateState", NULL);
    dispatch_async(queue, ^{
        COUNTER_START();
        GameOptions *gameOptions = [GameOptions optionsWithDifficutyLevel:level];
        Game *game = [Game gameWithOptions:gameOptions];
        [game generateNewPuzzle];
        COUNTER_END();
        if (game) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self jumpToGameSceneWithGame:game];
            });
        }
    });
}

- (void)jumpToGameSceneWithGame:(Game *)game{
    [[CCDirector sharedDirector] replaceScene:[MainScene sceneWithGame:game]];
}
@end
