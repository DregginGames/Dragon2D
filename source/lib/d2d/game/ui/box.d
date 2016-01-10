/**
    Holds the box ui class
*/
module d2d.game.ui.box;

import std.json;
import gl3n.linalg;

import d2d.util.jsonutil;
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
        _quad.scale = vec3(size.x,size.y, 1.0f);
        _quad.pos = absolutePos - absoluteSize/2.0;
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

    /// Loads color data of box
    override void load(JSONValue data) 
    {
        _quad.color = vectorFromJson!(vec4)(data["color"]);
        super.load(data);
    }

    /// Stores color data of box
    override void store(ref JSONValue data) 
    {
        data["color"] = vectorToJson(_quad.color);
        super.store(data);
    }
    
private:
    /// The ColoredQuad used to draw this ui box
    ColoredQuad _quad;
}