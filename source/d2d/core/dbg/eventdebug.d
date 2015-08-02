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
   /** propagateEvent is overwritten to make shure every event that reaches us gets printed immediatly
     */
    override void propagateEvent(Event e)
    {
        debug
        {
            // FIXME: move this into the event classes? i think this is ugly... 
            string msg = "Recived Event(" ~ toImpl!string(e.id) ~ ") of type ";   
            if(cast(SDLEvent) e) {
                msg ~= fullyQualifiedName!SDLEvent;
            }
            else if(cast(IOEvent) e) {
                msg ~= fullyQualifiedName!IOEvent;
                if(cast(MouseButtonEvent) e) {
                    msg ~= "-" ~ fullyQualifiedName!MouseButtonEvent;
                }
                else if(cast(MouseWheelEvent) e) {
                    msg ~= "-" ~ fullyQualifiedName!MouseWheelEvent;
                }
                else if(cast(MouseMotionEvent) e) {
                    msg ~= "-" ~ fullyQualifiedName!MouseMotionEvent;
                }
                else if(cast(KeyEvent) e) {
                    msg ~= "-" ~ fullyQualifiedName!KeyEvent;
                }
            }
            else {
                msg ~= "[custom event type]";
            }
            Logger.log(msg);
        }
        super.propagateEvent(e);
    }
}
