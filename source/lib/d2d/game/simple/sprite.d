/**
	d2d.game.simple.sprite holds the sprite class: a simple class to display images on screen
*/
module d2d.game.simple.sprite;

import d2d.core.render.renderer;
import d2d.core.render.objects.quad;
import d2d.game.entity;

class Sprite : Entity
{
    this(string texture)
	{
		_quad = new TexturedQuad(texture);
	}

	override void render()
	{
		auto renderer = getService!Renderer("d2d.renderer");
        _quad.pos = this.absolutePos;
		renderer.pushObject(_quad);
	}

private:
	TexturedQuad _quad;
}
