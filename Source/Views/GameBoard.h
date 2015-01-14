//
//  GameBoard.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-15.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

@class GameBoard;
@protocol GameBoardDelegate <NSObject>

@optional
- (void)gameBoard:(GameBoard *)board onSelectPoint:(CGPoint)point;

@required
@end

@interface GameBoard : CCSprite {
    CCNode          *   _numberGrid;
    CCNode          *   _noteGrid;
    CCNode          *   _highlightGrid;
    CCNode          *   _hintHighlightGrid;
}

@property (nonatomic, weak) id<GameBoardDelegate> delegate;


- (void)updatePenAtRow:(NSInteger)row col:(NSInteger)col label:(NSString *)label color:(CCColor *)color;
- (void)updateNotesAtRow:(NSInteger)row col:(NSInteger)col numbers:(NSArray *)numbers colors:(NSArray *)colors;

// highlight
- (void)resetAllHighlights;
- (void)highlightCellAtRow:(NSInteger)row col:(NSInteger)col isHint:(BOOL)isHint;
- (void)highlightCellsAtPoints:(NSArray *)array isHint:(BOOL)isHint;
@end
