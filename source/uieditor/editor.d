//import d2d.engine;

import d2d.engine;
import d2d.system.env;
import d2d.core.base;
import d2d.core.dbg.eventdebug;
import d2d.game.simple.camera;
import d2d.game.simple.sprite;
import d2d.game.ui.cursor;
import d2d.game.ui.ui;
import d2d.game.ui.box;
import d2d.game.dbg.grid;
import d2d.game.audio.music;
import d2d.game.ui.text;
import d2d.game.ui.edit;
import gl3n.linalg;
alias d2d.game.ui.text.Text Text;

int main(char[][] args)
{
    auto engine = new Engine(args, &onStartup);
    engine.run();
    return 0;
}

bool onStartup(Base base)
{
	import std.stdio;
    // camera
    auto camera = new Camera(1.0f);
    
    //camera.addChild(new Sprite("texture.test"));
    
    // ui
    auto ui = new UI("ui.menu");
    camera.addChild(ui);
    Edit e = new Edit("font.Roboto-Medium","testtext");
    e.pos = vec2(0.0,0.0);
    e.size = vec2(0.2,0.05);
    e.color(vec4(0.2,0.5,0.5,1.0));
    ui.addChild(e);

    // Text
    auto t = new Text("font.Roboto-Medium", "Sabberschi\nnkensch\nnitzel World centered text");
    t.text.ignoreView = true;
    auto settings = t.text.settings;
    settings.height = 0.09;
    settings.maxwidth = 1.0;
    settings.overflow = t.text.OverflowBehaviour.scroll;
    settings.positioning = t.text.Positioning.left;
    settings.scroll = 0.0;
    settings.maxheight = 0.1;
    settings.linebreak = true;
    t.text.settings = settings;
    base.addChild(t);

    base.addChild(camera);

    //base.addChild(new Grid(vec4(0.2f,0.0f,1.0f,.5f)));
	
    base.addChild(new NoSDLEventDebugger());

    return true;
}