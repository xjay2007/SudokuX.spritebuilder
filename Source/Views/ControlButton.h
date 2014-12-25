//
//  ControlButton.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-22.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

@class ControlButton;
@protocol ControlButtonDelegate <NSObject>
@optional
- (void)controlButton:(ControlButton *)button onClickFunction:(ControlButtonFunction)functionType;

@end

@interface ControlButton : CCSprite {
    CCNode<CCLabelProtocol>     *   _label;
    CCSprite                    *   _image;
}
@property (nonatomic, assign) ControlButtonFunction     functionType;
@property (nonatomic, weak) id<ControlButtonDelegate>   delegate;

@end
