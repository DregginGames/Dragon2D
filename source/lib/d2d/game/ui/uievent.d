/**
    Holds all ui events or events related to ui
*/
module d2d.game.ui.uievent;

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
    this(UIElement element) { super(element); }
}

/** 
Event that is fired if an ui element is right-clicked on
*/
class UiOnRightClickEvent : UiEvent 
{
    this(UIElement element) { super(element); }
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