//
//  WinBoard.m
//  SudokuX
//
//  Created by Kalvin Xie on 15-1-7.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "WinBoard.h"

@implementation WinBoard

- (void)onReplay:(id)sender {
    if ([self.delegate respondsToSelector:@selector(winBoardOnReplay:)]) {
        [self.delegate winBoardOnReplay:self];
    }
}

- (void)onMenu:(id)sender {
    if ([self.delegate respondsToSelector:@selector(winBoardOnMenu:)]) {
        [self.delegate winBoardOnMenu:self];
    }
}
@end
