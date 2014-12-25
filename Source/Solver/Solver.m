//
//  Solver.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Solver.h"
#import "PuzzleState.h"
#import "SolverOptions.h"
#import "SolverResults.h"
#import "GeneratorOptions.h"
#import "NakedSingleTechnique.h"
#import "FastBitArray.h"

@interface Solver ()

@end

/// <summary>Attempts to solve a Sudoku puzzle.</summary>
/// <param name="state">The state of the puzzle to be solved.</param>
/// <param name="options">Options to use for solving.</param>
/// <returns>The result of the solve attempt.</returns>
/// <remarks>No changes are made to the parameter state.</remarks>
static SolverResults *SolveInternal(PuzzleState *state, SolverOptions *options);

/// <summary>Uses brute-force search techniques to solve the puzzle.</summary>
/// <param name="state">The state to be solved.</param>
/// <param name="options">The options to use in solving.</param>
/// <param name="possibleNumbers">The possible numbers off of which to base the search.</param>
/// <returns>The result of the solve attempt.</returns>
/// <remarks>Changes may be made to the parameter state.</remarks>
static SolverResults *BruteForceSolve(PuzzleState *state, SolverOptions *options, NSArray *possibleNumbers); // FastBitArray [][]

/// <summary>Combines an incremental usage table into the total usage table.</summary>
/// <param name="totalTable">The total table.</param>
/// <param name="incrementalTable">The incremental table.</param>
static void AddTechniqueUsageTables(NSMutableDictionary *totalTable, NSDictionary *incrementalTable);

/// <summary>Attempts to fill one square in the Sudoku puzzle, based purely on logic and elimination techniques.</summary>
/// <param name="state">The state to be augmented.</param>
/// <param name="techniques">The techniques to use for number elimination.</param>
/// <param name="totalUseOfTechniques">The total usage of each technique.</param>
/// <returns>The current set of possible numbers for each cell.</returns>
/// <remarks>Changes may be made to the parameter state.</remarks>
static NSArray *FillCellsWithSolePossibleNumber(PuzzleState *state, NSArray *techniques, NSMutableDictionary **totalUseOfTechniques);

@implementation Solver

+ (PuzzleDifficulty)evaluateDifficulty:(PuzzleState *)state {
    NSAssert(state != nil, @"state is nil");
    
    SolverOptions *options = [[SolverOptions alloc] init];
    for (NSNumber *diff in @[@(PuzzleDifficultyEasy), @(PuzzleDifficultyMedium), @(PuzzleDifficultyHard)]) {
        GeneratorOptions *go = [GeneratorOptions createWithDifficulty:[diff integerValue]];
        if (state.numberOfFilledCells < go.minimumFilledCells) {
            continue;
        }
        
        options.isAllowBruteForce = !go.maximumNumberOfDecisionPoints;
        options.eliminationTechniques = go.techniques;
        options.maximumSolutionsToFind = options.isAllowBruteForce ? @2u : @1u;
        SolverResults *results = [[self class] solveState:state options:options];
        if (results.status == PuzzleStatusSolved && [results.puzzles count] == 1) {
            return [diff integerValue];
        }
    }
    return PuzzleDifficultyInvalid;
}

+ (SolverResults *)solveState:(PuzzleState *)state options:(SolverOptions *)options {
    // Validate parameters
    NSAssert(state != nil, @"state");
    NSAssert(options != nil, @"options");
    
    BOOL isAddedTechnique = NO;
    if ([options.eliminationTechniques count] == 0) {
        options.eliminationTechniques = @[[[NakedSingleTechnique alloc] init]];
        isAddedTechnique = YES;
    }
    
    // Turn off the raising of changed events while solving,
    // though it probably doesn't matter as the first thing
    // SolveInternal does is make a clone, and RaiseStateChangedEvent
    // is not cloned (on purpose).
    BOOL isRaiseChangedEvent = state.isRaiseStateChangedEvent;
    state.isRaiseStateChangedEvent = NO;
    
    // Attempt to solve the puzzle
    SolverResults *results = SolveInternal(state, options);
    
    // Reset whether changed events should be raised
    state.isRaiseStateChangedEvent = isRaiseChangedEvent;
    
    if (isAddedTechnique) {
        options.eliminationTechniques = @[];
    }
    
    // Return the solver results
    return results;
}
@end

