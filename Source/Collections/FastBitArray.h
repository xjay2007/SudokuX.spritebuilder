//
//  FastBitArray.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

// A simple bit bucket class
// Maximum length of the array == sizeof(Int32)*8
@interface FastBitArray : NSObject <NSCopying>

+ (instancetype)arrayWithLength:(NSInteger)length;
+ (instancetype)arrayWithLength:(NSInteger)length defaultValue:(BOOL)defaultValue;
- (instancetype)initWithLength:(NSInteger)length;
- (instancetype)initWithLength:(NSInteger)length defaultValue:(BOOL)defaultValue;

- (BOOL)valueAtIndex:(NSInteger)index;
- (void)setValue:(BOOL)value atIndex:(NSInteger)index;

- (void)setAllValue:(BOOL)value;

// The length, <= MAX_LENGTH
@property(nonatomic, readonly) NSInteger        length;
// The number of set bits in the array.
@property(nonatomic, readonly) NSInteger        countSet;

/// <summary>Gets an array of the values set in the bit array.</summary>
/// <returns>An array of the values set.</returns>
- (NSArray *)bitsArray; //
@end
