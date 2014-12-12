//
//  NakedSingleTechnique.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "NakedSingleTechnique.h"
#import "PuzzleState.h"
#import "FastBitArray.h"

@implementation NakedSingleTechnique

- (NSUInteger)difficultyLevel {
    return 2;
}

- (BOOL)            execute:(PuzzleState *)state
   isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
            possibleNumbers:(NSArray *)possibleNumbers // FastBitArray[][]
            numberOfChanges:(NSInteger *)numberOfChanges
              isExitedEarly:(BOOL *)isExitedEarly {
    *numberOfChanges = 0;
    *isExitedEarly = NO;
    
    // Eliminate impossible numbers based on numbers already set in the grid
    for (Byte i = 0; i < state.gridSize; ++i)
    {
        for (Byte j = 0; j < state.gridSize; ++j)
        {
            // If this cell has a value, we use it to eliminate numbers in other cells
            id value = [state cellValueAtX:i y:j];
            if ([value isKindOfClass:[NSNumber class]])
            {
                Byte valueToEliminate = [value unsignedCharValue];
                
                // eliminate numbers in same row
                for (Byte y = 0; y < state.gridSize; ++y)
                {
                    FastBitArray *iy = possibleNumbers[i][y];
                    if ([iy valueAtIndex:valueToEliminate])
                    {
                        numberOfChanges++;
                        [iy setValue:NO atIndex:valueToEliminate];
                    }
                }
                
                // eliminate numbers in same column
                for (Byte x = 0; x < state.gridSize; ++x)
                {
                    FastBitArray *xj = possibleNumbers[x][j];
                    if ([xj valueAtIndex:valueToEliminate])
                    {
                        numberOfChanges++;
                        [xj setValue:NO atIndex:valueToEliminate];
                    }
                }
                
                // eliminate numbers in same box
                Byte boxStartX = (i / state.boxSize) * state.boxSize;
                for (Byte x = boxStartX; x < boxStartX + state.boxSize; ++x)
                {
                    Byte boxStartY = (j / state.boxSize) * state.boxSize;
                    for (Byte y = boxStartY; y < boxStartY + state.boxSize; ++y)
                    {
                        FastBitArray *xy = possibleNumbers[x][y];
                        if ([xy valueAtIndex:valueToEliminate])
                        {
                            numberOfChanges++;
                            [xy setValue:NO atIndex:valueToEliminate];
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}
@end
