//
//  DrawBoardCtx.h
//  DCPaintBoard
//
//  Created by cort xu on 2021/6/5.
//  Copyright © 2021 Wade. All rights reserved.
//

#ifndef DrawBoardCtx_h
#define DrawBoardCtx_h
#import <Foundation/Foundation.h>
#import "common/GLDefine.h"

@interface DrawBoardCtx : NSObject
- (BOOL)create;
- (BOOL)render:(CAEAGLLayer*)layer;
- (void)destroy;
@end

#endif /* DrawBoardCtx_h */
