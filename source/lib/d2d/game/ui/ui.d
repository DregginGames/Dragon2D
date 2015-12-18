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
class UI : Base
{
    /// Creates a new user interface.
    this(string name) 
    {
        _name = name;
        Resource.preload!JSONData(_name);
        load();        
    }

    /// (Re-)loads the useriterface. Also dosnt do anything if the file is invalid
    void load()
    {
        auto r = Resource.create!JSONData(_name);
        if (r.data.type != JSON_TYPE.OBJECT) {
            return;
        }
        auto elements = ("elements" in r.data.object);
        if(elements !is null) {
            foreach(ref e; elements.array) {
                auto newelem = UIElement.fromClassname(e.object["className"].str);
                if(newelem !is null) {
                    this.addChild(newelem);
                    newelem.load(e);
                }
            }
        }
    }

    /// Stores the ui tree below into the resource
    void store()
    {
        JSONValue storedata = [ "name": _name ];
        foreach(ref c; children) {
            if (cast(UIElement)c) {
                JSONValue elemdata;
                (cast(UIElement)c).store(elemdata);
                storedata.object["elements"].array ~= elemdata;
            }
        }
        auto r = Resource.create!JSONData(_name);
        r.data = storedata;
        r.save();
    }

    /// Cleans up
    ~this() 
    {
        Resource.free(_name);    
    }
private:
    /// the name of this user interface
    string _name;
}