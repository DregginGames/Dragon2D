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
import d2d.game.ui.cursor;
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
    auto cursor = new WorldCursor();
    auto camera = new Camera(4.0f);
    auto camera2 = new Camera(4.0f);
    camera2.view.viewportPos = vec2(0.8,0.8);
    camera2.view.viewportSize = vec2(.2,.2);
    auto sprite = new Sprite("texture.test");
    sprite.pos = vec2(-1,-1);
    auto sprite2 = new Sprite("texture.test");
    cursor.addChild(sprite2);
    sprite2.positionMode = Entity.PositionMode.parentBound;
    camera.addChild(cursor);
    base.addChild(camera);
    base.addChild(camera2);

    auto t = new Text("font.Roboto-Medium", "Sabberschinkenschnitzel World centered text");
    auto settings = t.text.settings;
    settings.height = 0.5;
    settings.maxwidth = 2.0;
    settings.linebreak = true;
    settings.positioning = t.text.Positioning.left;
    t.text.settings = settings;
    base.addChild(t);
    base.addChild(new Grid(vec4(0.2f,0.0f,1.0f,.5f)));
	return true;
}