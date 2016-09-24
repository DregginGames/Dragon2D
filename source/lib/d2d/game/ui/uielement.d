/**
    Abstract base for all ui elements. 
*/

module d2d.game.ui.uielement;

import std.json;
import std.variant;

import gl3n.linalg;

import d2d.core.base;
import d2d.core.io;
import d2d.system.env;
import d2d.util.jsonutil;

import d2d.game.ui.uievent;
import d2d.game.ui.uicolor;
import d2d.util.logger;
import d2d.util.serialize;


/**
    A UI Element is a non-entity visual class that is part of the user interface. 
    Ui elemnts always life inside the -1..1 position space. 
    The hirarchy that makes a ui element is ALWAYS on - positions and sizes are always relative to the parent ui element
    That means that if the "colored box 7" is at position [0.5,0.5] and is [0.5,0.5] in size and on that you put another box [0.0,0.0,0.5,0.5] on there, 
        its absolute coordinates are [0.5,0.5] and size [0.25,0.25]!
    This is very similar, but not eqal to, the Entities ParentRelative mode. The major difference is the -1..1 position space and the size.
    To remember:
        Child lays on top of parent
        Absolute position ans size is relative to parents position and size
*/
abstract class UiElement : Base, Serializeable
{
    this() 
    {
        enableEventHandling();
        _color = defaultUiColorScheme(UiColorSchemeSelect.BASE);
    }

    ~this()
    {
        _unfocus();
    }

    void reload(JSONValue data) {
        foreach(ref c; children) {
            c.setDeleted();
        }
        load(data);
    }

    /// Loads a element from stored json data. Should only be called by UI
    /// The data should only represent the current element, not 
    void load(JSONValue data)
    {
        try {
            this.deserialize(data);
        } catch (Exception e) {
            Logger.log("WARNING: Could not load a UI element - " ~ e.msg);
        }

        // afterwards we can assume that everything changeed, so do this 
        onPosSizeChange();
        onColorChange();

        // now for the children
        auto p = "children" in data.object;
        if (!p) {
            return;
        }
        foreach(ref c; p.array) {
            auto newelem = fromClassname(c.object["typename"].str);
            if(newelem !is null) {
                this.addChild(newelem);
                newelem.load(c);
            }
        }

    }

    /** 
        Stores a ui element tree into json data structure
        Overload for custom ui elements to store additional data. Make sure to call super.store(store) afterwards!
        Dont call by hand, insted let UI do that for you. 
        Params:
            data = the JsonData struct that will be written into
    */
    void store(ref JSONValue dst)
    {
        dst = this.serialize();
        JSONValue[] iHateArrays;
        dst["children"] = iHateArrays;
        foreach(ref c; children) {
            if(cast(UiElement)c) {
                JSONValue childData = (cast(UiElement)c).serialize();
                dst["children"].array ~= childData;
            }
        }
    }

    /// The name of a ui object
    @property string name() const
    {
        return _name;
    }
    /// Ditto
    @property string name(string n)
    {
        return _name=n;
    }

    /// The position of a ui element
    @property vec2 pos() const
    {
        return _pos;
    }
    /// Ditto
    @property vec2 pos(vec2 p)
    {
        _pos = p;
        onPosSizeChange();
        return _pos;
    }

    /// The size of a ui element
    @property vec2 size() const
    {
        return _size;
    }
    /// Ditto
    @property vec2 size(vec2 s)
    {
        _size = s;
        onPosSizeChange();
        return _size;
    }

    /// The absolute positoin of ui element - dependent from parent position and size
    @property vec2 absolutePos()
    {
        if (this.parent && cast(UiElement)this.parent) {
            auto p = cast(UiElement)this.parent;
            return p.absolutePos + vec2(p.absoluteSize.x*_pos.x,p.absoluteSize.y*_pos.y);
        }

        return _pos;
    }
    
    /// The absolute size of a ui element - depends on the parent objects size
    @property vec2 absoluteSize()
    {
        if (this.parent && cast(UiElement)this.parent) {
            auto p = cast(UiElement)this.parent;
            return vec2(p.absoluteSize.x*_size.x,p.absoluteSize.y*_size.y);
        }
        
        return _size;
    }

    @property vec2 viewPos()
    {
        auto p = absolutePos*2.0-vec2(1,1);
        p.y *= -1;
        return p;
    }

    @property vec2 viewSize()
    {
        return absoluteSize*2.0;
    }


    /// The color of this ui element. Setting might redraw things
    @property UiColor color()
    {
        return _color;
    }
    /// Ditto
    @property UiColor color(UiColor c)
    {
        _color = c;
        onColorChange();
        return _color;
    }

