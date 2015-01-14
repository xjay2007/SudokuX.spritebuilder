//
//  SolverGame.m
//  SudokuX
//
//  Created by Kalvin Xie on 15-1-8.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "SolverGame.h"
#import "PuzzleState.h"
#import "Solver.h"
#import "NakedSingleTechnique.h"

NSString *const MSG_WRONG_CELLS_TO_CORRECT = @"There are some wrong numbers.";
NSString *const MSG_SOLVING_PUZZLE = @"Solving puzzle...";

@interface SolverGame () <PuzzleStateDelegate> {
    NSMutableSet        *   _wrongCellsSet;
}
@property (nonatomic, strong) NSMutableSet      *   wrongCellsSet;
@end

@implementation SolverGame

+ (instancetype)gameWithOptions:(GameOptions *)options {
    return [[SolverGame alloc] initWithOptions:options];
}

//- (instancetype)initWithOptions:(GameOptions *)options {
//    self = [super init];
//    if (self) {
//        _options = options;
//        _state = [PuzzleState state];
//        _state.delegate = self;
//    }
//    return self;
//}


#pragma mark - Accessor

- (PuzzleState *)state {
    if (_state == nil) {
        _state = [PuzzleState state];
        _state.delegate = self;
    }
    return _state;
}

- (NSMutableSet *)wrongCellsSet {
    if (_wrongCellsSet == nil) {
        _wrongCellsSet = [[NSMutableSet alloc] init];
    }
    return _wrongCellsSet;
}

- (void)setOriginalState:(PuzzleState *)originalState {
    if (_originalState != originalState) {
        _originalState = originalState;
    }
}

#pragma mark - set up

- (void)setStateCellValue:(Byte)value atPoint:(CGPoint)point {
    id cellvalue = [self.state cellValueAtPoint:point];
    if (![cellvalue isKindOfClass:[NSNumber class]] || [cellvalue unsignedCharValue] != value) {
        
        [self.state setCellValue:@(value) atPoint:point];
        
        // remove note at relative cells
        [self updateCells:[self pointsRelativeWithPoint:point isOriginalPointExclusive:NO]];
        
        [self showSuggestedCell];
    }
}

- (void)eraseCellAtPoint:(CGPoint)point {
    id cellvalue = [self.state cellValueAtPoint:point];
    if ([cellvalue isKindOfClass:[NSNumber class]]) {
        
        [self.state setCellValue:nil atPoint:point];
        
        // remove note at relative cells
        [self updateCells:[self pointsRelativeWithPoint:point isOriginalPointExclusive:NO]];
        
        self.selectedCell = GAME_SELECTED_CELL_INVALID;
        self.selectedCell = point;
    }
}

- (BOOL)canModifyCell:(CGPoint)point {
    return (point.x >= 0 && point.x < self.state.gridSize && point.y >= 0 && point.y < self.state.gridSize);
}

#pragma mark - PuzzleStateDelegate
- (void)puzzleState:(PuzzleState *)state stateChanged:(NSArray *)args {
    if (state.status == PuzzleStatusSolved) {
        // TODO: Sudoku Solved.
        if ([self.delegate respondsToSelector:@selector(game:didFinishAndIsWinning:)]) {
            [self.delegate game:self didFinishAndIsWinning:YES];
        }
    }
    
//    self.gameNotes = nil;
}

#pragma mark Public

- (void)showSuggestedCell {
    if (self.wrongCellsSet.count > 0) {
        self.selectedCell = [self.wrongCellsSet.allObjects.lastObject CGPointValue];
        return;
    }
    if (CGPointEqualToPoint(self.selectedCell, GAME_SELECTED_CELL_INVALID)) {
        self.selectedCell = CGPointZero;
    } else {
        BOOL isStop = NO;
        for (Byte row = self.selectedCell.x; row < self.state.gridSize && !isStop; ++row) {
            for (Byte col = 0; col < self.state.gridSize && !isStop; ++col) {
                if (row == self.selectedCell.x && col <= self.selectedCell.y) {
                    continue;
                }
                id cellValue = [self.state cellValueAtX:row y:col];
                if (![cellValue isKindOfClass:[NSNumber class]]) {
                    self.selectedCell = ccp(row, col);
                    isStop = YES;
                    break;
                }
            }
        }
    }
}

