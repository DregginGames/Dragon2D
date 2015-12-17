/**
    This modukle holds the wrapper for a json-data resource.
*/
module d2d.core.resources.jsondata;

import std.json;

import d2d.core.resource;
import d2d.util.fileio;
import d2d.util.logger;

/**
    This class is a wrapper for JSON files. 
    Many systems of the engine might need to store data, and json is a nice format to do so. 
*/
class JSONData : Resource
{
    /// Creates a new JSONData resource
    this (string name) 
    {
        auto fresource = FileResource.getFileResource(name);
        if (!fresource.invalid) {
            _data = parseJSON(fresource.getData());
        } else {
            Logger.log("Could not load JSONData "~ name);
        }

        super(name);
    }

    /// saves json-data onto the disk
    void save() 
    {
        auto fresource = FileResource.getFileResource(name);
        if (!fresource.invalid) {
            fresource.setData(_data.toPrettyString());
            fresource.flush();
        } else {
            Logger.log("Could not save JSONData "~ name);
        }
    }

    /// Returns the JSONValue struct that hold the file if it was loaded properly
    @property ref JSONValue data()
    {
        return _data;
    }

private:
    /// Holds the loaded json data
    JSONValue _data;
}