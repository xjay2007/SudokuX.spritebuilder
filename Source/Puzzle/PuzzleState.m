//
//  PuzzleState.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "PuzzleState.h"
#import "FastBitArray.h"
#import "EliminationTechnique.h"

// Maximum size of a puzzle state box.
const Byte          _defaultBoxSize = 3;
const Byte          MaxBoxSize = 3;
const Byte          MinBoxSize = 3;

static BOOL StatesMatch(PuzzleState *first, PuzzleState *second);
static NSMutableArray *InstantiatePossibleNumbersArray(PuzzleState *state);

@interface PuzzleState ()
@property (nonatomic, strong) NSMutableArray          *   grid;
@property (nonatomic, assign) PuzzleStatus              status;
@property (nonatomic, copy) NSNumber                *   filledCells;
//@property (nonatomic, assign) PuzzleDifficulty          difficulty;

/// <summary>Analyzes the state of the puzzle to determine whether it is a solution or not.</summary>
/// <returns>The status of the puzzle.</returns>
- (PuzzleStatus)analyzeSolutionStatus;
@end

@implementation PuzzleState

+ (instancetype)state {
    return [[[self class] alloc] init];
}
+ (instancetype)stateWithBoxSize:(Byte)boxSize {
    return [[[self class] alloc] initWithBoxSize:boxSize];
}
- (instancetype)init
{
    return [self initWithBoxSize:_defaultBoxSize];
}

- (instancetype)initWithBoxSize:(Byte)boxSize {
    self = [super init];
    if (self) {
        NSAssert(boxSize <= MaxBoxSize && boxSize >= MinBoxSize, @"ArgumentOutOfRangeException");
        
        _boxSize = boxSize;
        _gridSize = (Byte)(boxSize * boxSize);
        _grid = [NSMutableArray arrayWithCapacity:_gridSize];
        for (int i = 0; i < _gridSize; ++i) {
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:_gridSize];
            NSNull *null = [NSNull null];
            for (int j = 0; j < _gridSize; ++j) {
                [arr addObject:null];
            }
            [_grid addObject:arr];
        }
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    PuzzleState *copy = [[[self class] alloc] initWithBoxSize:self.boxSize];
    copy.grid = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.grid count]; ++i) {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:self.grid[i] copyItems:YES];
        copy.grid[i] = arr;
    }
    copy.status = _status;
    copy.filledCells = _filledCells;
    copy.difficulty = _difficulty;
    return copy;
}

- (BOOL)isEqual:(id)object {
    PuzzleState *other = object;
    return [other isKindOfClass:[self class]] && StatesMatch(self, other);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ : \n%@", [super description], [self gridString]];
}

- (NSUInteger)hash {
    return [[self description] hash];
}

- (id)cellValueAtX:(NSInteger)x y:(NSInteger)y {
    NSAssert(x >= 0 && x < self.gridSize && y >= 0 && y < self.gridSize, @"Out of Range");
    
    return self.grid[x][y];
}
- (void)setCellValue:(id)value atX:(NSInteger)x y:(NSInteger)y {
    NSAssert(x >= 0 && x < self.gridSize && y >= 0 && y < self.gridSize, @"Out of Range");
    
    id oldValue = self.grid[x][y];
    if (![oldValue isEqual:value]) {
        self.status = PuzzleStatusUnknown;
        self.filledCells = nil;
        
        self.grid[x][y] = [value isKindOfClass:[NSNumber class]] ? value : [NSNull null];
        [self onStateChanged]; // cell, oldValue, value
    }
}
- (id)cellValueAtPoint:(CGPoint)point {
    return [self cellValueAtX:point.x y:point.y];
}
- (void)setCellValue:(id)value atPoint:(CGPoint)point {
    [self setCellValue:value atX:point.x y:point.y];
}

- (void)onStateChanged {
    if (self.isRaisedStateChangedEvent) {
        [_delegate puzzleState:self stateChanged:nil];
    }
}

