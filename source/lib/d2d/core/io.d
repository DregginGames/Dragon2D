/** 
  d2d.core.io holds the classes that abstract the interaction with the user 
  */
module d2d.core.io; 

import std.conv;
import derelict.sdl2.sdl;
import gl3n.linalg;

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

/// Fired every time a button is pressed
class KeyDownEvent : KeyEvent 
{
    this(string name, SDL_Keycode key, SDLEvent sdlevent) 
    {
        super(name, key, sdlevent);
    }
}   

/// Fired every time a button is released 
class KeyUpEvent : KeyEvent 
{
    this(string name, SDL_Keycode key, SDLEvent sdlevent)
    {
        super(name, key, sdlevent);
    }
}

/// Fire(not directly) every time anything happens with the mouse
abstract class MouseEvent : Event, IOEvent 
{
    /// takes name and (normalized and normal) position
    this(string name, SDLEvent sdlevent, vec2i pos, vec2 npos) 
    {
        _name = name;
        _sdlevent = sdlevent;
        _pos = pos;
        _npos = npos;
    }

    /// Gets the name of the event
    @property string name() const 
    {
        return _name;
    }

    /// Gets the original sdl event
    @property SDLEvent sdlevent() const
    {
        return sdlevent;
    }

    /// Gets the position of the mouse
    @property vec2i pos() const
    {
        return _pos;
    }

    /// Gets the normalized positoin of the mouse
    @property vec2 npos() const
    {
        return _npos;
    }
private:
    /// the original sdl eevent
    SDLEvent _sdlevent;
    /// the name
    string _name;
    /// the position of the mouse
    vec2i   _pos;    
    /// the normalized position of the mouse
    vec2    _npos;
}

/// Fired(not directly) every time a mousebutton is changed
abstract class MouseButtonEvent : MouseEvent
{
    enum MouseButtonId {
        MouseLeft = 0,
        MouseRight = 1,
        MouseWheelButton = 2,
        MouseThumb1 = 3,
        MOuseThumb2 = 4
    };

    /// ctor takes name and pos and the button that changed
    this(string name, SDLEvent sdlevent, vec2i pos, vec2 npos, int button)
    {
        super(name, sdlevent, pos, npos);
        _button = button;
    }

    /// Gets the button that has been pressed
    @property int button() const
    {
        return _button;
    }

private: 
    /// the mouse button that changed
    int _button;    
}

/// Fired every time a mouse button is pressed
class MouseButtonDownEvent : MouseButtonEvent 
{
    /// ctor takes same args as MouseButtonEvent
    this(string name, SDLEvent sdlevent, vec2i pos, vec2 npos, int button)
    {
        super(name, sdlevent, pos, npos, button);
    }
}

/// Fired every time a mouse button is released
class MouseButtonUpEvent : MouseButtonEvent 
{
    /// ctor takes same args as MouseBUttonEvent
    this(string name, SDLEvent sdlevent, vec2i pos, vec2 npos, int button)
    {
        super(name, sdlevent, pos, npos, button);
    }   
}

/// Fired every tome the scrollwheel is moved
class MouseWheelEvent : MouseEvent
{
    this(string name, SDLEvent sdlevent)
    {
        super(name, sdlevent, vec2i(0), vec2(0));
        _movement = vec2i(sdlevent.event.wheel.x, sdlevent.event.wheel.y);
        /// TODO(WORKS IN SDL 2.0.4) TO BE ADDED
        version(none) {
            if (sdlevent.event.wheel.direction == SDL_MOUSEWHEEL_FLIPPED) {
                _movement *= -1;
            }
        }
    }  

    /// returns the movement offset of the mousewheel
    @property vec2i movement() 
    {
        return _movement;
    }   
private:
    ///x and the y movement of the mousewheel
    vec2i   _movement;
}

