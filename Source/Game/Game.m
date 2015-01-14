//
//  Game.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-30.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Game.h"
#import "PuzzleState.h"
#import "Generator.h"
#import "Solver.h"
#import "FastBitArray.h"
#import "NakedSingleTechnique.h"

static NSString * const UNDO_KEY_STATE = @"UNDO_KEY_STATE";
static NSString * const UNDO_KEY_NOTES = @"UNDO_KEY_NOTES";

@interface Game () <PuzzleStateDelegate>
@property (nonatomic, strong)   NSMutableArray  *   undoStack;
@property (nonatomic, strong)   NSArray         *   gameNotes;
@property (nonatomic, strong)   NSMutableArray  *   userNotes;
@end

@implementation Game

+ (instancetype)gameWithOptions:(GameOptions *)options {
    return [[Game alloc] initWithOptions:options];
}

- (instancetype)initWithOptions:(GameOptions *)options {
    self = [super init];
    if (self) {
        _options = options;
        _selectedCell = GAME_SELECTED_CELL_INVALID;
    }
    return self;
}


#pragma mark - Accessor

- (NSMutableArray *)undoStack {
    if (_undoStack == nil) {
        _undoStack = [[NSMutableArray alloc] init];
    }
    return _undoStack;
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
        
        self.gameNotes = nil;
    }
}

- (NSMutableArray *)userNotes {
    if (_userNotes == nil) {
        _userNotes = [[NSMutableArray alloc] init];
    }
    return _userNotes;
}

- (void)setIsNotesOn:(BOOL)isNotesOn {
    if (_isNotesOn != isNotesOn) {
        _isNotesOn = isNotesOn;
        
        if ([self.delegate respondsToSelector:@selector(game:updateIsNotesOn:)]) {
            [self.delegate game:self updateIsNotesOn:_isNotesOn];
        }
    }
}

- (void)setSelectedCell:(CGPoint)selectedCell {
    if (!CGPointEqualToPoint(_selectedCell, selectedCell)) {
        _selectedCell = selectedCell;
        
        [self showHighlightsAtPoint:_selectedCell];
    }
}

- (NSArray *)gameNotes {
    if (_gameNotes == nil || [_gameNotes count] == 0) {
        NSMutableArray *possibleNumbers = [PuzzleState instantiatePossibleNumbersArrayWithState:self.state];
        if (self.state != nil) {
            [self.state computePossibleNumbersWithTechniques:@[[NakedSingleTechnique technique]] usesOfTechnique:NULL isOnlyOnePass:NO isEarlyExitWhenSoleFound:NO possibleNumbers:possibleNumbers];
        }
        _gameNotes = possibleNumbers;
    }
    return _gameNotes;
}
#pragma mark - set up

- (void)generateNewPuzzle {
    [self generateNewPuzzleWithLevel:self.options.difficutyLevel];
}
- (void)generateNewPuzzleWithLevel:(PuzzleDifficulty)level {
    Generator *generator = [Generator generatorWithOptions:[GeneratorOptions createWithDifficulty:level]];
    [self loadNewPuzzleWithState:[generator generate]];
}

- (void)loadNewPuzzleWithState:(PuzzleState *)state {
    [self clearUndoCheckpoints];
    [self clearOriginalPuzzleCheckpoint];
    [self setOriginalPuzzleCheckpoint:[state copy]];
    self.state = state;
    self.selectedCell = GAME_SELECTED_CELL_INVALID;
    
    [self clearNotesCheckpoint];
    
    CCLOG(@"state.filledCellNum = %ld", self.state.numberOfFilledCells);
}

- (void)clearUndoCheckpoints {
    [self.undoStack removeAllObjects];
}

