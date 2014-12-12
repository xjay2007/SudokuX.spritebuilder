//
//  Position.m
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-9.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Position.h"

@implementation Position
@synthesize x = _x, y = _y;

+ (instancetype)emptyPosition {
    return [[Position alloc] init];
}

+ (instancetype)positionWithX:(NSInteger)x y:(NSInteger)y {
    return [[Position alloc] initWithX:x y:y];
}
+ (instancetype)positionWithCGPoint:(CGPoint)point {
    return [[Position alloc] initWithCGPoint:point];
}
+ (instancetype)positionWithCGSize:(CGSize)size {
    return [[Position alloc] initWithCGSize:size];
}
- (instancetype)initWithX:(NSInteger)x y:(NSInteger)y {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
    }
    return self;
}
- (instancetype)initWithCGPoint:(CGPoint)point {
    return [self initWithX:point.x y:point.y];
}
- (instancetype)initWithCGSize:(CGSize)size {
    return [self initWithX:size.width y:size.height];
}
- (instancetype)init {
    return [self initWithX:0 y:0];
}

+ (instancetype)addPosition:(Position *)p1 withOther:(Position *)p2 {
    return [Position positionWithX:p1.x + p2.x y:p1.y + p2.y];
}
+ (instancetype)subtractPosition:(Position *)p1 withOther:(Position *)p2 {
    return [Position positionWithX:p1.x - p2.x y:p1.y - p2.y];
}
+ (BOOL)isEqualPosition:(Position *)p1 withOther:(Position *)p2 {
    return [p1 isKindOfClass:[Position class]] && [p2 isKindOfClass:[Position class]] && [p1 isEqual:p2];
}
+ (CGSize)sizeFromPosition:(Position *)p {
    return CGSizeMake(p.x, p.y);
}
+ (CGPoint)pointFromPosition:(Position *)p {
    return CGPointMake(p.x, p.y);
}

- (BOOL)isEmpty {
    return self.x == 0 && self.y == 0;
}

+ (instancetype)addPosition:(Position *)pos withSize:(CGSize)sz {
//    return [Position addPosition:pos withOther:[Position positionWithCGSize:sz]];
    return [Position positionWithX:pos.x + sz.width y:pos.y + sz.height];
}
+ (instancetype)ceilingWithCGPoint:(CGPoint)p {
    return [Position positionWithX:ceil(p.x) y:ceil(p.y)];
}

- (BOOL)isEqual:(id)object {
    Position *other = object;
    return [other isKindOfClass:[Position class]] && self.x == other.x && self.y == other.y;
}
- (NSUInteger)hash {
    return [[self description] hash];
}
- (void)offsetWithPosition:(Position *)pos {
    self.x += pos.x;
    self.y += pos.y;
}
- (void)offsetWithX:(NSInteger)x y:(NSInteger)y {
    self.x += x;
    self.y += y;
}
+ (instancetype)roundWithCGPoint:(CGPoint)p {
    return [Position positionWithX:round(p.x) y:round(p.y)];
}
+ (instancetype)subtractPosition:(Position *)pos withSize:(CGSize)sz {
    return [Position positionWithX:pos.x - sz.width y:pos.y - sz.height];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {%ld, %ld}", [super description], self.x, self.y];
}
+ (instancetype)truncateWithCGPoint:(CGPoint)p {
    return [Position positionWithX:trunc(p.x) y:trunc(p.y)];
}
@end
