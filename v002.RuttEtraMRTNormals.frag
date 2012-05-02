varying vec2 texcoord0;

varying vec2 s1Coord;
varying vec2 s2Coord;
varying vec2 s3Coord;

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
    float h0 = luma;
    float h1 = dot(lumcoeff, texture2DRect( tex0, s2Coord ));
    float h2 = dot(lumcoeff, texture2DRect( tex0, s3Coord ));
            
    vec3 v01 = vec3( s2Coord.x, s2Coord.y, h1 - h0 );
    vec3 v02 = vec3( s3Coord.x, s3Coord.y, h2 - h0 );

    vec3 n = cross( v02, v01 );

    // Can be useful to scale the Z component to tweak the
    // amount bumps show up, less than 1.0 will make them
    // more apparent, greater than 1.0 will smooth them out
    n.z *= -coef;

    gl_FragData[2] =  vec4(normalize( n ), 1.0);
}