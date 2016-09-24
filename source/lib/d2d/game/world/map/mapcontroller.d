module d2d.game.world.map.mapcontroller;

import d2d.game.world.map.map;

/*
    A mapcotroller can (mut dosnt have to) be set for a map
    Mapcontrollers should be derived from Base as a map will try to set it as its child

    They exsist to handle common tasks, interface with the map above them etc.
*/  
interface Mapcontroller
{
    void onMapload();
    void onMapUnload();

    void setMap(Map m);

}