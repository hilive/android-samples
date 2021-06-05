//
//  GLProgram.m
//  DrawingBoard
//
//  Created by cort xu on 2021/5/22.
//

#import "GLProgram.h"

@implementation GLProgram {
  BOOL    _ready;
  GLuint  _program;
  GLuint  _vertexShader;
  GLuint  _fragmentShader;
}

@synthesize ready = _ready;
@synthesize program = _program;

- (void)dealloc {
  [self detach];
}

- (BOOL)attach:(const char*)vShader fragShader:(const char*)fShader {
  do {
    if (_ready) {
      break;
    }
    
    if (![self compileShader:vShader withType:GL_VERTEX_SHADER shaderHandle:&_vertexShader]) {
      HILIVEINFO(@"createVertexShader fail");
      return NO;
    }
    
    if (![self compileShader:fShader withType:GL_FRAGMENT_SHADER shaderHandle:&_fragmentShader]) {
      HILIVEINFO(@"createFragmentShader fail");
      return NO;
    }
    
    _program = glCreateProgram();
    
    glAttachShader(_program, _vertexShader);
    glAttachShader(_program, _fragmentShader);
    
    glLinkProgram(_program);
    
    glValidateProgram(_program);
    
    GLint logLen = 0;
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLen);
    if (logLen > 0) {
      GLchar *log = (GLchar *)malloc(logLen + 1);
      glGetProgramInfoLog(_program, logLen, &logLen, log);
      HILIVEINFO(@"shader, log, %s", log);
      free(log);
    }
    
    GLint status = 0;
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
      HILIVEINFO(@"shader, link fail");
      return NO;
    }

    _ready = YES;
  } while (false);
  return _ready;
}

- (void)use {
  if (!_ready) {
    return;
  }
  
  glUseProgram(_program);
}

- (GLint)getAttrib:(const char*)name {
  if (!_ready) {
    return -1;
  }
  
  return glGetAttribLocation(_program, name);
}

- (GLint)getUniform:(const char*)name {
  if (!_ready) {
    return -1;
  }
  
  return glGetUniformLocation(_program, name);
}

- (void)detach {
  if (_program) {
    if (_vertexShader) {
      glDetachShader(_program, _vertexShader);
      glDeleteShader(_vertexShader);
      _vertexShader = 0;
    }
    
    if (_fragmentShader) {
      glDetachShader(_program, _fragmentShader);
      glDeleteShader(_fragmentShader);
      _fragmentShader = 0;
    }
    
    glDeleteProgram(_program);
    _program = 0;
  }
  
  _ready = NO;
}

- (BOOL)compileShader:(const char*)shaderData withType:(GLenum)shaderType shaderHandle:(GLuint*)shaderHandle {
  // create ID for shader
  GLuint handle = glCreateShader(shaderType);
  *shaderHandle = handle;
  
  // define shader text
  int shaderLength = (int)strlen(shaderData);
  glShaderSource(handle, 1, &shaderData, &shaderLength);
  
  // compile shader
  glCompileShader(handle);
  
  GLint logLen = 0;
  glGetShaderiv(handle, GL_INFO_LOG_LENGTH, &logLen);
  if (logLen > 0) {
    GLchar* log = (GLchar *)malloc(logLen + 1);
    glGetShaderInfoLog(handle, logLen, &logLen, log);
    HILIVEINFO(@"compileShader, log, %s", log);
    free(log);
  }
  
  // verify the compiling
  GLint status = 0;
  glGetShaderiv(handle, GL_COMPILE_STATUS, &status);
  
  return status != GL_FALSE;
}
@end
