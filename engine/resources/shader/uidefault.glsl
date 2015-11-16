// This is the UI default program for the d2d engine.
// It ignores all transformations and renders in -1..1 space.

// Because noone likes too split-up files, vertex and fragment shader live in a single file
#ifdef STAGE_VERTEX
	void main() 
	{
		gl_Position =  in_pos;
		UV = in_uv;
	}
#endif

#ifdef STAGE_FRAGMENT
	void main()
	{
		outColor = texture(textureSampler, UV);
	}
#endif
