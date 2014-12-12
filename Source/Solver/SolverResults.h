//
//  SolverResults.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PuzzleState;

// Represents the results from attempting to solve a Sudoku puzzle.
@interface SolverResults : NSObject {
    // The status of the result.
    PuzzleStatus                    _status;
    // The puzzle states returned from the solver, containing at least one valid solution if status is PuzzleStatus.Solved.
    NSMutableArray              *   _puzzles; // PuzzleState[]
    // The number of decision points involved in finding the solution.  This is the number
    // of times that the solver had to use brute-force methods to make progress.
    NSInteger                       _numberOfDecisionPoints;
    
    // The use of each elimination technique.
    NSMutableDictionary         *   _useOfTechniques; // HashTable
}
@property (nonatomic, readonly) PuzzleStatus            status;
@property (nonatomic, readonly) PuzzleState         *   puzzle;
@property (nonatomic, readonly) NSMutableArray      *   puzzles;
@property (nonatomic, assign)   NSInteger               numberOfDecisionPoints;
@property (nonatomic, readonly) NSMutableDictionary *   useOfTechniques;


+ (instancetype)resultsWithStatus:(PuzzleStatus)status
                            state:(PuzzleState *)state
           numberOfDecisionPoints:(NSInteger)numberOfDecisionPoints
                  useOfTechniques:(NSDictionary *)useOfTechniques;
- (instancetype)initWithStatus:(PuzzleStatus)status
                         state:(PuzzleState *)state
        numberOfDecisionPoints:(NSInteger)numberOfDecisionPoints
               useOfTechniques:(NSDictionary *)useOfTechniques;
@end