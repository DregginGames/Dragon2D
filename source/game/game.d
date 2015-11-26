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
    camera2.view.viewportPos = vec2(0.9,0.9);
    camera2.view.viewportSize = vec2(.1,.1);
    auto sprite = new Sprite("texture.test");
    sprite.pos = vec2(-1,-1);
    auto sprite2 = new Sprite("texture.test");
    cursor.addChild(sprite2);
    sprite2.positionMode = Entity.PositionMode.parentBound;
    camera.addChild(cursor);
    base.addChild(sprite);
    base.addChild(camera);
    base.addChild(camera2);

    auto t = new Text("font.Roboto-Medium", "Sabberschinkenschnitzel World centered text");
    t.text.height = 0.5;
    t.text.maxwidth = 2.0;
    t.text.linebreak = true;
    base.addChild(t);
	return true;
}