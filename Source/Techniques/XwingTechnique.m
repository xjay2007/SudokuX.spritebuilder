//
//  XwingTechnique.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "XwingTechnique.h"
#import "PuzzleState.h"
#import "FastBitArray.h"

@implementation XwingTechnique

- (NSUInteger)difficultyLevel {
    return 11;
}

- (BOOL)            execute:(PuzzleState *)state
   isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound
            possibleNumbers:(NSArray *)possibleNumbers // FastBitArray[][]
            numberOfChanges:(NSInteger *)numberOfChanges
              isExitedEarly:(BOOL *)isExitedEarly {
    *numberOfChanges = 0;
    *isExitedEarly = false;
    
    // Check each row to see if it contains the start of an xwing
    for (Byte row = 0; row < state.gridSize; ++row) {
        NSInteger count = 0; // used to find the two first-row members of the x-wing
        NSMutableArray *foundColumns = [NSMutableArray arrayWithCapacity:2]; // used to store the two first-row members of the x-wing
        
        // Check all numbers to see whether they're in an x-wing
        for(Byte n = 0; n < state.gridSize; ++n) {
            // Look at every column in the row, and find the occurrences of the number.
            // For it to be a valid x-wing, it must have two and only two of the specified number as a possibility.
            for(Byte column = 0; column < state.gridSize; ++column) {
                id cellValue = [state cellValueAtX:row y:column];
                if ([((FastBitArray *)possibleNumbers[row][column]) valueAtIndex:n] || ([cellValue isKindOfClass:[NSNumber class]] && [cellValue unsignedCharValue] == n)) {
                    count++;
                    if (count <= 2/*foundColumns.count*/) foundColumns[count-1] = @(column);
                    else break;
                }
            }
            
            // Assuming you found a row that has only two cells with the number as a possibility
            if (count == 2) {
                // Look for another row that has the same property
                for(Byte subRow = row + 1; subRow < state.gridSize; ++subRow) {
                    BOOL validXwingFound = YES;
                    for(Byte subColumn = 0; subColumn < state.gridSize && validXwingFound; ++subColumn) {
                        BOOL isMatchingColumn = (subColumn == [foundColumns[0] unsignedCharValue] || subColumn == [foundColumns[1] unsignedCharValue]);
                        id cellValue = [state cellValueAtX:subRow y:subColumn];
                        BOOL hasPossibleNumber = [((FastBitArray *)possibleNumbers[subRow][subColumn]) valueAtIndex:n] || ([cellValue isKindOfClass:[NSNumber class]] && [cellValue unsignedCharValue] == n);
                        if ((hasPossibleNumber && !isMatchingColumn) ||
                            (!hasPossibleNumber && isMatchingColumn)) validXwingFound = NO;
                    }
                    
                    // If another row is found that has only two cells with the number
                    // as a possibility, and if those two cells are in the same two columns
                    // as the original row, an x-wing is located, and you can eliminate
                    // that number from every other cell in the columns containing the numbers.
                    if (validXwingFound) {
                        for (Byte elimRow = 0; elimRow < state.gridSize; ++elimRow) {
                            if (elimRow != row && elimRow != subRow) {
                                for( Byte locationNum = 0; locationNum < 2; ++locationNum) {
                                    FastBitArray *fbaEF = possibleNumbers[elimRow][[foundColumns[locationNum] unsignedCharValue]];
                                    if ([fbaEF valueAtIndex:n]) {
                                        [fbaEF setValue:NO atIndex:n];
                                        (*numberOfChanges)++;
                                        if (isExitEarlyWhenSoleFound &&
                                            fbaEF.countSet == 1) {
                                            *isExitedEarly = YES;
                                            return NO;
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    return (*numberOfChanges) != 0;
}
@end
