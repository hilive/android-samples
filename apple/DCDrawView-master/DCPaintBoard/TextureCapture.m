//
//  EJTextureCapture.m
//  WAOpenGL
//
//  Created by cort xu on 2021/4/24.
//  Copyright © 2021 eldwinwang. All rights reserved.
//
#import "TextureCapture.h"
#import <UIKit/UIKit.h>


#define SHADER_SOURCE(NAME, ...) const char * const NAME = #__VA_ARGS__;

SHADER_SOURCE(VertexShader,
              attribute vec3 position;
              attribute vec2 texcoord;
              varying vec2 v_texcoord;
              void main() {
  gl_Position=vec4(position,1.0);
  v_texcoord=texcoord;
}
              );

SHADER_SOURCE(PresentFragmentsShader,
              precision highp float;
              varying highp vec2 v_texcoord;
              uniform sampler2D my_texture;
              void main() {
  gl_FragColor=texture2D(my_texture,v_texcoord);
}
              );

SHADER_SOURCE(FlipFragmentsShader,
              precision highp float;
              varying highp vec2 v_texcoord;
              uniform sampler2D my_texture;
              void main() {
  vec2 flip = vec2(v_texcoord.x, 1.0-v_texcoord.y);
  gl_FragColor = texture2D(my_texture,flip);
}
              );

@interface StatusHolder : NSObject

@end

@implementation StatusHolder {
  EAGLContext* currContext;
  GLint currActiveTexture;
  GLint currTextureId;
  GLint currFrameBuffer;
  GLint currRenderBuffer;
  GLint currProgram;
  GLint curVAO;
  GLint curVBO;
  GLint curEBO;
  GLint currArrayBuffer;
  GLint currElementArrayBuffer;
  GLint currVertexArray;
  GLint currViewPort[4];
}

- (void) dealloc {
  [self leave];
}

- (void)join {
  if (!EAGLContext.currentContext) {
    return;
  }
  
  currContext = EAGLContext.currentContext;
  glGetIntegerv( GL_ACTIVE_TEXTURE, &currActiveTexture);
  glGetIntegerv(GL_TEXTURE_BINDING_2D, &currTextureId);
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, &currFrameBuffer);
  glGetIntegerv(GL_RENDERBUFFER_BINDING, &currRenderBuffer);
  glGetIntegerv(GL_CURRENT_PROGRAM, &currProgram);
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING_OES, &curVAO);
  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &curVBO);
  glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &curEBO);
  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &currArrayBuffer);
  glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &currElementArrayBuffer);
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING_OES, &currVertexArray);
  glGetIntegerv(GL_VIEWPORT, currViewPort);
}

- (void)leave {
  if (!currContext) {
    return;
  }
  
  [EAGLContext setCurrentContext:currContext];
  currContext = nil;
  
  glBindRenderbuffer(GL_RENDERBUFFER, currRenderBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, currFrameBuffer);
  glActiveTexture(currActiveTexture);
  glBindTexture(GL_TEXTURE_2D, currTextureId);
  glUseProgram(currProgram);
  glBindVertexArrayOES(curVAO);
  glBindBuffer(GL_ARRAY_BUFFER, curVBO);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, curEBO);
  glBindBuffer(GL_ARRAY_BUFFER, currArrayBuffer);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, currElementArrayBuffer);
  glBindVertexArrayOES(currVertexArray);
  glViewport(currViewPort[0], currViewPort[1], currViewPort[2], currViewPort[3]);
}

@end

@interface MyProgram : NSObject
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint position;
@property (nonatomic, assign) GLuint coords;
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, assign) GLuint vao;
@property (nonatomic, assign) GLuint vbo;
@property (nonatomic, assign) GLuint ebo;
@end

@implementation MyProgram

- (void) dealloc {
  [self destroy];
}

