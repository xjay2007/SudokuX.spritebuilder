//
//  EliminationTechnique.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PuzzleState, FastBitArray;

// Base type used for eliminating possible numbers from cells in a puzzle state.
@interface EliminationTechnique : NSObject <NSCopying> {
}

+ (instancetype)technique;

// Gets a collection containing an instance of each available technique.
+ (NSArray *)availableTechniques;

// Gets the difficulty level of this technique.
@property (nonatomic, readonly) NSUInteger          difficultyLevel;

/// <summary>Runs this elimination technique over the supplied puzzle state and previously computed possible numbers.</summary>
/// <param name="state">The puzzle state.</param>
/// <param name="exitEarlyWhenSoleFound">Whether the method can exit early when a cell with only one possible number is found.</param>
/// <param name="possibleNumbers">The previously computed possible numbers.</param>
/// <param name="numberOfChanges">The number of changes made by this elimination technique.</param>
/// <param name="exitedEarly">Whether the method exited early due to a cell with only one value being found.</param>
/// <returns>Whether more changes may be possible based on changes made during this execution.</returns>
- (BOOL)            execute:(PuzzleState *)state
   isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
            possibleNumbers:(NSArray *)possibleNumbers // FastBitArray[][]
            numberOfChanges:(NSInteger *)numberOfChanges
              isExitedEarly:(BOOL *)isExitedEarly;

/// <summary>Gets an array of the possible number bit arrays for a given row in the puzzle state.</summary>
/// <param name="possibleNumbers">The possible numbers.</param>
/// <param name="row">The row.</param>
/// <param name="target">The array to store the output.</param>
+ (void)getRowPossibleNumbers:(NSArray *) possibleNumbers // FastBitArray[][]
                          row:(NSInteger)row
                       target:(NSMutableArray *)target; // FastBitArray[]
+ (void)getColumnPossibleNumbers:(NSArray *) possibleNumbers // FastBitArray[][]
                          column:(NSInteger)column
                          target:(NSMutableArray *)target; // FastBitArray[]

/// <summary>Gets an array of the possible number bit arrays for a given box in the puzzle state.</summary>
/// <param name="state">The puzzle state.</param>
/// <param name="possibleNumbers">The possible numbers.</param>
/// <param name="box">The box.</param>
/// <param name="target">The array to store the output.</param>
+ (void)getBoxPossibleNumbers:(PuzzleState *)state
              possibleNumbers:(NSArray *)possibleNumbers // FastBitArray[][]
                          box:(NSInteger)box
                       target:(NSMutableArray *)target; // FastBitArray[]
+ (NSInteger)boxNumberWithBoxSize:(NSInteger)boxSize atRow:(NSInteger)row column:(NSInteger)column;
+ (BOOL)isAllAreSetInNumbers:(NSArray *)numbers // NSInteger[]
                       array:(FastBitArray *)array;
+ (BOOL)isAnyAreSetInNumbers:(NSArray *)numbers // NSInteger[]
                       array:(FastBitArray *)array;
@end
