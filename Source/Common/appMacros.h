//
//  appMacros.h
//  SudokuX
//
//  Created by Kalvin Xie on 14-12-26.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#ifndef SudokuX_appMacros_h
#define SudokuX_appMacros_h

#define COUNTER_DEBUG           1

#if COUNTER_DEBUG
#define COUNTER_START()         long ___counter___ = 0;clock_t ___t0___ = clock();
#define COUNTER_INCREASE()      {++___counter___;}
#define COUNTER_END()           {clock_t ___t1___ = clock(); printf("\n----------\ncounter == %ld\ntime = %f\n----------\n", ___counter___, (double)(___t1___ - ___t0___) / CLOCKS_PER_SEC);}
#else
#define COUNTER_START()         do{}while(0);
#define COUNTER_INCREASE()      do{}while(0);
#define COUNTER_END()           do{}while(0);
#endif //

#define GAME_SELECTED_CELL_INVALID  CGPointMake(-1,-1)

#endif
