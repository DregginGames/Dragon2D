/**
    Holds the map class. And stuff
*/

module d2d.game.world.map.map;

import gl3n.linalg;

import std.json;
import std.conv;


import d2d.core.base;
import d2d.core.resource;
import d2d.core.resources.jsondata;

import d2d.game.world;
import d2d.game.world.map.mapcontroller;
import d2d.util.serialize;
import d2d.util.logger;



class Map : Base, Serializeable
{
    this(string name, bool controllerEnabled=true)
    {
        _name = name;
        _isAddedToWorld = false;
        _controllerEnabled = controllerEnabled;
        loadMap(); 
    }

    ~this() 
    {
        Resource.free(_name);
    }

    /// loads the map (not mapdata or anythign)
    void loadMap() 
    {
        import d2d.util.logger,std.datetime;
        auto beforeLoad = Clock.currTime();
        Logger.log("Loading map " ~ _name ~ "...");
        // the laod
        debug {
            auto data = JsonData.createNew(_name,serialize());
        }
        else {
            auto data = Resource.create!JsonData(_name);
        }
        
        deserialize(data.data);
        // the controller controlls
        if(_controllerEnabled) {
            try {
                _controller = cast(MapController)Object.factory(_controllerName);
                if(_controller) {
                    auto c = cast(Base)_controller;
                    if(c) {
                        this.addChild(c);
                    } else {
                        Logger.log("Map Controller " ~ _controllerName ~ " cannot be added as child to " ~ _name);
                    }
                    _controller.setMap(this);
                } else {
                    Logger.log("Map Controller " ~ _controllerName ~ " does not exsist");
                }
            } catch(Exception e) {
                Logger.log("Map Controller " ~ _controllerName ~ " causes problems");
            }
        }
        // performance stats iu guess
        auto dur = Clock.currTime()-beforeLoad;
        Logger.log("Success, in " ~ dur.toString());
    }

    /// saves the map (not mapdata or anything)
    void saveMap()
    {
        auto data = Resource.create!JsonData(_name);
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

        _isAddedToWorld = true;

        if(_controller) {
            _controller.onMapload();
        }   
    }

    /// removes a map from the world
    void removeFromWorld()
    {
        auto world = this.getService!World("d2d.world");
        foreach(ref l; _layers) {
            world.removeLayer(l);
        }

        _isAddedToWorld = false;

        if(_controller) {
            _controller.onMapUnload();
        }
    }

    /// manual implementation of a serializeable 
    override JSONValue serialize() 
    {
        JSONValue res = [ "typename" : to!string(typeid(this))];
        res["_displayName"] = toJson(_displayName);
        res["_controllerName"] = toJson(_controllerName);
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
            fromJson(v["_controllerName"],_controllerName);
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

    /// transforms a position from map-relative to absolute
    vec2 toWorldPos(vec2 p) const 
    {
        return p+_offsetPos;
    }

    /// transforms a position from absolute to map-relative
    vec2 toMapPos(vec2 p) const
    {
        return p-_offsetPos;
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

    /// Gets/Sets the controller name of this map. Changes here dont take affect normally. Dont use, use a map editor :3
    @property string controllerName() const
    {
        return _controllerName;
    }
    /// Ditto
    @property string controllerName(string name)
    {
        return _controllerName = name;
    }

    /// Gets/Sets the offset position of the map
    @property vec2 offset() const
    {
        return _offsetPos;
    }
    /// Ditto
    @property vec2 offset(vec2 o) 
    {
        _offsetPos = o;
        foreach(ref l; _layers) {
            l.pos = _offsetPos;
        }
        
        if(_isAddedToWorld) {
            auto world = this.getService!World("d2d.world");
            world.forceBatchRebuild();
        }

        return _offsetPos;
    }

private:
    string _name;
    string _displayName;
    string _controllerName;
    WorldTileLayer[] _layers;
        
    MapController _controller;
    bool _controllerEnabled;
    bool _isAddedToWorld;
    vec2 _offsetPos = 0;
}