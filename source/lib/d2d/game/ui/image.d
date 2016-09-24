/**
    Holds the image class for the ui
*/
module d2d.game.ui.image;

import std.json;
import gl3n.linalg;

import d2d.util.serialize;
import d2d.core.render.objects.quad;
import d2d.core.render.renderer;
import d2d.game.ui.uielement;

/**
A box is a simple colored box renderd to the screen
*/
class Image : UiElement
{
    /// Constructor
    this(string texture="")
    {
        _quad = new TexturedQuad(texture);
        _quad.ignoreView = true;
        _quad.detailLevel = 100;
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
    @property string texture()
    {
        return _quad.texname;
    }
    /// Ditto
    @property string texture(string tex)
    {
        return _quad.texname=tex;
    }

    mixin createSerialize!(true,"_quad.texname");


protected:

    /// images cannot be focused
    override bool _focusable() 
    {
        return false;
    }
    
private:
    /// The ColoredQuad used to draw this ui box
    TexturedQuad _quad;
}