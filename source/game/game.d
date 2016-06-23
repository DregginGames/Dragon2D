/**
    Main entry point for a game. Here a game should define its "scripting".
    This includes game logic, ui handlers, ...
    
*/
module game;

//import d2d.engine;
import d2d.engine;
import d2d.core.base;
import d2d.core.dbg.eventdebug;
import d2d.core.resource;
import d2d.core.resources.font;
import d2d.game.simple.camera;
import d2d.game.simple.sprite;
import d2d.game.ui.ui;
import d2d.game.entity;
import d2d.game.ui.text;
import d2d.game.dbg.grid;
import gl3n.linalg;

int main(char[][] args)
{
    auto engine = new Engine(args, &onStartup);
    engine.run();
    return 0;
}

bool onStartup(Base base)
{
	import std.stdio;
    auto camera = new Camera(4.0f);
    base.addChild(camera);
    base.addChild(new Grid(vec4(0.2f,0.0f,1.0f,.5f)));

    auto ui = new UI("ui.menu");
    base.addChild(ui);

	return true;
}