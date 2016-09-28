/**

*/

module d2d.game.ui.label;

import gl3n.linalg;

import d2d.core.render.renderer;
public import d2d.core.render.objects.text;
import d2d.game.ui.uielement;

class Label : UiElement
{
    this(string text, string font="font.default")
	{
        _text = new Text(text,font,1.0);
        _text.ignoreView = true;
        _text.detailLevel = 100;
        _label = text;
        updateText();
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

    override void render()
    {
        super.render();
        _text.pos = this.viewPos+0.5*vec2(0,-this.viewSize.y);
        auto r = getService!Renderer("d2d.renderer");
        r.pushObject(_text);     
    }


protected:

    void updateText()
    {
        auto s = _text.settings;
        s.height = this.absoluteSize.y;
        s.maxwidth = this.absoluteSize.x;
        s.positioning = Text.Positioning.left;
        s.overflow = Text.OverflowBehaviour.showBegin;
        s.color = color.foreground;
        s.text = _label;
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
    string _label;
}