/**
    Abstract base for all ui elements. 
*/

module d2d.game.ui.uielement;

import gl3n.linalg;
import d2d.core.base;
import d2d.game.ui.uievent;

/**
    A UI Element is a non-entity visual class that is part of the user interface. 
    Ui elemnts always life inside the -1..1 position space. 
    The hirarchy that makes a ui element is ALWAYS on - positions and sizes are always relative to the parent ui element
    That means that if the "colored box 7" is at position [0.5,0.5] and is [0.5,0.5] in size and on that you put another box [0.0,0.0,0.5,0.5] on there, 
        its absolute coordinates are [0.5,0.5] and size [0.25,0.25]!
    This is very similar, but not eqal to, the Entities ParentRelative mode. The major difference is the -1..1 position space and the size.
*/
abstract class UIElement : Base
{
    this() 
    {
        enableEventHandling();
    }

    /// The name of a ui object
    @property string name()
    {
        return _name;
    }
    @property string name(string n)
    {
        return _name=name;
    }

    ///The position of a ui element
    
protected:

private:
    /// name of a ui element
    string _name;
    /// position of a ui element
    vec2 _pos;
    /// size of a ui element
    vec2 _size;
}