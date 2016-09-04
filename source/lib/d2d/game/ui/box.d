/**
    Holds the box ui class
*/
module d2d.game.ui.box;

import std.json;
import gl3n.linalg;

import d2d.util.serialize;
import d2d.core.render.objects.quad;
import d2d.core.render.renderer;
import d2d.game.ui.uielement;

/**
    A box is a simple colored box renderd to the screen
*/
class Box : UIElement
{
    /// Constructor
    this()
    {
        _quad = new ColoredQuad();
        _quad.ignoreView = true;
    }

    /// Renders a box
    override void render()
    {
        _quad.scale = vec3(viewSize.x,viewSize.y, 1.0f);
        _quad.pos = viewPos+vec2(viewSize.x*0.5,-viewSize.y*0.5);
        auto r = getService!Renderer("d2d.renderer");
        r.pushObject(_quad);
    }

    /// The color of the box
    @property vec4 color()
    {
        return _quad.color;
    }
    /// Ditto
    @property vec4 color(vec4 c)
    {
        return _quad.color=c;
    }
    
    mixin createSerialize!(true,"_quad.color");

private:
    /// The ColoredQuad used to draw this ui box
    ColoredQuad _quad;
}

/**
    A border box is a simple colored box with a border. 
*/
class BorderBox : Box
{
    /// Constructs a new borderd box
    this() 
    {
        _borderQuad = new ColoredQuad();
        _borderQuad.ignoreView = true;
    }

    /// Renders a borderd box
    override void render()
    {
        _borderQuad.scale = vec3(viewSize.x*(1.0+_borderWidth*2),viewSize.y*(1.0+_borderWidth*2), 1.0f);
        _borderQuad.pos = viewPos-vec2(_borderWidth,_borderWidth);

        auto r = getService!Renderer("d2d.renderer");
        r.pushObject(_borderQuad);
        super.render();
    }
    /// Color of the border of this box
    @property vec4 borderColor()
    {
        return _borderQuad.color;
    }
    /// Dittp
    @property vec4 borderColor(vec4 c)
    {
        return _borderQuad.color=c;
    }

    /// The width of the border of this box - absolute
    @property float borderWidth()
    {
        return _borderWidth;
    }
    /// Ditto
    @property float borderWidth(float b)
    {
        return _borderWidth = b;
    }

    mixin createSerialize!(true,"_borderWidth","_borderQuad.color");

private: 
    ColoredQuad _borderQuad;
    float       _borderWidth=0.01;
}