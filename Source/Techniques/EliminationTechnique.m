//
//  EliminationTechnique.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "EliminationTechnique.h"
#import "PuzzleState.h"
#import "FastBitArray.h"

static NSMutableArray   *   _allAvailableTechniques = nil; // Base type used for eliminating possible numbers from cells in a puzzle state.

static NSString * const subclassnames[] = {
    @"BeginnerTechnique",
    @"NakedSingleTechnique",
    @"HiddenSingleTechnique",
    @"BlockAndColumnRowInteractionTechnique",
    @"NakedPairTechnique",
    @"HiddenPairTechnique",
    @"NakedTripletTechnique",
    @"HiddenTripletTechnique",
    @"NakedQuadTechnique",
    @"HiddenQuadTechnique",
    @"XwingTechnique",
};

@interface EliminationTechnique()

+ (NSComparisonResult)compareTechinique:(EliminationTechnique *)first withOther:(EliminationTechnique *)second;
@end

@implementation EliminationTechnique
+ (instancetype)technique {
    NSString *className = NSStringFromClass([self class]);
    NSArray *availableTechniques = [EliminationTechnique availableTechniques];
    NSInteger size = sizeof(subclassnames) / sizeof(*subclassnames);
    for (NSInteger i = 0; i < size; ++i) {
        if ([className isEqualToString:subclassnames[i]]) {
            return availableTechniques[i];
        }
    }
    return [[[self class] alloc] init];
}

+ (NSArray *)availableTechniques {
    if (_allAvailableTechniques == nil) {
        @synchronized(self) {
            _allAvailableTechniques = [NSMutableArray arrayWithCapacity:0];
            NSInteger size = sizeof(subclassnames) / sizeof(*subclassnames);
            for (NSInteger i = 0; i < size; ++i) {
                Class subClass = NSClassFromString(subclassnames[i]);
                [_allAvailableTechniques addObject:[[subClass alloc] init]];
            }
        }
    }
    return _allAvailableTechniques;
}

- (NSUInteger)difficultyLevel {
    return 0;
}

+ (void)getRowPossibleNumbers:(NSArray *) possibleNumbers
                          row:(NSInteger)row
                       target:(NSMutableArray *)target {
    NSMutableArray *obj = target;
    for (NSInteger i = 0; i < [possibleNumbers[row] count]; ++i) {
        obj[i] = possibleNumbers[row][i];
    }
}
+ (void)getColumnPossibleNumbers:(NSArray *) possibleNumbers
                          column:(NSInteger)column
                          target:(NSMutableArray *)target {
    NSMutableArray *obj = target;
    for (NSInteger i = 0; i < [possibleNumbers count]; ++i) {
        obj[i] = possibleNumbers[i][column];
    }
}
+ (void)getBoxPossibleNumbers:(PuzzleState *)state
              possibleNumbers:(NSArray *)possibleNumbers
                          box:(NSInteger)box
                       target:(NSMutableArray *)target {
    NSMutableArray *obj = target;
    NSInteger count = 0;
    NSInteger boxStartX = (box % state.boxSize) * state.boxSize;
    for (NSInteger x = boxStartX; x < boxStartX + state.boxSize; ++x) {
        NSInteger boxStartY = (box / state.boxSize) * state.boxSize;
        for (NSInteger y = 0; y < boxStartY + state.boxSize; ++y) {
            obj[count++] = possibleNumbers[x][y];
        }
    }
}
+ (NSInteger)boxNumberWithBoxSize:(NSInteger)boxSize atRow:(NSInteger)row column:(NSInteger)column {
    return ((row / boxSize) * 3) + (column / boxSize);
}
+ (BOOL)isAllAreSetInNumbers:(NSArray *)numbers // NSInteger[]
                       array:(FastBitArray *)array {
    for (NSNumber *n in numbers) {
        if (!([array valueAtIndex:[n integerValue]])) {
            return NO;
        }
    }
    return YES;
}
+ (BOOL)isAnyAreSetInNumbers:(NSArray *)numbers // NSInteger[]
                       array:(FastBitArray *)array {
    for (NSNumber *n in numbers) {
        if ([array valueAtIndex:[n integerValue]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)execute:(PuzzleState *)state isExitEarlyWhenSoleFound:(BOOL)isExitEarlyWhenSoleFound possibleNumbers:(NSArray *)possibleNumbers numberOfChanges:(NSInteger *)numberOfChanges isExitedEarly:(BOOL *)isExitedEarly {
    return NO;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[self class] technique];
}

- (NSUInteger)hash {
    return [NSStringFromClass([self class]) hash];
}

- (NSComparisonResult)compare:(id)object {
    if (![object isKindOfClass:[EliminationTechnique class]]) {
        return NSOrderedDescending;
    }
    return [EliminationTechnique compareTechinique:self withOther:object];
}

+ (NSComparisonResult)compareTechinique:(EliminationTechnique *)first withOther:(EliminationTechnique *)second {
    if (first == nil && second == nil) {
        return NSOrderedSame;
    } else if (first == nil) {
        return NSOrderedAscending;
    } else if (second == nil) {
        return NSOrderedDescending;
    } else {
        return first.difficultyLevel == (second.difficultyLevel) ? NSOrderedSame : ((first.difficultyLevel < second.difficultyLevel) ? NSOrderedAscending : NSOrderedDescending);
    }
}
@end