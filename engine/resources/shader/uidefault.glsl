// This is the UI default program for the d2d engine.
// It ignores all transformations and renders in -1..1 space.

#ifdef STAGE_VERTEX
	void main() 
	{
		gl_Position = in_pos;
		UV = in_uv;
	}
#endif

#ifdef STAGE_FRAGMENT
	void main()
	{
		//gl_FragColor = vec4(1.0,UV.x,UV.y,1.0);
		gl_FragColor = texture2D(textureSampler, UV);
	}
#endif