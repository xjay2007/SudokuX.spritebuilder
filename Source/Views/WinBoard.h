//
//  WinBoard.h
//  SudokuX
//
//  Created by Kalvin Xie on 15-1-7.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "CCNode.h"

@class WinBoard;
@protocol WinBoardDelegate <NSObject>

@optional
- (void)winBoardOnReplay:(WinBoard *)winBoard;
- (void)winBoardOnMenu:(WinBoard *)winBoard;

@end

@interface WinBoard : CCNode
@property(nonatomic, weak) id<WinBoardDelegate> delegate;
@end
