attribute vec4 position;
attribute vec4 normal;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

uniform mat4 normalMatrix;

varying vec4 colorVarying;

void main()
{
	vec4 vertexEye 	= modelViewMatrix * position;
	vec4 normalEye 	= normalize(normalMatrix * normal);

	gl_Position = projectionMatrix * vertexEye;
	float g = dot(normalEye.xyz,normalize(-vertexEye.xyz));

	colorVarying = vec4(g,g,g, 1.0);
}