/**
	d2d.core.render.view holds the view classes that manage the rendering of the scene on screen.
*/
module d2d.core.render.objects.view;

import gl3n.linalg;
import gl3n.math;

import d2d.core.render.util;

/// a view is the representation of the engine on screen. The scene is renderd for each registerd (pusehd) view. 
class View
{
	/// Creates the view. Position is relative on screen, with 0,0 being the lower left corner.
	this(vec2 pos, vec2 size, vec2 viewportPos = vec2(0.0,0.0), vec2 viewportSize =vec2(1.0,1.0), uint zindex = 0)
	{
		_pos = pos;
		_size = size;
		_viewportPos = viewportPos;
		_viewportSize = viewportSize;
		_zindex = zindex;

		// set initial value
		_updateWorldToView();
	}



	/// Retrun the Projection matrix for this view
	@property const mat4 worldToView()
	{
		return _worldToView;
	}

    /// The world-position of the view
    @property vec2 pos() const
    {
        return _pos;
    } 
    @property vec2 pos(vec2 p)
    {   
        _pos = p;
        _updateWorldToView();
        return _pos;
    }

    /// The world-size (visible area of the world) of the view
    @property vec2 size() const
    {
        return _size;
    }
    @property vec2 size(vec2 s)
    {
        _size = s;
        _updateWorldToView();
        return _size;
    }

    /// The screen-position of the view (!lower-left corner, -1..1!)
    @property vec2 viewportPos() const
    {
        return _viewportPos;
    }
    @property vec2 viewportPos(vec2 p)
    {
        _viewportPos = p;
        _updateWorldToView();
        return _viewportPos;
    }

    /// The screen-size of the view (!-1..1!) 
    @property vec2 viewportSize() const
    {
        return _viewportSize;
    }
    @property vec2 viewportSize(vec2 s)
    {
        _viewportSize = s;
        _updateWorldToView();
        return _viewportSize;
    }

	/// returns the zindex of the view. Higher zindex means later rendering -> on top
	@property uint zindex() const
	{
		return _zindex;
	}
	/// sets the zindex
	@property uint zindex(uint z)
	{
		return _zindex = z;
	}

    /// returns the detail level that this view can see
    @property int detailLevel() const
    {
        return _detailLevel;
    }
    @property int detailLevel(int l)
    {
        return _detailLevel = l;
    }

protected:

    /// Updates the world to view Matrix
	void _updateWorldToView()
	{
		_worldToView = genOrtographicProjection(_size.x, _size.y)*gen2DWorldToView(_pos);
	}

private:
	/// the position inside of the engine coorditantes
	vec2 _pos;
	/// thesize of the view inside of the engine coorditantes
	vec2 _size;
	/// the position on screen
	vec2 _viewportPos;
	/// the size on screen
	vec2 _viewportSize;
	/// higer z-index means renderd later -> above other views
	uint _zindex = 0;
    /// the detail level
    uint _detailLevel = 19; // see d2d.core.render.renderable

	/// this generated member is the WorldToView matrix for this view
	mat4 _worldToView;
}

/// This class is a helper for objects that will be only positioned in screen space
final class ScreenSpaceView : View
{
    /// Creates a ScreenSpace view from a normal view
    this(in View v) 
    {
        super(v.pos, v.size, v.viewportPos, v.viewportSize, v.zindex);
    }

    /// Returns mat4.identity so the ScreenSpace view causes no side effects
    /// The aspect ratio however is kept, so -1,-1 is not a corner but the furthest point in a square on the screen!
    final override @property const mat4 worldToView() 
    {
        mat4 result = mat4.identity;
        vec2 s = size();
        double r = s.y/s.x;
        result[0][0] = r;
        return result;
    }
protected:
    /// Generation is overwritten since it is not needed
    final override void _updateWorldToView()
    {
    }

    
}