static SolverResults *SolveInternal(PuzzleState *state, SolverOptions *options) {
    // First, make a copy of the state and work on that copy.  That way, the original
    // instance passed to us by the client remains unmodified.
    
    state = [state copy];
    
    // Fill cells using logic and analysis techniques until no more
    // can be filled.
    NSMutableDictionary *totalUseOfTechniques = [NSMutableDictionary dictionary];
    NSArray *possibleNumbers = FillCellsWithSolePossibleNumber(state, options.eliminationTechniques, &totalUseOfTechniques);
    
    // Analyze the current state of the board
    switch (state.status) {
        // If the puzzle is now solved, return it. If the puzzle is in an inconsistent state (such as
        // two of the same number in the same row), return that also, as there's nothing more to be done.
        case PuzzleStatusSolved:
        case PuzzleStatusCannotBeSolved:
            return [SolverResults resultsWithStatus:state.status state:state numberOfDecisionPoints:0 useOfTechniques:totalUseOfTechniques];
            break;
            // If the puzzle is still in progress, it means no more cells
            // can be filled by elimination alone, so do a brute-force step.
            // BruteForceSolve recursively calls back to this method.
        default:
            if (options.isAllowBruteForce) {
                SolverResults *results = BruteForceSolve(state, options, possibleNumbers);
                if (results.status == PuzzleStatusSolved) {
                    AddTechniqueUsageTables(results.useOfTechniques, totalUseOfTechniques);
                }
                return results;
            } else {
                return [SolverResults resultsWithStatus:PuzzleStatusCannotBeSolved state:state numberOfDecisionPoints:0 useOfTechniques:nil];
            }
            break;
    }
}

