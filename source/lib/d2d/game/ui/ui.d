/**
    Holds the loader / interface for a user interface
*/

module d2d.game.ui.ui;

import std.json;

import d2d.core.base;
import d2d.core.io;

import d2d.core.resources.jsondata;
import d2d.core.resource;
import d2d.game.ui.uielement;

/// Loads a UI from a file. 
class Ui : UiElement
{
    /// Creates a new user interface.
    this(string n) 
    {
        name = n;
        Resource.preload!JsonData(name);
        load();        
    }

    /// (Re-)loads the useriterface. Also dosnt do anything if the file is invalid
    void load()
    {
        auto r = Resource.create!JsonData(name);
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
        auto r = Resource.create!JsonData(name);
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

    /// and cleanup focusing n stuff
    override void postUpdate() 
    {
        if (!isAnythingHovered()) {
            foreach(event; pollEvents()) {
                event.on!MouseButtonDownEvent(delegate(MouseButtonDownEvent e) {
                    _forceUnfocus();
                });
            }
        } else {
            cast(void)pollEvents();
        }
    }
    
private:
}