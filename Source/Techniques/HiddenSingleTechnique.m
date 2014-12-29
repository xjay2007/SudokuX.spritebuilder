//
//  HiddenSingleTechnique.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "HiddenSingleTechnique.h"
#import "PuzzleState.h"
#import "FastBitArray.h"

@implementation HiddenSingleTechnique

- (NSUInteger)difficultyLevel {
    return 3;
}

- (BOOL)            execute:(PuzzleState *)state
   isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
            possibleNumbers:(NSArray *)possibleNumbers // FastBitArray[][]
            numberOfChanges:(NSInteger *)numberOfChanges
              isExitedEarly:(BOOL *)isExitedEarly {
    *numberOfChanges = 0;
    *isExitedEarly = NO;
    Byte gridSize = state.gridSize;
    Byte boxSize = state.boxSize;
    
    // For each number that can exist in the puzzle (0-8, etc.)
    for (Byte n = 0; n < gridSize; ++n) {
        // For each row, if number only exists as a possibility in one cell, set it.
        for (Byte x = 0; x < gridSize; ++x) {
            NSNumber *seenIndex = nil;
            for (Byte y = 0; y < gridSize; ++y) {
                if ([(FastBitArray *)possibleNumbers[x][y] valueAtIndex:n]) {
                    // If this is the first time you locate the number, set seenIndex.
                    if (seenIndex == nil) seenIndex = @(y);
                    // You have seen this number before, so move on
                    else {
                        seenIndex = nil;
                        break;
                    }
                }
            }
            FastBitArray *fbaXSeeIndex = possibleNumbers[x][[seenIndex unsignedCharValue]];
            if (seenIndex != nil && fbaXSeeIndex.countSet > 1) {
                [fbaXSeeIndex setAllValue:NO];
                [fbaXSeeIndex setValue:YES atIndex:n];
                (*numberOfChanges)++;
                if (isExitEarlyWhenSoleFound) {
                    *isExitedEarly = YES;
                    return NO;
                }
            }
        }
        
        // For each column, if number only exists as a possibility in one cell, set it.
        // Same basic logic as above.
        for (Byte y = 0; y < gridSize; ++y) {
            NSNumber *seenIndex = nil;
            for (Byte x = 0; x < gridSize; ++x) {
                if ([(FastBitArray *)possibleNumbers[x][y] valueAtIndex:n]) {
                    if (seenIndex == nil) seenIndex = @(x);
                    else {
                        seenIndex = nil;
                        break;
                    }
                }
            }
            FastBitArray *fbaSeenIndexY = possibleNumbers[[seenIndex unsignedCharValue]][y];
            if (seenIndex != nil && fbaSeenIndexY.countSet > 1) {
                [fbaSeenIndexY setAllValue:NO];
                [fbaSeenIndexY setValue:YES atIndex:n];
                (*numberOfChanges)++;
                if (isExitEarlyWhenSoleFound) {
                    *isExitedEarly = YES;
                    return NO;
                }
            }
        }
        
        // For each grid, if number only exists as a possibility in one cell, set it.
        // Same basic logic as above.
        for (Byte gridNum = 0; gridNum < gridSize; ++gridNum) {
            Byte gridX = (Byte)(gridNum % boxSize);
            Byte gridY = (Byte)(gridNum / boxSize);
            
            Byte startX = (Byte)(gridX * boxSize);
            Byte startY = (Byte)(gridY * boxSize);
            
            BOOL canEliminate = YES;
            NSValue *seenIndex = nil;
            for (Byte x = startX; x < startX + boxSize && canEliminate; ++x) {
                for (Byte y = startY; y < startY + boxSize; ++y) {
                    if ([(FastBitArray *)possibleNumbers[x][y] valueAtIndex:n]) {
                        if (seenIndex == nil) seenIndex = [NSValue valueWithCGPoint:CGPointMake(x, y)];
                        else {
                            canEliminate = NO;
                            seenIndex = nil;
                            break;
                        }
                    }
                }
            }
            
            FastBitArray *fbaSeenIndex = possibleNumbers[(Byte)[seenIndex CGPointValue].x][(Byte)[seenIndex CGPointValue].y];
            if (seenIndex != nil && canEliminate &&
                fbaSeenIndex.countSet > 1) {
                [fbaSeenIndex setAllValue:NO];
                [fbaSeenIndex setValue:YES atIndex:n];
                (*numberOfChanges)++;
                if (isExitEarlyWhenSoleFound) {
                    *isExitedEarly = YES;
                    return NO;
                }
            }
        }
    }
    
    return (*numberOfChanges) != 0;
}
@end
