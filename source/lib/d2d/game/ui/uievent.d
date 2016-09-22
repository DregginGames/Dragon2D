/**
    Holds all ui events or events related to ui
*/
module d2d.game.ui.uievent;

import gl3n.linalg;

import d2d.core.event;
import d2d.game.ui.uielement;

/**
    Base for all ui events
*/
abstract class UiEvent : Event
{
    /// Creates a new UI event. Always attached to a ui element
    this(UIElement element) 
    {
        _element = element;
    }

    final @property UIElement element()
    {
        return _element;
    }
private:
    /// The UI element wich emmits this event
    UIElement _element;
}

/** 
    Event that is fired if an ui element is clicked on
*/
class UiOnClickEvent : UiEvent 
{
    this(UIElement element,vec2 absolute, vec2 relative) 
    { 
        super(element); 
        _absoluteClick = absolute;
        _relativeClick = relative;
    }
    
    @property vec2 absoluteClick()
    {
        return _absoluteClick;
    }
    @property vec2 relativeClick()
    {
        return _relativeClick;
    }
private:

    vec2 _absoluteClick;
    vec2 _relativeClick;
}

/** 
Event that is fired if an ui element is right-clicked on
*/
class UiOnLeftClickEvent : UiOnClickEvent 
{
    this(UIElement element,vec2 absolute, vec2 relative) { super(element,absolute,relative); }
}

/** 
Event that is fired if an ui element is right-clicked on
*/
class UiOnRightClickEvent : UiOnClickEvent 
{
    this(UIElement element,vec2 absolute, vec2 relative) { super(element,absolute,relative); }
}

/** 
Event that is fired if an ui element is focused on
*/
class UiOnFocusEvent : UiEvent 
{
    this(UIElement element) { super(element); }
}

/** 
Event that is fired if an ui element is hoverd on
*/
class UiOnHoverEvent : UiEvent 
{
    this(UIElement element) { super(element); }
}