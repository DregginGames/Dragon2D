/**
	d2d.core.render.renderer holds the classes used to render the whole engine. 
*/
module d2d.core.render.renderer;

import d2d.core.base;
import d2d.core.render.view;
import d2d.core.render.renderable;

/// The renderer manages the finalized rendering of all classes within the engine; it abstracts all calls to the graphics api away from the engine
class Renderer : Base
{
	this()
	{
		registerAsService("d2d.renderer");
	}

	
}