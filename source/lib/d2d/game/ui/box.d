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
public import d2d.core.render.objects.text;

/**
    A box is a simple colored box renderd to the screen
*/
class Box : UiElement
{
    /// Constructor
    this()
    {
        _quad = new ColoredQuad();
        _quad.ignoreView = true;
        _quad.detailLevel = 100;
        _quad.color = this.color.background;
    }

    /// Renders a box
    override void render()
    {
        _quad.scale = vec3(viewSize.x,viewSize.y, 1.0f);
        _quad.pos = viewPos+vec2(viewSize.x*0.5,-viewSize.y*0.5);
        auto r = getService!Renderer("d2d.renderer");
        r.pushObject(_quad);     
    }

    
protected:
    override void onColorChange()
    {
        _quad.color = this.color.background;
    }

private:
    /// The ColoredQuad used to draw this ui box
    ColoredQuad _quad;
}

/**
    A box that can be filled with text. 
*/
class TextBox : Box 
{
    this()
    {
        this("","font.default");
    }

    this(string text, string font="font.default")
    {
        _text = new Text(text,font,0.05);
        _text.ignoreView = true;
        _text.detailLevel = 100;
        auto s = _text.settings; 
        s.positioning = Text.Positioning.left;
        _text.settings = s;
        updateText();
        super();
    }

    override void render()
    {
        super.render();
        auto r = getService!Renderer("d2d.renderer");
        _text.pos = this.viewPos+0.7*vec2(0.02,-textHeight);
        r.pushObject(_text); 

    }

    /// Gets/sets the text positioning
    @property Text.Positioning textPosition()
    {
        return _text.settings.positioning;
    }
    /// Ditto
    @property Text.Positioning textPosition(Text.Positioning p)
    {
        auto s = _text.settings;
        s.positioning = p;
        _text.settings = s;
        return p;
    }

    /// Gets/sets the text string
    @property string text()
    {
        return _text.settings.text;
    }
    /// Ditto
    @property string text(string str)
    {
        auto s = _text.settings;
        s.text = str;
        _text.settings = s;
        return str;
    }

    /// Gets/sets the text height 
    @property double textHeight()
    {
        return _text.settings.height;
    }
    /// Ditto
    @property double textHeight(double h)
    {
        auto s = _text.settings;
        s.height = h;
        _text.settings = s;
        return h;
    }

protected:

    void updateText()
    {
        auto s = _text.settings;
        s.maxwidth = this.viewSize.x;
        s.maxheight = this.viewSize.y;
        s.overflow = Text.OverflowBehaviour.scroll;
        s.color = color.foreground;
        s.linebreak = true;
        _text.settings = s;
    }

    override void onPosSizeChange()  
    {
        updateText();
    }

    override void onColorChange()
    {
        updateText();
        super.onColorChange();
    }

private:
    Text _text;
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
        _borderQuad.detailLevel = 100;
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

    mixin createSerialize!(true,"_borderWidth");

protected:
    override void onColorChange()
    {
        _borderQuad.color = color.border;
        super.onColorChange();
    }

private: 
    ColoredQuad _borderQuad;
    float       _borderWidth=0.01;
}