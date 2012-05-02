varying vec2 texcoord0;


varying vec2 s1Coord;
varying vec2 s2Coord;
varying vec2 s3Coord;
varying vec2 s4Coord;
varying vec2 s5Coord;
varying vec2 s6Coord;
varying vec2 s7Coord;
varying vec2 s8Coord;


uniform sampler2DRect tex0;
uniform vec2 imageSize;
uniform float useRaw;
uniform float extrude;

uniform float coef;

const vec4 lumcoeff = vec4(0.299,0.587,0.114,0.);

void main (void)
{
	vec4 pixel = texture2DRect(tex0, texcoord0);
	float luma = dot(lumcoeff, pixel);
    
    float normX = floor(gl_FragCoord.x)  / (imageSize.x - 1.0);
    float normY = floor(gl_FragCoord.y)  / (imageSize.y - 1.0);
    
    vec4 lumaPixel = vec4(normX, normY, luma * extrude, 1.0);

	gl_FragData[0] = mix(lumaPixel, vec4(pixel.rgb, 1.0), useRaw);
    gl_FragData[1] = vec4(normX, normY, 0.0, 1.0);

    // Normal calculation
    
    float h00 = dot(lumcoeff,texture2DRect( tex0, s1Coord ));
    float h10 = dot(lumcoeff,texture2DRect( tex0, s2Coord ));
    float h20 = dot(lumcoeff,texture2DRect( tex0, s3Coord ));

    float h01 = dot(lumcoeff,texture2DRect( tex0, s4Coord ));
    float h21 = dot(lumcoeff,texture2DRect( tex0, s5Coord ));

    float h02 = dot(lumcoeff,texture2DRect( tex0, s6Coord ));
    float h12 = dot(lumcoeff,texture2DRect( tex0, s7Coord ));
    float h22 = dot(lumcoeff,texture2DRect( tex0, s8Coord ));
    
    // The Sobel X kernel is:
    //
    // [ 1.0  0.0  -1.0 ]
    // [ 2.0  0.0  -2.0 ]
    // [ 1.0  0.0  -1.0 ]
    
    float Gx = h00 - h20 + 2.0 * h01 - 2.0 * h21 + h02 - h22;
                
    // The Sobel Y kernel is:
    //
    // [  1.0    2.0    1.0 ]
    // [  0.0    0.0    0.0 ]
    // [ -1.0   -2.0   -1.0 ]
    
    float Gy = h00 + 2.0 * h10 + h20 - h02 - 2.0 * h12 - h22;
    //float Gz = h00 + 2.0 * h10 + h20 - h02 - 2.0 * h12 - h22;
    
    // Generate the missing Z component - tangent
    // space normals are +Z which makes things easier
    // The 0.5f leading coefficient can be used to control
    // how pronounced the bumps are - less than 1.0 enhances
    // and greater than 1.0 smoothes.
    float Gz = coef * sqrt( 1.0 - Gx * Gx - Gy * Gy );
    //float Gy = 0.5 * sqrt( 1.0 - Gx * Gx - Gz * Gz );

    // Make sure the returned normal is of unit length
    gl_FragData[2] = vec4( normalize( vec3( 2.0 * Gx, 2.0 * Gy, Gz)) , 1.0);
    //gl_FragData[2] = vec4( normalize( vec3( 2.0 * Gx, Gy * coef, Gz * 2.0)) , 1.0);

    

}