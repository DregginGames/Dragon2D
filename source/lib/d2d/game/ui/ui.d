/**
    Holds the loader / interface for a user interface
*/

module d2d.game.ui.ui;

import std.json;

import d2d.core.base;

import d2d.core.resources.jsondata;
import d2d.core.resource;
import d2d.game.ui.uielement;

/// Loads a UI from a file. 
class UI : UIElement
{
    /// Creates a new user interface.
    this(string n) 
    {
        name = n;
        Resource.preload!JSONData(name);
        load();        
    }

    /// (Re-)loads the useriterface. Also dosnt do anything if the file is invalid
    void load()
    {
        auto r = Resource.create!JSONData(name);
        if (r.data.type != JSON_TYPE.OBJECT) {
            return;
        }
        super.reload(r.data);
    }

    /// Stores the ui tree below into the resource
    void store()
    {
        JSONValue storedata = ["root" : true];
        super.store(storedata);
        auto r = Resource.create!JSONData(name);
        r.data = storedata;
        r.save();
    }

    /// Cleans up
    ~this() 
    {
        Resource.free(name);    
    }

    /// root dosnt annoy. amen.
    override void preUpdate()
    {
        _anythingHovered = false;
    }
private:
}