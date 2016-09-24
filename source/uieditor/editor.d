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
   

    base.addChild(camera);

    //base.addChild(new Grid(vec4(0.2f,0.0f,1.0f,.5f)));
	
    base.addChild(new NoSDLEventDebugger());

    return true;
}