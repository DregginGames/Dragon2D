
module navigator;

import std.math;
import std.regex;

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

        _ui = new Ui("ui.mapeditor");
        this.addChild(_ui);
        _cam.addChild(_map);
        _map.addToWorld();

        _redrawUi();
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
            event.on!(UiOnClickEvent,"e.element.name == \"addLayerButton\"")(delegate(UiOnClickEvent e) {
                auto edit = cast(Edit)_ui.getByName("addLayerEdit")[0];
                WorldTileLayer l = new WorldTileLayer(edit.text);
                _map.addLayer(l);
                _map.removeFromWorld();
                _map.addToWorld();
                _activeLayer = cast(int)(_map.layers.length-1); //dont ask
                _layerUpdate();
            });
            
            event.on!(UiOnClickEvent,"e.element.name == \"saveMapButton\"")(delegate(UiOnClickEvent e) {
                _map.saveMap();
            });

            event.on!(UiOnClickEvent,"e.element.name == \"setLayerText\"")(delegate(UiOnClickEvent e) {
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

            event.on!(UiOnChangeEvent,"e.element.name == \"layerZEdit\"")(delegate(UiOnChangeEvent e) {
                auto elem = cast(Edit)e.element;
                if (elem.text.length>0) {
                    _map.layers[_activeLayer].layerZ = cast(int)elem.integer;
                    auto world = this.getService!World("d2d.world");
                    world.forceBatchRebuild();
                }
            });

            event.on!(UiOnChangeEvent,"e.element.name == \"displayNameEdit\"")(delegate(UiOnChangeEvent e) {
                auto elem = cast(Edit)e.element;
                    _map.displayName = elem.text;
            });

            event.on!(UiOnChangeEvent,"e.element.name == \"controllerNameEdit\"")(delegate(UiOnChangeEvent e) {
                auto elem = cast(Edit)e.element;
                _map.controllerName = elem.text;
            });

            if(!Ui.isAnythingFocused()&&!Ui.isAnythingHovered()) {
                event.on!(MouseButtonDownEvent,"e.button == T.MouseButtonId.MouseLeft")(delegate(MouseButtonDownEvent e) {
                    _isDrawing = true;
                    _isDeleting = false;
                });
                event.on!(MouseButtonDownEvent,"e.button == T.MouseButtonId.MouseRight")(delegate(MouseButtonDownEvent e) {
                    _isDeleting = true;
                    _isDrawing = false;
                });
            }

            event.on!(MouseButtonUpEvent,"e.button == T.MouseButtonId.MouseLeft")(delegate(MouseButtonUpEvent e) {
                _isDrawing = false;
            });
            event.on!(MouseButtonUpEvent,"e.button == T.MouseButtonId.MouseRight")(delegate(MouseButtonUpEvent e) {
                _isDeleting = false;
            });

            

        }

        if (_isDrawing) {
            import d2d.util.logger;
            Logger.log("Adding tile at around " ~ to!string(_cursor.absolutePos));
            // check if there is a tile already
            auto tileList = _map.layers[_activeLayer].tilesAt(_cursor.absolutePos);
            if (tileList.length > 0) {
                foreach(ref t; tileList) {
                    t.id = _activeTile;
                }
            }
            else {
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
            }
            auto world = this.getService!World("d2d.world");
            world.forceBatchRebuild();
        }
        else if (_isDeleting) {
            _map.layers[_activeLayer].removeTilesAt(_cursor.absolutePos);
            auto world = this.getService!World("d2d.world");
            world.forceBatchRebuild();
        }

    }


