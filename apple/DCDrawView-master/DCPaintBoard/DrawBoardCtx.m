//
//  DrawBoardCtx.m
//  DCPaintBoard
//
//  Created by cort xu on 2021/6/5.
//  Copyright © 2021 Wade. All rights reserved.
//


#import "DrawBoardCtx.h"
#import "common/GLContext.h"
#import "common/GLTexture.h"
#import "common/GLProgram.h"

@interface DrawBoardCtx()
@property (nonatomic, strong) GLContext* context;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, strong) GLProgram* drawProgram;
@end

@implementation DrawBoardCtx {
  BOOL      _ready;
  GLint     _buffWidth;
  GLint     _buffHeight;
}

- (id)init {
  if (self = [super init]) {
  }
  
  return self;
}

- (void)dealloc {
  [self destroy];
}

- (BOOL)create {
  do {
    if (_ready) {
      break;
    }

    _context = [[GLContext alloc] init];
    [_context join];
    glGenFramebuffers(1, &_frameBuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    [_context leave];

    _ready = YES;
  } while (false);
  
  return _ready;
}

- (BOOL)render:(CAEAGLLayer*)layer {
    if (!_ready) {
      return NO;;
    }

  [_context join];

  do {

    
    glBindFramebuffer(1, _frameBuffer);
    glBindRenderbuffer(1, _renderBuffer);
    
    [_context.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_buffWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_buffHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    GLenum glStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (glStatus != GL_FRAMEBUFFER_COMPLETE) {
        HILIVEINFO(@"frame buffer not complete");
        break;
    }
    
  } while (false);

  [_context leave];

  return _ready;
}

- (void)destroy {
  if (!_context) {
      return;
  }

  _ready = NO;
  [_context join];
  
  if (_frameBuffer) {
      glDeleteFramebuffers(1, &_frameBuffer);
      _frameBuffer = 0;
  }
  
  if (_renderBuffer) {
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
  }
  
  [_context leave];
  
  _context = nil;
}

@end
