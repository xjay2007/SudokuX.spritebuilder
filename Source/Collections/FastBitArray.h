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
@interface FastBitArray : NSObject

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


- (NSArray *)bitsArray;
- (void)setBitsArray:(NSArray *)array;
- (void)bits:(BOOL **)bits length:(NSInteger *)length;
- (void)setBits:(BOOL [])bits length:(NSInteger)length;
@end
