/**

*/

module d2d.game.ui.label;

import d2d.core.render.renderer;
public import d2d.core.render.objects.text;
import d2d.game.ui.uielement;

class Label : UIElement
{
    this(string font, string text)
	{
		_text = new Text(text,font, 1.0f);
        _text.ignoreView = true;
	}

	override void render()
	{
		auto renderer = getService!Renderer("d2d.renderer");
        _text.pos = this.viewPos;
		renderer.pushObject(_text);
	}

    @property Text text()
    {
        return _text;
    }   

private:
	Text _text;
}