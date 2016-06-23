/**
  d2d.core.debug.eventdebug holds helpers to debug the event system 
  */
module d2d.core.dbg.eventdebug;

import std.traits;
import std.conv;

import d2d.core.base;
import d2d.util.logger;
import d2d.core.event;
import d2d.core.io;

/// The Eventdebugger helps to debug events by putting them onto the logger 
class EventDebugger : Base
{
	this() 
	{
		debug {
			enableEventHandling();
		}
	}
   /** propagateEvent is overwritten to make shure every event that reaches us gets printed immediatly
     */
    override void update()
    {
		foreach(e; pollEvents()) {
			Logger.log("event: " ~ to!string(typeid(e)));
		}
	}
}

class NoSDLEventDebugger : Base
{
    this()
    {
		debug {
			enableEventHandling();
		}
	}

    override void update()
    {
		foreach(e; pollEvents()) {
            auto s = cast(SDLEvent)e;
            if(s is null) {
			    Logger.log("event: " ~ to!string(typeid(e)));
            }
		}
	}
}
