//
//  GLTexture.h
//  DrawingBoard
//
//  Created by cort xu on 2021/5/22.
//

#ifndef GLTexture_h
#define GLTexture_h
#import "GLDefine.h"

@interface GLTexture : NSObject
@property (nonatomic, assign, readonly) BOOL ready;
@property (nonatomic, assign, readonly) GLuint textureId;
@property (nonatomic, readonly) CVPixelBufferRef textureBuffer;
-(BOOL)resize:(CVOpenGLESTextureCacheRef)cache width:(uint32_t)width height:(uint32_t)height;
@end

#endif /* GLTexture_h */
