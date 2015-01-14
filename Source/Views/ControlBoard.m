//
//  ControlBoard.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-22.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "ControlBoard.h"
#import "ControlButton.h"

const NSInteger BUTTON_PER_ROW =        5;

@interface ControlBoard () <ControlButtonDelegate>

@end

@implementation ControlBoard

- (void)onEnter {
    [super onEnter];
    
    [self updateButtonDelegate];
//    [self updateButtonLayout];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    for (CCNode *node in _buttonsNode.children) {
        [node setUserInteractionEnabled:userInteractionEnabled];
    }
}

- (void)updateButtonDelegate {
    for (ControlButton *btn in _buttonsNode.children) {
        btn.delegate = self;
    }
}

- (void)updateButtonLayout {
    
//    for (ControlButton *btn in _buttonsNode.children) {
//        
//    }
//    for (NSInteger i = 0, counter = 0; i <= ControlButtonFunctionPen; ++i) {
//        if (i == ControlButtonFunctionDigitIndexMax) {
//            continue;
//        }
//        ControlButton *button = (ControlButton *)[CCBReader load:@"ControlButton"];
//        button.functionType = i;
//        button.delegate = self;
//        [self addChild:button];
//        button.positionType = CCPositionTypeNormalized;
//        button.position = ccp(0.25f * (counter % BUTTON_PER_ROW), 1.f - 0.3f * (counter / BUTTON_PER_ROW));
//        
//        ++counter;
//    }
}

- (void)setIsNotesOn:(BOOL)isNotesOn {
    if (_isNotesOn != isNotesOn) {
        _isNotesOn = isNotesOn;
        
        for (ControlButton *btn in _buttonsNode.children) {
            if (btn.functionType < ControlButtonFunctionDigitIndexMax) {
                
            } else if (btn.functionType == ControlButtonFunctionPen) {
                btn.functionType = ControlButtonFunctionNote;
            } else if (btn.functionType == ControlButtonFunctionNote) {
                btn.functionType = ControlButtonFunctionPen;
            }
        }
    }
}

#pragma mark ControlButtonDelegate
- (void)controlButton:(ControlButton *)button onClickFunction:(ControlButtonFunction)functionType {
    if ([self.delegate respondsToSelector:@selector(controlBoard:button:onClickFunction:)]) {
        [self.delegate controlBoard:self button:button onClickFunction:functionType];
    }
}
@end
