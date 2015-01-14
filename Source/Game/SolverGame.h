//
//  SolverGame.h
//  SudokuX
//
//  Created by Kalvin Xie on 15-1-8.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "Game.h"

@class SolverGame;
@protocol SolverGameDelegate <GameDelegate>

@optional
- (void)solverGame:(SolverGame *)game showMessage:(NSString *)msg;

@end

@interface SolverGame : Game {
    //
    BOOL        _isPuzzleSolving;
    BOOL        _isPuzzleSolved;
}

@property (nonatomic, weak) id<SolverGameDelegate>  delegate;
@property (nonatomic, assign) BOOL                  isPuzzleSolving;
@property (nonatomic, assign) BOOL                  isPuzzleSolved;

- (void)showSuggestedCell;
@end
