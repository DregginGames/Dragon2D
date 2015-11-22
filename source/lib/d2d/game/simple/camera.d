/**
	d2d.game.simple.camera holds the default camera class
*/
module d2d.game.simple.camera;

import gl3n.linalg;

import d2d.core.render.objects.view;
import d2d.core.render.util;
import d2d.core.render.renderer;
import d2d.game.entity;

/// A simple fullscreen camera. 
class Camera : Entity
{
	this(float height)
	{
		_height = height;
		auto size = aspectRatioRectangleRange(height);
		_view = new View(vec2(0.0f,0.0f), size);
        _view.detailLevel = 100; //we want to see everything!
	}

	/// tje height of the cameras view
	@property float height()
	{
		return _height;
	}
	@property float height(float h)
	{
		return _height = h;
	}

    @property View view()
    {
        _view.pos = this.absolutePos; //needed to give an updated view back
        return _view;
    }

	override void render()
	{
		auto renderer = getService!Renderer("d2d.renderer");
		renderer.pushView(this.view);
	}
private:
	/// the height of the cameras view
	float _height = 1.0f;

	/// the view of this camera
	View _view;
}