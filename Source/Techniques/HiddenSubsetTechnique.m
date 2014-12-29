//
//  HiddenSubsetTechnique.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "HiddenSubsetTechnique.h"
#import "PuzzleState.h"
#import "FastBitArray.h"

@interface HiddenSubsetTechnique ()

/// <summary>Initialize the technique.</summary>
/// <param name="subsetSize">The size of the subset to evaluate.</param>
- (instancetype)initWithSubsetSize:(NSInteger)subsetSize;

/// <summary>Performs hidden subset elimination on one dimension of possible numbers.</summary>
/// <param name="possibleNumbers">The row/column/box to analyze.</param>
/// <returns>The number of changes that were made to the possible numbers.</returns>
- (NSInteger)eliminateHiddenSubsets:(NSMutableArray *)possibleNumbers // FastBitArray []
           isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
                      isExitedEarly:(BOOL *)isExitedEarly;
@end

@implementation HiddenSubsetTechnique

- (instancetype)initWithSubsetSize:(NSInteger)subsetSize {
    NSAssert(subsetSize >= 2, @"subsetSize");
    self = [super init];
    if (self) {
        _subsetSize = subsetSize;
        _foundLocations = [[NSMutableArray alloc] initWithCapacity:subsetSize];
    }
    return self;
}

- (instancetype)init {
    return [self initWithSubsetSize:0];
}

- (NSInteger)eliminateHiddenSubsets:(NSMutableArray *)possibleNumbers // FastBitArray []
           isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
                      isExitedEarly:(BOOL *)isExitedEarly {
    NSInteger changesMade = 0;
    *isExitedEarly = NO;
    NSInteger numLocations;
    NSMutableArray *foundLocations = _foundLocations; // optimization, rather than allocating on each call
    
    // Begin looking at each cell in the row/column/box
    for (Byte i = 0; i < possibleNumbers.count; ++i) {
        // Only look at the cell if it has at least a subsetSize values set,
        // otherwise it can't be part of a hidden subset
        FastBitArray *fbaI = possibleNumbers[i];
        NSInteger numPossible = fbaI.countSet;
        if (numPossible >= _subsetSize) {
            // For each combination
            NSArray *bitsArray = fbaI.bitsArray;
            for (NSInteger combinationStartX = 0; combinationStartX < bitsArray.count - _subsetSize; ++combinationStartX) {
                NSArray *combination = [bitsArray subarrayWithRange:NSMakeRange(combinationStartX, _subsetSize)];
                // Find other cells that contain that same combination,
                // but only up to the subset size
                numLocations = 0;
                foundLocations[numLocations++] = @(i);
                for (Byte j = i + 1; j < possibleNumbers.count && numLocations < foundLocations.count; ++j) {
                    if ([EliminationTechnique isAllAreSetInNumbers:combination array:possibleNumbers[j]]) {
                        foundLocations[numLocations++] = @(j);
                    }
                }
                
                if (numLocations == foundLocations.count) {
                    BOOL isValidHidden = YES;
                    
                    // Make sure that none of the numbers appear in any other cell
                    for (Byte j = 0; j < possibleNumbers.count && isValidHidden; ++j) {
                        BOOL isFoundLocation = [foundLocations indexOfObject:@(j)] != NSNotFound;
                        if (!isFoundLocation && [EliminationTechnique isAnyAreSetInNumbers:combination array:possibleNumbers[j]]) {
                            isValidHidden = NO;
                            break;
                        }
                    }
                    
                    // If this is a valid hidden subset, eliminate all other numbers
                    // from each cell in the subset
                    if (isValidHidden) {
                        for (NSNumber *foundLoc in foundLocations) {
                            FastBitArray *possibleNumbersForLoc = possibleNumbers[[foundLoc unsignedCharValue]];
                            for (NSNumber *n in [possibleNumbersForLoc bitsArray]) {
                                if ([combination indexOfObject:n] == NSNotFound) {
                                    [possibleNumbersForLoc setValue:NO atIndex:[n unsignedCharValue]];
                                    changesMade++;
                                }
                            }
                            if (isExitEarlyWhenSoleFound &&
                                possibleNumbersForLoc.countSet == 1) {
                                *isExitedEarly = YES;
                                return changesMade;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    return changesMade;
}

- (BOOL)            execute:(PuzzleState *)state
   isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
            possibleNumbers:(NSArray *)possibleNumbers // FastBitArray[][]
            numberOfChanges:(NSInteger *)numberOfChanges
              isExitedEarly:(BOOL *)isExitedEarly {
    *numberOfChanges = 0;
    *isExitedEarly = NO;
    NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:state.gridSize]; // FastBitArray[]
    
    for (Byte i = 0; i < state.gridSize; ++i) {
        [EliminationTechnique getRowPossibleNumbers:possibleNumbers row:i target:arrays];
        (*numberOfChanges) += [self eliminateHiddenSubsets:arrays isExitEarlyWhenSoleFound:isExitEarlyWhenSoleFound isExitedEarly:isExitedEarly];
        if (*isExitedEarly) return NO;
        
        [EliminationTechnique getColumnPossibleNumbers:possibleNumbers column:i target:arrays];
        (*numberOfChanges) += [self eliminateHiddenSubsets:arrays isExitEarlyWhenSoleFound:isExitEarlyWhenSoleFound isExitedEarly:isExitedEarly];
        if (*isExitedEarly) return NO;
        
        [EliminationTechnique getBoxPossibleNumbers:state possibleNumbers:possibleNumbers box:i target:arrays];
        (*numberOfChanges) += [self eliminateHiddenSubsets:arrays isExitEarlyWhenSoleFound:isExitEarlyWhenSoleFound isExitedEarly:isExitedEarly];
        if (*isExitedEarly) return NO;
    }
    
    return (*numberOfChanges) != 0;
}
@end

@implementation HiddenPairTechnique
- (instancetype)init {
    return [self initWithSubsetSize:2];
}

- (NSUInteger)difficultyLevel {
    return 6;
}
@end

@implementation HiddenTripletTechnique
- (instancetype)init {
    return [self initWithSubsetSize:3];
}

- (NSUInteger)difficultyLevel {
    return 8;
}
@end

@implementation HiddenQuadTechnique
- (instancetype)init {
    return [self initWithSubsetSize:4];
}

- (NSUInteger)difficultyLevel {
    return 10;
}
@end