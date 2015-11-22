/**
	d2d.core.render.renderable holds the base classes for object rendering. 
*/
module d2d.core.render.objects.renderable;

import gl3n.linalg;
import gl3n.math;
import derelict.opengl3.gl3;

import d2d.util.logger;
import d2d.core.render.objects.view;
import d2d.core.render.lowlevel.vao;

/**
	Renderable is abstract base for all types of /renderables/. 
	A Renderable is an object that actually is renderd on screen, like a circle, a textured quad, a tile map, ....
	Its one of the few structures that life outside the Base-class hirarchy
    
    An importand concept of Renderables is the detail level. The higher this level is, the higher the level of the View needs to be to be able to see this object. 
    Here is a reccomendation for the detail levels:
        00..19: Application-level - always-visible things: Debug information, Alerts, ....
        20..39: Map-level - map-baisc stuff like terrain
        40..59: Map-detail-level - advaned stuff like Buildings, details, flowers, ... 
        60..79: Actor-level - everything that actually does things like NPCs, players, ...
        80+: UI-Level - the user interface. Above that... whatever 
 
*/
abstract class Renderable
{
    /// The Mode in wich a VAO is "run".
    enum VAOMode {
        unspecified = 0, /// default. equals none in behaviour, but makes a cleaner case for "my parent class will manage this"
        none = 1,   /// no vao at all. usefull for more abstract thigs (like text wich onlly utilizes other things
        classWide = 2,  /// usefull for basically everything "simple" - primitives
        objectWide = 3, // /every object has its own vao. usefull for batches, complex models, ....
    }

	/// Creates a renderable. Does nothing atm.
	this()
	{		      
	}

	/// Cleanup
	~this()
	{
	}

	/// Performs an actual render on screen. 
	void render(ref View view)
	{
	}

	@property VAO vao()
	{
        switch(_vaoMode) {
            case VAOMode.classWide:
                return _classwideVAO[typeid(this).toHash()];
            case VAPMode.objectWide:
                return _vao;
            default:
                break;
        }
		throw Exception("Can't access an VAO of an renderable in unspecified or none mode!");
        assert(0);
	}

    /// The detail Level. The higher this level is, the higher the level of a view needs to be to see this object
    @property int detailLevel()
    {
        return _detailLevel;
    }
    @property int detailLevel(int l)
    {
        return _detailLevel = l;
    }

protected:
    /// Sets the mode with wich the classes VAO is managed. If set once, it cant be changed - means that there is a need to take care how the interaction with parten-classes is handled
    /// If set to unspecified the partent-classes mode is used or none if none is set. 
    void _setupVAO(VAOMode mode) {
        if (_vaoMode == VAOMode.unspecified) {
            _vaoMode = mode;
            switch(_vaoMode) {
                case VAOMode.unspecified:
                    break;
                case VAOMode.none:
                    break;
                case VAOMode.classWide:
                    auto p = typeid(this).toHash() in _classwideVAO;
                    if (!p) {
                        _classwideVAO[typeid(this).toHash()] = new VAO;
                    }
                    break;
                case VAOMode.objectWide:
                    _vao = new VAO();
                    break;
                default:
                    break;
            }
        }
    }

private:
	/// the vertex array object - used if activated
	VAO _vao;
    /// the management for classwide vao
    static VAO[size_t] _classwideVAO;
    /// the mode in wich the class will run the vao in
    VAOMode _vaoMode = VAOMode.unspecified;

    /// the detail level
    int _detailLevel = 25; // imagine everything is a map
    
}