- (void)setUndoCheckpoint {
    if (self.state != nil) {
        PuzzleState *stateCopy = [self.state copy];
        NSMutableArray *notesCopy = [NSMutableArray arrayWithCapacity:self.userNotes.count];
        for (NSArray *array in self.userNotes) {
            [notesCopy addObject:[[NSArray alloc] initWithArray:array copyItems:YES]];
        }
        NSDictionary *undoDict = @{UNDO_KEY_STATE : stateCopy,
                                   UNDO_KEY_NOTES : notesCopy};
        [self.undoStack addObject:undoDict];
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

- (void)clearNotesCheckpoint {
    for (NSInteger i = 0; i < self.state.gridSize; ++i) {
        NSMutableArray *arr = nil;
        if (i < self.userNotes.count) {
            arr = self.userNotes[i];
        } else if (i == self.userNotes.count) {
            arr = [NSMutableArray arrayWithCapacity:self.state.gridSize];
            self.userNotes[i] = arr;
        }
        if (arr != nil) {
            for (NSInteger j = 0; j < self.state.gridSize; ++j) {
                FastBitArray *fba = nil;
                if (j < arr.count) {
                    fba = arr[j];
                } else if (j == arr.count) {
                    fba = [FastBitArray arrayWithLength:self.state.gridSize];
                    arr[j] = fba;
                }
                if (fba != nil) {
                    [fba setAllValue:NO];
                }
            }
        }
    }
}

- (void)setStateCellValue:(Byte)value atPoint:(CGPoint)point {
    id cellvalue = [self.state cellValueAtPoint:point];
    if (![cellvalue isKindOfClass:[NSNumber class]] || [cellvalue unsignedCharValue] != value) {
        [self setUndoCheckpoint];
        
        [self.state setCellValue:@(value) atPoint:point];
        
        // remove note at relative cells
        NSMutableSet *set = [NSMutableSet setWithObject:[NSValue valueWithCGPoint:point]];
        [set unionSet:[self removeRelativeNoteCellsWithValue:value atPoint:point]];
        
//        [self updateCellAtRow:point.x col:point.y];
        [self updateCells:set.allObjects];
        
        // reset selected cell
//        self.selectedCell = GAME_SELECTED_CELL_INVALID;
        [self showHighlightsAtPoint:self.selectedCell];
    }
}

- (void)takeNoteValue:(Byte)value atPoint:(CGPoint)point {
    id cellvalue = [self.state cellValueAtPoint:point];
    if (![cellvalue isKindOfClass:[NSNumber class]]) {
        FastBitArray *fba = self.userNotes[(int)point.x][(int)point.y];
        [fba setValue:![fba valueAtIndex:value] atIndex:value];
        
        [self updateCellAtRow:point.x col:point.y];
    }
}

- (NSSet *)removeRelativeNoteCellsWithValue:(Byte)value atPoint:(CGPoint)point {
    NSMutableSet *ret = [NSMutableSet set];
    NSArray *points = [self pointsRelativeWithPoint:point isOriginalPointExclusive:NO];
    for (NSValue *pvalue in points) {
        CGPoint p = [pvalue CGPointValue];
        FastBitArray *fba = self.userNotes[(int)p.x][(int)p.y];
        if ([fba valueAtIndex:value]) {
            [fba setValue:NO atIndex:value];
            [ret addObject:pvalue];
        }
    }
    return ret;
}

- (void)showHighlightsAtPoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(game:updateHighlightedCells:hintCells:)]) {
        if (_selectedCell.x == -1 || _selectedCell.y == -1) {
            [self.delegate game:self updateHighlightedCells:nil hintCells:nil];
        } else {
            NSMutableSet *cells = [NSMutableSet setWithObject:[NSValue valueWithCGPoint:point]];
            NSMutableSet *hintCells = [NSMutableSet set];
            if (self.options.isShowHighlights) {
                id cellValue = [self.state cellValueAtPoint:point];
                if ([cellValue isKindOfClass:[NSNumber class]]) {
                    // selected a number
                    for (Byte x = 0; x < self.state.gridSize; ++x) {
                        for (Byte y = 0; y < self.state.gridSize; ++y) {
                            if (self.options.isShowSameNumberHighlights) {
                                // highlight the cell with the same number
                                id xyValue = [self.state cellValueAtX:x y:y];
                                if ([xyValue isKindOfClass:[NSNumber class]] && [xyValue unsignedCharValue] == [cellValue unsignedCharValue]) {
                                    if (self.options.isShowSameNumberHighlightsInHints) {
                                        [hintCells addObject:[NSValue valueWithCGPoint:ccp(x, y)]];
                                    } else {
                                        [cells addObject:[NSValue valueWithCGPoint:ccp(x, y)]];
                                    }
                                }
                            }
                            // highlight the notes within the same number
                            if (self.options.isShowNoteHighlights) {
                                FastBitArray *fba = self.userNotes[x][y];
                                if ([fba valueAtIndex:[cellValue unsignedCharValue]]) {
                                    [hintCells addObject:[NSValue valueWithCGPoint:ccp(x, y)]];
                                }
                            }
                            // highlight the possible cell with the same number
                            if (self.options.isShowSuggestedCellsHightlights) {
                                FastBitArray *fba = self.gameNotes[x][y];
                                if ([fba valueAtIndex:[cellValue unsignedCharValue]]) {
                                    [hintCells addObject:[NSValue valueWithCGPoint:ccp(x, y)]];
                                }
                            }
                        }
                    }
                } else {
                    if (self.options.isShowRelativeCellsHighlights) {
                        // not filled
                        [hintCells addObjectsFromArray:[self pointsRelativeWithPoint:point isOriginalPointExclusive:YES]];
                    }
                }
            }
            [hintCells removeObject:[NSValue valueWithCGPoint:point]];
//            NSMutableSet *needToRemoveCells = [NSMutableSet set];
//            for (NSValue *value in hintCells) {
//                CGPoint point = [value CGPointValue];
//                if ([[self.state cellValueAtPoint:point] isKindOfClass:[NSNumber class]]) {
//                    [needToRemoveCells addObject:value];
//                }
//            }
//            [hintCells minusSet:needToRemoveCells];
            [self.delegate game:self updateHighlightedCells:cells.allObjects hintCells:hintCells.allObjects];
        }
    }
}

