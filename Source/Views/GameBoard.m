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

static NSString   *const FONT_NAME = @"Helvetica-Bold";
static const CGFloat    FONT_SIZE = 20;

@implementation GameBoard

- (void)didLoadFromCCB {
    self.userInteractionEnabled = YES;
}

- (void)updateGrid:(NSArray *)grid {
    [grid enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger row, BOOL *stop) {
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger col, BOOL *stop) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [obj unsignedCharValue] + 1] fontName:FONT_NAME fontSize:FONT_SIZE];
                label.color = [CCColor blackColor];
                label.position = [self positionWithRow:row col:col];
                [_numberGrid addChild:label];
                label.name = [NSString stringWithFormat:@"%lu, %lu", row, col];
            }
        }];
    }];
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint position = [touch locationInNode:self];
    CGPoint point = [self pointWithPosition:position];
    CCLOG(@"%@, %@", NSStringFromCGPoint(position), NSStringFromCGPoint(point));
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
    return ccp(col, row);
}

- (void)convertPosition:(CGPoint)position toRow:(NSInteger *)row col:(NSInteger *)col {
    CGPoint point = [self pointWithPosition:position];
    *row = point.y;
    *col = point.x;
}

- (CGPoint)positionWithPoint:(CGPoint)point {
    return [self positionWithRow:point.y col:point.x];
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

- (NSString *)cellHighlightedImageNameWithRow:(NSInteger)row col:(NSInteger)col {
    if (row == 0) {
        if (col == 0) {
            return @"Images/CellActiveUpperLeft.png";
        } else if (col == CELL_ROW_MAX - 1) {
            return @"Images/CellActiveUpperRight.png";
        }
    }
    if (row == CELL_ROW_MAX - 1) {
        if (col == 0) {
            return @"Images/CellActiveLowerLeft.png";
        } else if (col == CELL_ROW_MAX - 1) {
            return @"Images/CellActiveLowerRight.png";
        }
    }
    return @"Images/CellActiveSquare.png";
}
@end
