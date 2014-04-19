//
//  v002_Rutt_Etra_2_0PlugIn.m
//  v002 Rutt Etra 2.0
//
//  Created by vade on 2/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */

// Fix for function declaration bug in Apples supplied CGLMacro header
//#import "v002CGLMacro.h"

#import <OpenGL/CGLMacro.h>

#import "v002RuttEtraPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Rutt Etra 3.0"
#define	kQCPlugIn_Description		@"For Bill.\n\nEmulates the Rutt/Etra raster based analog computer, video synthesizer and effects system. This software is donation ware. All proceeds go towards helping Bill Etra and the further development of this plugin.\n\nIf you would like to donate, please visit http://v002.info. \n\nThank you."

static void planeEquation(float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, double* eq)
{
    eq[0] = (y1*(z2 - z3)) + (y2*(z3 - z1)) + (y3*(z1 - z2));
    eq[1] = (z1*(x2 - x3)) + (z2*(x3 - x1)) + (z3*(x1 - x2));
    eq[2] = (x1*(y2 - y3)) + (x2*(y3 - y1)) + (x3*(y1 - y2));
    eq[3] = -((x1*((y2*z3) - (y3*z2))) + (x2*((y3*z1) - (y1*z3))) + (x3*((y1*z2) - (y2*z1))));
}

@implementation v002RuttEtraPlugIn

@dynamic inputImage;
@dynamic inputImageLuma;
@dynamic inputPointSpriteImage;
@dynamic inputColor;
@dynamic inputLumaOrRaw;
@dynamic inputColorCorrect;
@dynamic inputResolutionX;
@dynamic inputResolutionY;
@dynamic inputDrawType;
@dynamic inputDepthScale;
@dynamic inputWireFrameWidth;
@dynamic inputAntialias;
@dynamic inputCalculateNormals;
@dynamic inputNormalCoeff;
@dynamic inputHQNormals;
@dynamic inputAttenuatePoints;
@dynamic inputConstantAttenuation;
@dynamic inputLinearAttenuation;
@dynamic inputQuadraticAttenuation;

@dynamic inputUVGenMode;
@dynamic inputTranslationX;
@dynamic inputTranslationY;
@dynamic inputTranslationZ;
@dynamic inputRotationX;
@dynamic inputRotationY;
@dynamic inputRotationZ;
@dynamic inputScaleX;
@dynamic inputScaleY;
@dynamic inputScaleZ;
@dynamic inputBlendMode;     
@dynamic inputDepthMode;

