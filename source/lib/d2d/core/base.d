/**
  d2d.base holds the base interfaces needed by most of the classes.
  */
module d2d.core.base;

import d2d.core.event;

/// exception thrown when something unlogical is done with the base class or its child objects, services, ...
class ObjectLogicException : Exception
{
    /// ctor
    this(string err)
    {
        super(err);
    }
}

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

    /* preUpdate is called before update is called
        Should be used to process events, inputs etc. 
        Also put everything that might fire events that should be processed immediatly
    */
    void preUpdate()
    {
    }

    /// postUpdate is called after update is called
    /// Avoid fireing events here. Here you should do things that dont affect other objects but need the full interaction with the rest of the world in before.
    void postUpdate()
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
    final void propagateUpdate(long tickTime)
    {
        _curtime+=tickTime; // time doesnt start at 0; its absolute
        propagate(
            (b) { b._objCurtime+=tickTime; b.preUpdate(); }, // this one updates the object time before the preUpdate
            (b) => !b._paused
        );
        propagate(
            (b) { b.update(); },
            (b) => !b._paused
        );
        propagate(
            (b) { b.postUpdate(); },
            (b) => !b._paused
        );

        _curticks++; // ticks start at 0. 
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

        this.onChildAdded(child);
        child.onParentSet();

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
        if(_children.remove(child.id)) {
            this.onChildRemoved(child);
            child.onParentRemoved();
        }
    }

	/** marks an object for deletion. It immediatly removes the service (if existant) and also marks all children for deletion!
		Deletion means removal from object hirarchy and services. 
		However if the object is stored somewhere else it also has to be removed manually there (should never ever happen).
	*/
	final void setDeleted()
	{
		_deleted = true;

		if (_isService) {
			removeService();
		}
		foreach(ref c; _children) {
			c.setDeleted();
		}
	}

	/**
		PreTickDelte removes all objects that are makred for deletion from the hirachy. If an objects had children, these are deleted, too. 
	*/
	final void preTickDelete()
	{
		propagate(
			(b) {
				foreach(ref c; b.children) {
					if (c.deleted) {
						b.removeChild(c);
					}
				}
			});
	}

	/// Gets a service by its name. Syntax is getService!ServiceClass(name)
	final static T getService (T) (string name)
	{
		auto exsisting = name in _services;
		if(exsisting) {
			return cast(T)(*exsisting);
		}

		throw new ObjectLogicException("Cannot get an unknown service (" ~ name ~ ")!");
	}

    /// fixed obj id of this object
    final @property size_t id() const
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
    final @property bool acceptsEvents() const
    {
        return canReciveEvents;
    }

    /// pauses/unpauses the object
    final @property bool paused() const
    {
        return _paused;
    }

    final @property bool paused(bool paused)
    {   
        return _paused = paused;
    }

	/// returns if the object will be deleted before the next tick
	final @property bool deleted() const
	{
		return _deleted;
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

    /// return the time since object creation (clipped to ticks)
    final @property long objCurtime() const
    {
        return _objCurtime;
    }
    /// return the time since object creation, in seconds (clipped to ticks)
    final @property double objCurtimeS() const 
    {
        return (cast(float)_objCurtime)/(cast(float)10000000);
    }

    /// returns the time since engine/root creation (clipped to ticks)
    final static @property long curtime()
    {
        return _curtime;
    }
    /// returns the time since engine/root creation in seconds (clipped to ticks)
    final static @property double curtimeS()
    {
        return (cast(float)_curtime)/(cast(float)10000000);
    }

    /// returns the ticks since engine creation.
    final static @property long curticks()
    {
        return _curticks;
    }


protected:

    /// Enables event reciving for this object. Should be called in the constructor of classes that want it.
    final void enableEventHandling()
    {
        canReciveEvents = true;
    }

    /// returns the pending events and does NOT clean them
    final Event[] peekEvents()
    {
        Event[] scpy = pendingEvents.dup;

        return scpy;
    }

    /// returns the pending events and cleans
    final Event[] pollEvents()
    {
        Event[] scpy = pendingEvents.dup;
        // empty the pending events - happy GC
        pendingEvents.length = 0; 
        return scpy;
    }

	/// Propagates event actions
    final void propagate(void delegate(Base) action) { propagate(action, (b) => true); }
    final void propagate(void delegate(Base) action, bool delegate(Base) test) {
      if(!test(this)) return;

      action(this);

      foreach(ref c; _children) {
          c.propagate(action, test);
      }
    }

	/// Registers a class as a service that can be accessed by its name. Should be called by classes that want to be deleted
	final void registerAsService(string name)
	{
		if (!_isService) {
			auto exsisting = name in _services;
			if (!exsisting) {
				_services[name] = this;
				_serviceName = name;
				_isService = true;
			}
		}
		else {
			throw new ObjectLogicException("Cannot create 2 services of the same name (" ~ name ~ ")!");
		}
	}

	/// Removes a service
	final void removeService() 
	{
		if (_isService) {
			_services.remove(_serviceName);
		}
		else {
			throw new ObjectLogicException("Cannot un-service an object that never was a service!");
		}
	}

    /// Called if a child is added to this object. overload to add usefullness
    void onChildAdded(Base c)
    {
    }
    /// Called if a child is removed from this object
    void onChildRemoved(Base c)
    {
    }

    /// Called if a parent is added to this object. overload to add usefullness
    void onParentSet()
    {
    }
    /// Called if this object has lost its parent
    void onParentRemoved()
    {
    }
    

private:
    /// every engine object has an object id, this is the current maximum
    static size_t maxId = 0;

	/// the known services
	static Base[string] _services;

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

	/// if the object is a service
	bool	_isService = false;
	/// name of the service
	string  _serviceName;
	
	/// true if an object is marked for deletion
	bool	_deleted = false;

    /// the current pending events
    Event[] pendingEvents;

    /// The current time since engine startup; 
    static long _curtime = 0;
    /// the current ticks since engine startup
    static long _curticks = 0;
    /// The current time since object creation; not updated in paused objects
    long _objCurtime = 0;
}
