//
//  TextureCapture.m
//  demo
//
//  Created by cort xu on 2021/4/24.
//
#import "TextureCapture.h"
#import <UIKit/UIKit.h>

#define CAPTURE_SHADER_SOURCE(NAME, ...) const char * const NAME = #__VA_ARGS__;

CAPTURE_SHADER_SOURCE(CaptureVertexShader,
                      attribute vec4 position;
                      attribute vec2 texcoord;
                      varying vec2 v_texcoord;
                      void main() {
  gl_Position=position;
  v_texcoord=texcoord;
}
                      );

CAPTURE_SHADER_SOURCE(CaptureFragmentsShader,
                      precision highp float;
                      varying highp vec2 v_texcoord;
                      uniform sampler2D texSampler;
                      void main() {
  gl_FragColor=texture2D(texSampler,v_texcoord);
}
                      );

@interface WAEJTextureCapture()
@property (nonatomic, readonly) EAGLContext* context;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint glProgram;
@property (nonatomic, assign) GLuint glPosition;
@property (nonatomic, assign) GLuint glTextureCoords;
@property (nonatomic, assign) GLuint glUniformTexture;
@end

@implementation WAEJTextureCapture {
  BOOL                        available;
  uint32_t                    bf_width;
  uint32_t                    bf_height;
  CVOpenGLESTextureCacheRef   texture_cache;
  CVOpenGLESTextureRef        textureRef;
  CVPixelBufferRef            pixel_buffer;
}

@synthesize ready;
@synthesize textureId;

- (id)initWithContext:(EAGLContext*)context {
  if (self = [super init]) {
    _context = context;
    [self setup];
  }
  
  return self;
}

- (void)setup {
  EAGLContext* currentContext = EAGLContext.currentContext;
  [EAGLContext setCurrentContext:_context];
  
  do {
    CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &texture_cache);
    if (ret != kCVReturnSuccess) {
      break;
    }
    
    glGenFramebuffers(1, &_frameBuffer);
    
    GLuint vertexShader = [self compileShader:CaptureVertexShader withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:CaptureFragmentsShader withType:GL_FRAGMENT_SHADER];
    
    _glProgram = glCreateProgram();
    glAttachShader(_glProgram, vertexShader);
    glAttachShader(_glProgram, fragmentShader);
    glLinkProgram(_glProgram);
    
    GLint linkSuccess;
    glGetProgramiv(_glProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
      GLchar message[256] = {0};
      glGetProgramInfoLog(_glProgram, sizeof(message), 0, &message[0]);
      NSString* messageStr = [NSString stringWithUTF8String:message];
      NSLog(@"%@", messageStr);
      break;
    }
    
    glUseProgram(_glProgram);
    _glPosition = glGetAttribLocation(_glProgram, "position");
    glEnableVertexAttribArray(_glPosition);
    
    _glTextureCoords = glGetAttribLocation(_glProgram, "texcoord");
    glEnableVertexAttribArray(_glTextureCoords);
    
    _glUniformTexture = glGetUniformLocation(_glProgram, "texSampler");
    
    available = YES;
  } while (false);
  
  [EAGLContext setCurrentContext:currentContext];
}

- (void)dealloc {
  if (pixel_buffer) {
    CFRelease(pixel_buffer);
    pixel_buffer = nil;
  }
  
  EAGLContext* currentContext = EAGLContext.currentContext;
  [EAGLContext setCurrentContext:_context];
  
  if (_frameBuffer) {
    glDeleteRenderbuffers(1, &_frameBuffer);
  }
  
  if (_glProgram) {
    glDeleteProgram(_glProgram);
  }
  
  if (textureRef) {
    CFRelease(textureRef);
  }
  
  if (texture_cache) {
    CVOpenGLESTextureCacheFlush(texture_cache, 0);
    CFRelease(texture_cache);
    texture_cache = nil;
  }
  
  [EAGLContext setCurrentContext:currentContext];
}

- (CVPixelBufferRef)pixelBuffer {
  return pixel_buffer;
}

