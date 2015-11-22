// This is the Default program for the d2d engine.
// It takes some verts, a texture and a mvp-matrix and renders all that on screen.

// Because noone likes too split-up files, vertex and fragment shader live in a single file
#ifdef STAGE_VERTEX
	void main() 
	{
		gl_Position = MVP*in_pos;
		UV = in_uv;
	}
#endif

#ifdef STAGE_FRAGMENT
	void main()
	{
		//gl_FragColor = vec4(1.0,UV.x,UV.y,1.0);
		gl_FragColor = texture2D(textureSampler, calcOffsetUV(UV));
	}
#endif
