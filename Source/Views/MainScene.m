#import "MainScene.h"
#import "Generator.h"
#import "GameBoard.h"
#import "ControlBoard.h"
#import "Solver.h"

#define SUDOKU_TABLE_LENGTH            9
#define SUDOKU_BLOCK_LENGTH            3


@interface MainScene () <GameBoardDelegate, ControlBoardDelegate, PuzzleStateDelegate>
@property (nonatomic, strong) PuzzleState       *   state;
@property (nonatomic, strong) PuzzleState       *   originalState;
@property (nonatomic, strong) PuzzleState       *   solvedOriginalState;
@property (nonatomic, assign) BOOL                  isShowSuggestedCells;
@property (nonatomic, assign) BOOL                  isShowIncorrectNumbers;
@property (nonatomic, assign) PuzzleDifficulty      difficutyLevel;
@property (nonatomic, strong) NSMutableArray    *   undoStatesStack;
@property (nonatomic, assign) CGPoint               selectedCell;

@property (nonatomic, strong) CCColor           *   userValueColor;
@property (nonatomic, strong) CCColor           *   originalValueColor;
@property (nonatomic, strong) CCColor           *   incorrectValueColor;
@end

@implementation MainScene

+ (CCScene *)sceneWithState:(PuzzleState *)state {
    MainScene *node = (MainScene *)[CCBReader load:@"MainScene"];
    [node loadNewPuzzleWithState:state];
    CCScene *scene = [CCScene node];
    [scene addChild:node];
    return scene;
}

+ (CCScene *)sceneWithDifficutyLevel:(PuzzleDifficulty)level {
    MainScene *node = (MainScene *)[CCBReader load:@"MainScene"];
    [node generateNewPuzzleWithLevel:level];
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
    
    _userValueColor = [CCColor blueColor];
    _originalValueColor = [CCColor blackColor];
    _incorrectValueColor = [CCColor redColor];
    
    _isShowIncorrectNumbers = YES;
}

- (void)onEnter {
    [super onEnter];
    
    [_gameBoard updateAllGrid];
}

#pragma Delegate
- (void)gameBoard:(GameBoard *)board onSelectPoint:(CGPoint)point {
    self.selectedCell = point;
    [board resetAllHighlights];
    [board highlightCellAtRow:point.x col:point.y isHint:NO];
}
- (void)gameBoard:(GameBoard *)board getLabelString:(NSString *__autoreleasing *)string andColor:(CCColor *__autoreleasing *)color atRow:(NSInteger)row col:(NSInteger)col {
    id cellValue = [self.state cellValueAtX:row y:col];
    if ([cellValue isKindOfClass:[NSNumber class]]) {
        id solvedCellValue = [self.solvedOriginalState cellValueAtX:row y:col];
        if (self.isShowIncorrectNumbers && [solvedCellValue isKindOfClass:[NSNumber class]]
            && [cellValue unsignedCharValue] != [solvedCellValue unsignedCharValue]) {
            *color = self.incorrectValueColor;
        } else {
            id originalValue = [self.originalState cellValueAtX:row y:col];
            if (self.originalState != nil && [originalValue isKindOfClass:[NSNumber class]]) {
                *color = self.originalValueColor;
            } else {
                *color = self.userValueColor;
            }
        }
        *string = [NSString stringWithFormat:@"%d", [cellValue unsignedCharValue] + 1];
    }
}

- (void)controlBoard:(ControlBoard *)board button:(ControlButton *)button onClickFunction:(ControlButtonFunction)function {
    if (function < ControlButtonFunctionDigitIndexMax) {
        if (self.state != nil && [self canModifyCell:self.selectedCell]) {
            [self setStateCellValue:function atPoint:self.selectedCell];
        }
    }
}

- (void)puzzleState:(PuzzleState *)state stateChanged:(NSArray *)args {
    if (state.status == PuzzleStatusSolved) {
        // TODO: Sudoku Solved.
        CCLOG(@"state solved");
    }
}

#pragma mark - Accessor

- (NSMutableArray *)undoStatesStack {
    if (_undoStatesStack == nil) {
        _undoStatesStack = [[NSMutableArray alloc] init];
    }
    return _undoStatesStack;
}

- (void)setOriginalState:(PuzzleState *)originalState {
    if (_originalState != originalState) {
        [self setOriginalPuzzleCheckpoint:originalState];
    }
}

- (void)setState:(PuzzleState *)state {
    if (_state != state) {
        _state.delegate = nil;
        _state.isRaiseStateChangedEvent = NO;
        _state = state;
        _state.isRaiseStateChangedEvent = YES;
        _state.delegate = self;
    }
}

#pragma mark - set up

- (void)generateNewPuzzleWithLevel:(PuzzleDifficulty)level {
    COUNTER_START();
    Generator *generator = [Generator generatorWithOptions:[GeneratorOptions createWithDifficulty:level]];
    [self loadNewPuzzleWithState:[generator generate]];
    COUNTER_END();
}

- (void)loadNewPuzzleWithState:(PuzzleState *)state {
    COUNTER_START();
    [self clearUndoCheckpoints];
    [self clearOriginalPuzzleCheckpoint];
    [self setOriginalPuzzleCheckpoint:[state copy]];
    self.state = state;
    self.selectedCell = ccp(-1, -1);
    COUNTER_END();
}

- (void)clearUndoCheckpoints {
    [self.undoStatesStack removeAllObjects];
}

- (void)setUndoCheckpoint {
    if (self.state != nil) {
        [self.undoStatesStack addObject:[self.state copy]];
    }
}

- (void)clearOriginalPuzzleCheckpoint {
    _originalState = nil;
    _solvedOriginalState = nil;
}

- (void)setOriginalPuzzleCheckpoint:(PuzzleState *)original {
    _originalState = original;
    if (original != nil) {
        SolverOptions *options = [SolverOptions options];
        options.maximumSolutionsToFind = @2;
        SolverResults *results = [Solver solveState:original options:options];
        if (results.status == PuzzleStatusSolved && [results.puzzles count] == 1) {
            self.solvedOriginalState = results.puzzle;
        } else {
            self.solvedOriginalState = nil;
        }
    }
}

- (void)setStateCellValue:(Byte)value atPoint:(CGPoint)point {
    id cellvalue = [self.state cellValueAtPoint:point];
    if (![cellvalue isKindOfClass:[NSNumber class]] || [cellvalue unsignedCharValue] != value) {
        [self setUndoCheckpoint];
        // TODO: remove note at this cell
        [self.state setCellValue:@(value) atPoint:self.selectedCell];
        [_gameBoard updateCellAtRow:self.selectedCell.x col:self.selectedCell.y];
    }
}

- (BOOL)canModifyCell:(CGPoint)point {
    return (point.x >= 0 && point.x < self.state.gridSize && point.y >= 0 && point.y < self.state.gridSize) && (self.originalState == nil || ![[self.originalState cellValueAtPoint:point] isKindOfClass:[NSNumber class]]);
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
