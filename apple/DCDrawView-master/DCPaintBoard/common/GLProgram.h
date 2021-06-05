//
//  GLProgram.h
//  DrawingBoard
//
//  Created by cort xu on 2021/5/22.
//

#ifndef GLProgram_h
#define GLProgram_h
#import "GLDefine.h"

@interface GLProgram : NSObject
@property (nonatomic, assign, readonly) BOOL ready;
@property (nonatomic, assign, readonly) GLuint program;
- (BOOL)attach:(const char*)vShader fragShader:(const char*)fShader;
- (void)use;
- (GLint)getAttrib:(const char*)name;
- (GLint)getUniform:(const char*)name;
- (void)detach;
@end

#endif /* GLProgram_h */
