/**
	d2d.core.render.renderer holds the classes used to render the whole engine. 
*/
module d2d.core.render.renderer;

import std.algorithm;

import gl3n.linalg;
import derelict.opengl3.gl3;

import d2d.core.base;
import d2d.core.render.objects;
import d2d.core.render.util;

/// The renderer manages the finalized rendering of all classes within the engine; it abstracts all calls to the graphics api away from the engine
class Renderer : Base
{
	this()
	{
		registerAsService("d2d.renderer");
	}

	/// Adds a view that will be shown on screen
	void pushView(View view)
	{
		_views ~= view;
	}

	/// Adds an object to be renderd
	void pushObject(Renderable r)
	{
		_objects ~= r;
	}

	/// Renders the scene, cleans the pushed objects
	override void postRender()
	{
		//clean everythin
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        //glClearColor(1.0f,1.0f,0.0f,1.0f);
		// sort views by z-index: higer index means later rendering
		sort!("a.zindex < b.zindex",SwapStrategy.stable)(_views);
        sort!("a.detailLevel < b.detailLevel",SwapStrategy.stable)(_objects);

		// Render everything
		foreach(ref v; _views) {
			// we clamp the viewport to the pixel-grid. Overlapping is better than a black gap, and overlapped things will simply be invisible.
			vec2i viewportPos = toPixel(v.viewportPos);
			vec2i viewportSize = toPixel(v.viewportSize, true);
            if(_currViewportPos != viewportPos || _currViewportSize != viewportSize) {
			    glViewport(viewportPos.x, viewportPos.y, viewportSize.x, viewportSize.y);
                _currViewportPos = viewportPos;
                _currViewportSize = viewportSize;
            }        
            // some objects are renderd independendly of workd coordinates, so we want this thing
            auto screenView = new ScreenSpaceView(v);
			foreach(ref o; _objects) {
                if (v.detailLevel >= o.detailLevel) {
                    if (o.ignoreView) {
                        o.render(screenView);
                    } else {
				        o.render(v);
                    }
                }
			}
		}

		//cleanup
		_views.length = 0;
		_objects.length = 0;
	}
private:
	/// The views
	View[] _views;

    /// Cached viewport offset
    vec2i _currViewportPos = vec2i(0,0);
    vec2i _currViewportSize = vec2i(0,0);
	/// The scene objects
	Renderable[] _objects;

}
