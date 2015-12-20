//import d2d.engine;

import d2d.engine;
import d2d.system.env;
import d2d.core.base;
import d2d.core.dbg.eventdebug;
import d2d.core.resource;
import d2d.core.resources.font;
import d2d.game.simple.camera;
import d2d.game.simple.sprite;
import d2d.game.ui.cursor;
import d2d.game.entity;
import d2d.game.ui.ui;
import d2d.game.dbg.grid;
import d2d.game.audio.sound;
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
    auto sprite = new Sprite("texture.test");
    sprite.pos = vec2(-1,-1);
    auto sprite2 = new Sprite("texture.test");
    cursor.addChild(sprite);
    sprite.positionMode = Entity.PositionMode.parentBound;
    camera.addChild(cursor);
    
    //isnt our ugly drawn sprite a mouse cursor in theory :P
    Base.getService!Env("d2d.env").cursor=false;

    auto s = new Sound("sound.alan");
    s.play();
    

    auto ui = new UI("ui.menu");
    ui.store();
    camera.addChild(ui);

    base.addChild(camera);
    base.addChild(s);
    base.addChild(new Grid(vec4(0.2f,0.0f,1.0f,.5f)));
	return true;
}