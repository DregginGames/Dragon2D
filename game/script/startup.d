module script.startup;;

import d2d.core.event;
import d2d.util.logger;
import d2d.core.base;

static this()
{
    Logger.log("i am a fish");
}

extern (C) void run(Base obj)
{
    import std.stdio;
    writeln(obj.id);
}
