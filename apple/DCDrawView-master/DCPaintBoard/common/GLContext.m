//
//  GLContext.m
//  DrawingBoard
//
//  Created by cort xu on 2021/5/22.
//

#import "GLContext.h"

@implementation GLContext {
  EAGLContext*                _prevContext;
  EAGLContext*                _currContext;
  CVOpenGLESTextureCacheRef   _textureCache;
}

@synthesize textureCache;

- (id)init {
  if (self = [super init]) {
    _currContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  }

  return self;
}

- (id)initWithShare:(nullable EAGLSharegroup*)group {
  if (self = [super init]) {
    if (group) {
      _currContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:group];
    } else {
      _currContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
  }

  return self;
}

- (void)dealloc {
    if (_textureCache) {
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
    CFRelease(_textureCache);
    _textureCache = nil;
  }
}

- (CVOpenGLESTextureCacheRef)textureCache {
  if (_textureCache) {
      return _textureCache;
  }

  CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, _currContext, nil, &_textureCache);
  if (ret != kCVReturnSuccess) {
    HILIVEINFO(@"CVOpenGLESTextureCacheCreate fail, ret: %d", ret);
  }
  
  return _textureCache;
}

- (void)join {
  if (EAGLContext.currentContext == _currContext) {
      return;
  }
  
  _prevContext = EAGLContext.currentContext;
  [EAGLContext setCurrentContext:_currContext];
}

- (void)leave {
  [EAGLContext setCurrentContext:_prevContext];
  _prevContext = nil;
}

@end
