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
    // ctor. is private because resources never should be crated directly. 
    private this(string name)
    {   
        this.resourceName = name;
    }

    /// gets the name of this resource
    @property final string name() const
    {
        return this.resourceName;
    }

    /// returns if this object was deleted. 
    @property final bool deleted() const 
    {
        return this.deleted;
    }

    /// gets the time when this obj was deleted
    @property final long deletetime() const 
    {
        return this.timeDeleted;    
    }

    /// sets the delteTime
    @property final long deletewaittime(long newVal)
    {
        return this.deleteWaitTime = newVal;
    }

    /// gets the time how long this object will survive a deletion
    @property final long deletewaittime()
    {
        return this.deleteWaitTime;
    }

    final static T create(T) (string name) 
    {
        checkFree():
        auto p = (name in resources);
        if (p is null) {
            T newRes = new T(name);
            resources[name] = cast(Resource) newRes;
            return newRes;
        }   
        if (cast(T) (*p)) {
            // save deleted objects
            if (p.isDeleted) {
                p.isDeleted = false;
                p.timeDeleted = 0;
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
    final static void free(string name)
    {
        auto p = (name in resources);
        if (p !is null) {
            p.deleteTime = Clock.currStdTime();
            p.isDeleted = true;
        }
        checkFree(); 
    }

private:
    /// the name of the resource
    string resourceName;
    /// the time this object survives after deletion - default is 30 seconds (= 30000ms = 300000000hns)
    long    deleteWaitTime = 300000000;
    /// the time this object was delete 
    long    timeDeleted;
    /// if the object was deleted 
    bool    isDeleted = false;

    /// static vars for resource management
    static {    
        /// the array of existing resources
        Resource[string] resources;

        /// called on every resource action, makes shure resources are actually removed
        /// referenes wont be deleted so the object is still useable until noone uses it
        final static void checkFree() 
        {
            foreach(key; resources.keys) {
                if(resources[key].isDeleted 
                  && (currStdTime()-resources[key].deleteTime) > resources[key].deleteWaitTime) {
                    resources.remove(key);
                }
            }
        }
    }
}
