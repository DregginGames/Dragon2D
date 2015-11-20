/**
	d2d.core.render.renderable holds the base classes for object rendering. 
*/
module d2d.core.render.renderable;

import gl3n.linalg;
import gl3n.math;
import derelict.opengl3.gl3;

import d2d.util.logger;
import d2d.core.render.view;

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
	/// Creates a renderable. Does nothing atm.
	this()
	{
		      
	}

	/// Cleanup
	~this()
	{
        if(_useVAO) {
		    glDeleteVertexArrays(1, &_vao);
        }
	}

	/// Performs an actual render on screen. 
	void render(ref View view)
	{
	}

	@property GLuint vao()
	{
		return _vao;
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

    /// Activates the use of a object-specific VAO. Use with caution i guess
    void _enableVAO()
    {
        if(!_useVAO) {
            glGenVertexArrays(1, &_vao);
            _useVAO = true;
        }
    }

    /// Sets a custom VAO WITHOUT activating the VAO state (auto-deletion on destruction). So a class can use classwide VAOs (and buffers etc.) without having to rewrite the _bindVAO and _unbindVAO functions
    void _setUnmanagedVAO(GLuint vao)
    {
        
    }

	/// binds the this objects vao
	void _bindVAO()
	{
        if(_useVAO||_unmanagedVAO) {
		    GLuint boundVAO = 0;
		    glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast(int*)&boundVAO);
		    if (boundVAO != _vao) {
			    glBindVertexArray(_vao);
		    }
		_vaoStored = boundVAO;
        }
	}

	/// unbinds this objects vao
	void _unbindVAO()
	{
        if(_useVAO||_unmanagedVAO) {
		    if (_vaoStored != _vao) {
			    glBindVertexArray(_vaoStored);
			    _vaoStored = 0;
		    }
        }
	}

private:
	/// the vertex array object - used if activated
	GLuint _vao;
    /// if true we will use a VAO for this object. if not we dont care what comes next
    bool _useVAO = false;
    /// enables _bindVAO and other functions possible to be used with a custom-set VAO that is not managed by this class
    bool _unmanagedVAO = false;
	/// the stored VAO for binding and rebinding the last one etc.
	GLuint _vaoStored;
    /// the detail level
    int _detailLevel = 25; // imagine everything is a map
    
}
