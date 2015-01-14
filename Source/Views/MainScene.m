#import "MainScene.h"
#import "LoadingScene.h"

#import "GameBoard.h"
#import "ControlBoard.h"
#import "WinBoard.h"

#import "Game.h"

#define SUDOKU_TABLE_LENGTH            9
#define SUDOKU_BLOCK_LENGTH            3


@interface MainScene () <GameDelegate, GameBoardDelegate, ControlBoardDelegate, WinBoardDelegate>
@property (nonatomic, strong) Game              *   game;
@end

@implementation MainScene

+ (CCScene *)sceneWithGame:(Game *)game {
    MainScene *node = (MainScene *)[CCBReader load:@"MainScene"];
    node.game = game;
    CCScene *scene = [CCScene node];
    [scene addChild:node];
    return scene;
}

- (void)onQuit:(id)sender {
//    [[CCDirector sharedDirector] replaceScene:[MainScene sceneWithDifficutyLevel:PuzzleDifficultyEasy]];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MenuScene"]];
}

- (void)didLoadFromCCB {
    
    _gameBoard.delegate = self;
    _controlBoard.delegate = self;
}

- (void)onEnter {
    [super onEnter];
    
    [self.game updateAllGrid];
}

- (void)setGame:(Game *)game {
    if (_game != game) {
        _game.delegate = nil;
        _game = game;
        _game.delegate = self;
    }
}

#pragma Delegate
- (void)game:(Game *)game updatePenAtRow:(NSInteger)row col:(NSInteger)col label:(NSString *)label color:(CCColor *)color {
    [_gameBoard updatePenAtRow:row col:col label:label color:color];
}

- (void)game:(Game *)game updateNotesAtRow:(NSInteger)row col:(NSInteger)col numbers:(NSArray *)numbers colors:(NSArray *)colors {
    [_gameBoard updateNotesAtRow:row col:col numbers:numbers colors:colors];
}

- (void)game:(Game *)game updateIsNotesOn:(BOOL)isNotesOn {
    _controlBoard.isNotesOn = isNotesOn;
}

- (void)game:(Game *)game updateHighlightedCells:(NSArray *)cells hintCells:(NSArray *)hintCells {
    [_gameBoard resetAllHighlights];
    [_gameBoard highlightCellsAtPoints:cells isHint:NO];
    [_gameBoard highlightCellsAtPoints:hintCells isHint:YES];
}

- (void)gameBoard:(GameBoard *)board onSelectPoint:(CGPoint)point {
    self.game.selectedCell = point;
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

- (void)controlBoard:(ControlBoard *)board button:(ControlButton *)button onClickFunction:(ControlButtonFunction)function {
    [self.game clickFunction:function];
}

- (void)winBoardOnReplay:(WinBoard *)winBoard {
    [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithDifficutyLevel:self.game.options.difficutyLevel]];
}

