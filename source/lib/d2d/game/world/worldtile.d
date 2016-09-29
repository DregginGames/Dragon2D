/**
    d2d.game.world.tile holds the base class for all kind of tiles that might exsist
*/

module d2d.game.world.worldtile;


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
        _tiles ~= t;
    }

    /// returns all tiles in this layer that can be found at the given position
    Worldtile[] tilesAt(vec2 inpos)
    {
        Worldtile[] result;
        inpos = inpos-_pos; // layers, internally, dont have the offset of the layer
        Tileset tset = Resource.create!Tileset(_tileset);
        foreach (ref t; _tiles) {
            vec2 size = tset.getTileData(t.id).size; 
            vec2 pos = t.pos-0.5*size; // tiles are still centered
            if (inpos.x >= pos.x && inpos.x <= pos.x+size.x) {
                if (inpos.y >= pos.y && inpos.y <= pos.y+size.y) {
                    result ~= t;
                }
            }
        }

        return result;
    }

    void removeTilesAt(vec2 inpos) 
    {
        int[] toDelete;
        inpos = inpos-_pos;
        Tileset tset = Resource.create!Tileset(_tileset);
        for (int i = 0; i < _tiles.length; i++) {
            auto t = _tiles[i];
            vec2 size = tset.getTileData(t.id).size; 
            vec2 pos = t.pos-0.5*size; // tiles are still centered
            if (inpos.x >= pos.x && inpos.x <= pos.x+size.x) {
                if (inpos.y >= pos.y && inpos.y <= pos.y+size.y) {
                    toDelete ~= i;
                }
            }
        }

        foreach(i; toDelete) {
            if (_tiles.length == 0) {
                break;
            }
            if (_tiles.length-1 == 0) {
                _tiles.length = 0;
            }
            else if (i==0) {
                _tiles = _tiles[1..$];
            }
            else if (i == _tiles.length) {
                _tiles = _tiles[0..$-1];
            }
            else {
                _tiles = _tiles[0..i] ~ _tiles[i+1..$];
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
    @property ref Worldtile[] tiles()
    {
        return _tiles;
    }

    /// id used for fast access inside the world
    ulong id() const
    {
        return _id;
    }

private:
    /// z index of this layer
    int _layerZ;
    /// the position of this layer
    vec2 _pos;
    /// tileset of this layer
    string _tileset;
    /// tiles in this layer
    Worldtile[] _tiles;
    /// id of this layer
    ulong _id;
    /// static thing to select the ids of layers
    static ulong _maxid = 0;
}