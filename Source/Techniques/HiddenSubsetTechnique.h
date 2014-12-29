//
//  HiddenSubsetTechnique.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-5.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "EliminationTechnique.h"

@interface HiddenSubsetTechnique : EliminationTechnique {
    @private
    // The size of the subset to evaluate.
    NSInteger           _subsetSize;
    NSMutableArray  *   _foundLocations;
}
@end

@interface HiddenPairTechnique : HiddenSubsetTechnique

@end

@interface HiddenTripletTechnique : HiddenSubsetTechnique

@end

@interface HiddenQuadTechnique : HiddenSubsetTechnique

@end