protected:

    /// builds the list of current layers
    void _buildLayerList()
    {
        auto box = _ui.getByName("layerbox")[0];
        box.children.clear();
        
        auto boxlabel = new Label("Layers");
        boxlabel.pos = vec2(0.0,0.0);
        boxlabel.size = vec2(.5,0.05);
        box.addChild(boxlabel);

        int yoffset = 0;
        foreach(ref layer; _map.layers) {            
            auto t = new Button(layer.tileset);
            auto c = t.color;
            c.background  = _activeLayer == yoffset ? vec4(1.0,0.0,0.0,1.0) : vec4(1.0,1.0,1.0,1.0);  
            c.foreground = vec4(0.0,0.0,0.0,1.0);  
            t.color = c;        
            t.pos = vec2(0.1,0.1+0.05*yoffset);
            t.size = vec2(0.9,0.05);
            t.name = "setLayerText";
            t.userData["layer"] = yoffset;
            box.addChild(t);
            yoffset++;
        }
        yoffset++;
        
        UiColor color = defaultUiColorScheme(UiColorSchemeSelect.INTERACTION);        
        auto addEdit = new Edit();
        addEdit.pos = vec2(0.05,0.1+0.05*yoffset);
        addEdit.size = vec2(0.7,0.05);
        addEdit.color = color;
        addEdit.name = "addLayerEdit";

        auto addButton = new Button("Add");
        addButton.name = "addLayerButton";
        addButton.color = color;
        addButton.size = vec2(0.2,0.05);
        addButton.pos = vec2(0.8,0.1+0.05*yoffset);
        
        box.addChild(addEdit);
        box.addChild(addButton);

        if(_map.layers.length > 0) {
            import std.regex,std.conv;
            yoffset+=2;
            double y = 0.1+0.05*yoffset;
            auto zEdit = mkeditpair(box,color,y,"layerZEdit","Z index",toImpl!string(_map.layers[_activeLayer].layerZ),"Z Index");
            zEdit.filter = ctRegex!("^\\d*$");
            yoffset++;
            auto levelEdit = mkeditpair(box,color,0.1+y,"layerZEdit","Detail Level","0","level");
        }

        
        
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
        UiColor selectBoxColor;
        selectBoxColor.background = vec4(1.0,0.0,0.0,0.5);
        selectBox.color = selectBoxColor;
        i.addChild(selectBox);
        box.addChild(i);

    }

    /// redraws the map-properties-blob
    void _buildMapProperties()
    {
        auto box = _ui.getByName("mapbox")[0];
        box.children.clear();

        auto boxlabel = new Label("Map Config");
        boxlabel.pos = vec2(0.0,0.0);
        boxlabel.size = vec2(.5,0.05);
        box.addChild(boxlabel);

        UiColor color = defaultUiColorScheme(UiColorSchemeSelect.INTERACTION);

        

        // display name
        
        mkeditpair(box,color,0.1,"displayNameEdit","Display Name",_map.displayName,"Display Name");
        mkeditpair(box,color,0.2,"controllerNameEdit","Map Controller",_map.controllerName,"fully.qualified.name");

        auto saveButton = new Button("Save");
        saveButton.name = "saveMapButton";
        saveButton.color = color;
        saveButton.size = vec2(0.5,0.05);
        saveButton.pos = vec2(0.01,0.94);
        box.addChild(saveButton);
    }
    
    void _redrawUi() 
    {
        _layerUpdate();
        _buildMapProperties();
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
    Ui          _ui;

    int _activeLayer;
    int _activeTile;

    bool _isDrawing;
    bool _isDeleting;
}


/// helper used in manual drawing of ui. Returns the created edit
Edit mkeditpair(UiElement target, UiColor color,double y, string name, string labelStr, string editDefault="", string placeholder="") {
    auto label = new Label(labelStr);
    label.pos = vec2(0.0,y);
    label.size = vec2(0.5,0.05);
    auto edit = new Edit(editDefault);
    edit.placeholder = placeholder;
    edit.pos = vec2(0.0,y+0.05);
    edit.size = vec2(1.0,0.05);
    edit.color = color;
    edit.name = name;
    target.addChild(label);
    target.addChild(edit);

    return edit;
}