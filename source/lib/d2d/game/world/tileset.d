
module d2d.game.world.tileset;

import std.json;
import gl3n.linalg;
import d2d.core;
import d2d.util.jsonutil;

class Tileset : Resource
{
    this (string name) 
    {
        _name = name;
        Resource.preload!JSONData(_name);
        load();
        super(name);
    }

    ~this()
    {
        Resource.free(_name);
    }

    /// first reload ever implemented. not that its the most usefull.
    override void reload()
    {
        Resource.free(_texture);
        load();
    }

    void load()
    {
        auto d = Resource.create!JSONData(_name).data;
        try {
            _texture = d["texture"].str;
            _xdim = d["xdim"].integer;
            _ydim = d["ydim"].integer;
            _tilesize = vectorFromJson!(vec2)(d["tilesize"]);
        }
        catch {
            // meh
        }
        
        Resource.preload!Texture(_texture);    
        _uvsize = vec2(1.0/_xdim,1.0/_ydim);
    }

    TileData getTileData(ulong id)
    {
        if (id > _xdim*_ydim) {
            throw new Exception("Invalid tileset id. To big!");
        }
        
        long x = id % _xdim;
        long y = id / _ydim;
        TileData d;
        d.size = _tilesize;
        d.uvsize = _uvsize;
        d.uvpos = vec2(_uvsize.x*x,_uvsize.y*y);
        d.id = id;
        return d;
    }

    @property string texture()
    {
        return _texture;
    }

    @property long xdim()
    {
        return _xdim;
    }

    @property long ydim()
    {
        return _ydim;
    }

private:
    string _name;
    string _texture;
    long _xdim;
    long _ydim;
    vec2 _tilesize;
    vec2 _uvsize;
}

struct TileData
{
    vec2 size;
    vec2 uvpos;
    vec2 uvsize;
    ulong id;
}