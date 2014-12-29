//
//  NakedSubsetTechnique.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "NakedSubsetTechnique.h"
#import "PuzzleState.h"
#import "FastBitArray.h"

@interface NakedSubsetTechnique ()

/// <summary>Initialize the technique.</summary>
/// <param name="subsetSize">The size of the subset to evaluate.</param>
- (instancetype)initWithSubsetSize:(NSInteger)subsetSize;

/// <summary>Performs naked subset elimination on one dimension of possible numbers.</summary>
/// <param name="possibleNumbers">The row/column/box to analyze.</param>
/// <returns>The number of changes that were made to the possible numbers.</returns>
- (NSInteger)eliminateHiddenSubsets:(NSMutableArray *)possibleNumbers // FastBitArray []
           isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
                      isExitedEarly:(BOOL *)isExitedEarly;

@end

@implementation NakedSubsetTechnique
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
    NSMutableArray *foundLocations = _foundLocations; // optimization, rather than allocating each time
    
    for (Byte i = 0; i<possibleNumbers.count; ++i) {
        FastBitArray *fbaI = possibleNumbers[i];
        if (fbaI.countSet == _subsetSize) {
            foundLocations[0] = @(i);
            NSArray *toMatchValues = fbaI.bitsArray;
            NSInteger matchesFound = 0;
            for (Byte j = i + 1; j < possibleNumbers.count; ++j) {
                FastBitArray *fbaj = possibleNumbers[j];
                if (fbaj.countSet == _subsetSize) {
                    BOOL foundMatch = [toMatchValues isEqualToArray:fbaj.bitsArray];
                    if (foundMatch) {
                        foundLocations[++matchesFound] = @(j);
                        if (matchesFound == _subsetSize - 1) {
                            for (Byte k = 0; k < possibleNumbers.count; ++k) {
                                if ([foundLocations indexOfObject:@(k)] == NSNotFound) {
                                    FastBitArray *fbak = possibleNumbers[k];
                                    for (NSNumber *eliminatedPossible in toMatchValues) {
                                        if ([fbak valueAtIndex:[eliminatedPossible unsignedCharValue]]) {
                                            changesMade++;
                                            [fbak setValue:NO atIndex:[eliminatedPossible unsignedCharValue]];
                                        }
                                    }
                                    if (isExitEarlyWhenSoleFound &&
                                        fbak.countSet == 1) {
                                        *isExitedEarly = YES;
                                        return changesMade;
                                    }
                                }
                            }
                            break;
                        }
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
    NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:state.gridSize]; //FastBitArray[state.GridSize];
    
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

@implementation NakedPairTechnique
- (instancetype)init {
    return [self initWithSubsetSize:2];
}

- (NSUInteger)difficultyLevel {
    return 5;
}
@end

@implementation NakedTripletTechnique
- (instancetype)init {
    return [self initWithSubsetSize:3];
}

- (NSUInteger)difficultyLevel {
    return 7;
}
@end

@implementation NakedQuadTechnique
- (instancetype)init {
    return [self initWithSubsetSize:2];
}

- (NSUInteger)difficultyLevel {
    return 9;
}
@end
