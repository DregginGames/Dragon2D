
module d2d.game.world.world;

import std.algorithm;

import gl3n.linalg;

import d2d.core;
import d2d.game.world;
import d2d.util.logger;

/// A footprint is part of the world
/// Its mainly used for players (at thier collision offset) and by the navigator
/// Footprints allow specific areas in the world to be marked as "collideable" or "unwalkable"
class Footprint 
{
    this() {
        id = max_id;
        max_id++;
    }
    size_t id;
    vec2 pos=vec2(0);
    double r = 0.0;
    bool walkable = false;
    bool collideable = false;
    bool ignored = false;
    static size_t max_id = 0;
}

/**
    The world service. Manages the rendering of the ingame world.
    This means it provides information about the loaded world-objects, manages the tile based rendering, ...
    
    One importand thing is the way the world-tiles are stored. Each tile is stored in form of layers. 
    in theory each tile in a layer has the same tileset as the rest of the layers but because of dynamic map loading that is not given.

    The batches will be generated and stored for rendering. 
*/
final class World : Base
{
    this()
    {
        registerAsService("d2d.world");
    }

    override void render()
    {
        auto r = getService!Renderer("d2d.renderer");
        foreach(ref b; _renderBatches) {
            r.pushObject(b);
        }
    }

    /// adds a layer
    void addLayer(WorldTileLayer l)
    {
        _layers[l.id] = l;
        regenerateBatches();
    }

    /// removes a layer
    void removeLayer(WorldTileLayer l)
    {
        _layers.remove(l.id);
    }
    
    /// forces batches to be rebuild. dont call to often. its slow.
    void forceBatchRebuild()
    {
        regenerateBatches();
    }

    /// returns if a tile is walkable
    bool isWalkable(vec2 p) 
    {
        bool result = true;
        bool anyTiles = false;
        bool footprintRes = true;

        foreach(ref l; _layers) {
            auto tset = Resource.create!Tileset(l.tileset);
            foreach(ref t; l.tilesAt(p)) {
                anyTiles = true;
                if(!tset.getTileData(t.id).walkable) {
                    result = false;
                    break;
                }
            }
            if (!result) {
                break;
            }
        }

        foreach(print; getFootprints(p)) {
            footprintRes &= print.walkable;
        }

        return result && anyTiles && footprintRes;
    }

    /// returns if a tile is collideable
    bool isCollideable(vec2 p)
    {
        bool result = false;
        bool anyTiles = false;
        bool footprintRes = false;

        foreach(ref l; _layers) {
            auto tset = Resource.create!Tileset(l.tileset);
            foreach(ref t; l.tilesAt(p)) {
                anyTiles = true;
                if(tset.getTileData(t.id).collideable) {
                    result = true;
                    break;
                }
            }
            if (result) {
                break;
            }
        }

        foreach(print; getFootprints(p)) {
            footprintRes |= print.collideable;
        }

        return result || !anyTiles || footprintRes;
    }

    // returns all footprints at a specific point
    Footprint[] getFootprints(vec2 p) 
    {
        Footprint[] res;
            foreach(footprint; _footprints) {
                if (!footprint.ignored && footprint.r*footprint.r >= (footprint.pos-p).magnitude_squared) {
                    res ~= footprint;
                }
            }
        return res;
    }

    /// adds a footprint to the world
    void addFootprint(ref Footprint p) 
    {
        if((p.id in _footprints) is null) {
            _footprints[p.id] = p;
        }
    }

    /// removes a footprint from the world
    void removeFootprint(ref Footprint p)
    {
        _footprints.remove(p.id);
    }

private:
    void regenerateBatches()
    {
        _renderBatches.length = 0; // delete all the old shit
        auto sortedLayers = sort!"a.layerZ < b.layerZ"(_layers.values);
        foreach(ref layer; sortedLayers) {
            string tsetname = layer.tileset;      
            try {
                auto tset = Resource.create!Tileset(tsetname);
                auto batch = new TexturedQuadBatch(tset.texture);
                batch.detailLevel = layer.layerZ; // yes
                foreach (ref tile; layer.tileList) {
                    BatchQuad q;
                    auto tdata = tset.getTileData(tile.id);
                    q.pos = tile.pos+layer.pos;
                    q.uvpos = tdata.uvpos;
                    q.uvsize = tdata.uvsize;
                    q.size = tdata.size;
                    batch.addQuad(q);
                }
                batch.flush();
                _renderBatches~=batch;
            } catch (Exception e) {
                Logger.log("ERROR: Could not gen tileset-batch for a render layer; Tileset that was drunk is " ~ tsetname ~ "--" ~ e.msg);
            }   
        }
    }

private:
    WorldTileLayer[ulong] _layers; // layers of tiles, stored first by layer and then by tileset. 
    Footprint[size_t] _footprints; // footprints on the map
    TexturedQuadBatch[] _renderBatches;
}