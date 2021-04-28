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
#import <GLKit/GLKit.h>

@interface WAEJTextureCapture : NSObject
@property (nonatomic, assign) BOOL ready;
@property (nonatomic, assign) GLuint textureId;
@property (nonatomic, assign) GLint width;
@property (nonatomic, assign) GLint height;
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;
@property (nonatomic, readonly) NSMutableData* nsData;
- (id)initWithContext:(EAGLContext*)context;
- (BOOL)resize:(CAEAGLLayer*)layer;
- (BOOL)present;
@end