- (void)winBoardOnMenu:(WinBoard *)winBoard {
    [self onQuit:nil];
}
/*
- (void)generateSudoku {
    
    NSMutableString *tableString = [[NSMutableString alloc] initWithString:@"\n"];
    NSMutableArray *table = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
    for (int i = 0; i < SUDOKU_TABLE_LENGTH; ++i) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
        for (int j = 0; j < SUDOKU_TABLE_LENGTH; ++j) {
            [row addObject:@0];
        }
        [table addObject:row];
    }
    NSSet *fullNumSet = [NSSet setWithArray:@[@1, @2, @3, @4, @5, @6, @7, @8, @9]];
    NSMutableArray *rowCache = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
    NSMutableArray *colCache = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
    NSMutableArray *blockCache = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
    
    COUNTER_START();
    int blockCachedRow = 0;
    int blockCachedCol = 0;
    for (int i = 0; i < [table count]; ++i) {
        [rowCache removeAllObjects];
        for (int j = 0; j < [table[i] count]; ++j) {
            // check col
            [colCache removeAllObjects];
            for (int k = 0; k < i; ++k) {
                [colCache addObject:table[k][j]];
                COUNTER_INCREASE();
            }
            // check block
            if (i / SUDOKU_BLOCK_LENGTH != blockCachedRow || j / SUDOKU_BLOCK_LENGTH != blockCachedCol) {
                blockCachedRow = i / SUDOKU_BLOCK_LENGTH;
                blockCachedCol = j / SUDOKU_BLOCK_LENGTH;
                [blockCache removeAllObjects];
                for (int m = blockCachedRow * SUDOKU_BLOCK_LENGTH; m <= i; ++m) {
                    for (int n = blockCachedCol * SUDOKU_BLOCK_LENGTH; (m < i && n < (blockCachedCol + 1) * SUDOKU_BLOCK_LENGTH) || (m == i && n < j); ++n) {
                        [blockCache addObject:table[m][n]];
                        COUNTER_INCREASE();
                    }
                }
            }
            
            NSMutableSet *numSet = [NSMutableSet setWithArray:rowCache];
            [numSet addObjectsFromArray:colCache];
            [numSet addObjectsFromArray:blockCache];
            
            NSMutableSet *finalSet = [NSMutableSet setWithSet:fullNumSet];
            [finalSet minusSet:numSet];
            
            if ([finalSet count] == 0 || [finalSet containsObject:@0]) {
                CCLOG(@"{ i = %d, j = %d}", i, j);
                if ( j > 0) {
                    // the last numbers
                    NSMutableSet *lastLackedNumberSet = [NSMutableSet setWithSet:fullNumSet];
                    [lastLackedNumberSet minusSet:[NSSet setWithArray:rowCache]];
                    if ([lastLackedNumberSet count] == 0) {
                        NSAssert(NO, @"should not be here");
                    }
                    NSInteger row = NSNotFound;
                    NSInteger rowInBlock = NSNotFound;
                    NSInteger rowInCol = NSNotFound;
                    for (NSNumber *number in lastLackedNumberSet) {
                        NSInteger rowFoundInBlock = [blockCache indexOfObject:number];
                        rowInBlock = (rowInBlock == NSNotFound) ? rowFoundInBlock : ((rowFoundInBlock == NSNotFound) ? rowInBlock : MIN(rowInBlock, rowFoundInBlock));
                        NSInteger rowFoundInCol = [colCache indexOfObject:number];
                        rowInCol = (rowInCol == NSNotFound) ? rowFoundInCol : ((rowFoundInCol == NSNotFound) ? rowInCol : MIN(rowInCol, rowFoundInCol));
                        COUNTER_INCREASE();
                    }
                    if (rowInBlock != NSNotFound) {
                        row = rowInBlock / SUDOKU_BLOCK_LENGTH + blockCachedRow * SUDOKU_BLOCK_LENGTH;
                        CCLOG(@"same number in block %d", (int)row);
                    } else if (rowInCol != NSNotFound) {
                        row = rowInCol;
                        CCLOG(@"same number in col %d", (int)row);
                    } else {
                        NSAssert(NO, @"something is wrong");
                    }
                    
                    if (row != NSNotFound) {
                        for (int m = i; m >= (int)row; --m) {
                            for (int n = 0; n < SUDOKU_TABLE_LENGTH; ++n) {
                                table[m][n] = @0;
                                COUNTER_INCREASE();
                            }
                        }
                        i = MAX((int)row - 1, -1);
                    }
                }
                // back to the prev line
                else if (j > 0) {
                    for (int k = 0; k < j; ++k) {
                        table[i][k] = @0;
                        COUNTER_INCREASE();
                    }
                    --i;
                } else {
                    int prevRow = MAX(i - 1, 0);
                    for (int k = 0; k < SUDOKU_TABLE_LENGTH; ++k) {
                        table[prevRow][k] = @0;
                        COUNTER_INCREASE();
                    }
                    i = MAX(prevRow - 1, -1);
                }
                break;
            }
            
            id num = nil;
            do {
                if (num) {
                    [finalSet removeObject:num];
                }
                num = [finalSet allObjects][arc4random_uniform((u_int32_t)[finalSet count])];
                COUNTER_INCREASE();
            } while ([rowCache containsObject:num] || [colCache containsObject:num] || [blockCache containsObject:num]);
            table[i][j] = num;
            
            [rowCache addObject:num];
            [blockCache addObject:num];
            COUNTER_INCREASE();
        }
    }
    
    COUNTER_END();
    
    [table enumerateObjectsUsingBlock:^(NSArray *row, NSUInteger i, BOOL *stop) {
        [row enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger j, BOOL *stop) {
            [tableString appendFormat:@"%@ %@", num, (j + 1) % 3 == 0 ? @"|" : @""];
        }];
        [tableString appendFormat:@"\n%@", (i + 1) % 3 == 0 ? @"---------------------\n" : @""];
    }];
    //    for (NSArray *row in table) {
    //        [tableString appendFormat:@"%@\n",[row componentsJoinedByString:@" "]];
    //
    //    }
    CCLOG(@"tableString = %@", tableString);
}
*/
@end
