
module d2d.game.world.world;

import std.algorithm;

import d2d.core;
import d2d.game.world;
import d2d.util.logger;

/**
    The world service. Manages the rendering of the ingame world.
    This means it provides information about the loaded world-objects, manages the tile based rendering, ...
    
    One importand thing is the way the world-tiles are stored. Each tile is stored in form of layers. 
    in theory each tile in a layer has the same tileset as the rest of the layers but because of dynamic map loading that is not given.
    So when adding new tiles, the tiles will be put into new arrays relating to thier tilesets - per layer. 
    Then the batches will be generated and stored for rendering. 
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


private:
    void regenerateBatches()
    {
        _renderBatches.length = 0; // delete all the old shit
        auto lids = _layers.keys;
        sort(lids);
        foreach(layer; lids) {
            string[] tsets = _layers[layer].keys;               
            foreach( tsetname; tsets) {
                try {
                    auto tset = Resource.create!Tileset(tsetname);
                    auto batch = new TexturedQuadBatch(tset.texture);
                    foreach (ref tile; _layers[layer][tsetname]) {
                        BatchQuad q;
                        auto tdata = tset.getTileData(tile.id);
                        q.pos = tile.pos;
                        q.uvpos = tdata.uvpos;
                        q.uvsize = tdata.uvpos;
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
    }

private:
    Worldtile[][string][long] _layers; // layers of tiles, stored first by layer and then by tileset. 
    TexturedQuadBatch[] _renderBatches;
}