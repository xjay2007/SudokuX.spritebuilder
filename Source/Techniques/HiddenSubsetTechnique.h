//
//  HiddenSubsetTechnique.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "EliminationTechnique.h"

@interface HiddenSubsetTechnique : EliminationTechnique

@end

@interface HiddenPairTechnique : HiddenSubsetTechnique

@end

@interface HiddenTripletTechnique : HiddenSubsetTechnique

@end

@interface HiddenQuadTechnique : HiddenSubsetTechnique

@end