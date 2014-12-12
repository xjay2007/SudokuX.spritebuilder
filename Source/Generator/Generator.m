//
//  Generator.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-8.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Generator.h"
#import "GeneratorOptions.h"
#import "PuzzleState.h"
#import "SolverResults.h"
#import "SolverOptions.h"
#import "Solver.h"
#import "NakedSingleTechnique.h"

@interface Generator ()
- (PuzzleState *)generateInternal;
/// <summary>Generates a random Sudoku puzzle.</summary>
/// <returns>The generated results.</returns>
- (SolverResults *)generateOne;

/// <summary>Returns all cells in a collection in random order.</summary>
/// <param name="state">The puzzle state.</param>
/// <returns>The collection of cells.</returns>
+ (NSMutableArray *)getRandomCellOrderingWithState:(PuzzleState *)state; // @return [NSValue valueWithCGPoint][]

/// <summary>
/// Based on the specified GeneratorOptions, determines whether the SolverResults
/// created by solving a puzzle with a particular cell value removed represents a valid
/// new state.
/// </summary>
/// <param name="state">The puzzle state being validated.</param>
/// <param name="results">The SolverResults to be verified.</param>
/// <returns>true if the removal that led to this call is valid; otherwise, false.</returns>
- (BOOL)isValidRemovalWithState:(PuzzleState *)state solverResults:(SolverResults *)results;
@property (nonatomic, strong) GeneratorOptions  *   options;
@end

@implementation Generator

+ (instancetype)generatorWithOptions:(GeneratorOptions *)options {
    return [[Generator alloc] initWithOptions:options];
}
- (instancetype)initWithOptions:(GeneratorOptions *)options {
    self = [super init];
    if (self) {
        if (options == nil) {
            options = [GeneratorOptions createWithDifficulty:PuzzleDifficultyEasy];
        }
        NSAssert(options.numberOfPuzzles >= 1, @"options");
        _options = options;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithOptions:nil];
}

- (PuzzleState *)generate {
    return [self generateInternal];
}
- (PuzzleState *)generateInternal {
    // Generate the number of puzzles specified in the options and sort them by difficulty
    NSMutableArray *puzzles = [NSMutableArray array];
    for (NSInteger i = 0; i < self.options.numberOfPuzzles; ++i) {
        [puzzles addObject:[self generateOne]];
    }
    
    // Find the hardest puzzle from those generated and return it.
    // NOTE: The puzzle may be easier than the numbers in the SolverResults
    // would otherwise indicate.  The generator runs each technique as much as possible
    // before filling in a number, but filling in a number can actually make the puzzle
    // solvable with fewer techniques.
    [puzzles sortUsingComparator:^NSComparisonResult(SolverResults *first, SolverResults *second) {
        if ([first isEqual:second]) {
            return NSOrderedSame;
        } else if (first == nil) {
            return NSOrderedAscending;
        } else if (second == nil) {
            return NSOrderedDescending;
        } else {
            // First compare by number of decisions points
            NSInteger diff = first.numberOfDecisionPoints - second.numberOfDecisionPoints;
            if (diff != 0) {
                return diff / ABS(diff);
            }
            
            // Then compare each by technique, starting with the most difficult.
            NSArray *techniques = self.options.techniques;
            for (NSInteger i = [techniques count] - 1; i >= 0; --i) {
                NSNumber *firstUse = first.useOfTechniques[techniques[i]];
                NSNumber *secondUse = second.useOfTechniques[techniques[i]];
                if (firstUse != nil && secondUse != nil) {
                    diff = [firstUse integerValue] - [secondUse integerValue];
                    if (diff != 0) {
                        return diff / ABS(diff);
                    }
                } else if (firstUse != nil) {
                    return NSOrderedDescending;
                } else if (secondUse != nil) {
                    return NSOrderedAscending;
                }
            }
        }
        // SolverResults are equal if they have the exact same number of decision points
        // and usage of each technique.
        return NSOrderedSame;
    }];
    
    return ((SolverResults *)[puzzles lastObject]).puzzle;
}

