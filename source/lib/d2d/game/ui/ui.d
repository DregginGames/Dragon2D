/**
    Holds the loader / interface for a user interface
*/

module d2d.game.ui.ui;

import d2d.core.base;

import d2d.core.resources.jsondata;
import d2d.core.resource;

/// Loads a UI from a file. 
class UI : Base
{
    /// Creates a new user interface.
    this(string name) 
    {
        _name = name;
        auto r = Resource.create!JSONData(_name);
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