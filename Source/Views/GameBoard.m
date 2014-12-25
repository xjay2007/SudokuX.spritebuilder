//
//  GameBoard.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-15.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "GameBoard.h"

static const NSInteger  BOX_SIZE = 3;
static const NSInteger  CELL_ROW_MAX = BOX_SIZE * BOX_SIZE;
static const NSInteger  CELL_COL_MAX = BOX_SIZE * BOX_SIZE;
static const CGFloat    CELL_WIDTH = 27;
static const CGFloat    CELL_HEIGHT = 27;
static const CGFloat    CELL_GAP_WIDTH = 0.5;
static const CGFloat    CELL_GAP_HEIGHT = 0.5;
static const CGFloat    BOX_GAP_WIDTH = 6.5;
static const CGFloat    BOX_GAP_HEIGHT = 6.5;
static const CGFloat    BOX_WIDTH = CELL_WIDTH * BOX_SIZE + CELL_GAP_WIDTH * (BOX_SIZE - 1) + BOX_GAP_WIDTH;
static const CGFloat    BOX_HEIGHT = CELL_HEIGHT * BOX_SIZE + CELL_GAP_HEIGHT * (BOX_SIZE - 1) + BOX_GAP_HEIGHT;

static NSString *const  FONT_NAME = @"Helvetica-Bold";
static const CGFloat    FONT_SIZE = 20;

@implementation GameBoard

- (void)didLoadFromCCB {
    self.userInteractionEnabled = YES;
    for (NSInteger row = 0; row < CELL_ROW_MAX; ++row) {
        for (NSInteger col = 0; col < CELL_COL_MAX; ++col) {
            CGPoint position = [self positionWithRow:row col:col];
            NSString *name = [self childNameWithRow:row col:col];
            CCLabelTTF *labelPen = [CCLabelTTF labelWithString:@"" fontName:FONT_NAME fontSize:FONT_SIZE];
            labelPen.position = position;
            labelPen.name = name;
            [_numberGrid addChild:labelPen];
            
            CCNode *nodeNote = [CCNode node];
            nodeNote.position = position;
            nodeNote.contentSize = CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
            nodeNote.anchorPoint = ccp(0.5f, 0.5f);
            nodeNote.name = name;
            [_noteGrid addChild:nodeNote];
            
            // hightlight
            CCSprite *highlightImage = [CCSprite spriteWithImageNamed:[self cellHighlightedImageNameWithRow:row col:col isHint:NO]];
            highlightImage.position = position;
            highlightImage.name = name;
            highlightImage.visible = NO;
            [_highlightGrid addChild:highlightImage];
            
            
            CCSprite *hintHighlightImage = [CCSprite spriteWithImageNamed:[self cellHighlightedImageNameWithRow:row col:col isHint:YES]];
            hintHighlightImage.position = position;
            hintHighlightImage.name = name;
            hintHighlightImage.visible = NO;
            [_hintHighlightGrid addChild:hintHighlightImage];
        }
    }
}

- (void)updateAllGrid {
    for (NSInteger row = 0; row < CELL_ROW_MAX; ++row) {
        for (NSInteger col = 0; col < CELL_COL_MAX; ++col) {
            CCLabelTTF *labelPen = (CCLabelTTF *)[_numberGrid getChildByName:[self childNameWithRow:row col:col] recursively:NO];
            NSString *string = @"";
            CCColor *color = [CCColor blackColor];
            [self.delegate gameBoard:self getLabelString:&string andColor:&color atRow:row col:col];
            labelPen.string = string;
            labelPen.color = color;
        }
    }
}
- (void)updateCellAtRow:(NSInteger)row col:(NSInteger)col {
    [self updatePenAtRow:row col:col];
}

- (void)updatePenAtRow:(NSInteger)row col:(NSInteger)col {
    CCLabelTTF *labelPen = (CCLabelTTF *)[_numberGrid getChildByName:[self childNameWithRow:row col:col] recursively:NO];
    NSString *string = @"";
    CCColor *color = [CCColor blackColor];
    [self.delegate gameBoard:self getLabelString:&string andColor:&color atRow:row col:col];
    labelPen.string = string;
    labelPen.color = color;
}