- (void)clickFunction:(ControlButtonFunction)function {
    if (self.isPuzzleSolving) {
        return;
    }
    switch (function) {
        case ControlButtonFunctionSolve:
            [self trySolve];
            break;
        case ControlButtonFunctionNew:
            [self newPuzzle];
            break;
        default:
            if (!self.isPuzzleSolved) {
                [super clickFunction:function];
            }
            break;
    }
}

- (void)updateCellAtRow:(NSInteger)row col:(NSInteger)col {
    if ([self.delegate respondsToSelector:@selector(game:updatePenAtRow:col:label:color:)]) {
        NSString *label = [self labelWithRow:row col:col];
        CCColor *color = [self colorWithRow:row col:col];
        [self.delegate game:self updatePenAtRow:row col:col label:label color:color];
    }
}

- (void)trySolve {
    if (self.isPuzzleSolved) {
        return;
    }
    if (self.wrongCellsSet.count > 0) {
        // Still wrong cells to correct
        self.selectedCell = [self.wrongCellsSet.allObjects.lastObject CGPointValue];
        [self delegateShowMessage:MSG_WRONG_CELLS_TO_CORRECT];
    } else {
        self.isPuzzleSolving = YES;
        [self delegateShowMessage:MSG_SOLVING_PUZZLE];
        dispatch_queue_t queue = dispatch_queue_create("com.xj.solvingPuzzle", NULL);
        dispatch_async(queue, ^{
            COUNTER_START();
            SolverOptions *solverOptions = [SolverOptions options];
            solverOptions.maximumSolutionsToFind = @2;
            solverOptions.eliminationTechniques = @[[NakedSingleTechnique technique]];
            solverOptions.isAllowBruteForce = YES;
            SolverResults *newSolution = [Solver solveState:self.state options:solverOptions];
            CCLOG(@"newSolution.puzzles = %@", newSolution.puzzles);
            COUNTER_END();
            self.originalState = self.state;
            self.state = newSolution.puzzle;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.isPuzzleSolving = NO;
                self.isPuzzleSolved = YES;
                
                self.selectedCell = GAME_SELECTED_CELL_INVALID;
                
                [self updateAllGrid];
            });
        });
    }
}

- (void)newPuzzle {
    if (self.isPuzzleSolving) {
        return;
    }
    self.state = nil;
    self.originalState = nil;
    self.isPuzzleSolved = NO;
    
    [self updateAllGrid];
    
    [self showSuggestedCell];
}

- (void)delegateShowMessage:(NSString *)msg {
    if ([self.delegate respondsToSelector:@selector(solverGame:showMessage:)]) {
        [self.delegate solverGame:self showMessage:msg];
    }
}

#pragma mark - Helper

- (CCColor *)colorWithRow:(NSInteger)row col:(NSInteger)col {
    if (self.isPuzzleSolved) {
        return [super colorWithRow:row col:col];
    }
    CCColor *color = self.options.userValueColor;
    id cellValue = [self.state cellValueAtX:row y:col];
    BOOL isCellWrong = NO;
    if ([cellValue isKindOfClass:[NSNumber class]]) {
        NSArray *array = [self pointsRelativeWithPoint:ccp(row, col) isOriginalPointExclusive:YES];
        for (NSValue *pvalue in array) {
            CGPoint point = [pvalue CGPointValue];
            id anotherCellValue = [self.state cellValueAtPoint:point];
            if ([anotherCellValue isKindOfClass:[NSNumber class]]) {
                if ([anotherCellValue unsignedCharValue] == [cellValue unsignedCharValue]) {
                    // Wrong number
                    color = self.options.incorrectNoteValueColor;
                    isCellWrong = YES;
                    break;
                }
            }
        }
    }
    id cell = [NSValue valueWithCGPoint:ccp(row, col)];
    if (isCellWrong) {
        [self.wrongCellsSet addObject:cell];
    } else {
        [self.wrongCellsSet removeObject:cell];
    }
    return color;
}

@end