- (SolverResults *)generateOne {
    
    // Generate a full solution randomly, using the solver to solve a completely empty grid.
    // For this, we'll use the elimination techniques that yield fast solving.
    PuzzleState *solvedState = [PuzzleState stateWithBoxSize:self.options.size];
    SolverOptions *solverOptions = [[SolverOptions alloc] init];
    solverOptions.maximumSolutionsToFind = @1;
    solverOptions.eliminationTechniques = @[[NakedSingleTechnique technique]];
    solverOptions.isAllowBruteForce = YES;
    SolverResults *newSolution = [Solver solveState:solvedState options:solverOptions];
    
    // Create options to use for removing filled cells from the complete solution.
    // MaximumSolutionsToFind is set to 2 so that we look for more than 1, but there's no
    // need in continuing once we know there's more than 1, so 2 is a find value to use.
    solverOptions.maximumSolutionsToFind = @2;
    solverOptions.isAllowBruteForce = ![self.options.maximumNumberOfDecisionPoints isKindOfClass:[NSNumber class]] || [self.options.maximumNumberOfDecisionPoints integerValue] > 0;
    solverOptions.eliminationTechniques = solverOptions.isAllowBruteForce ? @[[NakedSingleTechnique technique]] : self.options.techniques;
    
    // Now that we have a full solution, we want to randomly remove values from cells
    // until we get to a point where there is not a unique solution for the puzzle.  The
    // last puzzle state that did have a unique solution can then be used.
    PuzzleState *newPuzzle = newSolution.puzzle;
    
    // Get a random ordering of the cells in which to test their removal
    NSMutableArray *filledCells = [Generator getRandomCellOrderingWithState:newPuzzle];
    
    // Do we want to ensure symmetry?
    NSInteger filledCellCount = (self.options.isEnsureSymmetry && ([filledCells count] % 2 != 0)) ? ([filledCells count] - 1) : [filledCells count];
    if (self.options.isEnsureSymmetry) {
        // Find the middle cell and put it at the end of the ordering
        for (NSInteger i = 0; i < [filledCells count] - 1; ++i) {
            CGPoint p = [(NSNumber *)(filledCells[i]) CGPointValue];
            NSInteger px = p.x;
            NSInteger py = p.y;
            if (px == newPuzzle.gridSize - px - 1 &&
                py == newPuzzle.gridSize - py - 1) {
                [filledCells exchangeObjectAtIndex:i withObjectAtIndex:[filledCells count] - 1];
            }
        }
        
        // Modify the random ordering so that paired symmetric cells are next to each other
        // i.e. filledCells[i] and filledCells[i+1] are symmetric pairs
        for (NSInteger i = 0; i < [filledCells count] - 1; i += 2) {
            CGPoint p = [(NSNumber *)(filledCells[i]) CGPointValue];
            NSInteger spx = newPuzzle.gridSize - (NSInteger)(p.x) - 1;
            NSInteger spy = newPuzzle.gridSize - (NSInteger)(p.y) - 1;
            for (NSInteger j = i + 1; j < [filledCells count]; ++j) {
                CGPoint pj = [(NSNumber *)(filledCells[j]) CGPointValue];
                NSInteger pjx = pj.x;
                NSInteger pjy = pj.y;
                if (pjx == spx && pjy == spy) {
                    [filledCells exchangeObjectAtIndex:i+1 withObjectAtIndex:j];
                    break;
                }
            }
        }
        
        // In the order of the array, try to remove each pair from the puzzle and see if it's
        // still solvable and in a valid way.  If it is, greedily leave those cells out of the puzzle.
        // Otherwise, skip them.
        id oldValues[2] = {0};
        for (NSInteger filledCellNum = 0; filledCellNum < filledCellCount && newPuzzle.numberOfFilledCells > self.options.minimumFilledCells; filledCellNum += 2) {
            // Store the old value so we can put it back if necessary,
            // then wipe it out of the cell
            CGPoint p1 = [(NSNumber *)(filledCells[filledCellNum]) CGPointValue];
            CGPoint p2 = [(NSNumber *)(filledCells[filledCellNum + 1]) CGPointValue];
            oldValues[0] = [newPuzzle cellValueAtPoint:p1];
            oldValues[1] = [newPuzzle cellValueAtPoint:p2];
            [newPuzzle setCellValue:nil atPoint:p1];
            [newPuzzle setCellValue:nil atPoint:p2];
            
            // Check to see whether removing it left us in a good position (i.e. a
            // single-solution puzzle that doesn't violate any of the generation options)
            SolverResults *newResults = [Solver solveState:newPuzzle options:solverOptions];
            if (![self isValidRemovalWithState:newPuzzle solverResults:newResults]) {
                [newPuzzle setCellValue:oldValues[0] atPoint:p1];
                [newPuzzle setCellValue:oldValues[1] atPoint:p2];
            }
        }
        
        // If there are an odd number of cells in the puzzle (which there will be
        // as everything we're doing is 9x9, 81 cells), try to remove the odd
        // cell that doesn't have a pairing.  This will be the middle cell.
        if ([filledCells count] % 2 != 0) {
            // Store the old value so we can put it back if necessary,
            // then wipe it out of the cell
            NSInteger filledCellNum = [filledCells count] - 1;
            CGPoint p1 = [(NSNumber *)(filledCells[filledCellNum]) CGPointValue];
            id oldValue = [newPuzzle cellValueAtPoint:p1];
            [newPuzzle setCellValue:nil atPoint:p1];
            
            // Check to see whether removing it left us in a good position (i.e. a
            // single-solution puzzle that doesn't violate any of the generation options)
            SolverResults *newResults = [Solver solveState:newPuzzle options:solverOptions];
            if (![self isValidRemovalWithState:newPuzzle solverResults:newResults]) {
                [newPuzzle setCellValue:oldValue atPoint:p1];
            }
        }
    }
    // otherwise, it's much easier
    else {
        // Look at each cell in the random ordering.  Try to remove it.
        // If it works to remove it, do so greedily.  Otherwise, skip it.
        for (NSInteger filledCellNum = 0; filledCellNum < filledCellCount && newPuzzle.numberOfFilledCells > self.options.minimumFilledCells; ++filledCellNum) {
            // Store the old value so we can put it back if necessary,
            // then wipe it out of the cell
            CGPoint p1 = [(NSNumber *)(filledCells[filledCellNum]) CGPointValue];
            id oldValue = [newPuzzle cellValueAtPoint:p1];
            [newPuzzle setCellValue:nil atPoint:p1];
            
            // Check to see whether removing it left us in a good position (i.e. a
            // single-solution puzzle that doesn't violate any of the generation options)
            SolverResults *newResults = [Solver solveState:newPuzzle options:solverOptions];
            if (![self isValidRemovalWithState:newPuzzle solverResults:newResults]) {
                [newPuzzle setCellValue:oldValue atPoint:p1];
            }
        }
    }
    
    // Make sure to now use the techniques specified by the user to score this thing
    solverOptions.eliminationTechniques = self.options.techniques;
    SolverResults *finalResult = [Solver solveState:newPuzzle options:solverOptions];
    
    // Return the best puzzle we could come up with
    newPuzzle.difficulty = self.options.difficulty;
    return [SolverResults resultsWithStatus:PuzzleStatusSolved state:newPuzzle numberOfDecisionPoints:finalResult.numberOfDecisionPoints useOfTechniques:finalResult.useOfTechniques];
}

