//
//  TextureCapture.h
//  demo
//
//  Created by cort xu on 2021/4/24.
//
#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>

@interface WAEJTextureCapture : NSObject
@property (nonatomic, assign) BOOL ready;
@property (nonatomic, assign) GLuint textureId;
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;
@property (nonatomic, readonly) NSMutableData* nsData;
- (id)initWithContext:(EAGLContext*)context;
- (BOOL)resize:(uint32_t)width height:(uint32_t)height;
- (BOOL)present;
@end
