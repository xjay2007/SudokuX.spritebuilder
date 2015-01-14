//
//  Game.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-30.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameOptions.h"

@class PuzzleState, GameOptions, Game;

@protocol GameDelegate <NSObject>

@optional
- (void)game:(Game *)game updatePenAtRow:(NSInteger)row col:(NSInteger)col label:(NSString *)label color:(CCColor *)color;
- (void)game:(Game *)game updateNotesAtRow:(NSInteger)row col:(NSInteger)col numbers:(NSArray *)numbers colors:(NSArray *)colors;

- (void)game:(Game *)game updateIsNotesOn:(BOOL)isNotesOn;

- (void)game:(Game *)game updateHighlightedCells:(NSArray *)cells hintCells:(NSArray *)hintCells;

- (void)game:(Game *)game didFinishAndIsWinning:(BOOL)isWinning;
@end

@interface Game : NSObject {
    
    // Game options
    GameOptions     *   _options;
    
    // The state currently being displayed in the grid.
    PuzzleState     *   _state;
    
    // The original state of a newly generated puzzle, used for comparison.
    PuzzleState     *   _originalState;
    
    // The original state of a newly generated puzzle, used for comparison.
    PuzzleState     *   _solvedOriginalState;
    
    // turn on the notes.
    BOOL                _isNotesOn;
    // current notes set in each cell by user
    NSMutableArray  *   _userNotes; // FastBitArray[][]
    // Notes computed by Solver class
    NSArray         *   _gameNotes;
    
    // Maintains a history of undo information.
    NSMutableArray  *   _undoStack;
    
    // Currently selected cell in the grid.
    CGPoint             _selectedCell;
}

+ (instancetype)gameWithOptions:(GameOptions *)options;
- (instancetype)initWithOptions:(GameOptions *)options;

@property (nonatomic, readonly) GameOptions         *   options;
@property (nonatomic, strong)   PuzzleState         *   state;
@property (nonatomic, strong)   PuzzleState         *   originalState;
@property (nonatomic, strong)   PuzzleState         *   solvedOriginalState;
@property (nonatomic, readonly) NSMutableArray      *   userNotes;
@property (nonatomic, readonly) NSArray             *   gameNotes;
@property (nonatomic, assign)   CGPoint                 selectedCell;
@property (nonatomic, assign)   BOOL                    isNotesOn;

@property (nonatomic, weak) id<GameDelegate>            delegate;

- (void)generateNewPuzzle;
- (void)loadNewPuzzleWithState:(PuzzleState *)state;
//
- (void)clickFunction:(ControlButtonFunction)function;

// update this cells
- (void)updateAllGrid;
- (void)updateCells:(NSArray *)cells;
// manually update label and string
- (void)updateCellAtRow:(NSInteger)row col:(NSInteger)col;

#pragma mark - Helper
// label and color in {row, col}
- (NSString *)labelWithRow:(NSInteger)row col:(NSInteger)col;
- (CCColor *)colorWithRow:(NSInteger)row col:(NSInteger)col;

- (NSArray *)noteNumbersWithRow:(NSInteger)row col:(NSInteger)col;
- (NSArray *)noteColorsWithRow:(NSInteger)row col:(NSInteger)col;

// points
- (NSArray *)pointsInSameRowWithPoint:(CGPoint)point isOriginalPointExclusive:(BOOL)isExclusive;
- (NSArray *)pointsInSameColWithPoint:(CGPoint)point isOriginalPointExclusive:(BOOL)isExclusive;
- (NSArray *)pointsInSameBlockWithPoint:(CGPoint)point isOriginalPointExclusive:(BOOL)isExclusive;
- (NSArray *)pointsRelativeWithPoint:(CGPoint)point  isOriginalPointExclusive:(BOOL)isExclusive;
@end
