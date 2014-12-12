//
//  Position.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-9.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject {
    
}

+ (instancetype)emptyPosition;

+ (instancetype)positionWithX:(NSInteger)x y:(NSInteger)y;
+ (instancetype)positionWithCGPoint:(CGPoint)point;
+ (instancetype)positionWithCGSize:(CGSize)size;
- (instancetype)initWithX:(NSInteger)x y:(NSInteger)y;
- (instancetype)initWithCGPoint:(CGPoint)point;
- (instancetype)initWithCGSize:(CGSize)size;

+ (instancetype)addPosition:(Position *)p1 withOther:(Position *)p2;
+ (instancetype)subtractPosition:(Position *)p1 withOther:(Position *)p2;
+ (BOOL)isEqualPosition:(Position *)p1 withOther:(Position *)p2;
+ (CGSize)sizeFromPosition:(Position *)p;
+ (CGPoint)pointFromPosition:(Position *)p;

@property (nonatomic, assign) NSInteger         x;
@property (nonatomic, assign) NSInteger         y;
@property (nonatomic, readonly) BOOL            isEmpty;

+ (instancetype)addPosition:(Position *)pos withSize:(CGSize)sz;
+ (instancetype)ceilingWithCGPoint:(CGPoint)p;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (void)offsetWithPosition:(Position *)pos;
- (void)offsetWithX:(NSInteger)x y:(NSInteger)y;
+ (instancetype)roundWithCGPoint:(CGPoint)p;
+ (instancetype)subtractPosition:(Position *)pos withSize:(CGSize)sz;
- (NSString *)description;
+ (instancetype)truncateWithCGPoint:(CGPoint)p;
@end
