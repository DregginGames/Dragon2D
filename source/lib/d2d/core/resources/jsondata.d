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
class JsonData : Resource
{
    /// Creates a new JsonData resource
    this (string name) 
    {
        auto fresource = FileResource.getFileResource(name);
        if (!fresource.invalid) {
            try {
                _data = parseJSON(fresource.getData());
            } 
            catch (JSONException e)
            {
                Logger.log("Could not load JsonData" ~ name ~ " - file error:\n" ~ e.msg);
                _data = JSONValue("");
            }
        } else {
            Logger.log("Could not load JsonData "~ name);
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
            Logger.log("Could not save JsonData "~ name);
        }
    }

    /// Returns the JSONValue struct that hold the file if it was loaded properly
    @property ref JSONValue data()
    {
        return _data;
    }

    /// creates a new json resource on the file system. 
    /// Fills it with newValue if given. 
    /// Returns exsisting resource if it already exsists or the newly created one if its new
    static JsonData createNew(string resourceString, lazy JSONValue newValue = JSONValue())
    {
        auto fresource = FileResource.getFileResource(resourceString);
        if (fresource.invalid) {
            FileResource.createGameResource(resourceString,"json");
            auto newdata = Resource.create!JsonData(resourceString);
            newdata._data = newValue;
            newdata.save();
            return newdata;
        }

        
        return Resource.create!JsonData(resourceString);
    }

private:
    /// Holds the loaded json data
    JSONValue _data;
}