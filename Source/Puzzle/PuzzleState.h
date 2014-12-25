//
//  PuzzleState.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PuzzleState;
@protocol PuzzleStateDelegate <NSObject>

- (void)puzzleState:(PuzzleState *)state stateChanged:(NSArray *)args;

@end

@interface PuzzleState : NSObject <NSCopying> {
    NSMutableArray      *   _grid; // The state of each cell in the puzzle. NSNumber[][], numberWithUnsignedChar
    PuzzleDifficulty        _difficulty;
    id                      _tag;
    
    NSNumber            *   _filledCells; // The number of cells currently filled in the puzzle.
    PuzzleStatus            _status; // The puzzle's current status.  Invalidated every time the puzzle is changed.
    
    void                    (^_stateChanged)(NSArray *args); // Event raised when a cell in the grid changes its contained value.
    BOOL                    _isRaiseStateChangedEvent; // Whether to raise state changed events.
}
@property (nonatomic, readonly) Byte                boxSize; // The size of each box in the puzzle
@property (nonatomic, readonly) Byte                gridSize; // The size of the entire puzzle.
@property (nonatomic, assign)   PuzzleDifficulty    difficulty;
@property (nonatomic, readonly) PuzzleStatus        status;
@property (nonatomic, strong)   id                  tag;
@property (nonatomic, weak) id<PuzzleStateDelegate> delegate;
@property (nonatomic, assign)   BOOL                isRaiseStateChangedEvent;
@property (nonatomic, readonly) NSInteger           numberOfFilledCells;

@property (nonatomic, readonly) NSArray         *   gridArray;
@property (nonatomic, readonly) NSEnumerator    *   enumerator;

@property (nonatomic, readonly) NSString        *   gridString;

+ (instancetype)state;
+ (instancetype)stateWithBoxSize:(Byte)boxSize;
- (instancetype)init;
- (instancetype)initWithBoxSize:(Byte)boxSize;

- (id)cellValueAtX:(NSInteger)x y:(NSInteger)y;
- (void)setCellValue:(id)value atX:(NSInteger)x y:(NSInteger)y;
- (id)cellValueAtPoint:(CGPoint)point;
- (void)setCellValue:(id)value atPoint:(CGPoint)point;

+ (NSMutableArray *)instantiatePossibleNumbersArrayWithState:(PuzzleState *)state;

/// <summary>Determines what numbers are possible in each of the cells in the state.</summary>
/// <param name="state">The puzzle state to analyze.</param>
/// <param name="techniques">The techniques to use for this elimination process.</param>
/// <param name="onlyOnePass">
/// Whether only one pass should be made through each technique, or whether it should repeat all techniques
/// as long as any technique made any changes.
/// </param>
/// <param name="usesOfTechnique">How much each of the techniques was used.</param>
/// <param name="possibleNumbers">The possible numbers used for this computation.</param>
/// <returns>The computed possible numbers.</returns>
- (NSArray *)computePossibleNumbersWithTechniques:(NSArray *)techniques
                                  usesOfTechnique:(NSMutableDictionary **)usesOfTechnique // HashTable
                                    isOnlyOnePass:(BOOL)isOnlyOnePass
                         isEarlyExitWhenSoleFound:(BOOL)isEarlyExitWhenSoleFound
                                  possibleNumbers:(NSArray *)possibleNumbers;
@end