#pragma mark Highlight
- (void)resetAllHighlights {
    for (CCSprite *spr in _highlightGrid.children) {
        spr.visible = NO;
    }
    for (CCSprite *spr in _hintHighlightGrid.children) {
        spr.visible = NO;
    }
}
- (void)highlightCellAtRow:(NSInteger)row col:(NSInteger)col isHint:(BOOL)isHint {
    NSString *name = [self childNameWithRow:row col:col];
    CCNode *node = [(isHint ? _hintHighlightGrid : _highlightGrid) getChildByName:name recursively:NO];
    node.visible = YES;
}
- (void)highlightCellsAtPoints:(NSArray *)array isHint:(BOOL)isHint {
    for (NSValue *value in array) {
        CGPoint point = [value CGPointValue];
        [self highlightCellAtRow:point.x col:point.y isHint:isHint];
    }
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint position = [touch locationInNode:self];
    CGPoint point = [self pointWithPosition:position];
    CCLOG(@"%@, %@", NSStringFromCGPoint(position), NSStringFromCGPoint(point));
    
    if ([self.delegate respondsToSelector:@selector(gameBoard:onSelectPoint:)]) {
        [self.delegate gameBoard:self onSelectPoint:point];
    }
}

- (CGPoint)pointWithPosition:(CGPoint)position {
    NSInteger boxCol = position.x / BOX_WIDTH;
    NSInteger boxRow = position.y / BOX_HEIGHT;
    CGPoint posBoxStart = ccp(boxCol * BOX_WIDTH, boxRow * BOX_HEIGHT);
    CGPoint posOffsetInBox = ccpSub(position, posBoxStart);
    NSInteger colInBox = posOffsetInBox.x / (CELL_WIDTH + CELL_GAP_WIDTH);
    NSInteger rowInBox = posOffsetInBox.y / (CELL_HEIGHT + CELL_GAP_HEIGHT);
    NSInteger col = boxCol * BOX_SIZE + colInBox;
    NSInteger row = boxRow * BOX_SIZE + rowInBox;
    row = CELL_ROW_MAX - 1 - row;
    return ccp(row, col);
}

- (void)convertPosition:(CGPoint)position toRow:(NSInteger *)row col:(NSInteger *)col {
    CGPoint point = [self pointWithPosition:position];
    *row = point.x;
    *col = point.y;
}

- (CGPoint)positionWithPoint:(CGPoint)point {
    return [self positionWithRow:point.x col:point.y];
}

- (CGPoint)positionWithRow:(NSInteger)row col:(NSInteger)col {
    row = CELL_ROW_MAX - 1 - row;
    NSInteger boxCol = col / BOX_SIZE;
    NSInteger boxRow = row / BOX_SIZE;
    CGPoint posBoxStart = ccp(boxCol * BOX_WIDTH, boxRow * BOX_HEIGHT);
    NSInteger colInBox = col % BOX_SIZE;
    NSInteger rowInBox = row % BOX_SIZE;
    CGPoint position = ccpAdd(posBoxStart, ccp(colInBox * (CELL_WIDTH + CELL_GAP_WIDTH), rowInBox * (CELL_HEIGHT + CELL_GAP_HEIGHT)));
    position = ccpAdd(position, ccpMult(ccp(CELL_WIDTH, CELL_HEIGHT), 0.5));
    return position;
}

- (NSString *)cellHighlightedImageNameWithRow:(NSInteger)row col:(NSInteger)col isHint:(BOOL)isHint {
    if (row == 0) {
        if (col == 0) {
            return isHint ? @"Images/CellHintUpperLeft.png" : @"Images/CellActiveUpperLeft.png";
        } else if (col == CELL_ROW_MAX - 1) {
            return isHint ? @"Images/CellHintUpperRight.png" : @"Images/CellActiveUpperRight.png";
        }
    }
    if (row == CELL_ROW_MAX - 1) {
        if (col == 0) {
            return isHint ? @"Images/CellHintLowerLeft.png" : @"Images/CellActiveLowerLeft.png";
        } else if (col == CELL_ROW_MAX - 1) {
            return isHint ? @"Images/CellHintLowerRight.png" : @"Images/CellActiveLowerRight.png";
        }
    }
    return isHint ? @"Images/CellHintSquare.png" : @"Images/CellActiveSquare.png";
}

- (NSString *)childNameWithRow:(NSInteger)row col:(NSInteger)col {
    return [NSString stringWithFormat:@"%lu, %lu", row, col];
}
@end
