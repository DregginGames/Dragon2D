/**

*/

module d2d.game.ui.text;

import d2d.core.render.renderer;
import r = d2d.core.render.objects.text;
import d2d.game.entity;

class Text : Entity
{
    this(string font, string text)
	{
		_text = new r.Text(text,font, 1.0f);
	}

	override void render()
	{
		auto renderer = getService!Renderer("d2d.renderer");
        _text.pos = this.absolutePos;
		renderer.pushObject(_text);
	}

    @property r.Text text()
    {
        return _text;
    }   

private:
	r.Text _text;
}