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