//
//  SolverResults.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "SolverResults.h"

@implementation SolverResults
+ (instancetype)resultsWithStatus:(PuzzleStatus)status
                           state:(PuzzleState *)state
          numberOfDecisionPoints:(NSInteger)numberOfDecisionPoints
                 useOfTechniques:(NSDictionary *)useOfTechniques {
    return [[[self class] alloc] initWithStatus:status state:state numberOfDecisionPoints:numberOfDecisionPoints useOfTechniques:useOfTechniques];
}

- (instancetype)initWithStatus:(PuzzleStatus)status
                         state:(PuzzleState *)state
        numberOfDecisionPoints:(NSInteger)numberOfDecisionPoints
               useOfTechniques:(NSDictionary *)useOfTechniques {
    self = [super init];
    if (self) {
        _status = status;
        _puzzles = [NSMutableArray arrayWithObject:state];
        _numberOfDecisionPoints = numberOfDecisionPoints;
        _useOfTechniques = [NSMutableDictionary dictionaryWithDictionary:useOfTechniques];
    }
    return self;
}

- (PuzzleState *)puzzle {
    return [self.puzzles firstObject];
}

- (BOOL)isEqual:(id)object {
    SolverResults *other = object;
    return [other isKindOfClass:[self class]] && self.status == other.status && [self.puzzles isEqual:other.puzzles] && self.numberOfDecisionPoints == other.numberOfDecisionPoints && [self.useOfTechniques isEqual:other.useOfTechniques];
}
@end
