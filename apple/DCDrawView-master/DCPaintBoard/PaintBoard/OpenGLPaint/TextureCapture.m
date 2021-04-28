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
                      attribute vec3 position;
                      attribute vec2 texcoord;
                      varying vec2 v_texcoord;
                      void main() {
  gl_Position=vec4(position,1.0);
  v_texcoord=texcoord;
}
);

CAPTURE_SHADER_SOURCE(CaptureFragmentsShader,
                      precision highp float;
                      varying highp vec2 v_texcoord;
                      uniform sampler2D texSampler;
                      void main() {
 // vec2 flip = vec2(v_texcoord.x, 1.0-v_texcoord.y);
//  gl_FragColor=texture2D(texSampler,flip);
  gl_FragColor=texture2D(texSampler,v_texcoord);
}
);

@interface WAEJTextureCapture()
@property (nonatomic, readonly) EAGLContext* context;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint vao;
@property (nonatomic, assign) GLuint vbo;
@property (nonatomic, assign) GLuint ebo;
@property (nonatomic, assign) GLuint gl_program;
@property (nonatomic, assign) GLuint gl_position;
@property (nonatomic, assign) GLuint gl_texture_coords;
@property (nonatomic, assign) GLuint gl_uniform_texture;
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
    
    _gl_program = glCreateProgram();
    glAttachShader(_gl_program, vertexShader);
    glAttachShader(_gl_program, fragmentShader);
    glLinkProgram(_gl_program);
    
    GLint linkSuccess;
    glGetProgramiv(_gl_program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
      GLchar message[256] = {0};
      glGetProgramInfoLog(_gl_program, sizeof(message), 0, &message[0]);
      NSString* messageStr = [NSString stringWithUTF8String:message];
      NSLog(@"%@", messageStr);
      break;
    }

    GLint curVAO = 0;
    glGetIntegerv(GL_VERTEX_ARRAY_BINDING_OES, &curVAO);

    GLint curVBO = 0;
    glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &curVBO);

    GLint curEBO = 0;
    glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &curEBO);

    GLint curProgram = 0;
    glGetIntegerv(GL_CURRENT_PROGRAM, &curProgram);

    glUseProgram(_gl_program);
    _gl_position = glGetAttribLocation(_gl_program, "position");
    _gl_texture_coords = glGetAttribLocation(_gl_program, "texcoord");
    _gl_uniform_texture = glGetUniformLocation(_gl_program, "texSampler");

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
    glEnableVertexAttribArray(_gl_position);
    glVertexAttribPointer(_gl_position, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)0);

    // TexCoord attribute
    glEnableVertexAttribArray(_gl_texture_coords);
    glVertexAttribPointer(_gl_texture_coords, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));

    glBindVertexArrayOES(curVAO);
    glBindBuffer(GL_ARRAY_BUFFER, curVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, curEBO);
    glUseProgram(curProgram);
    
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
  
  if (_vao) {
    glDeleteVertexArraysOES(1, &_vao);
  }

  if (_vbo) {
    glDeleteBuffers(1, &_vbo);
  }

  if (_ebo) {
    glDeleteBuffers(1, &_ebo);
  }
  
  if (_gl_program) {
    glDeleteProgram(_gl_program);
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

  GLint currTextureId = 0;
  glGetIntegerv(GL_TEXTURE_BINDING_2D, &currTextureId);

  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, textureId);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  glBindTexture(GL_TEXTURE_2D, currTextureId);
  
  bf_width = width;
  bf_height = height;
  ready = YES;
  return YES;
}

- (BOOL)present {
  if (!ready) {
    return NO;
  }

  GLenum glError = glGetError();
  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);

  glFlush();
  
  GLint currProgram;
  glGetIntegerv(GL_CURRENT_PROGRAM, &currProgram);
  
  GLint currTextureId;
  glGetIntegerv(GL_TEXTURE_BINDING_2D, &currTextureId);
  
  GLint currFrameBuffer;
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, &currFrameBuffer);
  
  GLint currRenderBuffer;
  glGetIntegerv(GL_RENDERBUFFER_BINDING, &currRenderBuffer);
  
  GLint currElementArrayBuffer;
  glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &currElementArrayBuffer);
  
  GLint currVertexArray;
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING_OES, &currVertexArray);
  
  glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, currRenderBuffer);
  
  glClear(GL_COLOR_BUFFER_BIT);
  
  glViewport(0, 0, bf_width, bf_height);
  
  glUseProgram(_gl_program);
  
  glError = glGetError();
  
  glUniform1i(_gl_uniform_texture, 0);

  glBindVertexArrayOES(_vao);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
  
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, textureId);
  
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
  glError = glGetError();
  
  [self.context presentRenderbuffer:GL_RENDERBUFFER];
  glError = glGetError();
  
  glBindTexture(GL_TEXTURE_2D, currTextureId);
  glBindFramebuffer(GL_FRAMEBUFFER, currFrameBuffer);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, currElementArrayBuffer);
  glBindVertexArrayOES(currVertexArray);
  glUseProgram(currProgram);

  glError = glGetError();
  
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