static SolverResults *BruteForceSolve(PuzzleState *state, SolverOptions *options, NSArray *possibleNumbers) {
    // A standard brute-force search would take much too long to solve a Sudoku puzzle.
    // Fortunately, there are ways to significantly trim the search tree to a point where
    // brute-force is not only possible, but also more efficient.  The idea is that not every number
    // can be put into every cell.  In fact, using elimination techniques, you can narrow down the list
    // of numbers for each cell, such that only those need be are tried.  Moreover, every time a new number
    // is entered into a cell, other cell's possible numbers decrease.  It's in your best interest
    // to start the search with a cell that has the least possible number of options, thereby increasing
    // your chances of "guessing" the right number sooner.  To this end, you find the cell in the grid
    // that is empty and that has the least number of possible numbers that can go in it.  If there is more
    // than one cell with the same number of possibilities, you choose randomly among them. This random
    // choice allows the solver to be used for puzzle generation.
    NSMutableArray *bestGuessCells = [NSMutableArray array];
    Byte bestNumberOfPossibilities = state.gridSize + 1;
    for (Byte i = 0; i < state.gridSize; ++i) {
        for (Byte j = 0; j < state.gridSize; ++j) {
            NSInteger count = ((FastBitArray *)possibleNumbers[i][j]).countSet;
            if (![[state cellValueAtX:i y:j] isKindOfClass:[NSNumber class]]) {
                if (count < bestNumberOfPossibilities) {
                    bestNumberOfPossibilities = count;
                    [bestGuessCells removeAllObjects];
                    [bestGuessCells addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
                } else if (count == bestNumberOfPossibilities) {
                    [bestGuessCells addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
                }
            }
        }
    }
    
    // If there are no cells available to fill, there is nothing you can do
    // to make forward progress.  If there are cells available, which should
    // always be the case when this method is called, go through each of the possible
    // numbers in the cell and try to solve the puzzle with that number in it.
    SolverResults *results = nil;
    if ([bestGuessCells count] > 0) {
        // Choose a random cell from amongst the possibilities found above
        CGPoint bestGuessCell = [(NSValue *)bestGuessCells[arc4random_uniform((u_int32_t)[bestGuessCells count])] CGPointValue];
        
        // Get the possible numbers for that cell.  For each possible number,
        // fill that number into the cell and recursively call to Solve.
        FastBitArray *possibleNumbersForBestCell = (FastBitArray *)possibleNumbers[(int)(bestGuessCell.x)][(int)(bestGuessCell.y)];
        for (Byte p = 0; p < possibleNumbersForBestCell.length; ++p) {
            if ([possibleNumbersForBestCell valueAtIndex:p]) {
                PuzzleState *newState = state;
                
                // Fill in the cell and solve the puzzle
                [newState setCellValue:@(p) atPoint:bestGuessCell];
//                [newState setCellValue:@(p) atX:(int)(bestGuessCell.x) y:(int)(bestGuessCell.y)];
                SolverOptions *tempOptions = [options copy];
                if (results != nil) {
                    tempOptions.maximumSolutionsToFind = @((NSUInteger)([tempOptions.maximumSolutionsToFind unsignedIntegerValue] - [results.puzzles count]));
                }
                SolverResults *tempResults = SolveInternal(newState, tempOptions);
                
                // If it could be solved, update information about the solving process
                // and return the solution.  Only if the user wants to find multiple
                // solutions will the search continue.
                if (tempResults.status == PuzzleStatusSolved) {
                    if (results != nil && [results.puzzles count] > 0) {
                        [results.puzzles addObjectsFromArray:tempResults.puzzles];
                    } else {
                        results = tempResults;
                        results.numberOfDecisionPoints++;
                    }
                    if ([options.maximumSolutionsToFind isKindOfClass:[NSNumber class]] && [results.puzzles count] >= [options.maximumSolutionsToFind unsignedIntegerValue]) {
                        return results;
                    }
                }
                
                // If you are not cloning, you need to cancel out the change
                [newState setCellValue:nil atX:(int)(bestGuessCell.x) y:(int)(bestGuessCell.y)];
            }
        }
    }
    
    // You will get here if the requested number of solutions could not be found, or if no
    // solutions at all could be found.  Either return a solution if you did get at least one,
    // or return that none could be found.
    return results != nil ? results : [SolverResults resultsWithStatus:PuzzleStatusCannotBeSolved state:state numberOfDecisionPoints:0 useOfTechniques:nil];
}

static void AddTechniqueUsageTables(NSMutableDictionary *totalTable, NSDictionary *incrementalTable) {
    if (totalTable != nil && incrementalTable != nil) {
        [incrementalTable enumerateKeysAndObjectsUsingBlock:^(id key, NSNumber *obj, BOOL *stop) {
            NSNumber *value = totalTable[key];
            totalTable[key] = value != nil ? @([value integerValue] + [obj integerValue]) : obj;
        }];
    }
}

static NSArray *FillCellsWithSolePossibleNumber(PuzzleState *state, NSArray *techniques, NSMutableDictionary **totalUseOfTechniques) {
    NSMutableArray *possibleNumbers = [PuzzleState instantiatePossibleNumbersArrayWithState:state];
    BOOL isMoreToDo;
    do {
        isMoreToDo = NO;
        Byte gridSize = state.gridSize;
        [state computePossibleNumbersWithTechniques:techniques usesOfTechnique:totalUseOfTechniques isOnlyOnePass:NO isEarlyExitWhenSoleFound:NO possibleNumbers:possibleNumbers];
        
        for (Byte i = 0; i < gridSize; ++i) {
            for (Byte j = 0; j < gridSize; ++j) {
                if (![[state cellValueAtX:i y:j] isKindOfClass:[NSNumber class]] && ((FastBitArray *)possibleNumbers[i][j]).countSet == 1) {
                    for (Byte n = 0; n < gridSize; ++n) {
                        if ([((FastBitArray *)possibleNumbers[i][j]) valueAtIndex:n]) {
                            [state setCellValue:@(n) atX:i y:j];
                            isMoreToDo = YES;
                            break;
                        }
                    }
                }
            }
        }
    } while (isMoreToDo);
    return possibleNumbers;
}

