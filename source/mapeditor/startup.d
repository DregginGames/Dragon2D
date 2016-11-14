//import d2d.engine;

import d2d.engine;
import d2d.core.base;

import mapeditor;

int main(char[][] args)
{
    auto engine = new Engine(args, &onStartup);
    engine.run();
    return 0;
}

bool onStartup(Base base)
{
    base.addChild(new Mapeditor());
    base.addChild(new NoSDLEventDebugger());
    return true;
}