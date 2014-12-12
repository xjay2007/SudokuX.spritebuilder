//
//  Generator.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-8.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneratorOptions.h"
#import "PuzzleState.h"

@class GeneratorOptions, PuzzleState;

// Generates Sudoku puzzles.
@interface Generator : NSObject {
    GeneratorOptions        *   _options; // Options for generation.
    
}

+ (instancetype)generatorWithOptions:(GeneratorOptions *)options;
- (instancetype)initWithOptions:(GeneratorOptions *)options;

/// <summary>Generates a random Sudoku puzzle.</summary>
/// <returns>The generated puzzle.</returns>
- (PuzzleState *)generate;
@end
