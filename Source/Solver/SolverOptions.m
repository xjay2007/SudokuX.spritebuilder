//
//  SolverOptions.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "SolverOptions.h"

@interface SolverOptions ()
@end

@implementation SolverOptions
@synthesize maximumSolutionsToFind = _maximumSolutionsToFind;
@synthesize isAllowBruteForce = _isAllowBruteForce;
@synthesize eliminationTechniques = _techniques;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maximumSolutionsToFind = @1u;
        _isAllowBruteForce = YES;
        _techniques = nil;
    }
    return self;
}

- (void)setMaximumSolutionsToFind:(NSNumber *)maximumSolutionsToFind {
    NSAssert(maximumSolutionsToFind != nil && [maximumSolutionsToFind unsignedIntegerValue] > 0, @"value");
    
    _maximumSolutionsToFind = maximumSolutionsToFind;
}

- (NSArray *)eliminationTechniques {
    if (_techniques == nil) {
        _techniques = @[];
    }
    return _techniques;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SolverOptions *copy = [[[self class] alloc] init];
    copy.maximumSolutionsToFind = [self.maximumSolutionsToFind copy];
    copy.isAllowBruteForce = self.isAllowBruteForce;
    copy.eliminationTechniques = [[NSArray alloc] initWithArray:self.eliminationTechniques];
    return copy;
}
@end
