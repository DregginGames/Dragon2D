/**
    Main entry point for a game. Here a game should define its "scripting".
    This includes game logic, ui handlers, ...
    
*/
module game;

//import d2d.engine;
import d2d;

int main(char[][] args)
{
    auto engine = new Engine(args, &onStartup);
    engine.run();
    return 0;
}

bool onStartup(Base base)
{
	import std.stdio;
    auto camera = new Camera(1.0f);
    
    //base.addChild(new Grid(vec4(0.2f,0.0f,1.0f,.5f)));

    auto ui = new UI("ui.menu");
    camera.addChild(ui);

    base.addChild(camera);

	return true;
}