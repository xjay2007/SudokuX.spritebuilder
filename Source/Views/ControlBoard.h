//
//  ControlBoard.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-22.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

@class ControlBoard, ControlButton;
@protocol ControlBoardDelegate <NSObject>
@optional
- (void)controlBoard:(ControlBoard *)board button:(ControlButton *)button onClickFunction:(ControlButtonFunction)function;

@end

@interface ControlBoard : CCNode

@property (nonatomic, weak) id<ControlBoardDelegate>        delegate;
@end
