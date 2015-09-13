//import d2d.engine;
import d2d.engine;
import d2d.core.base;
import d2d.core.dbg.eventdebug;
import d2d.core.services.scheduler;
import d2d.core.resource;
import d2d.core.resources.glprogram;

int main(char[][] args)
{
    auto engine = new Engine(args, &onStartup);
    engine.run();
    return 0;
}

bool onStartup(Base base)
{
	//base.addChild(new EventDebugger());
	auto s = base.getService!Scheduler("d2d.scheduler");
	s.setTimeout(20, &func, 1, 3);
    auto r = Resource.create!GLProgram("shader.default");
	return true;
}

void func(int i, int j)
{
	import std.stdio; 
	writeln(i+j);
	auto s = Base.getService!Scheduler("d2d.scheduler");
	s.setTimeout(30, &func, i+j, i);
}
