/**
  d2d.base holds the base interfaces needed by most of the classes.
  */
module d2d.base;



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
    void addChild(Base child)
    {
        if (child.parent == this) {
            return;
        }
        
        if (child.parent) {
            child.parent.removeChild(child);
        }

        childObjects[child.id] = child;
        child.parent = this;
    }

    /// removes a child from this object
    void removeChild(Base child)
    {
        child.parent = null;
        childObjects.remove(child.id);
    }

    /// fixed obj id of this object
    @property long id()
    {
        return maxObjId;
    }

    /// gets the parent object of this object
    @property Base parent()
    {
        return parentObject;
    }

    /// sets the parent object of this object
    @property void parent(Base newParent)
    {
        parentObject = newParent;
    }

    /// gets the child objects of this object
    @property Base[long] children()
    {
        return childObjects;
    }
private:
    /// every engine object has an object id, this is the current maximum
    static long maxObjId = 0;

    /// the object id of the engine object
    immutable long objId;

    /// the child objects, key is the object id
    Base[long]  childObjects;

    /// the parent object
    Base    parentObject;
}