    override void preUpdate()
    {
        // we, per definition, are not clicked anymore
        _clicked = false;
        double aspect = this.getService!Env("d2d.env").aspectRatio();
        foreach(e; pollEvents()) {
            // check for hovering. hovering ignores children completly
            auto mm = cast(MouseMotionEvent)e;
            if(mm) {
                import std.stdio;
                auto mp = mm.npos;
                mp.x = mp.x*aspect - (aspect-1.0)/2.0; // because screen space rendering. Noone lieks this but do i have a choce? no.          
                auto p = absolutePos;
                auto s = absoluteSize;
                if((p.x <= mp.x && p.x+s.x >= mp.x && p.y <= mp.y && p.y+s.y >= mp.y) != _hoverd) {
                    _hoverd = !_hoverd;
                    if(_hoverd) {
                        fireEvent(new UiOnHoverEvent(this));
                    }
                }
            }

            // make sure to unfocus 
            if (!_hoverd) {
                auto mc = cast(MouseButtonDownEvent)e;
                if(mc) {
                    if (focus) {
                        _unfocus();
                    }
                }
            }

            // if any of our children are hoverd we, btw, ignore any other events because they go directly to our children. hover is the exception.
            bool childIsHoverd = false;
            foreach(c; children) {
                auto e = cast(UiElement)c;
                if(e && e.hovered) {
                    childIsHoverd = true;
                    break;
                }
            }
            if(childIsHoverd) {
                continue;
            }
            // if hoverd check for the clicking
            else if (_hoverd) {
                auto mc = cast(MouseButtonDownEvent)e;
                if(mc) {
                    auto absolute = mc.npos;
                    absolute.x = absolute.x*aspect - (aspect-1.0)/2.0;
                    vec2 relative;
                    relative.x = (absolute.x-this.absolutePos.x)/this.absoluteSize.x;
                    relative.y = (absolute.y-this.absolutePos.y)/this.absoluteSize.y;
                    switch (mc.button) {
                        case MouseButtonEvent.MouseButtonId.MouseLeft:
                            fireEvent(new UiOnLeftClickEvent(this,absolute,relative));
                            _clicked = true;
                            break;
                        case MouseButtonEvent.MouseButtonId.MouseRight:
                            fireEvent(new UiOnRightClickEvent(this,absolute,relative));
                            _clicked = true;
                            break;
                        default:
                            _clicked = false;
                            break;
                    }
                }
            }
            // and check for focus.
            if (_clicked) {
                _setFocus();
            }
        }
        
        _anythingHovered |= _hoverd;
    }

    UiElement[] getByName(string name)
    {
        UiElement[] res;
        if(_name==name) {
            res ~= this;
        }
        foreach(ref c; children) {
            if (cast(UiElement)c) {
                res ~= (cast(UiElement)c).getByName(name);
            }
        }

        return res;
    }

    @property bool hovered() const
    {
        return _hoverd;
    }

    @property bool clicked() const
    {
        return _clicked;
    }

    @property bool focus() const
    {
        return _focusedElement==this;
    }

    @property ref Variant[string] userData()
    {
        return _userData;
    }
    
    /**  
        Acts around Object.factory to make sure generated objects are UiElements
        Return: New UiElement of type named in s, null if not successfull.
    */
    static UiElement fromClassname(string s)
    {
        auto newelem = Object.factory(s);
        if(newelem && cast(UiElement)newelem) {
            return cast(UiElement)newelem;
        }

        return null;
    }

    /// returns if any ui element is focused
    static bool isAnythingFocused()
    {
        return _focusedElement !is null;
    }

    /// returns if any ui element is hovered
    static bool isAnythingHovered()
    {
        return _anythingHovered;
    }

    mixin createSerialize!(false,"_name","_pos","_size","_color");

protected:
    /// Sets the focus of a element and unfocuses the current one
    void _setFocus() 
    {
        if (!_focusable()) {
            return;
        }
        if (_focusedElement==this) {
            return;
        }
        else if(_focusedElement) {
            _focusedElement._unfocus();
        }
        _focusedElement = this;
        _onFocus();
        fireEvent(new UiOnFocusEvent(this));
    }

    /// Unfocuses this element if it is focused
    void _unfocus()
    {
        if(_focusedElement==this) {
            _focusedElement = null;
        }
    }

    /// forces unfocus over everything
    void _forceUnfocus()
    {
        if(_focusedElement !is null) {
            _focusedElement._unfocus();
        }
    }

    /// operates on relative postions. used to check if a ui element can be focused
    /// Override to return false if you want to make an object that cant be focused
    bool _focusable()
    {
        foreach(ref c; children) {
            auto p = cast(UiElement)c;
            if(p) {
                if (p._focusable()) {
                    return false;
                }
            }
        }

        return hovered();
    }

    /// called if position or size is changed. overload for maximum usefullness.
    void onPosSizeChange()
    {

    }

    /// called if this element os focues. overload for maxiumum usefullness
    void _onFocus()
    {
    }

    /// called if the color of this element was changed. overload for maximum usefullness
    void onColorChange()
    {
    }

private:
    /// name of a ui element
    string _name;
    /// position of a ui element
    vec2 _pos = 0.0f;
    /// size of a ui element
    vec2 _size = 1.0f;
    /// color of a ui element
    UiColor _color;
    /// if true the element can be dragged around with the mouse
    bool _dragable = false;
    /// user data. variants are cool
    Variant[string] _userData;

    // The floowing are interaction statuses of the element
    /// If the mouse is "hovering" above this object
    bool _hoverd = false;
    /// If the object is being clicked
    bool _clicked = false;
    /// If the object is in focus. Only one ui element can be in focus at a time. see also _focus
    bool _focus = false;
    /// If the object is being dragged around
    bool _dragged = false;
    /// static thing that represents the focused element
    static UiElement _focusedElement;

protected:
    /// stores if anything in the current update cyclus is detected as hovered
    static bool     _anythingHovered;
}