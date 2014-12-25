//
//  SolverOptions.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

// Options for configuring how the solver does its processing.
@interface SolverOptions : NSObject <NSCopying> {
    NSNumber        *   _maximumSolutionsToFind;
    NSArray         *   _techniques;
    BOOL                _isAllowBruteForce;
}
// The maximum number of solutions the solver should find.
@property (nonatomic, copy) NSNumber          *   maximumSolutionsToFind; // numberWithUnsignedInteger
// The techniques to use while solving.
@property (nonatomic, copy) NSArray           *   eliminationTechniques; // EliminationTechnique[]
// Whether to allow brute-force techniques in the solver.
@property (nonatomic, assign) BOOL                  isAllowBruteForce;

+ (instancetype)options;
@end
