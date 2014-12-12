#import "MainScene.h"
#import "Generator.h"

#define SUDOKU_TABLE_LENGTH            9
#define SUDOKU_BLOCK_LENGTH            3

#define COUNTER_DEBUG           1

#if COUNTER_DEBUG
#define COUNTER_START()         long ___counter___ = 0;clock_t ___t0___ = clock();
#define COUNTER_INCREASE()      {++___counter___;}
#define COUNTER_END()           {clock_t ___t1___ = clock(); printf("\n----------\ncounter == %ld\ntime = %f\n----------\n", ___counter___, (double)(___t1___ - ___t0___) / CLOCKS_PER_SEC);}
#else
#define COUNTER_START()         do{}while(0);
#define COUNTER_INCREASE()      do{}while(0);
#define COUNTER_END()           do{}while(0);
#endif //

@interface AObj : NSObject
@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;

+ (instancetype)objWithX:(NSInteger)x y:(NSInteger)y;
- (instancetype)initWithX:(NSInteger)x y:(NSInteger)y;
@end

@implementation AObj
@synthesize x = _x, y = _y;

+ (instancetype)objWithX:(NSInteger)x y:(NSInteger)y {
    return [[[self class] alloc] initWithX:x y:y];
}
- (instancetype)initWithX:(NSInteger)x y:(NSInteger)y
{
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
    }
    return self;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@"{%ld, %ld}", self.x, self.y];
}
@end

@implementation MainScene


- (void)reload:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}

- (void)didLoadFromCCB {
    [self generateSudoku2];
//    NSMutableArray *a = [NSMutableArray arrayWithObjects:[AObj objWithX:0 y:0], [AObj objWithX:1 y:1], [AObj objWithX:2 y:2], nil];
//    CCLOG(@"before a = %@", a);
//    ((AObj *)a[0]).x = 2;
//    [self doWithArray:a];
//    CCLOG(@"after a = %@", a);
}

- (void)doWithArray:(NSMutableArray *)array {
    ((AObj *)array[0]).x = 1;
    array[1] = [AObj objWithX:3 y:3];
}

- (void)generateSudoku2 {
    COUNTER_START();
    Generator *generator = [Generator generatorWithOptions:[GeneratorOptions createWithDifficulty:PuzzleDifficultyEasy]];
    PuzzleState *state = [generator generate];
    COUNTER_END();
    CCLOG(@"state = %@", state);
}


- (BOOL)isNumUnique:(int)num inTable:(int[SUDOKU_TABLE_LENGTH][SUDOKU_TABLE_LENGTH])table atRow:(int)row col:(int)col {
    NSAssert(row >= 0 && row < SUDOKU_TABLE_LENGTH && col >= 0 && col < SUDOKU_TABLE_LENGTH, @"Out of boundary");
    BOOL ret = YES;
    // in row
    for (int i = 0; i < SUDOKU_TABLE_LENGTH; ++i) {
        if (num == table[row][i]) {
            ret = NO;
            break;
        }
    }
    if (!ret) {
        return ret;
    }
    
    // in col
    for (int i = 0; i < SUDOKU_TABLE_LENGTH; ++i) {
        if (num == table[i][col]) {
            ret = NO;
            break;
        }
    }
    if (!ret) {
        return ret;
    }
    // in block
    int blockRow = row / SUDOKU_BLOCK_LENGTH;
    int blockCol = col / SUDOKU_BLOCK_LENGTH;
    for (int i = 0; i < SUDOKU_BLOCK_LENGTH; ++i) {
        for (int j = 0; j < SUDOKU_BLOCK_LENGTH; ++j) {
            if (num == table[blockRow * SUDOKU_BLOCK_LENGTH + i][blockCol * SUDOKU_BLOCK_LENGTH + j]) {
                ret = NO;
                break;
            }
        }
    }
    if (!ret) {
        return ret;
    }
    return ret;
}

