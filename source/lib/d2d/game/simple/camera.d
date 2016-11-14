/**
	d2d.game.simple.camera holds the default camera class
*/
module d2d.game.simple.camera;

import gl3n.linalg;

import d2d.core.render;
import d2d.game.entity;

// this is unluckey. I should fix this.
import d2d.game.ui.cursor;

/// A simple fullscreen camera. 
class Camera : Entity
{
    /// Creates a new camera. If mainCamera is true, it will overwrite the mainCamera service
	this(float height, bool mainCamera=false)
	{
		_height = height;
		auto size = aspectRatioRectangleRange(height);
		_view = new View(vec2(0.0f,0.0f), size);
        _view.detailLevel = 100; //we want to see everything!
        if (mainCamera) {
            registerAsService("d2d.mainCamera");
        }
        _cursor = new Cursor();
        _worldCursor = new WorldCursor();
        this.addChild(_cursor);
        this.addChild(_worldCursor);
	}

	/// tje height of the cameras view
	@property float height() const
	{
		return _height;
	}
    /// Ditto
	@property float height(float h)
	{
        _view.size = aspectRatioRectangleRange(h);
		return _height = h;
	}

    /// Returns the objects view. Not const becuase we need to change _view here
    @property View view()
    {
        _view.pos = this.absolutePos; //needed to give an updated view back
        return _view;
    }

    /// Returns the (World)Cursor of this camera
    @property Cursor cursor()
    {
        return _cursor;
    }
    /// Ditto
    @property WorldCursor worldCursor()
    {
        return _worldCursor;
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

    /// The cursor and the world cursor of this camera
    Cursor _cursor;
    /// Ditto
    WorldCursor _worldCursor;
}