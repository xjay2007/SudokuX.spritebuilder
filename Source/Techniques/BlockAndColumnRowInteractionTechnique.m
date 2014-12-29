//
//  BlockAndColumnRowInteractionTechnique.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "BlockAndColumnRowInteractionTechnique.h"
#import "PuzzleState.h"
#import "FastBitArray.h"

@implementation BlockAndColumnRowInteractionTechnique

- (NSUInteger)difficultyLevel {
    return 4;
}

- (BOOL)            execute:(PuzzleState *)state
   isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
            possibleNumbers:(NSArray *)possibleNumbers // FastBitArray[][]
            numberOfChanges:(NSInteger *)numberOfChanges
              isExitedEarly:(BOOL *)isExitedEarly {
    *numberOfChanges = 0;
    *isExitedEarly = NO;
    
    // Find the open cells in this block
    NSInteger numLocations;
    NSMutableArray *foundLocations = [NSMutableArray arrayWithCapacity:state.gridSize];
    
    // Analyze each box
    for (Byte box = 0; box < state.gridSize; ++box) {
        for (Byte n = 0; n < state.gridSize; ++n) {
            numLocations = 0;
            
            // Find all locations that n is possible within the box
            Byte boxStartX = (box / state.boxSize) * state.boxSize;
            for (Byte x = boxStartX; x < boxStartX + state.boxSize && numLocations <= state.boxSize; ++x) {
                Byte boxStartY = (box % state.boxSize) * state.boxSize;
                for (Byte y = boxStartY; y < boxStartY + state.boxSize && numLocations <= state.boxSize; ++y) {
                    if ([(FastBitArray *)possibleNumbers[x][y] valueAtIndex:n]) {
                        foundLocations[numLocations++] = [NSValue valueWithCGPoint:CGPointMake(x, y)];
                    }
                }
            }
            
            // Matters only when two or three are open in the grid and if they're
            // in the same row or column
            if (numLocations > 1 && numLocations <= state.boxSize) {
                BOOL isMatchesRow = YES, isMatchesColumn = YES;
                Byte row = [foundLocations[0] CGPointValue].x;
                Byte column = [foundLocations[0] CGPointValue].y;
                for (Byte i = 1; i < numLocations; ++i) {
                    if ([foundLocations[i] CGPointValue].x != row) isMatchesRow = NO;
                    if ([foundLocations[i] CGPointValue].y != column) isMatchesColumn = NO;
                }
                
                // If they're all in the same row
                if (isMatchesRow) {
                    for (Byte j = 0; j < state.gridSize; ++j) {
                        // only works if boxSize == 3
                        FastBitArray *fbaRowJ = possibleNumbers[row][j];
                        if ([fbaRowJ valueAtIndex:n] &&
                            j != [foundLocations[0] CGPointValue].y &&
                            j != [foundLocations[1] CGPointValue].y &&
                            (numLocations == 2 || j != [foundLocations[2] CGPointValue].y)) {
                            [fbaRowJ setValue:NO atIndex:n];
                            (*numberOfChanges)++;
                            if (isExitEarlyWhenSoleFound &&
                                fbaRowJ.countSet == 1) {
                                *isExitedEarly = YES;
                                return NO;
                            }
                        }
                    }
                }
                // If they're all in the same column
                else if (isMatchesColumn) {
                    for(Byte j = 0; j < state.gridSize; ++j) {
                        // only works if boxSize == 3
                        FastBitArray *fbaJCol = possibleNumbers[j][column];
                        if ([fbaJCol valueAtIndex:n] &&
                            j != [foundLocations[0] CGPointValue].x &&
                            j != [foundLocations[1] CGPointValue].x &&
                            (numLocations == 2 || j != [foundLocations[2] CGPointValue].x)) {
                            [fbaJCol setValue:NO atIndex:n];
                            (*numberOfChanges)++;
                            if (isExitEarlyWhenSoleFound &&
                                fbaJCol.countSet == 1) {
                                *isExitedEarly = YES;
                                return NO;
                            }
                        }
                    }
                }
            }
        }
    }
    
    return (*numberOfChanges) != 0;
}
@end