- (void)generateSudoku {
    
    NSMutableString *tableString = [[NSMutableString alloc] initWithString:@"\n"];
    NSMutableArray *table = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
    for (int i = 0; i < SUDOKU_TABLE_LENGTH; ++i) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
        for (int j = 0; j < SUDOKU_TABLE_LENGTH; ++j) {
            [row addObject:@0];
        }
        [table addObject:row];
    }
    NSSet *fullNumSet = [NSSet setWithArray:@[@1, @2, @3, @4, @5, @6, @7, @8, @9]];
    NSMutableArray *rowCache = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
    NSMutableArray *colCache = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
    NSMutableArray *blockCache = [NSMutableArray arrayWithCapacity:SUDOKU_TABLE_LENGTH];
    
    COUNTER_START();
    int blockCachedRow = 0;
    int blockCachedCol = 0;
    for (int i = 0; i < [table count]; ++i) {
        [rowCache removeAllObjects];
        for (int j = 0; j < [table[i] count]; ++j) {
            // check col
            [colCache removeAllObjects];
            for (int k = 0; k < i; ++k) {
                [colCache addObject:table[k][j]];
                COUNTER_INCREASE();
            }
            // check block
            if (i / SUDOKU_BLOCK_LENGTH != blockCachedRow || j / SUDOKU_BLOCK_LENGTH != blockCachedCol) {
                blockCachedRow = i / SUDOKU_BLOCK_LENGTH;
                blockCachedCol = j / SUDOKU_BLOCK_LENGTH;
                [blockCache removeAllObjects];
                for (int m = blockCachedRow * SUDOKU_BLOCK_LENGTH; m <= i; ++m) {
                    for (int n = blockCachedCol * SUDOKU_BLOCK_LENGTH; (m < i && n < (blockCachedCol + 1) * SUDOKU_BLOCK_LENGTH) || (m == i && n < j); ++n) {
                        [blockCache addObject:table[m][n]];
                        COUNTER_INCREASE();
                    }
                }
            }
            
            NSMutableSet *numSet = [NSMutableSet setWithArray:rowCache];
            [numSet addObjectsFromArray:colCache];
            [numSet addObjectsFromArray:blockCache];
            
            NSMutableSet *finalSet = [NSMutableSet setWithSet:fullNumSet];
            [finalSet minusSet:numSet];
            
            if ([finalSet count] == 0 || [finalSet containsObject:@0]) {
                CCLOG(@"{ i = %d, j = %d}", i, j);
                if ( j > 0) {
                    // the last numbers
                    NSMutableSet *lastLackedNumberSet = [NSMutableSet setWithSet:fullNumSet];
                    [lastLackedNumberSet minusSet:[NSSet setWithArray:rowCache]];
                    if ([lastLackedNumberSet count] == 0) {
                        NSAssert(NO, @"should not be here");
                    }
                    NSInteger row = NSNotFound;
                    NSInteger rowInBlock = NSNotFound;
                    NSInteger rowInCol = NSNotFound;
                    for (NSNumber *number in lastLackedNumberSet) {
                        NSInteger rowFoundInBlock = [blockCache indexOfObject:number];
                        rowInBlock = (rowInBlock == NSNotFound) ? rowFoundInBlock : ((rowFoundInBlock == NSNotFound) ? rowInBlock : MIN(rowInBlock, rowFoundInBlock));
                        NSInteger rowFoundInCol = [colCache indexOfObject:number];
                        rowInCol = (rowInCol == NSNotFound) ? rowFoundInCol : ((rowFoundInCol == NSNotFound) ? rowInCol : MIN(rowInCol, rowFoundInCol));
                        COUNTER_INCREASE();
                    }
                    if (rowInBlock != NSNotFound) {
                        row = rowInBlock / SUDOKU_BLOCK_LENGTH + blockCachedRow * SUDOKU_BLOCK_LENGTH;
                        CCLOG(@"same number in block %d", (int)row);
                    } else if (rowInCol != NSNotFound) {
                        row = rowInCol;
                        CCLOG(@"same number in col %d", (int)row);
                    } else {
                        NSAssert(NO, @"something is wrong");
                    }
                    
                    if (row != NSNotFound) {
                        for (int m = i; m >= (int)row; --m) {
                            for (int n = 0; n < SUDOKU_TABLE_LENGTH; ++n) {
                                table[m][n] = @0;
                                COUNTER_INCREASE();
                            }
                        }
                        i = MAX((int)row - 1, -1);
                    }
                }
                // back to the prev line
                else if (j > 0) {
                    for (int k = 0; k < j; ++k) {
                        table[i][k] = @0;
                        COUNTER_INCREASE();
                    }
                    --i;
                } else {
                    int prevRow = MAX(i - 1, 0);
                    for (int k = 0; k < SUDOKU_TABLE_LENGTH; ++k) {
                        table[prevRow][k] = @0;
                        COUNTER_INCREASE();
                    }
                    i = MAX(prevRow - 1, -1);
                }
                break;
            }
            
            id num = nil;
            do {
                if (num) {
                    [finalSet removeObject:num];
                }
                num = [finalSet allObjects][arc4random_uniform((u_int32_t)[finalSet count])];
                COUNTER_INCREASE();
            } while ([rowCache containsObject:num] || [colCache containsObject:num] || [blockCache containsObject:num]);
            table[i][j] = num;
            
            [rowCache addObject:num];
            [blockCache addObject:num];
            COUNTER_INCREASE();
        }
    }
    
    COUNTER_END();
    
    [table enumerateObjectsUsingBlock:^(NSArray *row, NSUInteger i, BOOL *stop) {
        [row enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger j, BOOL *stop) {
            [tableString appendFormat:@"%@ %@", num, (j + 1) % 3 == 0 ? @"|" : @""];
        }];
        [tableString appendFormat:@"\n%@", (i + 1) % 3 == 0 ? @"---------------------\n" : @""];
    }];
    //    for (NSArray *row in table) {
    //        [tableString appendFormat:@"%@\n",[row componentsJoinedByString:@" "]];
    //
    //    }
    CCLOG(@"tableString = %@", tableString);
}

@end
