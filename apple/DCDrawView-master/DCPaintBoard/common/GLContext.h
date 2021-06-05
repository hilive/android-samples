//
//  GLContext.h
//  DrawingBoard
//
//  Created by cort xu on 2021/5/22.
//

#ifndef GLContext_h
#define GLContext_h
#import "GLDefine.h"

@interface GLContext : NSObject
@property (nonatomic, nullable, readonly) CVOpenGLESTextureCacheRef textureCache;
- (id)initWithShare:(nullable EAGLSharegroup*)group;
-(void)join;
-(void)leave;
@end

#endif /* GLContext_h */
