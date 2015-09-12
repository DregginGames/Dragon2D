/**
	d2d.core.services.scheduler manages the scheudling of function calles and other timed mechanisms
*/
module d2d.core.services.scheduler;

import d2d.core.base;
import d2d.core.event;
import std.algorithm;
import std.functional;

/// The Scheudler manages the timing based calling of functions, firing of events etc. 
class Scheduler : Base
{
public:
	/// registers the scheduler
	this()
	{
		registerAsService("d2d.scheduler");
	}

	// Updates each callable event
	override void update()
	{
		foreach(int index, ref o; scheduledObjects) {
			if(o.tick()) {
				scheduledObjects.remove(index);
			}
		}	
	}

	/// Calls a function after a number of engine ticks. 
	/// example: setTimeout(30, delegate (int i) { writeln(i); }, 42);
	void setTimeout (T, Args...) (uint ticks, T func, auto ref Args args)
	{
		if (0 >= ticks) {
			func(args);
		}
		else {
			scheduledObjects[maxObj] = new funcSObject!(T, Args).obj(ticks, func, args);
			maxObj++;
		}
	}

private:
	static int maxObj = 0;

	sObject[int] scheduledObjects;
}

/// The helper structs
private {
	interface sObject
	{
		/// tick is called every time the scheduler is updated. if tick returns true, the scheduler will remove the sObject from the list of existing scheduler objects
		bool tick();
	}

	template funcSObject(T, Args...)
	{
		class obj : sObject
		{
			this(uint ticks, T func, ref Args args) 
			{
				_func = func;
				_args = args;
				_ticks = ticks;
			}

			bool tick()
			{
				_ticks--;
				if (0 >= _ticks) {
					_func(_args);
					//_func(forward!_args);
					return true;
				}
				return false;
			}

		private:
			T _func;
			Args _args;
			uint _ticks;
		}
	}
}