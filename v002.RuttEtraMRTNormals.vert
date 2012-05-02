varying vec2 texcoord0;

varying vec2 s2Coord;
varying vec2 s3Coord;

void main()
{
    // perform standard transform on vertex
    gl_Position = ftransform();

    // transform texcoords
	texcoord0 = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);
    	
	s2Coord = texcoord0 + vec2(1.0, 0.0);
	s3Coord = texcoord0 + vec2(0.0, 1.0);
}