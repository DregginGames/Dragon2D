// This is the Default program for the d2d engine.
// It takes some verts, a texture and a mvp-matrix and renders all that on screen.

// Because noone likes too split-up files, vertex and fragment shader live in a single file
#ifdef STAGE_VERTEX
	void main() 
	{
		gl_Position =  MVP*in_pos;
		UV = in_uv;
	}
#endif

#ifdef STAGE_FRAGMENT
	void main()
	{
		outColor = texture(textureSampler, UV);
	}
#endif
