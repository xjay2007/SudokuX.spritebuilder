//
//  GameOptions.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-30.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameOptions : NSObject {
    
    // The puzzle difficulty level used for showing hints.
    PuzzleDifficulty    _difficutyLevel;
    
    // Whether to highlight cells that can only be a specific number.
    BOOL                _isShowSuggestedCells;
    
    // Whether to show where incorrect numbers have been added to the grid.
    BOOL                _isShowIncorrectNumbers;
    
    // Highlight options
    // Whether to show highlights, total switch
    BOOL                _isShowHighlights;
    // whether to show same number highlight
    BOOL                _isShowSameNumberHighlights;
    BOOL                _isShowSameNumberHighlightsInHints; // show same number highlight in yellow
    // Whether to show relative cells, yellow highlight
    BOOL                _isShowRelativeCellsHighlights;
    // Whether to highlight the notes cells those contain current number, yellow highlight
    BOOL                _isShowNoteHighlights;
    // whether to highlight suggested cells with current number, yellow highlight
    BOOL                _isShowSuggestedCellsHightlights;
    
    // Color
    CCColor         *   _userValueColor;
    CCColor         *   _originalValueColor;
    CCColor         *   _incorrectValueColor;
    CCColor         *   _noteValueColor;
    CCColor         *   _incorrectNoteValueColor;
}

+ (instancetype)optionsWithDifficutyLevel:(PuzzleDifficulty)level;
- (instancetype)initWithDifficutyLevel:(PuzzleDifficulty)level;

@property (nonatomic, assign)   BOOL                isShowSuggestedCells;
@property (nonatomic, assign)   BOOL                isShowIncorrectNumbers;
@property (nonatomic, readonly) PuzzleDifficulty    difficutyLevel;
// Highlight
@property (nonatomic, assign)   BOOL                isShowHighlights;
@property (nonatomic, assign)   BOOL                isShowSameNumberHighlights;
@property (nonatomic, assign)   BOOL                isShowSameNumberHighlightsInHints;
@property (nonatomic, assign)   BOOL                isShowRelativeCellsHighlights;
@property (nonatomic, assign)   BOOL                isShowNoteHighlights;
@property (nonatomic, assign)   BOOL                isShowSuggestedCellsHightlights;
// Color
@property (nonatomic, strong)   CCColor         *   userValueColor;
@property (nonatomic, strong)   CCColor         *   originalValueColor;
@property (nonatomic, strong)   CCColor         *   incorrectValueColor;
@property (nonatomic, strong)   CCColor         *   noteValueColor;
@property (nonatomic, strong)   CCColor         *   incorrectNoteValueColor;

@end
