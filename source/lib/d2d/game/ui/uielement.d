/**
    Abstract base for all ui elements. 
*/

module d2d.game.ui.uielement;

import std.json;

import gl3n.linalg;

import d2d.core.base;
import d2d.core.io;
import d2d.util.jsonutil;

import d2d.game.ui.uievent;
import d2d.util.logger;



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
abstract class UIElement : Base
{
    this() 
    {
        enableEventHandling();
    }

    ~this()
    {
        _unfocus();
    }

    /// Loads a element from stored json data. Should only be called by UI
    /// The data should only represent the current element, not 
    void load(JSONValue data)
    {
        _name = data.object["name"].str;
        _pos = vectorFromJson!(vec2)(data.object["pos"]);
        _size = vectorFromJson!(vec2)(data.object["size"]);
        foreach(ref c; data.object["children"].array) {
            auto newelem = fromClassname(c.object["className"].str);
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
            data = the JSONData struct that will be written into
    */
    void store(ref JSONValue data)
    {
        data["className"] = to!string(typeid(this));
        data["name"] = _name;
        data["pos"] = vectorToJson(pos);
        data["size"] = vectorToJson(size);
        JSONValue[] iHateArrays;
        data["children"] = iHateArrays;
        foreach(ref c; children) {
            if(cast(UIElement)c) {
                JSONValue childData;
                (cast(UIElement)c).store(childData);
                data["children"].array ~= childData;
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
        return _pos=p;
    }

    /// The size of a ui element
    @property vec2 size() const
    {
        return _size;
    }
    /// Ditto
    @property vec2 size(vec2 s)
    {
        return _size = s;
    }

    /// The absolute positoin of ui element - dependent from parent position and size
    @property vec2 absolutePos()
    {
        if (this.parent && cast(UIElement)this.parent) {
            auto p = cast(UIElement)this.parent;
            return p.absolutePos + vec2(p.absoluteSize.x*_pos.x,p.absoluteSize.y*_pos.y);
        }

        return _pos;
    }
    
    /// The absolute size of a ui element - depends on the parent objects size
    @property vec2 absoluteSize()
    {
        if (this.parent && cast(UIElement)this.parent) {
            auto p = cast(UIElement)this.parent;
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

    override void preUpdate()
    {
        // we, per definition, are not clicked anymore
        _clicked = false;

        foreach(e; pollEvents()) {
            // check for hovering. hovering ignores children completly
            auto mm = cast(MouseMotionEvent)e;
            if(mm) {
                import std.stdio;
                auto mp = mm.npos;
                auto p = absolutePos;
                auto s = absoluteSize;
                if((p.x <= mp.x && p.x+s.x >= mp.x && p.y <= mp.y && p.y+s.y >= mp.y) != _hoverd) {
                    _hoverd = !_hoverd;
                    if(_hoverd) {
                        fireEvent(new UiOnHoverEvent(this));
                    }
                }
            }
            // if any of our children are hoverd we, btw, ignore any other events because they go directly to our children. hover is the exception.
            bool childIsHoverd = false;
            foreach(c; children) {
                auto e = cast(UIElement)c;
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
                    switch (mc.button) {
                        case MouseButtonEvent.MouseButtonId.MouseLeft:
                            fireEvent(new UiOnClickEvent(this));
                            _clicked = true;
                            break;
                        case MouseButtonEvent.MouseButtonId.MouseRight:
                            fireEvent(new UiOnRightClickEvent(this));
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
        return _focus;
    }

    
    
    /**  
        Acts around Object.factory to make sure generated objects are UIElements
        Return: New UIElement of type named in s, null if not successfull.
    */
    static UIElement fromClassname(string s)
    {
        auto newelem = Object.factory(s);
        if(newelem && cast(UIElement)newelem) {
            return cast(UIElement)newelem;
        }

        return null;
    }

protected:
    /// Sets the focus of a element and unfocuses the current one
    void _setFocus() 
    {
        if (_focusedElement==this) {
            return;
        }
        else if(_focusedElement) {
            _focusedElement._unfocus();
        }
        _focus = true;
        _focusedElement = this;
        fireEvent(new UiOnFocusEvent(this));
    }

    /// Unfocuses this element if it is focused
    void _unfocus()
    {
        if(_focus) {
            _focus = false;
            _focusedElement = null;
        }
    }

    /// operates on relative postions. used to check if a ui element can be focused
    /// Override to return false if you want to make an object that cant be focused
    bool _focusable(vec2 pos)
    {
        if(children.length==0) {
            return true;
        }

        foreach(ref c; children) {
            auto p = cast(UIElement)c;
            if(p) {
                if (
                   p.pos.x <= pos.x 
                   && p.pos.y <= pos.y 
                   && p.pos.x+p.size.x>=p.pos.x 
                   && p.pos.y+p.size.y>=p.pos.y
                   )
                   {
                    return false;
                }
            }
        }

        return true;
    }
private:
    /// name of a ui element
    string _name;
    /// position of a ui element
    vec2 _pos = 0.0f;
    /// size of a ui element
    vec2 _size = 1.0f;
    /// if true the element can be dragged around with the mouse
    bool _dragable = false;

    // The floowing are interaction statuses of the element
    /// If the mouse is "hovering" above this object
    bool _hoverd = false;
    /// If the object is being clicked
    bool _clicked = false;
    /// If the object is in focus. Only one ui element can be in focus at a time. see also _focus
    bool _focus = false;
    /// If the object is being dragged around
    bool _dragged = false;
    static UIElement _focusedElement;
}