- (BOOL)create:(const char*)vShader fragmentsShader:(const char*)fShader {
  GLuint vertexShader = [self compileShader:vShader withType:GL_VERTEX_SHADER];
  GLuint fragmentShader = [self compileShader:fShader withType:GL_FRAGMENT_SHADER];
  
  _program = glCreateProgram();
  glAttachShader(_program, vertexShader);
  glAttachShader(_program, fragmentShader);
  glLinkProgram(_program);
  
  GLint linkSuccess;
  glGetProgramiv(_program, GL_LINK_STATUS, &linkSuccess);
  if (linkSuccess == GL_FALSE) {
    GLchar message[256] = {0};
    glGetProgramInfoLog(_program, sizeof(message), 0, &message[0]);
    NSString* messageStr = [NSString stringWithUTF8String:message];
    NSLog(@"%@", messageStr);
    return NO;
  }
  
  glUseProgram(_program);
  _position = glGetAttribLocation(_program, "position");
  _coords = glGetAttribLocation(_program, "texcoord");
  _texture = glGetUniformLocation(_program, "my_texture");
  
  glGenVertexArraysOES(1, &_vao);
  glGenBuffers(1, &_vbo);
  glGenBuffers(1, &_ebo);
  
  // Set up vertex data (and buffer(s)) and attribute pointers
  
  GLfloat vertices[] = {
    // Positions    // Texture Coords
    -1.0f,  -1.0f, 0.0f, 0.0f, 0.0f, // Bottom Left
    1.0f, -1.0f, 0.0f, 1.0f, 0.0f, // Bottom Right
    1.0f, 1.0f, 0.0f, 1.0f, 1.0f, // Top Right
    -1.0f,  1.0f, 0.0f, 0.0f, 1.0f  // Top Left
  };
  
  glBindVertexArrayOES(_vao);
  
  glBindBuffer(GL_ARRAY_BUFFER, _vbo);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
  
  const GLushort indices[] = { 0, 1, 2, 2, 3, 0 };
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
  
  // Position attribute
  glEnableVertexAttribArray(_position);
  glVertexAttribPointer(_position, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)0);
  
  // TexCoord attribute
  glEnableVertexAttribArray(_coords);
  glVertexAttribPointer(_coords, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
  return YES;
}

- (void)use {
  glUseProgram(_program);
  glUniform1i(_texture, 0);
  glBindVertexArrayOES(_vao);
  glBindBuffer(GL_ARRAY_BUFFER, _vbo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
}

- (void)destroy {
  if (_vao) {
    glDeleteVertexArraysOES(1, &_vao);
    _vao = 0;
  }
  
  if (_vbo) {
    glDeleteBuffers(1, &_vbo);
    _vbo = 0;
  }
  
  if (_ebo) {
    glDeleteBuffers(1, &_ebo);
    _ebo = 0;
  }
  
  if (_program) {
    glDeleteProgram(_program);
    _program = 0;
  }
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

@interface WAEJTextureCapture()
@property (nonatomic, readonly) EAGLContext* context;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, strong) MyProgram* program1;
@property (nonatomic, strong) MyProgram* program2;
@end

@implementation WAEJTextureCapture {
  BOOL                        available;
  uint32_t                    bf_width;
  uint32_t                    bf_height;
  CVOpenGLESTextureCacheRef   texture_cache;
  CVOpenGLESTextureRef        pixel_texture;
  CVPixelBufferRef            pixel_buffer;
  CVOpenGLESTextureRef        flip_pixel_texture;
  GLuint                      flip_texture_id;
  CVPixelBufferRef            flip_pixel_buffer;
}

@synthesize ready;
@synthesize textureId;
@synthesize width;
@synthesize height;

- (id)initWithContext:(EAGLContext*)context {
  if (self = [super init]) {
    _context = context;
    _program1 = [[MyProgram alloc] init];
    _program2 = [[MyProgram alloc] init];
    [self setup];
  }
  
  return self;
}

- (void)setup {
  StatusHolder* status = [[StatusHolder alloc] init];
  [status join];
  
  [EAGLContext setCurrentContext:_context];
  
  do {
    CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &texture_cache);
    if (ret != kCVReturnSuccess) {
      break;
    }
    
    [_program1 destroy];
    if (![_program1 create:VertexShader fragmentsShader:PresentFragmentsShader]) {
      break;
    }
    
    [_program2 destroy];
    if (![_program2 create:VertexShader fragmentsShader:FlipFragmentsShader]) {
      break;
    }
    
    available = YES;
  } while (false);
  
  [status leave];
}

- (void)dealloc {
  StatusHolder* status = [[StatusHolder alloc] init];
  [status join];
  
  [EAGLContext setCurrentContext:_context];
  
  if (pixel_buffer) {
    CFRelease(pixel_buffer);
    pixel_buffer = nil;
  }
  
  if (flip_pixel_buffer) {
    CFRelease(flip_pixel_buffer);
    flip_pixel_buffer = nil;
  }
  
  if (pixel_texture) {
    CFRelease(pixel_texture);
    pixel_texture = nil;
  }
  
  if (flip_pixel_texture) {
    CFRelease(flip_pixel_texture);
    flip_pixel_texture = nil;
  }
  
  if (_frameBuffer) {
    glDeleteFramebuffers(1, &_frameBuffer);
  }
  
  if (_renderBuffer) {
    glDeleteRenderbuffers(1, &_renderBuffer);
  }
  
  [_program1 destroy];
  [_program2 destroy];
  
  if (texture_cache) {
    CVOpenGLESTextureCacheFlush(texture_cache, 0);
    CFRelease(texture_cache);
    texture_cache = nil;
  }
  
  [status leave];
}

