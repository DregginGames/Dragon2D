/**
    d2d.game.world.tile holds the base class for all kind of tiles that might exsist
*/

module d2d.game.world.worldtile;


import gl3n.linalg;
import d2d.game.world.tileset;

class Worldtile 
{
    this(string tileset, long id, vec2 pos)
    {
        _tileset = tileset;
        _id = id;
        _pos = pos;
        _collision = false; //for now
        _layer = 0; // for now
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
    long _layer;    
    string _tileset;
    long _id;
    bool _collision;
};