
module d2d.game.world.tileset;

import std.json;
import std.algorithm;


import gl3n.linalg;
import d2d.core;
import d2d.util.jsonutil;



class Tileset : Resource
{
    this (string name) 
    {
        super(name);
        Resource.preload!JsonData(name);
        reload();
    }

    ~this()
    {
        Resource.free(name);
        Resource.free(_texture);
    }

    /// first reload ever implemented. not that its the most usefull.
    override void reload()
    {
        Resource.free(_texture);
        auto json = Resource.create!JsonData(name);
        json.reload();

        load();
    }

    void load()
    {
        auto d = Resource.create!JsonData(name).data;
        try {
            _texture = d["texture"].str;
            _xdim = d["xdim"].integer;
            _ydim = d["ydim"].integer;
            _tilesize = vectorFromJson!(vec2)(d["tilesize"]);
            foreach(i; d["collide"].array) {
                _collide ~= i.integer;
            }
            foreach(i; d["nowalk"].array) {
                _nowalk ~= i.integer;
            }
            // for pixel art tilesets this is relevant
            auto pFilter = "filter" in d;
            if (pFilter && pFilter.integer == 0) {
                import derelict.opengl3.gl;
                auto tex = Resource.create!Texture(_texture);
                tex.gpuTexture.filter = GL_NEAREST;
            }
        }
        catch (Throwable) {
            import d2d.util.logger;
            Logger.log("Error loading tileset");
        }
        
        Resource.preload!Texture(_texture);    
        _uvsize = vec2(1.0/_xdim,1.0/_ydim);
    }

    TileData getTileData(ulong id)
    {
        if (id > _xdim*_ydim) {
            throw new Exception("Invalid tileset id. To big!");
        }
        auto tex = Resource.create!Texture(_texture);

        long x = id % _xdim;
        long y = min(id / _xdim,_ydim);
        TileData d;
        d.size = _tilesize;
        d.uvsize = _uvsize;
        d.uvpos = vec2(_uvsize.x*x,_uvsize.y*y);
        tex.toPixelCenter(d.uvpos,d.uvsize); //importand, removes tearing
        d.id = id;
        d.walkable = !_nowalk.canFind(id);
        d.collideable = _collide.canFind(id);
        return d;
    }

    /// revovers a tileset id from a uv pos
    ulong getTileId(vec2 pos) const
    {
        long x = 0;
        long y = 0;
        x = cast(long)(pos.x/_uvsize.x);
        y = cast(long)(pos.y/_uvsize.y);
        return max(0,min(_xdim*_ydim,x + y*_xdim));
    }

    @property string texture() const
    {
        return _texture;
    }

    @property long xdim() const
    {
        return _xdim;
    }

    @property long ydim() const
    {
        return _ydim;
    }

    @property vec2 tilesize() const
    {
        return _tilesize;
    }

private:
    string _texture;
    long _xdim;
    long _ydim;
    vec2 _tilesize;
    vec2 _uvsize;
    long[] _nowalk;
    long[] _collide;
}

struct TileData
{
    vec2 size;
    vec2 uvpos;
    vec2 uvsize;
    bool collideable;
    bool walkable;
    ulong id;
}
