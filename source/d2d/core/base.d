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
        _id = maxId;
        maxId++;
    }    

    /// Base destructor
    ~this() 
    {   
    } 

    /// Update is called every tick (1/30 of a second). 
    void update()
    {
    }

	// preRender is called before all children and the object is renderd.
	void preRender()
	{
	}

    /// Render is called every frame
    void render()
    {
    }

	/// postRender is called after all children and the object were renderd.
	void postRender()
	{
	}

    /// Propagates an update thru the object hirarchy
    final void propagateUpdate()
    {
        propagate(
            (b) { b.update(); },
            (b) => !b._paused
        );
    }

    /// Propagates the rendering through the object hirarchy
	// cant use the propagate because render has additional pre- and post functions.
    final void propagateRender()
    {
		this.preRender();

		this.render();
        foreach(ref c; _children) {
			c.propagateRender();
		}

		this.postRender();
    }

    /// add a child to this object. Resets the parent of the object to add.
    T addChild(this T)(Base child)
    {
        if (child.parent && child.parent != this) {
            child.parent.removeChild(child);
        }

        _children[child.id] = child;
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
    final void propagateEvent(Event e)
    {
        propagate(
            (b) { if(b.canReciveEvents && e.source != b) b.pendingEvents ~= e; },
            (b) => !b._paused
        );
    }

    /// removes a child from this object
    final void removeChild(Base child)
    {
        child.parent = null;
        _children.remove(child.id);
    }

    /// fixed obj id of this object
    final @property size_t id()
    {
        return _id;
    }

    /// gets the parent object of this object
    final @property Base parent()
    {
        return _parent;
    }

    /// sets the parent object of this object
    final @property Base parent(Base newParent)
    {
        return _parent = newParent;
    }

    /// gets the child objects of this object
    final @property Base[long] children()
    {
        return _children;
    }

    /// if this object accepts events
    final @property bool acceptsEvents()
    {
        return canReciveEvents;
    }

    /// pauses/unpauses the object
    final @property bool paused()
    {
        return _paused;
    }

    final @property bool paused(bool paused)
    {   
        return _paused = paused;
    }

    /// the "root" is the root of the element tree wich this object is a member
    final @property Base root()
    {
        // i am root!
        if (_parent is null) {
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

    final void propagate(void delegate(Base) action) { propagate(action, (b) => true); }
    final void propagate(void delegate(Base) action, bool delegate(Base) test) {
      if(!test(this)) return;

      action(this);

      foreach(ref c; _children) {
          c.propagate(action, test);
      }
    }

private:
    /// every engine object has an object id, this is the current maximum
    static size_t maxId = 0;

    /// the object id of the engine object
    immutable size_t _id;

    /// the child objects, key is the object id
    Base[long]  _children;

    /// the parent object
    Base    _parent;

    /// if true the object can recive events
    bool    canReciveEvents = false;

    /// if true the object is paused; no child objects or the object is updated or renderd, can recive any events or anything.
    bool    _paused = false;

    /// the current pending events
    Event[] pendingEvents;
}
