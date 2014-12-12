//
//  BeginnerTechnique.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "BeginnerTechnique.h"
#import "PuzzleState.h"
#import "FastBitArray.h"

@implementation BeginnerTechnique

- (NSUInteger)difficultyLevel {
    return 1;
}

- (BOOL)            execute:(PuzzleState *)state
   isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
            possibleNumbers:(NSArray *)possibleNumbers // FastBitArray[][]
            numberOfChanges:(NSInteger *)numberOfChanges
              isExitedEarly:(BOOL *)isExitedEarly {
    
    *numberOfChanges = 0;
    *isExitedEarly = NO;
    
    NSInteger numLocations;
    NSMutableArray *locations = [NSMutableArray arrayWithCapacity:state.gridSize]; // [CGPointValue[]
    
    for(Byte n = 0; n<state.gridSize; n++) {
        // Find all occurrences of n.  If GridSize (9) or more are found, no need to continue.
        // If more than GridSize are found, there is at least one mistake somewhere on the
        // board.  If fewer than 9 are found, populate locations with a new Point.
        numLocations = 0;
        for(Byte row = 0; row < state.gridSize && numLocations < state.gridSize; ++row) {
            for(Byte column = 0; column < state.gridSize && numLocations < state.gridSize; ++column)
            {
                id value = [state cellValueAtX:row y:column];
                if ( [value isKindOfClass:[NSNumber class]] &&
                    [value unsignedCharValue] == n) {
                    locations[numLocations++] = [NSValue valueWithCGPoint:CGPointMake(row, column)];
                }
            }
        }
        if (numLocations >= state.gridSize) {
            continue;
        }
        
        // For each box
        for(Byte box=0; box < state.gridSize; ++box) {
            BOOL isDone = NO;
            
            // If any of the cells in the box is the number, set bool done to true
            Byte boxStartX = (box % state.boxSize) * state.boxSize;
            for (Byte x = boxStartX; x < boxStartX + state.boxSize && !isDone; ++x) {
                Byte boxStartY = (box / state.boxSize) * state.boxSize;
                for (Byte y = boxStartY; y < boxStartY + state.boxSize && !isDone; ++y) {
                    CGPoint cell = CGPointMake(x, y);
                    id value = [state cellValueAtPoint:cell];
                    if (([value isKindOfClass:[NSNumber class]] && [value unsignedCharValue] == n) ||
                        (![value isKindOfClass:[NSNumber class]] && ((FastBitArray *)possibleNumbers[x][y]).countSet == 1 &&
                         [((FastBitArray *)possibleNumbers[x][y]) valueAtIndex:n])) {
                            isDone = YES;
                        }
                }
            }
            if (isDone) {
                continue;
            }
            
            // Look at each cell in the box
            CGPoint targetCell = CGPointMake(-1, -1);
            boxStartX = (box % state.boxSize) * state.boxSize;
            for (Byte x = boxStartX; x < boxStartX + state.boxSize && !isDone; ++x) {
                Byte boxStartY = (box / state.boxSize) * state.boxSize;
                for (Byte y = boxStartY; y < boxStartY + state.boxSize && !isDone; ++y) {
                    // Check for one cell in the box that can be
                    // this number.  If there is, it must be there.
                    CGPoint cell = CGPointMake(x, y);
                    if (![[state cellValueAtPoint:cell] isKindOfClass:[NSNumber class]] && [((FastBitArray *)possibleNumbers[x][y]) valueAtIndex:n]) {
                        BOOL isInvalid = NO;
                        for(Byte locNum=0; locNum<numLocations; ++locNum) {
                            if ([locations[locNum] CGPointValue].x == cell.x || [locations[locNum] CGPointValue].y == cell.y) {
                                isInvalid = YES;
                                break;
                            }
                        }
                        if (!isInvalid) {
                            if (CGPointEqualToPoint(targetCell, CGPointMake(-1, -1))) {
                                targetCell = cell;
                            } else {
                                targetCell = CGPointMake(-1, -1);
                                isDone = YES;
                            }
                        }
                    }
                }
            }
            
            // If a cell is found, you can fill in and 
            //modify the possible numbers list appropriately
            if (!CGPointEqualToPoint(targetCell, CGPointMake(-1, -1))) {
                NSInteger targetCellX = targetCell.x;
                NSInteger targetCellY = targetCell.y;
                [((FastBitArray *)(possibleNumbers[targetCellX][targetCellY])) setAllValue:NO];
                [((FastBitArray *)(possibleNumbers[targetCellX][targetCellY])) setValue:YES atIndex:n];
                (*numberOfChanges)++;
                if (isExitEarlyWhenSoleFound)
                {
                    *isExitedEarly = YES;
                    return NO;
                }
            }
        }
    }
    
    // If numberOfChanges > 0, possibleNumbers was changed, but the state
    // itself was not affected.  Thus, running this again won't help.
    return NO;
}
@end
