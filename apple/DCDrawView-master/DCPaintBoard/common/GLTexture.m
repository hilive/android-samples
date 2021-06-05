//
//  GLTexture.m
//  DrawingBoard
//
//  Created by cort xu on 2021/5/22.
//

#import "GLTexture.h"

@implementation GLTexture {
  BOOL                _ready;
  uint32_t            _width;
  uint32_t            _height;
  GLuint              _textureId;
  CVPixelBufferRef    _textureBuffer;
}

@synthesize ready = _ready;
@synthesize textureId = _textureId;
@synthesize textureBuffer = _textureBuffer;

- (void)dealloc {
  if (_textureBuffer) {
      CFRelease(_textureBuffer);
      _textureBuffer = nil;
  }
}

- (BOOL)resize:(CVOpenGLESTextureCacheRef)cache width:(uint32_t)width height:(uint32_t)height {
  do {
    if (!cache || !width || !height || (_ready && _width == width && _height == height)) {
      break;
    }
    
    _ready = NO;
    
    if (_textureBuffer) {
      CFRelease(_textureBuffer);
      _textureBuffer = nil;
    }
    
    NSDictionary *pixelAttribs = @{ (id)kCVPixelBufferIOSurfacePropertiesKey: @{} };
    CVReturn errCode = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelAttribs, &_textureBuffer);
    if (errCode != kCVReturnSuccess) {
      break;
    }
    
    CVOpenGLESTextureRef pixelTexture = nil;
    errCode = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           cache,
                                                           _textureBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RGBA,
                                                           width,
                                                           height,
                                                           GL_BGRA,
                                                           GL_UNSIGNED_BYTE,
                                                           0,
                                                           &pixelTexture);
    if (errCode != kCVReturnSuccess) {
      break;
    }
    
    _textureId = CVOpenGLESTextureGetName(pixelTexture);
    CFRelease(pixelTexture);
    pixelTexture = nil;
    
    _width = width;
    _height = height;
    
    _ready = YES;
  } while (false);
  
  return _ready;
}

@end
