#version 330 core
#define CONFIG_HAS_VERTEX
#define CONFIG_HAS_FRAGMENT

#ifdef CONTROL_COMPILE_VERTEX
layout(location = 0) in vec2 pos;
layout(location = 1) in vec2 inUv;
out vec2 UV;

void main()
{
	gl_Position = vec4(pos.x*2-1, pos.y*2-1, 0.0f, 1.0f);
	UV = vec2(inUv.x, inUv.y);
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