- (BOOL)resize:(uint32_t)width height:(uint32_t)height {
  if (!available) {
    return NO;
  }
  
  if (!texture_cache) {
    return NO;
  }
  
  if (ready && width == bf_width && height == bf_height) {
    return YES;
  }
  
  if (pixel_buffer) {
    CFRelease(pixel_buffer);
    pixel_buffer = nil;
  }
  
  NSDictionary *pixelAttribs = @{ (id)kCVPixelBufferIOSurfacePropertiesKey: @{} };
  CVReturn errCode = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelAttribs, &pixel_buffer);
  if (errCode != kCVReturnSuccess) {
    return NO;
  }

  if (textureRef) {
    CFRelease(textureRef);
    textureRef = nil;
  }

  errCode = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         texture_cache,
                                                         pixel_buffer,
                                                         NULL,
                                                         GL_TEXTURE_2D,
                                                         GL_RGBA,
                                                         width,
                                                         height,
                                                         GL_BGRA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         &textureRef);
  if (errCode != kCVReturnSuccess) {
    return NO;
  }
  
  textureId = CVOpenGLESTextureGetName(textureRef);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, textureId);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glBindTexture(GL_TEXTURE_2D, 0);
  
  bf_width = width;
  bf_height = height;
  ready = YES;
  return YES;
}

- (BOOL)present {
  if (!ready) {
    return NO;
  }

  GLint currProgram;
  glGetIntegerv(GL_CURRENT_PROGRAM, &currProgram);

  GLint currTextureId;
  glGetIntegerv(GL_TEXTURE_BINDING_2D, &currTextureId);
  
  GLint currCubeMap;
	glGetIntegerv(GL_TEXTURE_BINDING_CUBE_MAP, &currCubeMap);
 
  GLint currFrameBuffer;
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, &currFrameBuffer);

  GLint currRenderBuffer;
  glGetIntegerv(GL_RENDERBUFFER_BINDING, &currRenderBuffer);

  glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, currRenderBuffer);

  GLenum glError = glGetError();
  glUseProgram(_glProgram);
  glError = glGetError();
  //设置物体坐标
  GLfloat vertices[] = {
    -1.0,-1.0,
    1.0,-1.0,
    -1.0,1.0,
    1.0,1.0
  };
  glVertexAttribPointer(_glPosition, 2, GL_FLOAT, 0, 0, vertices);
  glEnableVertexAttribArray(_glPosition);
  glError = glGetError();
  //设置纹理坐标
  
  GLfloat texCoords2[] = {
    0,0,
    1,0,
    0,1,
    1,1
  };
  
  glVertexAttribPointer(_glTextureCoords, 2, GL_FLOAT, 0, 0, texCoords2);
  glEnableVertexAttribArray(_glTextureCoords);
  glError = glGetError();
  glUniform1i(_glUniformTexture, 0);
  glError = glGetError();
  glViewport(0, 0, bf_width, bf_height);

  glError = glGetError();
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, textureId);
  glError = glGetError();
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  [self.context presentRenderbuffer:GL_RENDERBUFFER];
  
  glError = glGetError();

  glBindTexture(GL_TEXTURE_2D, currTextureId);
  glBindTexture(GL_TEXTURE_CUBE_MAP, currCubeMap);
  glBindFramebuffer(GL_FRAMEBUFFER, currFrameBuffer);
  glUseProgram(currProgram);
  
  glError = glGetError();
  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  
  return YES;
}

- (GLuint)compileShader:(const char*)shaderData withType:(GLenum)shaderType {
  // create ID for shader
  GLuint shaderHandle = glCreateShader(shaderType);
  
  // define shader text
  int shaderLength = (int)strlen(shaderData);
  glShaderSource(shaderHandle, 1, &shaderData, &shaderLength);
  
  // compile shader
  glCompileShader(shaderHandle);
  
  // verify the compiling
  GLint compileSucess;
  glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSucess);
  if (compileSucess == GL_FALSE)
  {
    GLchar message[256];
    glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
    NSString *messageStr = [NSString stringWithUTF8String:message];
    NSLog(@"----%@", messageStr);
    return 0;
  }
  
  return shaderHandle;
}

@end
