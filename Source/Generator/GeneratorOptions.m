//
//  GeneratorOptions.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "GeneratorOptions.h"
#import "BeginnerTechnique.h"
#import "NakedSingleTechnique.h"
#import "NakedSubsetTechnique.h"
#import "BlockAndColumnRowInteractionTechnique.h"
#import "HiddenSingleTechnique.h"
#import "HiddenSubsetTechnique.h"
#import "NakedSubsetTechnique.h"
#import "XwingTechnique.h"

@interface GeneratorOptions ()
- (instancetype)    initWithSize:(Byte)size
                      difficulty:(PuzzleDifficulty)difficulty
              minimumFilledCells:(NSInteger)minimumFilledCells
   maximumNumberOfDecisionPoints:(NSNumber *)maximumNumberOfDecisionPoints
                 numberOfPuzzles:(NSInteger)numberOfPuzzles
                      techniques:(NSArray *)techniques
                isEnsureSymmetry:(BOOL)isEnsureSymmetry;
@end

@implementation GeneratorOptions
@synthesize techniques = _eliminationTechniques;

+ (instancetype)createWithDifficulty:(PuzzleDifficulty)diff {
    switch (diff) {
        case PuzzleDifficultyEasy: {
            return [[[self class] alloc] initWithSize:3
                                           difficulty:PuzzleDifficultyEasy
                                   minimumFilledCells:32
                        maximumNumberOfDecisionPoints:@0
                                      numberOfPuzzles:1//3
                                           techniques:@[
                                                        [BeginnerTechnique technique]
                                                        ]
                                     isEnsureSymmetry:YES];
        }
        case PuzzleDifficultyMedium: {
            return [[[self class] alloc] initWithSize:3
                                           difficulty:PuzzleDifficultyMedium
                                   minimumFilledCells:0
                        maximumNumberOfDecisionPoints:@0
                                      numberOfPuzzles:1//10
                                           techniques:@[
                                                        [BeginnerTechnique technique],
                                                        [NakedSingleTechnique technique],
                                                        [HiddenSingleTechnique technique],
                                                        [BlockAndColumnRowInteractionTechnique technique],
                                                        [NakedPairTechnique technique],
                                                        [HiddenPairTechnique technique],
                                                        [NakedTripletTechnique technique],
                                                        ]
                                     isEnsureSymmetry:YES];
        }
        case PuzzleDifficultyHard: {
            return [[[self class] alloc] initWithSize:3
                                           difficulty:PuzzleDifficultyHard
                                   minimumFilledCells:0
                        maximumNumberOfDecisionPoints:nil
                                      numberOfPuzzles:1//20
                                           techniques:@[
                                                        [BeginnerTechnique technique],
                                                        [NakedSingleTechnique technique],
                                                        [HiddenSingleTechnique technique],
                                                        [BlockAndColumnRowInteractionTechnique technique],
                                                        [NakedPairTechnique technique],
                                                        [HiddenPairTechnique technique],
                                                        [NakedTripletTechnique technique],
                                                        [HiddenTripletTechnique technique],
                                                        [NakedQuadTechnique technique],
                                                        [HiddenQuadTechnique technique],
                                                        [XwingTechnique technique],
                                                        ]
                                     isEnsureSymmetry:YES];
        }
            
        default:
            NSAssert(NO, @"difficultyLevel");
            break;
    }
    return nil;
}

- (instancetype)    initWithSize:(Byte)size
                      difficulty:(PuzzleDifficulty)difficulty
              minimumFilledCells:(NSInteger)minimumFilledCells
   maximumNumberOfDecisionPoints:(NSNumber *)maximumNumberOfDecisionPoints
                 numberOfPuzzles:(NSInteger)numberOfPuzzles
                      techniques:(NSArray *)techniques
                isEnsureSymmetry:(BOOL)isEnsureSymmetry {
    self = [super init];
    if (self) {
        NSAssert(size == 3, @"size");
        NSAssert(difficulty == PuzzleDifficultyEasy || difficulty == PuzzleDifficultyMedium || difficulty == PuzzleDifficultyHard, @"difficulty");
        NSAssert(minimumFilledCells >= 0, @"minimumFilledCells");
        NSAssert(numberOfPuzzles >= 1, @"numberOfPuzzles");
        NSAssert(techniques != nil, @"techniques");
        
        _difficulty = difficulty;
        _size = size;
        _minimumFilledCells = minimumFilledCells;
        _maximumNumberOfDecisionPoints = maximumNumberOfDecisionPoints;
        _numberOfPuzzles = numberOfPuzzles;
        _isEnsureSymmetry = isEnsureSymmetry;
        _eliminationTechniques = [NSArray arrayWithArray:techniques];
    }
    return self;
}
@end
