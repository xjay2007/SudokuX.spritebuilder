//
//  appEnums.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#ifndef SudokuX_appEnums_h
#define SudokuX_appEnums_h

typedef enum : NSUInteger {
    PuzzleStatusUnknown, // The puzzle state has not been analyzed.
    PuzzleStatusInProgress, // The puzzle state does not represent a valid solution nor is it in an inconsistent state.
    PuzzleStatusSolved, // The puzzle state represents a valid solution.
    PuzzleStatusCannotBeSolved // The puzzle state represents a configuration that is known to be invalid.
} PuzzleStatus;

typedef enum : NSUInteger {
    PuzzleDifficultyEasy,
    PuzzleDifficultyMedium,
    PuzzleDifficultyHard,
    PuzzleDifficultyInvalid
} PuzzleDifficulty;

typedef enum : NSUInteger {
    ControlButtonFunctionUnvalid = -1,
    ControlButtonFunctionDigitIndexMax = 9,
    // image
    ControlButtonFunctionPen,
    ControlButtonFunctionNote,
    ControlButtonFunctionEraser,
    ControlButtonFunctionUndo,
    ControlButtonFunctionExit,
    ControlButtonFunctionHelp,
    // max
    ControlButtonFunctionMax,
} ControlButtonFunction;

#endif
