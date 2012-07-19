varying vec2 texcoord0;

uniform sampler2DRect tex0;
uniform vec2 imageSize;
uniform float useRaw;
uniform float extrude;

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
}