- (PuzzleStatus)status {
    if (_status == PuzzleStatusUnknown) {
        _status = [self analyzeSolutionStatus];
    }
    return _status;
}

- (NSInteger)numberOfFilledCells {
    if (![self.filledCells isKindOfClass:[NSNumber class]]) {
        __block NSInteger count = 0;
        [self.grid enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL *stop) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    ++count;
                }
            }];
        }];
        self.filledCells = @(count);
    }
    return [self.filledCells integerValue];
}

- (NSArray *)gridArray {
    return self.grid;
}

- (NSEnumerator *)enumerator {
    return [self.grid objectEnumerator];
}

- (NSString *)gridString {
    NSMutableString *ret = [NSMutableString stringWithCapacity:self.gridSize * self.gridSize];
//    for (NSArray *arr in self.grid) {
//        for (id obj in arr) {
//            [ret appendFormat:@"%@ ", [obj isKindOfClass:[NSNumber class]] ? [obj stringValue] : @"x"];
//        }
//        [ret appendString:@"\n"];
//    }
    [self.grid enumerateObjectsUsingBlock:^(NSArray *row, NSUInteger i, BOOL *stop) {
        [row enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger j, BOOL *stop) {
            [ret appendFormat:@"%@ %@", [num isKindOfClass:[NSNumber class]] ? @([num integerValue] + 1) : @"x", (j + 1) % 3 == 0 ? @"|" : @""];
        }];
        [ret appendFormat:@"\n%@", (i + 1) % 3 == 0 ? @"---------------------\n" : @""];
    }];
    return ret;
}

- (NSArray *)computePossibleNumbersWithTechniques:(NSArray *)techniques
                                         usesOfTechnique:(NSMutableDictionary **)usesOfTechnique // HashTable
                                           isOnlyOnePass:(BOOL)isOnlyOnePass
                                isEarlyExitWhenSoleFound:(BOOL)isEarlyExitWhenSoleFound
                                         possibleNumbers:(NSArray *)possibleNumbers {
    // Initialize the possible numbers grid
    [possibleNumbers enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger i, BOOL *stop) {
        [arr enumerateObjectsUsingBlock:^(FastBitArray *obj, NSUInteger j, BOOL *stop) {
            [obj setAllValue:([[self cellValueAtX:i y:j] isKindOfClass:[NSNumber class]] ? NO : YES)];
        }];
    }];
    // Perform eliminations based on the techniques available to this puzzle state.
    // The techniques available depend on the difficulty level of the puzzle.
    BOOL isNotDone;
    do {
        isNotDone = NO;
        for (EliminationTechnique *e in techniques) {
            NSInteger numberOfChanges = 0;
            BOOL isExitedEarly = NO;
            isNotDone |= [e execute:self isExitEarlyWhenSoleFound:isEarlyExitWhenSoleFound possibleNumbers:possibleNumbers numberOfChanges:&numberOfChanges isExitedEarly:&isExitedEarly];
            if (*usesOfTechnique != nil) {
                NSNumber *uses = (*usesOfTechnique)[e];
                (*usesOfTechnique)[e] = (uses != nil) ? @(numberOfChanges + [uses integerValue]) : @(numberOfChanges);
            }
            if (isExitedEarly) {
                isNotDone = NO;
                break;
            }
        }
    } while (isNotDone && !isOnlyOnePass);
    return possibleNumbers;
}

