// This file is the default header for all .glsl files. 
// It is automatically appended to all loaded .glsl files.

// These are the default input-variables used by the vertex shader.
#ifdef STAGE_VERTEX
    attribute vec4 in_pos;
    attribute vec2 in_uv;
    uniform mat4 MVP; 
    // and some output
    varying vec2 UV;
#endif // STAGE_VERTEX

// these are the default input-variables used by the fragment shader.
#ifdef STAGE_FRAGMENT 
	precision mediump float;
    uniform sampler2D textureSampler;
	uniform vec2 uvpos; // Used for UV offsetting. a bit ugly but the alternative is altering buffers.
	uniform vec2 uvsize;
    varying vec2 UV;
	
	// Calculates an offset UV - used by everythig quad-based to give an example
	// i think its extreamly ugly, but the alternative is altering buffers...
	vec2 calcOffsetUV(vec2 inUV) 
	{
		return uvpos+vec2(UV.x*uvsize.x,UV.y*uvsize.y);
	}
#endif //STAGE_FRAGMENT
