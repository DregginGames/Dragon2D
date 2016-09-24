module d2d.game.world.map.mapcontroller;

import d2d.game.world.map.map;

/*
    A mapcotroller can (mut dosnt have to) be set for a map
    MapControllers should be derived from Base as a map will try to set it as its child

    They exsist to handle common tasks, interface with the map above them etc.
*/  
interface MapController
{
    /// called when a map is added to the world
    void onMapload();
    /// called when the map is removed from the world
    void onMapUnload();

    /// called somewhere during the maps initialization. 
    void setMap(Map m);

}