- (void)eraseCellAtPoint:(CGPoint)point {
    id cellvalue = [self.state cellValueAtPoint:point];
    if ([cellvalue isKindOfClass:[NSNumber class]]) {
        [self setUndoCheckpoint];
        
        [self.state setCellValue:nil atPoint:point];
        
        [self updateCellAtRow:point.x col:point.y];
        
        self.selectedCell = GAME_SELECTED_CELL_INVALID;
    }
}

- (void)undo {
    if (self.undoStack.count > 0) {
        NSDictionary *undoDict = [self.undoStack lastObject];
        [self.undoStack removeLastObject];
        PuzzleState *state = undoDict[UNDO_KEY_STATE];
        NSMutableArray *userNotes = undoDict[UNDO_KEY_NOTES];
        self.state = state;
        self.userNotes = userNotes;
        
        [self updateAllGrid];
        
        // reset highlight
        self.selectedCell = GAME_SELECTED_CELL_INVALID;
    }
}

- (BOOL)canModifyCell:(CGPoint)point {
    return (point.x >= 0 && point.x < self.state.gridSize && point.y >= 0 && point.y < self.state.gridSize) && (self.originalState == nil || ![[self.originalState cellValueAtPoint:point] isKindOfClass:[NSNumber class]]);
}

- (BOOL)canTakeNotesAtCell:(CGPoint)point {
    return (point.x >= 0 && point.x < self.state.gridSize && point.y >= 0 && point.y < self.state.gridSize) && (![[self.state cellValueAtPoint:point] isKindOfClass:[NSNumber class]]);
}

#pragma mark - PuzzleStateDelegate
- (void)puzzleState:(PuzzleState *)state stateChanged:(NSArray *)args {
    if (state.status == PuzzleStatusSolved) {
        // TODO: Sudoku Solved.
        if ([self.delegate respondsToSelector:@selector(game:didFinishAndIsWinning:)]) {
            [self.delegate game:self didFinishAndIsWinning:YES];
        }
    }
    
    self.gameNotes = nil;
}

