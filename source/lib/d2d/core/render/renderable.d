/**
	d2d.core.render.renderable holds the base class for object rendering. 
*/
module d2d.core.render.renderable;

import gl3n.linalg;
import gl3n.math;

import d2d.core.render.view;

/**
	Renderable is abstract base for all types of /renderables/. 
	A Renderable is an object that actually is renderd on screen, like a circle, a textured quad, a tile map, ....
	Its one of the few structures that life outside the Base-class hirarchy
*/
abstract class Renderable
{
	/// Performs an actual render on screen.
	void Render(ref View view)
	{
		
	}

	
private:

}