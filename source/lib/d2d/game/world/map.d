/**
    Holds the map class. And stuff
*/

module d2d.game.world.map;

import gl3n.linalg;

import std.json;
import std.conv;


import d2d.core.base;
import d2d.core.resource;
import d2d.core.resources.jsondata;

import d2d.game.world;
import d2d.util.serialize;
import d2d.util.logger;

class Map : Base, Serializeable
{
    this(string name)
    {
        _name = name;
        loadMap(); 
    }

    ~this() 
    {
        Resource.free(_name);
    }

    /// loads the map (not mapdata or anythign)
    void loadMap() 
    {
        auto data = Resource.create!JSONData(_name);
        deserialize(data.data);
    }

    /// saves the map (not mapdata or anything)
    void saveMap()
    {
        auto data = Resource.create!JSONData(_name);
        data.data = serialize();
        data.save();
    }

    /// loads a map into the world
    void addToWorld()
    {
        auto world = this.getService!World("d2d.world");
        foreach(ref l; _layers) {
            world.addLayer(l);
        }
    }

    /// removes a map from the world
    void removeFromWorld()
    {
        auto world = this.getService!World("d2d.world");
        foreach(ref l; _layers) {
            world.removeLayer(l);
        }
    }

    /// manual implementation of a serializeable 
    override JSONValue serialize() 
    {
        JSONValue res = [ "typename" : to!string(typeid(this))];
        res["_displayName"] = toJson(_displayName);
        JSONValue[] arr;
        res["_layers"] = arr;
        foreach(ref l; _layers) {
            JSONValue layer;
            layer["tileset"] = toJson(l.tileset);
            int layerZ = l.layerZ;
            layer["layerZ"] = JSONValue(layerZ);
            JSONValue[] arr2;
            layer["tiles"] = arr2;
            foreach(ref t; l.tiles) {
                JSONValue tile;
                tile["pos"] = toJson(t.pos);
                tile["id"] = toJson(t.id);
                layer["tiles"].array ~= tile;
            }
            res["_layers"].array ~= layer;
        }

        return res;
    }

    /// Ditto
    void deserialize(JSONValue v) 
    {
        try {
            fromJson(v["_displayName"], _displayName);
            try {
                foreach (ref l; v["_layers"].array()) {
                    
                    try {
                        string tileset;
                        fromJson(l["tileset"],tileset);
                        int layerZ;
                        fromJson(l["layerZ"],layerZ);
                        WorldTileLayer layer = new WorldTileLayer(tileset,layerZ);
                        _layers ~= layer;
                        foreach (ref t; l["tiles"].array()) {
                            int id;
                            vec2 pos;
                            fromJson(t["pos"],pos);
                            fromJson(t["id"],id);
                            Worldtile tile = new Worldtile(id,pos);
                            layer.addTile(tile);
                        }
                    } 
                    catch (Exception e) {
                        Logger.log("Error loading tiles for a layer of " ~ _name);
                    }
                }
            } 
            catch (Exception e) {
                Logger.log("Map " ~ _name ~ " has no layers!");
            }
        } 
        catch (Exception e) {
            Logger.log("Cannot deserialize map" ~ _name ~ "!");
        }
    }
    
    /// adds a layer to the map
    void addLayer(WorldTileLayer l)
    {
        _layers ~= l;
    }

    /// Gets a reference to all the maps layers
    @property ref WorldTileLayer[] layers()
    {
        return _layers;
    }

    /// Gets the name of the map resource
    @property string name() const
    {
        return _name;
    }
    
    /// Gets/Sets the display name of the map (what a player might see)
    @property string displayName() const
    {
        return _displayName;
    }
    /// Ditto
    @property string displayName(string name)
    {
        return _displayName = name;
    }



private:
    string _name;
    string _displayName;
    WorldTileLayer[] _layers;
        
}