module script.startup;

import std.conv;

import d2d.core.event;
import d2d.util.logger;
import d2d.core.base;

import d2d.core.dbg.eventdebug;
import d2d.core.resources.texture;

static this()
{
    Logger.log("i am a fish");
}

extern (C) void run(Base obj)
{
    auto t = Texture.create!Texture("texture.test"); 
    auto t2 = Texture.create!Texture("texture.test");
    assert(t==t2);
    obj.addChild(new EventDebugger);
    //throw new Exception("testshit");
}
