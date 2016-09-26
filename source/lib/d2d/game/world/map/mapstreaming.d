module d2d.game.world.map.mapstreaming;

/** Holds classes and helpers for mapstreaming */

import gl3n.linalg;

import d2d.core.base;
import d2d.game;
import d2d.util.logger;


/** A StreamTrigger is a trigger especially made to stream a map
*/
class StreamTrigger(filterClass, string filterCompare="") : Trigger!(filterClass,filterCompare)
{
    /** 
        Creates a new StreamTrigger. It will load the map specified by mapname underneath the given target
        Parameters:
            mapname = the name of the map to load 
            target = the object to add the map to 
    */
    this(string mapname, Base target)
    {
        _target = target;
        _mapname = mapname;
        super.triggerMode = AbstractTrigger.TriggerMode.once;
        _isLoaded = false;
    }

    override void update()
    {
        if (this.triggered&&!_isLoaded) {
            Logger.log("Attempting to stream map " ~ _mapname);
            _isLoaded = true;
            if (_target !is null) {
                try {
                    auto m = new Map(_mapname);
                    _target.addChild(m);
                    m.offset = this.absolutePos+_loadOffset;
                    m.addToWorld();
                }
                catch (Exception e) {
                    Logger.log("Could not stream map - exception! " ~ e.msg);
                }
            } else {
                Logger.log("Could not load map - target does not exsist");
            }
            // make even more sure that we cannot trigger again
            this.sizeMode = Entity.SizeMode.none;
        }
    }

    /// Sets/gets the offset of the map to load - relative to the triggers absolute position
    @property vec2 loadOffset() const 
    {
        return _loadOffset;
    }
    /// Ditto
    @property vec2 loadOffset(vec2 o)
    {
        return _loadOffset=o;
    }

    /// Returns if the map is loaded already
    @property bool isLoaded() const
    {
        return _isLoaded;
    }   

    /// Returns the name of the map this Streamer loads
    @property string mapname() const 
    {
        return _mapname;
    }
private:
    Base _target;
    string _mapname;
    bool _isLoaded;  

    vec2 _loadOffset = 0;
}