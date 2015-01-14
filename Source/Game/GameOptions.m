//
//  GameOptions.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-30.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "GameOptions.h"

@implementation GameOptions

+ (instancetype)optionsWithDifficutyLevel:(PuzzleDifficulty)level {
    return [[GameOptions alloc] initWithDifficutyLevel:level];
}

- (instancetype)initWithDifficutyLevel:(PuzzleDifficulty)level {
    self = [super init];
    if (self) {
        _difficutyLevel = level;
        _isShowIncorrectNumbers = YES;
        _isShowSuggestedCells = YES;
        
        _isShowHighlights = YES;
        _isShowSameNumberHighlights = YES;
        _isShowSameNumberHighlightsInHints = NO;
        _isShowRelativeCellsHighlights = YES;
        _isShowNoteHighlights = YES;
        _isShowSuggestedCellsHightlights = YES;
        
        _userValueColor = [CCColor blueColor];
        _originalValueColor = [CCColor blackColor];
        _incorrectValueColor = [CCColor redColor];
        
        _noteValueColor = [CCColor blueColor];
        _incorrectNoteValueColor = [CCColor redColor];
    }
    return self;
}
@end
