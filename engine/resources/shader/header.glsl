// This file is the default header for all .glsl files. 
// It is automatically appended to all loaded .glsl files.

// These are the default input-variables used by the vertex shader.
#ifdef STAGE_VERTEX
    attribute in vec4 in_pos;
    attribute in vec2 in_uv;
    uniform mat4 MVP; 
    // and some output
    varying vec2 UV;
#endif // STAGE_VERTEX

// these are the default input-variables used by the fragment shader.
#ifdef STAGE_FRAGMENT 
	precision mediump float;
    uniform sampler2D textureSampler;
    varying vec2 UV;
#endif //STAGE_FRAGMENT
