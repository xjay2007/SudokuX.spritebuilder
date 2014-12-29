//
//  LoadingScene.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-26.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface LoadingScene : CCNode

+ (CCScene *)sceneWithDifficutyLevel:(PuzzleDifficulty)level;
@end
