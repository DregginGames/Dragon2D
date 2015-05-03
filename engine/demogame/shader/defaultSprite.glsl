#define CONFIG_HAS_VERTEX
#define CONFIG_HAS_FRAGMENT

#ifdef CONTROL_COMPILE_VERTEX
layout(location = 0) in vec3 vertexPosition_screenspace;
uniform vec4 position;
uniform vec4 offset;
out vec2 UV;

void main()
{
	float xscale = (vertexPosition_screenspace.x + 1) / 2;
	float yscale = (vertexPosition_screenspace.y + 1) / 2;
	vec2 inpos = vec2(position.x * 2 - 1 + xscale * 2 * position[2], (1-position.y-position[3]) * 2 - 1 + yscale * 2 * position[3]);
	gl_Position = vec4(inpos, 0, 1.0);
	float uvx = offset[0]+xscale*offset[2];
	float uvy = (1.0f-offset[1])+(yscale-1.0f)*offset[3];
	UV = vec2(uvx, uvy);
}

#endif

#ifdef CONTROL_COMPILE_FRAGMENT
in vec2 UV;
out vec4 color;
uniform sampler2D textureSampler;

void main()
{
	color = texture2D(textureSampler, UV).rgba;
}

#endif