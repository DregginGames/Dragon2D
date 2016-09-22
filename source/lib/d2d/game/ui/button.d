/**
    Holds the button image class
*/
module d2d.game.ui.button;

import std.json;

import d2d.util.jsonutil;
import gl3n.linalg;

import d2d.core.render.objects.text;
import d2d.core.render.renderer;
import d2d.game.ui.box;
import d2d.game.ui.label;

/// A button
class Button : Box
{
    this(string text, string font = "font.default")
    {
        _text = new Text(text,font,1.0);
        _text.ignoreView = true;
        _label = text;
        _updateText();
    }

    /// Gets/Sets the label of this button
    @property string label() const
    {
        return _label;
    }
    /// Ditto
    @property string label(string l) 
    {
        return _label = l;
    }

    /// Gets/Sets the text color
    @property vec4 textColor() const
    {
        return _text.settings.color;
    }
    /// Ditto
    @property vec4 textColor(vec4 c) 
    {
        auto s = _text.settings;
        s.color = c;
        _text.settings = s;
        return c;
    }


    override void render()
    {
        super.render();
        _text.pos = this.viewPos+0.5*vec2(this.viewSize.x,-this.viewSize.y);
        auto r = getService!Renderer("d2d.renderer");
        r.pushObject(_text);     
    }

protected:
    void _updateText()
    {
        auto s = _text.settings;
        s.height = this.absoluteSize.y;
        s.maxwidth = this.absoluteSize.x;
        s.positioning = Text.Positioning.centered;
        s.overflow = Text.OverflowBehaviour.showBegin;
        
        s.text = _label;
        _text.settings = s;
    }

    override void _onPosSizeChange()  
    {
        _updateText();
    }
private:
    Text _text;
    string _label;
}