//import d2d.engine;
import d2d.engine;
import d2d.core.base;
import d2d.core.dbg.eventdebug;
import d2d.core.services.scheduler;

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
	return true;
}

void func(int i, int j)
{
	import std.stdio; 
	writeln(i+j);
	auto s = Base.getService!Scheduler("d2d.scheduler");
	s.setTimeout(30, &func, i+j, i);
}
