/**
  d2d.base holds the base interfaces needed by most of the classes.
  */
module d2d.core.base;

import d2d.core.event;

/**
  Base is the base interaface for all engine classes. 
  It has the methods that are basically needed by every part of the system. 
  */
class Base 
{
    /// Base ctor
    this() 
    {
        // first set the object id 
        objId = maxObjId;
        maxObjId++;
    }    

    /// Base destructor
    ~this() 
    {   
    } 

    /// Update is called every tick (1/30 of a second). 
    void update()
    {
    }

    /// Render is called every frame
    void render()
    {
    }

    /// Propagates an update thru the object hirarchy
    void propagateUpdate()
    {
        // paused object dont update
        if (isPaused) {
            return;
        }
        update();

        foreach(ref c; childObjects) {
            c.propagateUpdate();        
        }   
    }

    /// Propagates the rendering through the object hirarchy
    void propagateRender()
    {
        render();

        foreach(ref c; childObjects) {
            c.propagateRender();
        }
    }

    /// add a child to this object. Resets the parent of the object to add.
    T addChild(this T)(Base child)
    {
        if (child.parent && child.parent != this) {
            child.parent.removeChild(child);
        }

        childObjects[child.id] = child;
        child.parent = this;

        return cast(T) this;
    }

    /// Fires an event, moves it up in the object hirarchy and propagetes it through
    void fireEvent(Event e)
    {
        e.source = this;
        this.root.propagateEvent(e);
    }

    /// propagate an event throgh the object hirarchy
    void propagateEvent(Event e)
    {
        //if paused we dont do anything
        if (isPaused) {
            return;
        }
        
        //do we recive events and are we the source? 
        if (canReciveEvents && e.source != this) {
            pendingEvents ~= e;
        }

        //propagate the event
        foreach(ref c; childObjects) {
            c.propagateEvent(e);
        }   
    }

    /// removes a child from this object
    final void removeChild(Base child)
    {
        child.parent = null;
        childObjects.remove(child.id);
    }

    /// fixed obj id of this object
    final @property size_t id()
    {
        return objId;
    }

    /// gets the parent object of this object
    final @property Base parent()
    {
        return parentObject;
    }

    /// sets the parent object of this object
    final @property Base parent(Base newParent)
    {
        return parentObject = newParent;
    }

    /// gets the child objects of this object
    final @property Base[long] children()
    {
        return childObjects;
    }

    /// if this object accepts events
    final @property bool acceptsEvents()
    {
        return canReciveEvents;
    }

    /// pauses/unpauses the object
    final @property bool paused()
    {
        return isPaused;
    }

    final @property bool paused(bool paused)
    {   
        return isPaused = paused;
    }

    /// the "root" is the root of the element tree wich this object is a member
    final @property Base root()
    {
        // i am root!
        if (parentObject is null) {
            return this;
        }
        //go up
        return this.parent.root;
    }
protected

    /// Enables event reciving for this object. Should be called in the constructor of classes that want it.
    final void enableEventHandling()
    {
        canReciveEvents = true;
    }

    /// returns the pending events and cleans
    final Event[] pollEvents()
    {
        Event[] scpy = pendingEvents.dup;
        // empty the pending events - happy GC
        pendingEvents.length = 0; 
        return scpy;
    }
    
private:
    /// every engine object has an object id, this is the current maximum
    static size_t maxObjId = 0;

    /// the object id of the engine object
    immutable size_t objId;

    /// the child objects, key is the object id
    Base[long]  childObjects;

    /// the parent object
    Base    parentObject;

    /// if true the object can recive events
    bool    canReciveEvents = false;

    /// if true the object is paused; no child objects or the object is updated or renderd, can recive any events or anything.
    bool    isPaused = false;

    /// the current pending events
    Event[] pendingEvents;
}
