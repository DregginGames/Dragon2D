/** 
  d2d.core.io holds the classes that abstract the interaction with the user 
  */
module d2d.core.io; 

import derelict.sdl2.sdl;
import d2d.core.event;
import d2d.core.base;
import d2d.util.settings; 

/// Every event that represents an input/output interaction is an IOEvent 
interface IOEvent 
{
    /// Ever IOEvent needs a name that is associated with it. can be, however, emptystring 
    @property string name() const;
    /// the orginal SDLevent that was fired 
    @property SDLEvent sdlevent();
}

abstract class KeyEvent : Event, IOEvent 
{
    /// ctor must have both the pressed/released key and the name 
    this(string name, SDL_Keycode key, SDLEvent sdlevent) 
    {
        _name = name;
        _key = key; 
        _sdlevent = sdlevent;
    }

    @property string name() const 
    {
        return _name;
    }

    @property SDLEvent sdlevent()  
    {
        return _sdlevent;
    }
private:
    /// the name of this event 
    string _name; 
    /// the key that was pressed 
    SDL_Keycode _key; 
    /// the original sdl event 
    SDLEvent _sdlevent; 
}

class KeyDownEvent : KeyEvent 
{
    this(string name, SDL_Keycode key, SDLEvent sdlevent) 
    {
        super(name, key, sdlevent);
    }
}   

class KeyUpEvent : KeyEvent 
{
    this(string name, SDL_Keycode key, SDLEvent sdlevent)
    {
        super(name, key, sdlevent);
    }
}

/// IOTransformer transforms sdl input events to the engine internal Mouse and Key events 
class IOTransformer : Base 
{
    /// ctor enables event handling 
    this()
    {
        enableEventHandling(); 
    }

    /// transforms every sdl input event into an IOEvent 
    override void update()
    {
        auto events = pollEvents();
        foreach (ref e; events) {
            if (cast(SDLEvent) e) {
                import std.string; //needed for tge stringification of the string event type meh 
                auto sdlevent = cast(SDLEvent) e; 
                switch (sdlevent.event.type) {
                    case SDL_KEYDOWN: 
                        auto key = sdlevent.event.key.keysym.sym;
                        string keyname = fromStringz(SDL_GetKeyName(key)).idup;
                        fireEvent(new KeyDownEvent(Settings.get(keyname, true), key, sdlevent));
                        break;
                    case SDL_KEYUP:
                        auto key = sdlevent.event.key.keysym.sym;
                        string keyname = fromStringz(SDL_GetKeyName(key)).idup;
                        fireEvent(new KeyUpEvent(Settings.get(keyname, true), key, sdlevent));
                        break;
                    default:
                        break;
                }
            }
        }
    }
}