- (CVPixelBufferRef)pixelBuffer {
  return pixel_buffer;
}

- (NSMutableData*) nsData {
  NSMutableData* data = nil;
  if (pixel_buffer) {
    return data;
  }
  
  CVPixelBufferLockBaseAddress(pixel_buffer, 0);
  void* addr = CVPixelBufferGetBaseAddress(pixel_buffer);
  size_t size = CVPixelBufferGetDataSize(pixel_buffer);
  data = [NSMutableData dataWithBytes:addr length:size];
  CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
  return data;
}

- (CVPixelBufferRef)flipPixelBuffer {
  return flip_pixel_buffer;
}

- (NSMutableData*) flipNsData {
  NSMutableData* data = nil;
  if (flip_pixel_buffer) {
    return data;
  }
  
  CVPixelBufferLockBaseAddress(flip_pixel_buffer, 0);
  void* addr = CVPixelBufferGetBaseAddress(flip_pixel_buffer);
  size_t size = CVPixelBufferGetDataSize(flip_pixel_buffer);
  data = [NSMutableData dataWithBytes:addr length:size];
  CVPixelBufferUnlockBaseAddress(flip_pixel_buffer, 0);
  return data;
}

- (BOOL)resize:(uint32_t)width height:(uint32_t)height {
  if (!available) {
    return NO;
  }
  
  if (!texture_cache || !width || !height) {
    return NO;
  }
  
  if (ready && width == bf_width && height == bf_height) {
    return YES;
  }
  
  if (pixel_buffer) {
    CFRelease(pixel_buffer);
    pixel_buffer = nil;
  }
  
  if (flip_pixel_buffer) {
    CFRelease(flip_pixel_buffer);
    flip_pixel_buffer = nil;
  }
  
  NSDictionary *pixelAttribs = @{ (id)kCVPixelBufferIOSurfacePropertiesKey: @{} };
  CVReturn errCode = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, NULL, &pixel_buffer);
  if (errCode != kCVReturnSuccess) {
    return NO;
  }
  
  if (pixel_texture) {
    CFRelease(pixel_texture);
    pixel_texture = nil;
  }
  
  errCode = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         texture_cache,
                                                         pixel_buffer,
                                                         NULL,
                                                         GL_RENDERBUFFER,
                                                         GL_RGBA8_OES,
                                                         width,
                                                         height,
                                                         GL_BGRA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         &pixel_texture);
  GLenum glError = glGetError();
  if (errCode != kCVReturnSuccess) {
    return NO;
  }
  
  textureId = CVOpenGLESTextureGetName(pixel_texture);
  /*
  errCode = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelAttribs, &flip_pixel_buffer);
  if (errCode != kCVReturnSuccess) {
    return NO;
  }
  
  if (flip_pixel_texture) {
    CFRelease(flip_pixel_texture);
  }
  
  errCode = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         texture_cache,
                                                         flip_pixel_buffer,
                                                         NULL,
                                                         GL_TEXTURE_2D,
                                                         GL_RGBA,
                                                         width,
                                                         height,
                                                         GL_BGRA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         &flip_pixel_texture);
  if (errCode != kCVReturnSuccess) {
    return NO;
  }
  
  flip_texture_id = CVOpenGLESTextureGetName(flip_pixel_texture);
  
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, textureId);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  
  glBindTexture(GL_TEXTURE_2D, flip_texture_id);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  */
  bf_width = width;
  bf_height = height;
  ready = YES;
  return YES;
}

- (BOOL)resize:(CAEAGLLayer*)layer {
  GLenum glStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  GLenum glError = glGetError();

  StatusHolder* status = [[StatusHolder alloc] init];
  [status join];

  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
  [self resize:width height:height];

  /*
  [EAGLContext setCurrentContext:_context];

  if (_frameBuffer) {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
  }

  if (_renderBuffer) {
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
  }

  glGenFramebuffers(1, &_frameBuffer);
  glGenRenderbuffers(1, &_renderBuffer);

  glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);

  glStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  glError = glGetError();

  [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);

  glStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  glError = glGetError();

  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
  
  [self resize:width height:height];
  */
  [status leave];
  return YES;
}

- (BOOL)present {
  if (!ready) {
    return NO;
  }
  
  glFlush();
  
  StatusHolder* status = [[StatusHolder alloc] init];
  [status join];
  
  [EAGLContext setCurrentContext:_context];
  
  glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
  
  glViewport(0, 0, bf_width, bf_height);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  [_program1 use];
  
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, textureId);
  
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
  
  [self.context presentRenderbuffer:GL_RENDERBUFFER];
  
  [_program2 use];
  
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, flip_texture_id, 0);
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
  glFlush();
  
  [status leave];
  
  return YES;
}
@end
