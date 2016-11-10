/**
    d2d.game.world.tile holds the base class for all kind of tiles that might exsist
*/

module d2d.game.world.worldtile;

import std.math;

import gl3n.linalg;
import d2d.game.world.tileset;
import d2d.core.resource;

class Worldtile 
{
    this(long id, vec2 pos)
    {
        _id = id;
        _pos = pos;
    }

    @property long id() const
    {
        return _id;
    }

    @property long id(long i)
    {
        return _id=i;
    }

    @property vec2 pos() const
    {
        return _pos;
    }

private:
    vec2 _pos;
    long _id;
};

class WorldTileLayer
{
    this(string tileset, int layerZ = 0) 
    {
        _id = _maxid;// id stuff
        _maxid++;
        _pos = vec2(0.0,0.0);
        _layerZ = layerZ;
        _tileset = tileset;

        Resource.preload!Tileset(_tileset);
    }

    ~this()
    {
        Resource.free(_tileset);
    }

    /// adds a new tile to the layer
    void addTile( Worldtile t)
    {
        auto pos = toArrayPos(t.pos);
        _tiles[pos.x][pos.y] = t;
    }

    /// returns all tiles in this layer that can be found at the given position
    /// usually should only return one or none tiles. 
    Worldtile[] tilesAt(vec2 inpos)
    {
        Worldtile[] result;
        inpos = inpos-_pos; // layers, internally, dont have the offset of the layer
        
        auto arrayPos = toArrayPos(inpos);
        auto x = arrayPos.x in _tiles;
        if (x !is null) {
            auto y = arrayPos.y in *x;
            if (y !is null) {
                result ~= *y;
            }
        }

        return result;
    }

    void removeTilesAt(vec2 inpos) 
    {
        inpos = inpos-_pos;
        auto arrayPos = toArrayPos(inpos);
        auto x = arrayPos.x in _tiles;
        if (x !is null) {
            auto y = arrayPos.y in *x;
            if (y !is null) {
                _tiles[arrayPos.x].remove(arrayPos.y);
            }
        }
    }
    /// tileset used by this layer
    @property string tileset() const
    {
        return _tileset;
    }
    /// Ditto
    @property string tileset(string s)
    {
        return _tileset = tileset;
    }

    /// z index of this layer
    @property int layerZ() const
    {
        return _layerZ;
    }
    /// Ditto
    @property int layerZ(int i) 
    {
        return _layerZ = i;
    }

    /// position of this layer
    @property vec2 pos() const 
    {
        return _pos;
    }
    /// Ditto
    @property vec2 pos(vec2 p) 
    {
        return _pos = p;
    }


    /// Raw access to the tiles
    @property ref Worldtile[int][int] tiles()
    {
        return _tiles;
    }

    /// returns a Worldtile[] list that can be used for different things
    @property Worldtile[] tileList()  
    {
        Worldtile[] res;
        foreach (row; _tiles) {
            foreach(tile; row) {
                res ~= tile;
            }
        }

        return res;
    }

    /// id used for fast access inside the world
    ulong id() const
    {
        return _id;
    }

protected:
    
    /// Converts the given input position to a position in the tile array
    /// Tiles are seen as being centered around a position, so i.e. (-0.1,-0.1) still could evaluate to (0,0)
    /// To do that, 0.5 is added in the flooring
    vec2i toArrayPos(vec2 pos)
    {
        Tileset tset = Resource.create!Tileset(_tileset);
        int xpos = cast(int)floor(pos.x/tset.tilesize.x+0.5);
        int ypos = cast(int)floor(pos.y/tset.tilesize.y+0.5);
        return vec2i(xpos,ypos);
    }

private:
    /// z index of this layer
    int _layerZ;
    /// the position of this layer
    vec2 _pos;
    /// tileset of this layer
    string _tileset;
    /// tiles in this layer
    Worldtile[int][int] _tiles;
    /// id of this layer
    ulong _id;
    /// static thing to select the ids of layers
    static ulong _maxid = 0;
}