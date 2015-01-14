//
//  SolverScene.m
//  SudokuX
//
//  Created by Kalvin Xie on 15-1-8.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "SolverScene.h"
#import "LoadingScene.h"

#import "GameBoard.h"
#import "ControlBoard.h"
#import "WinBoard.h"

#import "SolverGame.h"


@interface SolverScene () <SolverGameDelegate, GameBoardDelegate, ControlBoardDelegate, WinBoardDelegate>
@property (nonatomic, readonly) SolverGame        *   game;
@end

@implementation SolverScene

- (void)onQuit:(id)sender {
    //    [[CCDirector sharedDirector] replaceScene:[MainScene sceneWithDifficutyLevel:PuzzleDifficultyEasy]];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MenuScene"]];
}

- (void)didLoadFromCCB {
    GameOptions *gameOptions = [GameOptions optionsWithDifficutyLevel:PuzzleDifficultyHard];
    gameOptions.isShowHighlights = YES;
    gameOptions.isShowSameNumberHighlights = YES;
    gameOptions.isShowSameNumberHighlightsInHints = YES;
    gameOptions.isShowRelativeCellsHighlights = NO;
    gameOptions.isShowNoteHighlights = NO;
    gameOptions.isShowSuggestedCellsHightlights = NO;
    _game = [SolverGame gameWithOptions:gameOptions];
    _game.delegate = self;
    _gameBoard.delegate = self;
    _controlBoard.delegate = self;
    
    _originalMessage = _messageLabel.string;
}

- (void)onEnter {
    [super onEnter];
    
    [self.game showSuggestedCell];
}

- (SolverGame *)game {
    return (SolverGame *)_game;
}

- (void)restoreMessage {
    _messageLabel.string = _originalMessage;
}

#pragma Delegate
- (void)game:(Game *)game updatePenAtRow:(NSInteger)row col:(NSInteger)col label:(NSString *)label color:(CCColor *)color {
    [_gameBoard updatePenAtRow:row col:col label:label color:color];
}

- (void)game:(Game *)game updateHighlightedCells:(NSArray *)cells hintCells:(NSArray *)hintCells {
    [_gameBoard resetAllHighlights];
    [_gameBoard highlightCellsAtPoints:cells isHint:NO];
    [_gameBoard highlightCellsAtPoints:hintCells isHint:YES];
}

- (void)game:(Game *)game didFinishAndIsWinning:(BOOL)isWinning {
    if (isWinning) {
        // TODO: play winnig animation
        _gameBoard.userInteractionEnabled = NO;
        _controlBoard.userInteractionEnabled = NO;
        
        WinBoard *winBoard = (WinBoard *)[CCBReader load:@"WinBoard"];
        winBoard.positionType = CCPositionTypeNormalized;
        winBoard.position = ccp(0.5f, 0.5f);
        winBoard.scale = 0;
        [[CCDirector sharedDirector].runningScene addChild:winBoard];
        winBoard.delegate = self;
        
        [winBoard runAction:[CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5f scale:1]]];
    }
}

- (void)solverGame:(SolverGame *)game showMessage:(NSString *)msg {
    if (msg != nil && msg.length > 0) {
        _messageLabel.string = msg;
        [self unschedule:@selector(restoreMessage)];
        [self scheduleOnce:@selector(restoreMessage) delay:2];
    }
}

- (void)gameBoard:(GameBoard *)board onSelectPoint:(CGPoint)point {
    self.game.selectedCell = point;
}

- (void)controlBoard:(ControlBoard *)board button:(ControlButton *)button onClickFunction:(ControlButtonFunction)function {
    [self.game clickFunction:function];
}

- (void)winBoardOnReplay:(WinBoard *)winBoard {
    [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithDifficutyLevel:self.game.options.difficutyLevel]];
}

- (void)winBoardOnMenu:(WinBoard *)winBoard {
    [self onQuit:nil];
}
@end
