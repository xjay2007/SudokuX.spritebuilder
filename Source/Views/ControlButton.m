//
//  ControlButton.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-22.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "ControlButton.h"

@implementation ControlButton

- (void)didLoadFromCCB {
    _functionType = ControlButtonFunctionUnvalid;
    _image.visible = NO;
    _label.visible = NO;
}

- (void)onEnter {
    [super onEnter];
    
    [self updateFunctionDisplay];
}

- (void)setFunctionType:(ControlButtonFunction)functionType {
    if (_functionType != functionType) {
        _functionType = functionType;
        
        [self updateFunctionDisplay];
    }
}

- (void)updateFunctionDisplay {
    _image.visible = self.functionType != ControlButtonFunctionUnvalid && self.functionType > ControlButtonFunctionDigitIndexMax;
    _label.visible = self.functionType != ControlButtonFunctionUnvalid && self.functionType < ControlButtonFunctionDigitIndexMax;
    [_label setString:[NSString stringWithFormat:@"%lu", self.functionType + 1]];
    NSString *imageName = [self imageNameWithFunctionType:self.functionType];
    if (imageName) {
        _image.spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
    }
}

- (void)onClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlButton:onClickFunction:)]) {
        [self.delegate controlButton:self onClickFunction:self.functionType];
    }
}

- (NSString *)imageNameWithFunctionType:(ControlButtonFunction)functionType {
    switch (functionType) {
        case ControlButtonFunctionPen:
            return @"Images/Pen.png";
            break;
            
        default:
            break;
    }
    return nil;
}
@end
