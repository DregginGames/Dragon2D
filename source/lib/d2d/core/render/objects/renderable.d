/**
	d2d.core.render.renderable holds the base classes for object rendering. 
*/
module d2d.core.render.objects.renderable;

import gl3n.linalg;
import gl3n.math;
import derelict.opengl3.gl3;

import d2d.util.logger;
import d2d.core;

/**
	Renderable is abstract base for all types of /renderables/. 
	A Renderable is an object that actually is renderd on screen, like a circle, a textured quad, a tile map, ....
	Its one of the few structures that life outside the Base-class hirarchy
    
    An importand concept of Renderables is the detail level. The higher this level is, the higher the level of the View needs to be to be able to see this object. 
    Here is a reccomendation for the detail levels:
        00..19: Application-level - always-visible-background things. Probably covered by everything.
        20..39: Map-level - map-baisc stuff like terrain
        40..59: Map-detail-level - advaned stuff like Buildings, details, flowers, ... 
        60..79: Actor-level - everything that actually does things like NPCs, players, ...
        80..89: Overlay-level: everything that should over. Effects, treetips, stuff like that, ...
        90+: UI-Level - the user interface. Above that... whatever 
    
    Detail levels also function as z offsets - higher level means rendered later-> on top
 
*/
abstract class Renderable
{
    /// The Mode in wich a VAO is "run".
    enum VAOMode {
        unspecified = 0, /// default. equals none in behaviour, but makes a cleaner case for "my parent class will manage this"
        none = 1,   /// no vao at all. usefull for more abstract thigs (like text wich onlly utilizes other things
        classScope = 2,  /// usefull for basically everything "simple" - primitives
        objectScope = 3, // /every object has its own vao. usefull for batches, complex models, ....
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
	void render(in View view)
	{
	}

	@property VAO vao()
	{
        switch(_vaoMode) {
            case VAOMode.classScope:
                return _classwideVAO[typeid(this).toHash()];
            case VAOMode.objectScope:
                return _vao;
            default:
                break;
        }
		throw new Exception("Can't access an VAO of an renderable in unspecified or none mode!");
        assert(0);
	}

    /// The detail Level. The higher this level is, the higher the level of a view needs to be to see this object
    @property int detailLevel() const
    {
        return _detailLevel;
    }
    /// Ditto
    @property int detailLevel(int l)
    {
        return _detailLevel = l;
    }

    /// The position of this renderable in world-coordinates
    @property vec2 pos() const
    {
        return _pos;
    }
    /// Ditto
    @property vec2 pos(vec2 p)
    {
        return _pos=p;
    }

    /// The scale of this renderable in world-coordinates
    @property vec3 scale() const
    {
        return _scale;
    }
    /// Ditto
    @property vec3 scale(vec3 s)
    {
        return _scale=s;
    }

    /// The rotation of the renderable (around z axis)
    @property float rotation() const
    {
        return _rotation;
    }
    /// Ditto
    @property float rotation(float r)
    {
        return _rotation = r;
    }

    /**
        Renderables can be set to ignore the effects of views (other than viewport), making, for them, -1..1 direkt mapping of screen space. 
        This can be usefull for the user interface, debug text, things that should annoy people, generally everything you dont want to use in world but in screen coordinates
    */
    @property bool ignoreView() const
    {
        return _ignoreView;
    }
    /// Ditto 
    @property bool ignoreView(bool b) 
    {
        return _ignoreView = true;
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
                case VAOMode.classScope:
                    auto p = typeid(this).toHash() in _classwideVAO;
                    if (!p) {
                        _classwideVAO[typeid(this).toHash()] = new VAO;
                        _vboInitClassScope();
                    }
                    break;
                case VAOMode.objectScope:
                    _vao = new VAO();
                    _vboInit();
                    break;
                default:
                    break;
            }
        }
    }

    /// Called by setupVAO if the mode fór VBO is objectScope
    void _vboInit()
    {
    }

    /// Called by setupVAO if the mode for VBO is classScope
    /// Note: Not static because needs access to this for the call to this.vao
    void _vboInitClassScope()
    {
    }

    /// Returns the model to world matrix for the combination of position, scale and rotation
    final mat4 _standardModelToWorld() const
    {
        return gen2DModelToWorld(_pos, _rotation, _scale);
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
    
    /// the position of the renderable
    vec2 _pos = 0;
    /// the scale of the renderable
    vec3 _scale = 1.0f;
    /// the rotation of the renderable (around z - were 2d!)
    float _rotation=0.0f;

    /// if the object ignoers the transformation of views 
    bool _ignoreView;
}
