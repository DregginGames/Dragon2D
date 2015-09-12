/**
	d2d.core.render.view holds the view classes that manage the rendering of the scene on screen.
*/
module d2d.core.render.view;
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
	@property mat4 worldToView()
	{
		return _worldToView;
	}


protected:

	void _updateWorldToView()
	{
		_worldToView = gen2DWorldToView(_pos)*genOrtographicProjection(_size.x, _size.y);
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

	/// this generated member is the WorldToView matrix for this view
	mat4 _worldToView;
}