+ (NSMutableArray *)getRandomCellOrderingWithState:(PuzzleState *)state {
    // Create the collection
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:state.gridSize * state.gridSize];
    
    // Find all cells
    NSInteger count = 0;
    for (NSInteger i = 0; i < state.gridSize; ++i) {
        for (NSInteger j = 0; j < state.gridSize; ++j) {
            points[count++] = [NSValue valueWithCGPoint:CGPointMake(i, j)];
        }
    }
    
    // Randomize their order
    for (NSInteger i = 0; i < [points count] - 1; ++i) {
        NSInteger swapPos = arc4random_uniform((u_int32_t)([points count] - 1 - i)) + i;
        [points exchangeObjectAtIndex:i withObjectAtIndex:swapPos];
    }
    
    return points;
}

- (BOOL)isValidRemovalWithState:(PuzzleState *)state solverResults:(SolverResults *)results {
    // Make sure we have a puzzle with one and only one solution
    if (results.status != PuzzleStatusSolved || [results.puzzles count] != 1) {
        return NO;
    }
    
    // Make sure we don't have too few cells
    if (state.numberOfFilledCells < self.options.minimumFilledCells) {
        return NO;
    }
    
    // Now check to see if too many decision points were involved
    if ([self.options.maximumNumberOfDecisionPoints isKindOfClass:[NSNumber class]] &&
        results.numberOfDecisionPoints > [self.options.maximumNumberOfDecisionPoints integerValue]) {
        return NO;
    }
    
    // Otherwise, it's a valid removal.
    return YES;
}
@end



