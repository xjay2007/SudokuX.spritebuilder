//
//  LoadingScene.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-26.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "LoadingScene.h"
#import "MainScene.h"
#import "Generator.h"

@implementation LoadingScene

+ (CCScene *)sceneWithDifficutyLevel:(PuzzleDifficulty)level {
    LoadingScene *node = (LoadingScene *)[CCBReader load:@"LoadingScene"];
    [node generateNewPuzzleWithLevel:level];
    CCScene *scene = [CCScene node];
    [scene addChild:node];
    return scene;
}

- (void)generateNewPuzzleWithLevel:(PuzzleDifficulty)level {
    dispatch_queue_t queue = dispatch_queue_create("com.xj.generateState", NULL);
    dispatch_async(queue, ^{
        COUNTER_START();
        Generator *generator = [Generator generatorWithOptions:[GeneratorOptions createWithDifficulty:level]];
        PuzzleState *state = [generator generate];
        COUNTER_END();
        CCLOG(@"puzzle.filledCellsNum = %ld", state.numberOfFilledCells);
        if (state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self jumpToGameSceneWithState:state];
            });
        }
    });
}

- (void)jumpToGameSceneWithState:(PuzzleState *)state{
    [[CCDirector sharedDirector] replaceScene:[MainScene sceneWithState:state]];
}
@end
