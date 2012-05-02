//
//  v002_Rutt_Etra_2_0PlugIn.h
//  v002 Rutt Etra 2.0
//
//  Created by vade on 2/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <OpenGL/OpenGL.h>

#import "v002Shader.h"

@interface v002RuttEtraPlugIn : QCPlugIn
{
    // GL resources
    v002Shader* ruttEtraMRTshader;
    v002Shader* ruttEtraMRTshaderNormals;
    v002Shader* ruttEtraMRTshaderNormalsHQ;
    
    GLuint vaoID;   // the combined state vector for all buffers for drawing
    
    // FBO and texture objects
    GLuint fboID;   // for drawing our MRT targets
    GLuint texureAttachmentVertices;    // vertices
    GLuint texureAttachmentNormals;     // normals
    GLuint texureAttachmentTextureCoords;   // texture coords
    
    // Buffer Objects
    GLuint vertexBufferID;
    GLuint textureBufferID;
    GLuint normalBufferID;
    GLuint indexBufferID;
    
    // state saving
    // GL State
	GLint previousFBO;
	GLint previousReadFBO;
	GLint previousDrawFBO;	
	GLint previousShader;
    
    BOOL rebuildGLResources;
    
    double* eq1;
    double* eq2;
}

@property (assign) id<QCPlugInInputImageSource> inputImage;
@property (assign) id<QCPlugInInputImageSource> inputImageLuma;
@property (assign) id<QCPlugInInputImageSource> inputPointSpriteImage;
@property (assign) CGColorRef inputColor;
@property (assign) NSUInteger inputLumaOrRaw;
@property (assign) BOOL inputColorCorrect;
@property (assign) NSUInteger inputResolutionX;
@property (assign) NSUInteger inputResolutionY;
@property (assign) NSUInteger inputDrawType;
@property (assign) double inputDepthScale;
@property (assign) double inputWireFrameWidth;
@property (assign) BOOL inputAntialias;
@property (assign) BOOL inputCalculateNormals;
@property (assign) double inputNormalCoeff;
@property (assign) BOOL inputHQNormals;
@property (assign) BOOL inputAttenuatePoints;
@property (assign) double inputConstantAttenuation;
@property (assign) double inputLinearAttenuation;
@property (assign) double inputQuadraticAttenuation;

@property (assign) NSUInteger inputUVGenMode;
@property (assign) double inputTranslationX;
@property (assign) double inputTranslationY;
@property (assign) double inputTranslationZ;
@property (assign) double inputRotationX;
@property (assign) double inputRotationY;
@property (assign) double inputRotationZ;
@property (assign) double inputScaleX;
@property (assign) double inputScaleY;
@property (assign) double inputScaleZ;
@property (assign) NSUInteger inputBlendMode; 
@property (assign) NSUInteger inputDepthMode;
@property (assign) BOOL inputEnableClipping;
@property (assign) double inputMinClip;
@property (assign) double inputMaxClip;

@end

@interface v002RuttEtraPlugIn (Execution)

- (void) createGLResourcesInContext:(CGLContextObj)cgl_ctx width:(NSUInteger)w height:(NSUInteger)h drawType:(NSUInteger)drawType normals:(BOOL)normals;
- (void) destroyGLResourcesInContext:(CGLContextObj)cgl_ctx;
- (void) pushGLState:(CGLContextObj)cgl_ctx;
- (void) popGLState:(CGLContextObj)cgl_ctx;

@end

