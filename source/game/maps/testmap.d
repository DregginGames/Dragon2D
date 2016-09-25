module maps.testmap;

import gl3n.linalg;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;

import d2d.core.base;
import d2d.core.dbg.eventdebug;
import d2d.game;

class Testmap : Base, MapController
{
    override void onMapload() 
    {
        if (_map) {
            auto addTarget = _map.parent;
            auto camera = new Camera(5.0f);
            addTarget.addChild(camera);

            auto trigg = new Trigger!Sprite();
            trigg.sizeMode = Entity.SizeMode.rect;
            trigg.size = vec2(1.0,1.0);
            addTarget.addChild(trigg);

            auto cursor = new WorldCursor();
            auto s2 = new Sprite("texture.test");
            s2.positionMode = Entity.PositionMode.parentBound;
            s2.sizeMode = Entity.SizeMode.rect;
            s2.size = vec2(1.0,1.0);
            cursor.addChild(s2);
            camera.addChild(cursor);

            auto m = new Music("music.intoTheMenu");
            addTarget.addChild(m);
            addTarget.addChild(new NoSDLEventDebugger());
            m.play();
        }
    }
    
    override void onMapUnload() 
    {
    
    }
    
    override void setMap(Map m) 
    {
        _map = m;
    }
    
private:
    Map _map;
}