/// Fired every time the mouse is moved
class MouseMotionEvent : MouseEvent 
{
    /// ctor takes many arguments, similar to MouseEvent but having additionally the relative mouse position 
    this(string name, SDLEvent sdlevent, vec2i pos, vec2 npos, vec2i rel, vec2 nrel)
    {
        super(name, sdlevent, pos, npos);
        _rel = rel;
        _nrel = nrel;
    }

    /// Gets the relative mouse movement
    @property vec2i rel()
    {
        return _rel;
    }

    /// Gets the normalized relative mouse movement
    @property vec2  nrel()
    {
        return _nrel;
    }
private:
    /// the relative mouse movement
    vec2i _rel;
    /// the normalized relative mouse movement
    vec2 _nrel;
}
/// IOTransformer transforms sdl input events to the engine internal Mouse and Key events 
class IOTransformer : Base 
{
    /// ctor enables event handling 
    this()
    {
        enableEventHandling(); 
    }

    /// transforms every sdl input event into an IOEvent in the preUpdate phase 
    override void preUpdate()
    {
        // Get Screen Res for normalization 
        float width = cast(float) Settings["window"].object["width"].integer;
        float height = cast(float) Settings["window"].object["height"].integer;
        auto events = pollEvents();
        foreach (e; events) {
            if (cast(SDLEvent) e) {
                import std.string; //needed for tge stringification of the string event type meh 
                auto sdlevent = cast(SDLEvent) e; 
                auto mevent = sdlevent.event.motion;
                auto mbevent = sdlevent.event.button;
                auto keyevent = sdlevent.event.key;
                
                switch (sdlevent.event.type) {
                    case SDL_KEYDOWN: 
                        auto key = keyevent.keysym.sym;
                        string keyname = fromStringz(SDL_GetKeyName(key)).idup;
                        fireEvent(new KeyDownEvent(_eventName(keyname), key, sdlevent));
                        break;
                    case SDL_KEYUP:
                        auto key = keyevent.keysym.sym;
                        string keyname = fromStringz(SDL_GetKeyName(key)).idup;
                        fireEvent(new KeyUpEvent(_eventName(keyname), key, sdlevent));
                        break;
                    case SDL_MOUSEMOTION:
                        string eventname = _eventName("mousemotion");
                        auto pos = vec2i(mevent.x, mevent.y);
                        auto nops = vec2(cast(float)(pos.x)/width, cast(float)(pos.y)/height);
                        auto rel = vec2i(mevent.xrel, mevent.yrel);
                        auto nrel = vec2(cast(float)(rel.x)/width, cast(float)(rel.y)/height);
                        fireEvent(new MouseMotionEvent(eventname, sdlevent, pos, nops, rel, nrel));
                        break;
                    case SDL_MOUSEBUTTONDOWN:
                        auto buttonId = mbevent.button;
                        auto pos = vec2i(mbevent.x, mbevent.y);
                        auto npos = vec2(cast(float)(pos.x)/width, cast(float)(pos.y)/height);
                        string eventname = _eventName("mouse" ~ toImpl!string(buttonId));
                        fireEvent(new MouseButtonDownEvent(eventname, sdlevent, pos, npos, buttonId));
                        break;
                    case SDL_MOUSEBUTTONUP:
                        auto buttonId = mbevent.button;
                        auto pos = vec2i(mbevent.x, mbevent.y);
                        auto npos = vec2(cast(float)(pos.x)/width, cast(float)(pos.y)/height);
                        string eventname = _eventName("mouse" ~ toImpl!string(buttonId));
                        fireEvent(new MouseButtonUpEvent(eventname, sdlevent, pos, npos, buttonId));
                        break;
                    case SDL_MOUSEWHEEL:
                        string eventname = _eventName("mousewheel");
                        fireEvent(new MouseWheelEvent(eventname, sdlevent));
						break;
                    default: 
                        break;
                }
            }
        }
    }
}

/// helper to get the names for input-events
private string _eventName(string keyname)
{
    try {
        auto p = keyname in Settings["keybinding"].object;
        if (null != p) {
            return p.str;
        }
    }
    catch (Exception e) //This means not even keybinding is defined. We dont care.
    {
    }

    return "";
}