@dynamic inputEnableClipping;
@dynamic inputMinClip;
@dynamic inputMaxClip;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey,
        kQCPlugIn_Category, @"categories", nil]; // Horrible work around
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
    if([key isEqualToString:@"inputImage"])
		return [NSDictionary dictionaryWithObject:@"Image" forKey:QCPortAttributeNameKey];
    
	if([key isEqualToString:@"inputImageLuma"])
		return [NSDictionary dictionaryWithObject:@"Displacement Image" forKey:QCPortAttributeNameKey];

    if([key isEqualToString:@"inputPointSpriteImage"])
		return [NSDictionary dictionaryWithObject:@"Point Sprite Image" forKey:QCPortAttributeNameKey];    

    if([key isEqualToString:@"inputColor"])
		return [NSDictionary dictionaryWithObject:@"Color" forKey:QCPortAttributeNameKey];    

    if([key isEqualToString:@"inputLumaOrRaw"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Displacement Mode",QCPortAttributeNameKey,
				[NSArray arrayWithObjects:@"Luminosity", @"Raw RGB to XYZ", nil], QCPortAttributeMenuItemsKey,
				[NSNumber numberWithInt:0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithInt:1], QCPortAttributeMaximumValueKey,
				nil];  

    if([key isEqualToString:@"inputColorCorrect"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Color Correct",QCPortAttributeNameKey, nil];

	if([key isEqualToString:@"inputDrawType"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Draw Mode",QCPortAttributeNameKey,
				[NSArray arrayWithObjects:@"Scanlines", /*@"Diag Scanlines 1", @"Diag Scanlines 2",*/ @"Points", @"Square Mesh", @"Triangle Mesh", @"Image Plane", nil], QCPortAttributeMenuItemsKey,
				[NSNumber numberWithInt:0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithInt:4], QCPortAttributeMaximumValueKey,
				nil];
    
	if([key isEqualToString:@"inputResolutionX"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Resolution X", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:32.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:4.0], QCPortAttributeMinimumValueKey,
				nil];
	
	if([key isEqualToString:@"inputResolutionY"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Resolution Y", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:24.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:4.0], QCPortAttributeMinimumValueKey,
				nil];
	
    if([key isEqualToString:@"inputUVGenMode"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Texture Coordinates", QCPortAttributeNameKey,
                [NSArray arrayWithObjects:@"Model", @"Object Linear", @"Eye Linear", @"Sphere Map", nil], QCPortAttributeMenuItemsKey,
                [NSNumber numberWithUnsignedInt:3], QCPortAttributeMaximumValueKey,
                [NSNumber numberWithUnsignedInt:0], QCPortAttributeDefaultValueKey,
                [NSNumber numberWithUnsignedInt:0], QCPortAttributeMinimumValueKey, nil];
    
	if([key isEqualToString:@"inputDepthScale"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Z Extrude", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey, 
				nil];
	
	if([key isEqualToString:@"inputWireFrameWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Element Size", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:0.5], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:100.0], QCPortAttributeMaximumValueKey,
				nil];	

	if([key isEqualToString:@"inputAntialias"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Element Antialiasing",QCPortAttributeNameKey,
				[NSNumber numberWithBool:FALSE], QCPortAttributeMinimumValueKey,
				nil];
    
    if([key isEqualToString:@"inputAttenuatePoints"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Point Attenuation",QCPortAttributeNameKey, nil];
    
    if([key isEqualToString:@"inputConstantAttenuation"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Point Constant Attenuation", QCPortAttributeNameKey, [NSNumber numberWithDouble:1.0],QCPortAttributeDefaultValueKey, nil];

    if([key isEqualToString:@"inputLinearAttenuation"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Point Linear Attenuation", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];

    if([key isEqualToString:@"inputQuadraticAttenuation"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Point Quadratic Attenuation", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];
    
	if([key isEqualToString:@"inputCalculateNormals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Calculate Normals",QCPortAttributeNameKey,
				[NSNumber numberWithBool:FALSE], QCPortAttributeMinimumValueKey,
				nil];
	
	if([key isEqualToString:@"inputNormalCoeff"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Normal Smoothness", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.5], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:0.1], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:5.0], QCPortAttributeMaximumValueKey,
				nil];
	
	if([key isEqualToString:@"inputHQNormals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"High Quality Normals",QCPortAttributeNameKey,
				[NSNumber numberWithBool:FALSE], QCPortAttributeMinimumValueKey,
				nil];
    
    if([key isEqualToString:@"inputRotationX"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"X Rotation", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputRotationY"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Y Rotation", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputRotationZ"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Z Rotation", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputTranslationX"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"X Position", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputTranslationY"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Y Position", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputTranslationZ"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Z Position", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputScaleX"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"X Scale", QCPortAttributeNameKey, [NSNumber numberWithDouble:1.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputScaleY"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Y Scale", QCPortAttributeNameKey, [NSNumber numberWithDouble:1.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputScaleZ"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Z Scale", QCPortAttributeNameKey, [NSNumber numberWithDouble:1.0],QCPortAttributeDefaultValueKey, nil];
    
    if([key isEqualToString:@"inputBlendMode"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Blending", QCPortAttributeNameKey,
                [NSArray arrayWithObjects:@"Replace", @"Over", @"Add", nil], QCPortAttributeMenuItemsKey,
                [NSNumber numberWithUnsignedInt:2], QCPortAttributeMaximumValueKey,
                [NSNumber numberWithUnsignedInt:1], QCPortAttributeDefaultValueKey,
                [NSNumber numberWithUnsignedInt:0], QCPortAttributeMinimumValueKey, nil];
    
    if([key isEqualToString:@"inputDepthMode"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Depth Testing", QCPortAttributeNameKey,
                [NSArray arrayWithObjects:@"None", @"Read/Write", @"Read-Only", nil], QCPortAttributeMenuItemsKey,
                [NSNumber numberWithUnsignedInt:2], QCPortAttributeMaximumValueKey,
                [NSNumber numberWithUnsignedInt:1], QCPortAttributeDefaultValueKey,
                [NSNumber numberWithUnsignedInt:0], QCPortAttributeMinimumValueKey, nil];
    
    if([key isEqualToString:@"inputEnableClipping"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Clipping", QCPortAttributeNameKey, nil];

    if([key isEqualToString:@"inputMinClip"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Minimum Clipping", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];

    if([key isEqualToString:@"inputMaxClip"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Maximum Clipping", QCPortAttributeNameKey, [NSNumber numberWithDouble:0.0],QCPortAttributeDefaultValueKey, nil];

    
    return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputImage",
            @"inputImageLuma",
            @"inputLumaOrRaw",
            @"inputColorCorrect",
            @"inputColor",
            @"inputResolutionX",
            @"inputResolutionY",
            @"inputDrawType",
            
            @"inputDepthScale",
            @"inputWireFrameWidth",
            @"inputAntialias",
            @"inputCalculateNormals",
            @"inputNormalCoeff",
            @"inputHQNormals",
            
            @"inputGenerateUVs",
            @"inputUVGenMode",
            @"inputTranslationX",
            @"inputTranslationY",
            @"inputTranslationZ",
            @"inputRotationX",
            @"inputRotationY",
            @"inputRotationZ",
            @"inputScaleX",
            @"inputScaleY",
            @"inputScaleZ", 
            @"inputBlendMode", 
            @"inputDepthMode",
            @"inputEnableClipping",
            @"inputMinClip",
            @"inputMaxClip",
            
            @"inputPointSpriteImage",
            @"inputAttenuatePoints",
            @"inputConstantAttenuation",
            @"inputLinearAttenuation",
            @"inputQuadraticAttenuation",

             nil];
}   

+ (QCPlugInExecutionMode) executionMode
{
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode) timeMode
{
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init])
    {        
        eq1 = (double*)malloc(4 * sizeof(double));
        eq2 = (double*)malloc(4 * sizeof(double));
	}
	
	return self;
}

- (void) dealloc
{	
    free(eq1);
    free(eq2);
	[super dealloc];
}

@end

@implementation v002RuttEtraPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
    [self createPersistantGLResourcesInContext:[context CGLContextObj]];
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
    CGLContextObj cgl_ctx = [context CGLContextObj];
    
    // cache local variables to save obj-c lookup
    id<QCPlugInInputImageSource> image = self.inputImage;
    id<QCPlugInInputImageSource> displacementImage = self.inputImageLuma;
       
    NSUInteger width = MAX(self.inputResolutionX, 10);
    NSUInteger height = MAX(self.inputResolutionY, 10);    
    BOOL normals = self.inputCalculateNormals;
    NSUInteger drawType = self.inputDrawType;
    
    if([self didValueForInputKeyChange:@"inputResolutionX"]
       || [self didValueForInputKeyChange:@"inputResolutionY"]
       || [self didValueForInputKeyChange:@"inputDrawType"]
       || [self didValueForInputKeyChange:@"inputCalculateNormals"])
    {
        [self createGLResourcesInContext:cgl_ctx width:width height:height drawType:drawType normals:normals];
    }
    
    // save GL state
    [self pushGLState:cgl_ctx];
       
    // Bind the FBO as the rendering destination
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboID);
    
	glViewport(0, 0, width, height);
    
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, width, 0, height, -1, 1);

	glMatrixMode(GL_TEXTURE);
	glPushMatrix();
	glLoadIdentity();
    
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
    
    // choose what image to use.
    id<QCPlugInInputImageSource> whichImage = (displacementImage != nil) ? displacementImage : image; 
    
    if(whichImage)
    {
        glDisable(GL_LIGHTING);
		glDisable(GL_BLEND);
        
        //glClampColorARB(GL_CLAMP_VERTEX_COLOR_ARB, GL_FALSE); 
        //glClampColorARB(GL_CLAMP_FRAGMENT_COLOR_ARB, GL_FALSE); 
        //glClampColorARB(GL_CLAMP_READ_COLOR_ARB, GL_FALSE); 
        
        // MRT
        if(normals)
        {
            GLenum buffers[] = {GL_COLOR_ATTACHMENT0_EXT, GL_COLOR_ATTACHMENT1_EXT, GL_COLOR_ATTACHMENT2_EXT};
            glDrawBuffers(3, buffers);
        }
        else
        {
            GLenum buffers[] = {GL_COLOR_ATTACHMENT0_EXT, GL_COLOR_ATTACHMENT1_EXT};
            glDrawBuffers(2, buffers);
        }
        
        CGColorSpaceRef cspace = (self.inputColorCorrect) ? [context colorSpace] : [whichImage imageColorSpace];
        [whichImage lockTextureRepresentationWithColorSpace:cspace forBounds:[whichImage imageBounds]];
        [whichImage bindTextureRepresentationToCGLContext:cgl_ctx textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];

        glEnable([whichImage textureTarget]);

        glTexParameterf([whichImage textureTarget], GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameterf([whichImage textureTarget], GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                
        if(!normals)
        {
            glUseProgramObjectARB([ruttEtraMRTshader programObject]);
            glUniform1iARB([ruttEtraMRTshader getUniformLocation:"tex0"], 0); // load tex0 sampler to texture unit 0 
            glUniform2fARB([ruttEtraMRTshader getUniformLocation:"imageSize"], width, height); 
            glUniform1fARB([ruttEtraMRTshader getUniformLocation:"extrude"], (GLfloat) self.inputDepthScale);
            glUniform1fARB([ruttEtraMRTshader getUniformLocation:"useRaw"], self.inputLumaOrRaw);             
        }
        else
        {
            if(!self.inputHQNormals)
            {    
                glUseProgramObjectARB([ruttEtraMRTshaderNormals programObject]);
                glUniform1iARB([ruttEtraMRTshaderNormals getUniformLocation:"tex0"], 0); // load tex0 sampler to texture unit 0 
                glUniform2fARB([ruttEtraMRTshaderNormals getUniformLocation:"imageSize"], width, height); 
                glUniform1fARB([ruttEtraMRTshaderNormals getUniformLocation:"extrude"], (GLfloat) self.inputDepthScale);
                glUniform1fARB([ruttEtraMRTshaderNormals getUniformLocation:"coef"], (GLfloat) self.inputNormalCoeff); 
                glUniform1fARB([ruttEtraMRTshaderNormals getUniformLocation:"useRaw"], self.inputLumaOrRaw);             
            }
            else
            {
                glUseProgramObjectARB([ruttEtraMRTshaderNormalsHQ programObject]);
                glUniform1iARB([ruttEtraMRTshaderNormalsHQ getUniformLocation:"tex0"], 0); // load tex0 sampler to texture unit 0 
                glUniform2fARB([ruttEtraMRTshaderNormalsHQ getUniformLocation:"imageSize"], width, height); 
                glUniform1fARB([ruttEtraMRTshaderNormalsHQ getUniformLocation:"extrude"], (GLfloat) self.inputDepthScale);
                glUniform1fARB([ruttEtraMRTshaderNormalsHQ getUniformLocation:"coef"], (GLfloat) self.inputNormalCoeff);                 
                glUniform1fARB([ruttEtraMRTshaderNormals getUniformLocation:"useRaw"], self.inputLumaOrRaw);             
            }
        }
        
        GLfloat tex_coords[] = 
        {
            1.0,1.0,
            0.0,1.0,
            0.0,0.0,
            1.0,0.0
        };
        
        GLfloat verts[] = 
        {
            width,height,
            0.0,height,
            0.0,0.0,
            width,0.0
        };
        
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2, GL_FLOAT, 0, tex_coords);
        glEnableClientState(GL_VERTEX_ARRAY);		
        glVertexPointer(2, GL_FLOAT, 0, verts );
        glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
		
        glUseProgramObjectARB(NULL);
            
		[whichImage unbindTextureRepresentationFromCGLContext:cgl_ctx textureUnit:GL_TEXTURE0];
		[whichImage unlockTextureRepresentation];
    }
    else
	{
		glClearColor(0.0, 0.0, 0.0, 0.0);
		glClear(GL_COLOR_BUFFER_BIT);
	}
        
    // grab the verts
	if(vertexBufferID)
	{
		glReadBuffer(GL_COLOR_ATTACHMENT0_EXT);
		glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, vertexBufferID);	
		glReadPixels(0, 0, width, height, GL_RGBA, GL_FLOAT, NULL);
	}
    
    // grab the texture coords
	if(textureBufferID)
	{
		glReadBuffer(GL_COLOR_ATTACHMENT1_EXT);
		glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, textureBufferID);	
		glReadPixels(0, 0, width, height, GL_RGBA, GL_FLOAT, NULL);
	}
    
    if(normals)
    {
        // grab the normals
        glReadBuffer(GL_COLOR_ATTACHMENT2_EXT);
        glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, normalBufferID);	
        glReadPixels(0, 0, width, height, GL_RGBA, GL_FLOAT, NULL);   
    }

    glReadBuffer(GL_NONE);
    glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB, 0);
    
    glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
    
	glMatrixMode(GL_TEXTURE);
	glPopMatrix();
    
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();

    [self popGLState:cgl_ctx];
        
    // now draw the VAO properly
    [self pushGLState:cgl_ctx];
    
    glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
    
	// aspect ratio    
    GLfloat aspect = [image imageBounds].size.width/[image imageBounds].size.height;

    glRotated(self.inputRotationX, 1.0, 0.0, 0.0);
    glRotated(self.inputRotationY, 0.0, 1.0, 0.0);
    glRotated(self.inputRotationZ, 0.0, 0.0, 1.0);

    if(!self.inputLumaOrRaw)
    {
        glTranslated(-(0.5 * aspect * self.inputScaleX) + self.inputTranslationX, -(0.5 * self.inputScaleY) + self.inputTranslationY, self.inputTranslationZ );
        glScaled(aspect * self.inputScaleX, self.inputScaleY, self.inputScaleZ);
    }
    else
    {
        glTranslated(-(0.5 * self.inputScaleX) + self.inputTranslationX, -(0.5 * self.inputScaleY) + self.inputTranslationY, self.inputTranslationZ );
        glScaled(self.inputScaleX, self.inputScaleY, self.inputScaleZ);
    }
    
    if(self.inputBlendMode == 0)
        glDisable(GL_BLEND);
    else if(self.inputBlendMode == 1)
    {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    else
    {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    }
    
    if(self.inputDepthMode == 0)
        glDisable(GL_DEPTH_TEST);
    else if(self.inputDepthMode == 1)
    {
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);
        glDepthMask(GL_TRUE);
    }
    else
    {
        glEnable(GL_DEPTH_TEST);
        glDepthMask(GL_FALSE);
    }   
    
    if(image && [image lockTextureRepresentationWithColorSpace:[context colorSpace] forBounds:[image imageBounds]])
	{	
		[image bindTextureRepresentationToCGLContext:cgl_ctx textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];
		
		//glTexParameterf([image textureTarget], GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		//glTexParameterf([image textureTarget], GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	}
    
    if(self.inputUVGenMode)
    {
        glEnable(GL_TEXTURE_GEN_S);
        glEnable(GL_TEXTURE_GEN_T);
        
        GLenum uvGenMode;
        switch (self.inputUVGenMode)
        {
            case 1:
                uvGenMode = GL_OBJECT_LINEAR;
                break;
            case 2:
                uvGenMode = GL_EYE_LINEAR;
                break;
            case 3:
                uvGenMode = GL_SPHERE_MAP;
                break;
            default:
                uvGenMode = GL_OBJECT_LINEAR;
                break;
        }
        
        glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, uvGenMode);
        glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, uvGenMode);
    } 
    else
    {
        glDisable(GL_TEXTURE_GEN_S);
        glDisable(GL_TEXTURE_GEN_T);
    }
    
    if(self.inputAntialias)
    {
        glEnable(GL_LINE_SMOOTH);
        glEnable(GL_POINT_SMOOTH);
    }
    else
    {
        glDisable(GL_LINE_SMOOTH);	
        glDisable(GL_POINT_SMOOTH);
    }
    
    glEnable(GL_NORMALIZE);
    
    glBindVertexArrayAPPLE(vaoID);        
    
    const CGFloat* color;
    
    color = CGColorGetComponents(self.inputColor);
    
    glColor4f(color[0], color[1], color[2],color[3]);
    
    if(self.inputEnableClipping)
    {        
        planeEquation(-1.0, 0.0, self.inputMaxClip, 0.0, 1.0, self.inputMaxClip, 0.0, 0.0, self.inputMaxClip, eq1);
        planeEquation(0.0, 1.0, self.inputMinClip, -1.0, 0.0, self.inputMinClip, 0.0, 0.0, self.inputMinClip, eq2);

        glClipPlane(GL_CLIP_PLANE0, eq1);
        glEnable(GL_CLIP_PLANE0);

        glClipPlane(GL_CLIP_PLANE1, eq2);
        glEnable(GL_CLIP_PLANE1);
    }
    
    switch(drawType)
    {
        case 0: // scanlines
        {	
            glLineWidth(self.inputWireFrameWidth);
            glDrawElements(GL_LINES,(width - 1) * (height -1) * 2, GL_UNSIGNED_INT, 0);
            break;
        }
        case 1: // points
        {
            id<QCPlugInInputImageSource> sprite = self.inputPointSpriteImage;

            glPointSize(self.inputWireFrameWidth);

            float coefficients[3];

            if(self.inputAttenuatePoints)
            {
                coefficients[0] = self.inputConstantAttenuation;
                coefficients[1] = self.inputLinearAttenuation;
                coefficients[2] = self.inputQuadraticAttenuation;
            }   
            else
            {
                coefficients[0] = 1;
                coefficients[1] = 0;
                coefficients[2] = 0;            
            }
			glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION, coefficients);
            
            if(sprite && [sprite lockTextureRepresentationWithColorSpace:[context colorSpace] forBounds:[sprite imageBounds]])
            {
                glActiveTexture(GL_TEXTURE1);
                glEnable(GL_POINT_SPRITE);
                                               
                [sprite bindTextureRepresentationToCGLContext:cgl_ctx textureUnit:GL_TEXTURE1 normalizeCoordinates:YES];
                
                if([sprite textureTarget] == GL_TEXTURE_2D)
                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

                glTexEnvf(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);
                
                //glPointParameterfv(GL_POINT_SIZE_MIN, &min);
                //glPointParameterfv(GL_POINT_SIZE_MAX, &max);
                //glPointParameterfv(GL_POINT_FADE_THRESHOLD_SIZE, &thresh);
                
//                if(self.inputBlendMode == 1)
//                {
//                    glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
//                }
//                else
//                {
//                    glBlendFunc(GL_ZERO, GL_ONE);
//                }
                
                // write to depth only
             //   glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
//                glDepthFunc(GL_);
//                glDepthMask(GL_TRUE);
//                glDrawElements(GL_POINTS, (width - 1) * (height - 1) * 2, GL_UNSIGNED_INT, 0);
//
//                // disable writing to depth, use depth test if its enabled                
//                glDepthMask(GL_FALSE);
//                glDepthFunc(GL_LEQUAL);
//                glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
            }
            
            glDrawElements(GL_POINTS, (width - 1) * (height - 1) * 2, GL_UNSIGNED_INT, 0);
            
            if(sprite)
            {
                glDisable(GL_POINT_SPRITE);
                glTexEnvf(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_FALSE);

                [sprite unbindTextureRepresentationFromCGLContext:cgl_ctx textureUnit:GL_TEXTURE1];
                [sprite unlockTextureRepresentation];
                glActiveTexture(GL_TEXTURE0);
            }
        
                break;
        }
        case 2: // square mesh
        {
            glDrawElements(GL_LINES, (width -1) * (height -1) * 6, GL_UNSIGNED_INT, 0);
            break;
        }
        case 3: // triangle mesh
        {
            glLineWidth(self.inputWireFrameWidth);
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            glDrawElements(GL_TRIANGLES, (width -1) * (height -1) * 6, GL_UNSIGNED_INT, 0);
            break;
        }
        case 4: // solid plane
        {	
            glDrawElements(GL_TRIANGLES, (width -1) * (height -1) * 6, GL_UNSIGNED_INT, 0);
            break;
        }
        default:
            break;
    }
    
    glBindVertexArrayAPPLE(0);        

    if(self.inputEnableClipping)
    {
        glDisable(GL_CLIP_PLANE0);
        glDisable(GL_CLIP_PLANE1);
    }
    
    
    if(image)
    {
        // unbind texture
        [image unbindTextureRepresentationFromCGLContext:cgl_ctx textureUnit:GL_TEXTURE0];
        [image unlockTextureRepresentation];
    }
    
    glPopMatrix();
    
    [self popGLState:cgl_ctx];
    
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
    [self destroyGLResourcesInContext:[context CGLContextObj]];
    [self destroyPersistantGLResources];
}

- (void) createPersistantGLResourcesInContext:(CGLContextObj)cgl_ctx
{
    if (ruttEtraMRTshader == nil)
    {
        // load our MRT shader
        ruttEtraMRTshader =  [[v002Shader alloc] initWithShadersInBundle:[NSBundle bundleForClass:[self class]]
                                                                withName:@"v002.RuttEtraMRT"
                                                              forContext:cgl_ctx];
    }
    if (ruttEtraMRTshaderNormals == nil)
    {
        ruttEtraMRTshaderNormals = [[v002Shader alloc] initWithShadersInBundle:[NSBundle bundleForClass:[self class]]
                                                                      withName:@"v002.RuttEtraMRTNormals"
                                                                    forContext:cgl_ctx];
    }
    if (ruttEtraMRTshaderNormalsHQ == nil)
    {
        ruttEtraMRTshaderNormalsHQ = [[v002Shader alloc] initWithShadersInBundle:[NSBundle bundleForClass:[self class]]
                                                                        withName:@"v002.RuttEtraMRTHQNormals"
                                                                      forContext:cgl_ctx];
    }
}

- (void) destroyPersistantGLResources
{
    [ruttEtraMRTshader release];
    ruttEtraMRTshader = nil;
    
    [ruttEtraMRTshaderNormals release];
    ruttEtraMRTshaderNormals = nil;
    
    [ruttEtraMRTshaderNormalsHQ release];
    ruttEtraMRTshaderNormalsHQ = nil;
}

- (void) createGLResourcesInContext:(CGLContextObj)cgl_ctx width:(NSUInteger)w height:(NSUInteger)h drawType:(NSUInteger)drawType normals:(BOOL)normals 
{
    [self destroyGLResourcesInContext:cgl_ctx];

    [self pushGLState:cgl_ctx];

    // create our FBO, and texture attachments
    glGenFramebuffers(1, & fboID);
    
    glGenTextures(1, &texureAttachmentVertices);
    glEnable(GL_TEXTURE_RECTANGLE_ARB);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texureAttachmentVertices);
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA32F_ARB, w, h, 0, GL_RGBA, GL_FLOAT, NULL);
    
    glGenTextures(1, &texureAttachmentTextureCoords);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texureAttachmentTextureCoords);
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA32F_ARB, w, h, 0, GL_RGBA, GL_FLOAT, NULL);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
    
    if(normals)
    {
        glGenTextures(1, &texureAttachmentNormals);
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texureAttachmentNormals);
        glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA32F_ARB, w, h, 0, GL_RGBA, GL_FLOAT, NULL);
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
    }
    // associate our textures to the renderable attachments of the FBO
    glBindFramebuffer(GL_FRAMEBUFFER, fboID);
    glFramebufferTexture2D(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_ARB, texureAttachmentVertices, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT1_EXT, GL_TEXTURE_RECTANGLE_ARB, texureAttachmentTextureCoords, 0);
    if(normals)
        glFramebufferTexture2D(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT2_EXT, GL_TEXTURE_RECTANGLE_ARB, texureAttachmentNormals, 0);
    
    // create our buffers
    glGenBuffers(1, &vertexBufferID);
	if(vertexBufferID)
	{
		glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
		glBufferData(GL_ARRAY_BUFFER, w * h * 4 * sizeof(GLfloat), NULL, GL_STREAM_COPY);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
	
    glGenBuffers(1, &textureBufferID);
	if(textureBufferID)
	{
		glBindBuffer(GL_ARRAY_BUFFER, textureBufferID);
		glBufferData(GL_ARRAY_BUFFER, w * h * 4 * sizeof(GLfloat), NULL, GL_STREAM_COPY);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
	
    if(normals)
    {
        glGenBuffers(1, &normalBufferID);
        glBindBuffer(GL_ARRAY_BUFFER, normalBufferID);
        glBufferData(GL_ARRAY_BUFFER, w * h * 4 * sizeof(GLfloat), NULL, GL_STREAM_COPY);
        glBindBuffer(GL_ARRAY_BUFFER, 0);    
    }    
    
    glGenBuffers(1, &indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    if((drawType == 0) || (drawType == 1)) // scanlines or points
    {
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, (w - 1) * (h -1) * 2 * sizeof(GLuint), NULL, GL_STATIC_DRAW);
        GLuint* indices = (GLuint*)glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_ARB);        
      
        GLuint i = 0, x, y;
		for( y = 0; y < h - 1 ; y++)
		{
			for(x = 0; x < w - 1 && w > 2; x++)
			{
				// this little aparatus makes sure we do not draw a line segment between different rows of scanline.
				if (i % (w - 2) <= (w - 1))
				{ 
					indices[i + 0] = x + y * w;
					indices[i + 1] = x + y * w + 1;
				} 
				i+= 2;
			} 	  
		}
        
        glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
 /*   else if (drawType == 1)
    {	
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, (w - 1) * (h -1) * 2 * sizeof(GLuint), NULL, GL_STATIC_DRAW);
        GLuint* indices = (GLuint*)glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_ARB);        
                
        GLuint i = 0, x, y;

        for( y = 0; y < h - 1; y++)
        {
            for(x = 0; x < w -1 ; x++)
            {
                indices[i + 0] = x + y * w;
                indices[i + 1] = x + y * w + w + 1;	
                i += 2;
            }
        }
        glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
    else if(drawType == 2)
    {
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, (w - 1) * (h -1) * 2 * sizeof(GLuint), NULL, GL_STATIC_DRAW);
        GLuint* indices = (GLuint*)glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_ARB);        
        
        GLuint i = 0, x, y;
        
        for( y = 0; y < h - 1; y++)
        {
            for(x = 0; x < w -1 ; x++)
            {
                indices[i + 0] = x + y * w + 1;
                indices[i + 1] = x + y * w + w;
                i += 2;
            }
        }
        glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }   
  */
    else
    {
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, (w - 1) * (h - 1) * 6 * sizeof(GLuint), NULL, GL_STATIC_DRAW);
        GLuint* indices = (GLuint*)glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_ARB);        

        GLuint i = 0, x, y;
		for(y = 0; y < h - 1; y++)
		{
			for(x = 0; x < w - 1 ; x++)
			{
				indices[i + 0] = x + y * w;
				indices[i + 1] = x + y * w + w;
				indices[i + 2] = x + y * w + 1;
				indices[i + 3] = x + y * w + 1;
				indices[i + 4] = x + y * w + w;
				indices[i + 5] = x + y * w + w + 1;
				i += 6;
			}
		}		
        
        glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
        
    // create our VAO which encapsulates all client state and buffer binding in one object.
    // this saves us state validation, and calls to GL.
    glGenVertexArraysAPPLE(1, &vaoID);
    
    glBindVertexArrayAPPLE(vaoID);

    if(normals)
    {
        glBindBuffer(GL_ARRAY_BUFFER, normalBufferID);
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT, sizeof(GLfloat) *4, NULL);
    }
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, textureBufferID);
    glTexCoordPointer(4, GL_FLOAT, sizeof(GLfloat) * 4, 0);

    glEnableClientState(GL_VERTEX_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glVertexPointer( 4, GL_FLOAT, 4 * sizeof(float), 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);

    glBindVertexArrayAPPLE(0);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    [self popGLState:cgl_ctx];
}

- (void) destroyGLResourcesInContext:(CGLContextObj)cgl_ctx
{
    if(fboID)
    {
        glDeleteFramebuffers(1, &fboID);
        fboID = 0;
    }
    
    if(texureAttachmentVertices)
    {
        glDeleteTextures(1, &texureAttachmentVertices);
        texureAttachmentVertices = 0;
    }

    if(texureAttachmentNormals)
    {
        glDeleteTextures(1, &texureAttachmentNormals);
        texureAttachmentNormals = 0;
    }
    
    if(texureAttachmentTextureCoords)
    {
        glDeleteTextures(1, &texureAttachmentTextureCoords);
        texureAttachmentTextureCoords = 0;
    }
    
    if(vertexBufferID)
    {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    
    if(normalBufferID)
    {   
        glDeleteBuffers(1, &normalBufferID);
        normalBufferID = 0;
    }
    
    if(textureBufferID)
    {
        glDeleteBuffers(1, &textureBufferID);
        textureBufferID = 0;
    }
    
    if(indexBufferID)
    {
        glDeleteBuffers(1, &indexBufferID);
        indexBufferID = 0;
    }
    
    if(vaoID)
    {
        glDeleteVertexArraysAPPLE(1, &vaoID);
        vaoID = 0;
    }
}

- (void) pushGLState:(CGLContextObj)cgl_ctx
{
    glPushAttrib(GL_ALL_ATTRIB_BITS);
    glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS);
    
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, &previousFBO);
	glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING_EXT, &previousReadFBO);
	glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING_EXT, &previousDrawFBO);
	glGetIntegerv(GL_CURRENT_PROGRAM, &previousShader);
    glGetIntegerv(GL_READ_BUFFER, &previousReadBuffer);
    glGetIntegerv(GL_PIXEL_PACK_BUFFER_BINDING, &previousPixelPackBuffer);
}

- (void) popGLState:(CGLContextObj)cgl_ctx
{
	glUseProgram(previousShader);
	glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, previousDrawFBO);
	glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, previousReadFBO);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, previousFBO);
    
    glReadBuffer(previousReadBuffer);
    glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, previousPixelPackBuffer);

    glPopClientAttrib();
	glPopAttrib();	
}



@end
