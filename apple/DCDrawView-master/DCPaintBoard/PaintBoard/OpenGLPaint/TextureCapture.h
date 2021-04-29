//
//  EJTextureCapture.h
//  WAOpenGL
//
//  Created by cort xu on 2021/4/24.
//  Copyright © 2021 eldwinwang. All rights reserved.
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
@property (nonatomic, readonly) CVPixelBufferRef flipPixelBuffer;
@property (nonatomic, readonly) NSMutableData* flipNsData;
- (id)initWithContext:(EAGLContext*)context;
//- (BOOL)resize:(uint32_t)width height:(uint32_t)height;
- (BOOL)resize:(CAEAGLLayer*)layer;
- (BOOL)present;
@end