#pragma mark Public

- (void)clickFunction:(ControlButtonFunction)function {
    if (function < ControlButtonFunctionDigitIndexMax) {
        if (!self.isNotesOn) {
            if (self.state != nil && [self canModifyCell:self.selectedCell]) {
                [self setStateCellValue:function atPoint:self.selectedCell];
            }
        } else {
            // take notes
            if (self.state != nil && [self canTakeNotesAtCell:self.selectedCell]) {
                [self takeNoteValue:function atPoint:self.selectedCell];
            }
        }
    } else {
        switch (function) {
            case ControlButtonFunctionPen:
            case ControlButtonFunctionNote:  {
                self.isNotesOn = !self.isNotesOn;
                break;
            }
            case ControlButtonFunctionEraser: {
                if ([self canModifyCell:self.selectedCell] && [[self.state cellValueAtPoint:self.selectedCell] isKindOfClass:[NSNumber class]]) {
                    [self eraseCellAtPoint:self.selectedCell];
                }
                break;
            }
            case ControlButtonFunctionUndo: {
                [self undo];
                break;
            }
            default:
                break;
        }
    }
}

- (void)updateAllGrid {
    for (NSInteger row = 0; row < self.state.gridSize; ++row) {
        for (NSInteger col = 0; col < self.state.gridSize; ++col) {
            [self updateCellAtRow:row col:col];
        }
    }
}
- (void)updateCells:(NSArray *)cells {
    for (NSValue *cell in cells) {
        CGPoint point = [cell CGPointValue];
        [self updateCellAtRow:point.x col:point.y];
    }
}

- (void)updateCellAtRow:(NSInteger)row col:(NSInteger)col {
//    id cellValue = [self.state cellValueAtX:row y:col];
//    if ([cellValue isKindOfClass:[NSNumber class]]) {
        // update pen
        if ([self.delegate respondsToSelector:@selector(game:updatePenAtRow:col:label:color:)]) {
            NSString *label = [self labelWithRow:row col:col];
            CCColor *color = [self colorWithRow:row col:col];
            [self.delegate game:self updatePenAtRow:row col:col label:label color:color];
        }
//    }
    if ([self.delegate respondsToSelector:@selector(game:updateNotesAtRow:col:numbers:colors:)]) {
        NSArray *numbers = [self noteNumbersWithRow:row col:col];
        NSArray *colors = [self noteColorsWithRow:row col:col];
        [self.delegate game:self updateNotesAtRow:row col:col numbers:numbers colors:colors];
    }
}

#pragma mark - Helper
- (NSString *)labelWithRow:(NSInteger)row col:(NSInteger)col {
    NSString *string = @"";
    id cellValue = [self.state cellValueAtX:row y:col];
    if ([cellValue isKindOfClass:[NSNumber class]]) {
        string = [NSString stringWithFormat:@"%d", [cellValue unsignedCharValue] + 1];
    }
    return string;
}

