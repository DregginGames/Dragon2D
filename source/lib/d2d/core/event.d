/** 
  d2d.core.event holds the basic event class and the container for native sdl events
  */
module d2d.core.event;

import derelict.sdl2.sdl;

import d2d.core.base;
import d2d.util.logger;

/// Events are well.. Events that are fired by casses derived form Base. They have a owner (the firing base). Derive events from this class.
class Event
{
    ///basic constructor 
    this()
    {
        eventId = maxId;
        maxId++;
    }

    /// the unique id for every event ever created
    @property size_t id() const
    {
        return eventId;
    }

    /// the one who fired the event
    @property Base source()
    {
        return eventSource;
    }
    
    /// sets the one who fired the event
    @property void source(Base s)
    {
        eventSource = source;
    }

    /// (helper) function to automate check, cast and filter
    void on(T, string filter="")(void delegate(T event) callback) 
    {
        try{
            T e = cast(T)this;
            if(e) {
                static if(filter == "") {
                    callback(e);
                }
                else {
                    mixin("if(" ~ filter ~ "){callback(e);}");
                }
            }
        }
        catch(Exception e) {
            Logger.log("CRITICAL: exception caught in event filter");
            Logger.log(e.msg);
        }
    }

private:
    static size_t       maxId = 0;
    immutable size_t    eventId;
    Base                eventSource;
}  

/// Maps sdl events to D2D events 
class SDLEvent : Event
{
    this(SDL_Event e) {
        _event = e;
    }

    /// gives the sdl event
    @property SDL_Event event() const
    {
        return _event;
    }
private:
    SDL_Event _event;
}

/// event fired in case the engine shall be killed
class KillEngineEvent : Event 
{
}
