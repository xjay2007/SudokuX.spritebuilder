//
//  Solver.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PuzzleState, SolverResults, SolverOptions;

// Analyzes and solves Sudoku puzzles.
@interface Solver : NSObject

/// <summary>Evaluates the difficulty level of a particular puzzle.</summary>
/// <param name="state">The puzzle to evaluate.</param>
/// <returns>The perceived difficulty level of the puzzle.</returns>
+ (PuzzleDifficulty)evaluateDifficulty:(PuzzleState *)state;

/// <summary>Attempts to solve a Sudoku puzzle.</summary>
/// <param name="state">The state of the puzzle to be solved.</param>
/// <param name="options">Options to use for solving.</param>
/// <returns>The result of the solve attempt.</returns>
/// <remarks>No changes are made to the parameter state.</remarks>
+ (SolverResults *)solveState:(PuzzleState *)state options:(SolverOptions *)options;
@end
