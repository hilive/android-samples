//
//  GLDefine.h
//  DrawingBoard
//
//  Created by cort xu on 2021/5/22.
//

#ifndef GLDefine_h
#define GLDefine_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>
#import <GLKit/GLKit.h>

#define HILIVEINFO(format, ...) NSLog(@"[hilive] TextureCapture %@", [NSString stringWithFormat:format, ##__VA_ARGS__])

#endif /* GLDefine_h */