- (CCColor *)colorWithRow:(NSInteger)row col:(NSInteger)col {
    CCColor *color = [CCColor blueColor];
    id cellValue = [self.state cellValueAtX:row y:col];
    if ([cellValue isKindOfClass:[NSNumber class]]) {
        id solvedCellValue = [self.solvedOriginalState cellValueAtX:row y:col];
        if (self.options.isShowIncorrectNumbers && [solvedCellValue isKindOfClass:[NSNumber class]]
            && [cellValue unsignedCharValue] != [solvedCellValue unsignedCharValue]) {
            color = self.options.incorrectValueColor;
        } else {
            id originalValue = [self.originalState cellValueAtX:row y:col];
            if (self.originalState != nil && [originalValue isKindOfClass:[NSNumber class]]) {
                color = self.options.originalValueColor;
            } else {
                color = self.options.userValueColor;
            }
        }
    }
    return color;
}
- (NSArray *)noteNumbersWithRow:(NSInteger)row col:(NSInteger)col {
    id cellValue = [self.state cellValueAtX:row y:col];
    if ([cellValue isKindOfClass:[NSNumber class]]) {
        return @[];
    } else {
        FastBitArray *fba = self.userNotes[row][col];
        NSArray *bitsArray = [fba bitsArray];
        return bitsArray;
    }
}
- (NSArray *)noteColorsWithRow:(NSInteger)row col:(NSInteger)col {
    NSArray *numbers = [self noteNumbersWithRow:row col:col];
    if (numbers.count == 0) {
        return @[];
    } else {
        NSMutableArray *colors = [NSMutableArray arrayWithCapacity:numbers.count];
        NSArray *points = [self pointsRelativeWithPoint:ccp(row, col) isOriginalPointExclusive:YES];
        for (NSNumber *num in numbers) {
            // same row
            BOOL isRightNumber = YES;
            for (NSValue *pvalue in points) {
                CGPoint p = [pvalue CGPointValue];
                id cellvalue = [self.state cellValueAtPoint:p];
                if ([cellvalue isKindOfClass:[NSNumber class]] && [cellvalue unsignedCharValue] == [num unsignedCharValue]) {
                    isRightNumber = NO;
                    break;
                }
            }
            
            [colors addObject:isRightNumber ? self.options.noteValueColor : self.options.incorrectNoteValueColor];
        }
        return colors;
    }
}

- (NSArray *)pointsInSameRowWithPoint:(CGPoint)point isOriginalPointExclusive:(BOOL)isExclusive{
    NSMutableSet *set = [NSMutableSet set];
    for (NSInteger col = 0; col < self.state.gridSize; ++col) {
        [set addObject:[NSValue valueWithCGPoint:ccp(point.x, col)]];
    }
    if (isExclusive) {
        [set removeObject:[NSValue valueWithCGPoint:point]];
    }
    return set.allObjects;
}

- (NSArray *)pointsInSameColWithPoint:(CGPoint)point isOriginalPointExclusive:(BOOL)isExclusive{
    NSMutableSet *set = [NSMutableSet set];
    for (NSInteger row = 0; row < self.state.gridSize; ++row) {
        [set addObject:[NSValue valueWithCGPoint:ccp(row, point.y)]];
    }
    if (isExclusive) {
        [set removeObject:[NSValue valueWithCGPoint:point]];
    }
    return set.allObjects;
}

- (NSArray *)pointsInSameBlockWithPoint:(CGPoint)point isOriginalPointExclusive:(BOOL)isExclusive{
    NSMutableSet *set = [NSMutableSet set];
    NSInteger row = point.x;
    NSInteger col = point.y;
    Byte blockStartX = (row / self.state.boxSize) * self.state.boxSize;
    Byte blockStartY = (col / self.state.boxSize) * self.state.boxSize;
    for (Byte x = blockStartX; x < blockStartX + self.state.boxSize; ++x) {
        for (Byte y = blockStartY; y < blockStartY + self.state.boxSize; ++y) {
            [set addObject:[NSValue valueWithCGPoint:ccp(x, y)]];
        }
    }
    if (isExclusive) {
        [set removeObject:[NSValue valueWithCGPoint:point]];
    }
    return set.allObjects;
}

- (NSArray *)pointsRelativeWithPoint:(CGPoint)point  isOriginalPointExclusive:(BOOL)isExclusive {
    NSMutableSet *set = [NSMutableSet set];
    [set addObjectsFromArray:[self pointsInSameRowWithPoint:point isOriginalPointExclusive:isExclusive]];
    [set addObjectsFromArray:[self pointsInSameColWithPoint:point isOriginalPointExclusive:isExclusive]];
    [set addObjectsFromArray:[self pointsInSameBlockWithPoint:point isOriginalPointExclusive:isExclusive]];
    return set.allObjects;
}
@end
