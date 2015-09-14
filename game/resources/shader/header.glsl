// This file is the default header for all .glsl files. 
// It is automatically appended to all loaded .glsl files.

// These are the default input-variables used by the vertex shader.
#ifdef STAGE_VERTEX
    layout(location = 0) in vec4 in_pos;
    layout(location = 1) in vec2 in_uv;
    uniform mat4 MVP; 
    // and some output
    out vec2 UV;
#endif // STAGE_VERTEX

// these are the default input-variables used by the fragment shader.
#ifdef STAGE_FRAGMENT 
    uniform sampler2D textureSampler;
    in vec2 UV;
	out vec4 outColor;
#endif //STAGE_FRAGMENT
