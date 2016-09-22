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
        _collision = false; //for now
    }

    @property long id()
    {
        return _id;
    }

    @property vec2 pos()
    {
        return _pos;
    }

private:
    vec2 _pos;
    long _id;
    bool _collision;
};

class WorldTileLayer
{
    this(string tileset, int layerZ = 0) 
    {
        _id = _maxid;// id stuff
        _maxid++;

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
        Tileset tset = Resource.create!Tileset(_tileset);
        foreach (ref t; _tiles) {
            vec2 size = tset.getTileData(t.id).size; 
            vec2 pos = t.pos;
            if (inpos.x >= pos.x && inpos.x <= pos.x+size.x) {
                if (inpos.y >= pos.y && inpos.y <= pos.y+size.y) {
                    result ~= t;
                }
            }
        }

        return result;
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
    int _layerZ;
    string _tileset;
    Worldtile[] _tiles;
    ulong _id;

    static ulong _maxid = 0;
}