/**
  d2d.core.resource contains the bases for all resources used by d2d
  */
module d2d.core.resource;

import std.datetime;

/**
    ResourceTypeInvalidException is thrown if you try to get a existing resource with a non-matching type.
  */
class ResourceTypeInvalidException : Exception 
{
    /// ctor - should be called with the name of the resource
    this(string name) {
        super("Accessing " ~ name ~ " failed because the resource types didnt match");
    }
}

/**
    A resource is a class that has some special properties:
        - instances of resources are unique, they get be get by create!type(name)
        - resources can be preloaded 
        - they have to manually free, hover they are not immediatly deleted - 
            thats because a resource might be reused in the direct future. The default livespan for a resource marked to be deleted is 30 seconds, but that can be incresed or decresed by a property. 
        - all updates that happen to resources are only fired on demand, so every time a resource operation is done (create, free, preload). That, however, means, that a resource isnt used can live longer than 30 seconds - however it will be deleted as soon as a new operation happens
  */
class Resource 
{
    // ctor. is protected because resources never should be crated directly. 
    protected this(string name)
    {   
        this._name = name;
    }

    /// gets the name of this resource
    @property final string name() const
    {
        return this._name;
    }

    /// returns if this object was deleted. 
    @property final bool deleted() const 
    {
        return this._deleted;
    }

    /// gets the time when this obj was deleted
    @property final long deletetime() const 
    {
        return this._deletetime;    
    }

    /// sets the delteTime
    @property final long deletewait(long newVal)
    {
        return this._deletewait = newVal;
    }

    /// gets the time how long this object will survive a deletion
    @property final long deletewait()
    {
        return this.deletewait;
    }

    final static T create(T) (string name) 
    {
        checkFree();
        auto p = (name in resources);
        if (p is null) {
            T newRes = new T(name);
            resources[name] = cast(Resource) newRes;
            return newRes;
        }   
        if (cast(T) (*p)) {
            // save deleted objects
            if (p._deleted) {
                p._deleted = false;
                p._deletetime = 0;
            }
            return cast(T)(*p);
        }
        
        //something something dead
        throw new ResourceTypeInvalidException(name);
    }

    /// preloads a resource. usefull for bigger stuff that isnt needed to often 
    final static void preload(T) (string name)
    {
        checkFree();
        auto p = (name in resources);
        /// already loaded, silently ignore possible type problems 
        if (p !is null) {
            return;
        }

        T newRes = new T(name);
        resources[name] = cast(Resource) newRes;
    }   

    /// frees a resource. note that it isnt freed until curtime - delteTime is > deleteWaitTime (all in seconds) 
    /// Call in destructors - its totally safe (i hope so now)
    final static void free(string name)
    {
        auto p = (name in resources);
        if (p !is null) {
            p._deletetime = Clock.currStdTime();
            p._deleted = true;
        } 
    }

    /// reloads all exsisting resources
    final static void reloadAll()
    {
        foreach(ref r; resources) {
            r.reload();
        }
    }

    /// reloads a resource. can be overloaded by a resource if it wants to be reloadable.
    /// useful fo textures and similar things that might change on disk. 
    void reload()
    {
    }

private:
    /// the name of the resource
    string  _name;
    /// the time this object survives after deletion - default is 30 seconds (= 30000ms = 300000000hns)
    long    _deletewait = 300000000;
    /// the time this object was delete 
    long    _deletetime;
    /// if the object was deleted 
    bool    _deleted = false;
    
    /// static vars for resource management
    static {    
        /// the array of existing resources
        Resource[string] resources;

        /// called on every resource allocation, makes shure resources are actually removed
        /// referenes wont be deleted so the object is still useable until noone uses it
        /// FIXME: cant be called on resource freeings because these might happen from inside the gc wich then causes bad things to happen
        final static void checkFree() 
        {
            foreach(key; resources.keys) {
                if(resources[key]._deleted 
                  && (Clock.currStdTime()-resources[key]._deletetime) > resources[key]._deletewait) {
                    resources.remove(key);
                }
            }
        }
    }
}
