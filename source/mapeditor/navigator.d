
module navigator;

import std.math;

import gl3n.linalg;

import d2d.core.base;
import d2d.core.io;
import d2d.core.resource;

import d2d.game.world;
import d2d.game.ui;
import d2d.game.simple.camera;

import d2d.util.settings;

class Navigator : Base
{
    this() 
    {
        enableEventHandling();

        _mapname = Settings["mapname"].str;
        _cam = new Camera(4.0);
        _map = new Map(_mapname);
        
        _cursor = new WorldCursor();
        _cam.addChild(_cursor);
        this.addChild(_cam);

        _ui = new UI("ui.mapeditor");
        this.addChild(_ui);
        _cam.addChild(_map);
        _map.addToWorld();

        _layerUpdate();
    }

    override void update() 
    {
        auto events = this.pollEvents();
        foreach(ref event; events) {
            if(cast(MouseWheelEvent)event) {
                auto e = cast(MouseWheelEvent) event;
                _cam.height = _cam.height + _cam.height*0.1*(cast(double)e.movement.y);
                auto cursorOff = _cursor.absolutePos-_cam.absolutePos;
                _cam.pos = e.movement.y < 0 ? _cam.pos + cursorOff*0.1 : _cam.pos - cursorOff*0.1;
            }

            /// parse ui interaction
            event.on!(UiOnRightClickEvent,"e.element.name == \"addLayerButton\"")(delegate(UiOnRightClickEvent e) {
                auto edit = cast(Edit)_ui.getByName("addLayerEdit")[0];
                WorldTileLayer l = new WorldTileLayer(edit.text);
                _map.addLayer(l);
                _activeLayer = _map.layers.length-1;
                _buildLayerList();
            });
            
            event.on!(UiOnRightClickEvent,"e.element.name == \"setLayerText\"")(delegate(UiOnRightClickEvent e) {
                int layerId = *e.element.userData["layer"].peek!(int);
                if (layerId >= 0 && layerId < _map.layers.length) {
                    _activeLayer = layerId;
                    _layerUpdate();
                }
            });

            event.on!(UiOnClickEvent,"e.element.name == \"tilesetImage\"")(delegate(UiOnClickEvent e) {
                auto setname = _map.layers[_activeLayer].tileset;
                auto set = Resource.create!Tileset(setname);
                _activeTile = cast(int)set.getTileId(e.relativeClick);
                _layerUpdate();
            });

            if(!UI.isAnythingFocused()&&!UI.isAnythingHovered()) {
                event.on!(MouseButtonDownEvent)(delegate(MouseButtonDownEvent e) {
                    import d2d.util.logger;
                    Logger.log("Adding tile at around " ~ to!string(_cursor.absolutePos));
                    // map click to raster size (size property of TsetData)
                    auto setname = _map.layers[_activeLayer].tileset;
                    auto set = Resource.create!Tileset(setname);
                    auto tileData = set.getTileData(_activeTile);
                    auto size = tileData.size;
                    vec2 p;
                    p.x = floor(size.x+_cursor.absolutePos.x/size.x)*size.x;
                    p.y = floor(size.y+_cursor.absolutePos.y/size.y)*size.y;
                    Worldtile tile = new Worldtile(_activeTile,p);
                    _map.layers[_activeLayer].addTile(tile);
                    auto world = this.getService!World("d2d.world");
                    world.forceBatchRebuild();
                });
            }
        }

        

    }


protected:

    /// builds the list of current layers
    void _buildLayerList()
    {
        auto box = _ui.getByName("layerbox")[0];
        box.children.clear();
        
        int yoffset = 0;
        foreach(ref layer; _map.layers) {            
            auto t = new Button(layer.tileset);
            t.color = _activeLayer == yoffset ? vec4(1.0,0.0,0.0,1.0) : vec4(1.0,1.0,1.0,1.0);   
            t.textColor = vec4(0.0,0.0,0.0,1.0);           
            t.pos = vec2(0.1,0.05+0.05*yoffset);
            t.size = vec2(0.9,0.05);
            t.name = "setLayerText";
            t.userData["layer"] = yoffset;
            box.addChild(t);
            yoffset++;
        }
        yoffset++;
        auto addEdit = new Edit();
        addEdit.pos = vec2(0.05,0.05+0.05*yoffset);
        addEdit.size = vec2(0.7,0.05);
        addEdit.color = vec4(1.0,1.0,1.0,1.0);
        addEdit.textColor = vec4(1.0,0.0,1.0,1.0);
        addEdit.name = "addLayerEdit";
        auto addButton = new Button("Add");
        addButton.name = "addLayerButton";
        addButton.color = vec4(0.1,0.8,0.5,1.0);
        addButton.size = vec2(0.2,0.05);
        addButton.pos = vec2(0.8,0.05+0.05*yoffset);
        box.addChild(addEdit);
        box.addChild(addButton);
    }

    /// redraws the layer-tileset area
    void _buildLayerTileset()
    {
        auto box = _ui.getByName("tilesetbox")[0];
        box.children.clear();
        
        if (_map.layers.length == 0 || _activeLayer >= _map.layers.length) {
            return;
        }
        auto setname = _map.layers[_activeLayer].tileset;
        auto set = Resource.create!Tileset(setname);
        auto i = new Image(set.texture);
        i.name="tilesetImage";

        auto selectBox = new Box();
        auto tileData = set.getTileData(_activeTile);
        selectBox.pos = tileData.uvpos;
        selectBox.size = tileData.uvsize;
        selectBox.color = vec4(1.0,0.0,0.0,0.5);
        i.addChild(selectBox);
        box.addChild(i);

    }

    void _layerUpdate()
    {
        _buildLayerList();
        _buildLayerTileset();
    }

private:
    string _mapname;
    Map    _map;
    Camera _cam;
    WorldCursor _cursor;
    UI          _ui;

    int _activeLayer;
    int _activeTile;
}