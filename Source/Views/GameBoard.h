//
//  GameBoard.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-15.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface GameBoard : CCSprite {
    CCNode          *   _numberGrid;
}

- (void)updateGrid:(NSArray *)grid;
@end
