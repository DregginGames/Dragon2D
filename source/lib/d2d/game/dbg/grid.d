/**
    Holds the debug class for grid rendering
*/
module d2d.game.dbg.grid;

import gl3n.linalg;

import d2d.core.render.renderer;
import d2d.core.render.objects.quad;
import d2d.game.entity;


class Grid : Entity
{
    this(vec4 color)
	{
		_quad = new ColoredQuad(color, "shader.grid");
	}

	override void render()
	{
		auto renderer = getService!Renderer("d2d.renderer");
        _quad.pos = this.absolutePos;
		renderer.pushObject(_quad);
	}


private:
	ColoredQuad _quad;
}