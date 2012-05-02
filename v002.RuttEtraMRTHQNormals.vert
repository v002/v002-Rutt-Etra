varying vec2 texcoord0;

varying vec2 s1Coord;
varying vec2 s2Coord;
varying vec2 s3Coord;
varying vec2 s4Coord;
varying vec2 s5Coord;
varying vec2 s6Coord;
varying vec2 s7Coord;
varying vec2 s8Coord;


void main()
{
    // perform standard transform on vertex
    gl_Position = ftransform();

    // transform texcoords
	texcoord0 = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);
    
    s1Coord = texcoord0 + vec2(-1.0, -1.0);
	s2Coord = texcoord0 + vec2(0.0, -1.0);
	s3Coord = texcoord0 + vec2(1.0, -1.0);
	s4Coord = texcoord0 + vec2(-1.0, 0.0);
	s5Coord = texcoord0 + vec2(1.0, 0.0);
	s6Coord = texcoord0 + vec2(-1.0, 1.0);
	s7Coord = texcoord0 + vec2(0.0, 1.0);
	s8Coord = texcoord0 + vec2(1.0, 1.0);
}