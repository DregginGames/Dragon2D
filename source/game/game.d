//import d2d.engine;
import d2d.engine;
import d2d.core.base;
import d2d.core.dbg.eventdebug;
import d2d.core.resource;
import d2d.core.resources.glprogram;
import d2d.game.simple.camera;
import d2d.game.simple.sprite;

int main(char[][] args)
{
    auto engine = new Engine(args, &onStartup);
    engine.run();
    return 0;
}

bool onStartup(Base base)
{
	import std.stdio;
	base.addChild(new Camera(2.0f));
	base.addChild(new Sprite("texture.test"));
    auto r = Resource.create!GLProgram("shader.default");
	return true;
}