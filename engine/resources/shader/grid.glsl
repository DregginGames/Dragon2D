// This is the Default program for the d2d engine.
// It takes some verts, a texture and a mvp-matrix and renders all that on screen.

// Because noone likes too split-up files, vertex and fragment shader live in a single file
#ifdef STAGE_VERTEX
	varying vec2 not_uv;
	void main() 
	{
		gl_Position = vec4(in_pos.x*2.0,in_pos.y*2.0,0.0,1.0);
		not_uv = in_pos.xy;
	}
#endif

#ifdef STAGE_FRAGMENT
	uniform vec4 color;
	varying vec2 not_uv;
	void main()
	{
		float x = fract(not_uv.x*25.0);
		float y = fract(not_uv.y*25.0);
		if(x>0.95 || y>0.95) {
			gl_FragColor = color;
		} else {
			gl_FragColor = vec4(0.0);
		}
	}
#endif
