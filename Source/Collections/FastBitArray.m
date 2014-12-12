//
//  FastBitArray.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "FastBitArray.h"


const int MAX_LENGTH = 32;

@interface FastBitArray () {
    NSUInteger          _bits; // The bits.
    NSInteger           _length; // The length, <= MAX_LENGTH
    NSInteger           _countSet; // The number of set bits in the array.
}
@property (nonatomic, assign) NSInteger     length;
@property (nonatomic, assign) NSInteger     countSet;

@end

@implementation FastBitArray

@synthesize length = _length;
@synthesize countSet = _countSet;

+ (instancetype)arrayWithLength:(NSInteger)length {
    return [[[self class] alloc] initWithLength:length];
}
+ (instancetype)arrayWithLength:(NSInteger)length defaultValue:(BOOL)defaultValue {
    return [[[self class] alloc] initWithLength:length defaultValue:defaultValue];
}
- (instancetype)initWithLength:(NSInteger)length {
    return [self initWithLength:length defaultValue:NO];
}
- (instancetype)initWithLength:(NSInteger)length defaultValue:(BOOL)defaultValue {
    self = [super init];
    if (self) {
        _length = MIN(length, MAX_LENGTH);
        [self setAllValue:defaultValue];
    }
    return self;
}

- (BOOL)valueAtIndex:(NSInteger)index {
    return (_bits & (1u << index)) != 0;
}
- (void)setValue:(BOOL)value atIndex:(NSInteger)index {
    BOOL curValue = [self valueAtIndex:index];
    if (value && !curValue) {
        _bits |= (1u << index);
        ++_countSet;
    } else if (!value && curValue) {
        _bits &= ~(1u << index);
        --_countSet;
    }
}

- (void)setAllValue:(BOOL)value {
    if (value) {
        _bits = 0xFFFFFFFF;
        _countSet = _length;
    } else {
        _bits = 0x0;
        _countSet = 0;
    }
}

- (NSArray *)bitsArray {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.length];
    for (NSInteger i = 0; i < self.length; ++i) {
        BOOL value = [self valueAtIndex:i];
        [ret addObject:@(value)];
    }
    return [ret copy];
}
- (void)setBitsArray:(NSArray *)array {
    [self setAllValue:NO];
    self.length = MIN([array count], MAX_LENGTH);
    for (NSInteger i = 0; i < self.length; ++i) {
        [self setValue:[array[i] boolValue] atIndex:i];
    }
}
- (void)bits:(BOOL **)bits length:(NSInteger *)length {
    *length = self.length;
    for (NSInteger i = 0; i < self.length; ++i) {
        *bits[i] = [self valueAtIndex:i];
    }
}
- (void)setBits:(BOOL [])bits length:(NSInteger)length {
    [self setAllValue:NO];
    self.length = MIN(length, MAX_LENGTH);
    for (NSInteger i = 0; i < self.length; ++i) {
        [self setValue:bits[i] atIndex:i];
    }
}

- (NSString *)description {
    NSMutableString *ret = [NSMutableString stringWithString:[super description]];
    [ret appendString:@":"];
    for (NSInteger i = self.length - 1; i >= 0; --i) {
        [ret appendFormat:@"%d", [self valueAtIndex:i] ? 1 : 0];
    }
    return ret;
}
@end