- (PuzzleStatus)analyzeSolutionStatus {
    // Need a way of keeping track of what numbers have been used (in each row, column, box, etc.)
    // A bit array is a great way to do this, where each bit corresponds to a true/false value
    // as to whether a number was already used in a particular scenario.
    FastBitArray *numbersUsed = [FastBitArray arrayWithLength:self.gridSize];
    
    // Make sure every column contains the right numbers.  It is fine if a column has holes
    // as long as those cells have possibilities, in which case it is a puzzle in progress.
    // However, two numbers cannot be used in the same column, even if there are holes.
    for (NSInteger i = 0; i < self.gridSize; ++i) {
        [numbersUsed setAllValue:NO];
        for (NSInteger j = 0; j < self.gridSize; ++j) {
            if ([self.grid[i][j] isKindOfClass:[NSNumber class]]) {
                NSInteger value = [self.grid[i][j] integerValue];
                if ([numbersUsed valueAtIndex:value]) {
                    return PuzzleStatusCannotBeSolved;
                }
                [numbersUsed setValue:YES atIndex:value];
            }
        }
    }
    
    // Same for rows
    for (NSInteger j = 0; j < self.gridSize; ++j) {
        [numbersUsed setAllValue:NO];
        for (NSInteger i = 0; i < self.gridSize; ++i) {
            if ([self.grid[i][j] isKindOfClass:[NSNumber class]]) {
                NSInteger value = [self.grid[i][j] integerValue];
                if ([numbersUsed valueAtIndex:value]) {
                    return PuzzleStatusCannotBeSolved;
                }
                [numbersUsed setValue:YES atIndex:value];
            }
        }
    }
    
    // Same for boxes
    for (NSInteger boxNumber = 0; boxNumber < self.gridSize; ++boxNumber) {
        [numbersUsed setAllValue:NO];
        NSInteger boxStartX = (boxNumber / self.boxSize) * self.boxSize;
        for (NSInteger x = boxStartX; x < boxStartX + self.boxSize; ++x) {
            NSInteger boxStartY = (boxNumber % self.boxSize) * self.boxSize;
            for (NSInteger y = boxStartY; y < boxStartY + self.boxSize; ++y) {
                if ([self.grid[x][y] isKindOfClass:[NSNumber class]]) {
                    NSInteger value = [self.grid[x][y] integerValue];
                    if ([numbersUsed valueAtIndex:value]) {
                        return PuzzleStatusCannotBeSolved;
                    }
                    [numbersUsed setValue:YES atIndex:value];
                }
            }
        }
    }
    
    // Now determine whether this is a solved puzzle or a work in progress
    // based on whether there are any holes
    for (NSInteger i = 0; i < self.gridSize; ++i) {
        for (NSInteger j = 0; j < self.gridSize; ++j) {
            if (![self.grid[i][j] isKindOfClass:[NSNumber class]]) {
                return PuzzleStatusInProgress;
            }
        }
    }
    
    // If you made it this far, this state is a valid solution
    return PuzzleStatusSolved;
}

+ (NSMutableArray *)instantiatePossibleNumbersArrayWithState:(PuzzleState *)state {
    return InstantiatePossibleNumbersArray(state);
}
@end
static BOOL StatesMatch(PuzzleState *first, PuzzleState *second) {
    if (first == nil) {
        @throw [NSException exceptionWithName:@"first state is nil" reason:nil userInfo:nil];
    }
    if (second == nil) {
        @throw [NSException exceptionWithName:@"second state is nil" reason:nil userInfo:nil];
    }
    
    // They're equal only if the corresponding cells both contain the
    // same number or are both empty.
    if (first.gridSize != second.gridSize) {
        return NO;
    }
    return [first.grid isEqualToArray:second.grid];
}

static NSMutableArray *InstantiatePossibleNumbersArray(PuzzleState *state) {
    NSMutableArray *possibleNumbers = [NSMutableArray arrayWithCapacity:state.gridSize];
    for (Byte i = 0; i < state.gridSize; ++i) {
        possibleNumbers[i] = [NSMutableArray arrayWithCapacity:state.gridSize];
        for (Byte j = 0; j < state.gridSize; ++j) {
            possibleNumbers[i][j] = [FastBitArray arrayWithLength:(state.gridSize)];
        }
    }
    return possibleNumbers;
}