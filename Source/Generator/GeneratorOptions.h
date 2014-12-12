//
//  GeneratorOptions.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

// Options used for generating puzzles.
@interface GeneratorOptions : NSObject {
    PuzzleDifficulty            _difficulty; // Perceived difficulty of the puzzle.
    NSInteger                   _minimumFilledCells; // The minimum number of filled cells in the generated puzzle.
    Byte                        _size; // The size of the puzzle to be generated.
    NSNumber                *   _maximumNumberOfDecisionPoints; // The maximum number of times brute-force techniques can be used in solving the puzzle.
    NSInteger                   _numberOfPuzzles; // The number of puzzles to generate in order to pick the best of the lot.
    NSArray                 *   _eliminationTechniques; // Techniques allowed to be used in the generation of puzzles.
    BOOL                        _isEnsureSymmetry; // Whether only symmetrical puzzles should be generated.
}
+ (instancetype)createWithDifficulty:(PuzzleDifficulty)diff;

@property(nonatomic, readonly) NSInteger                   minimumFilledCells;
@property(nonatomic, readonly) Byte                        size;
@property(nonatomic, readonly) NSNumber                *   maximumNumberOfDecisionPoints;
@property(nonatomic, readonly) NSInteger                   numberOfPuzzles;
@property(nonatomic, readonly) NSArray                 *   techniques;
@property(nonatomic, assign)   BOOL                        isEnsureSymmetry;
@property(nonatomic, readonly) PuzzleDifficulty            difficulty;
@end
