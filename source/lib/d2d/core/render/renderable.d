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
	/// Creates a renderable. MUST be called first in child constructor in case that is somehow fucked up and needs to be done manually. 
	this()
	{
		glGenVertexArrays(1, &_vao);
        
	}

	/// Cleanup
	~this()
	{
		glDeleteVertexArrays(1, &_vao);
        
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
	/// binds the this objects vao
	void _bindVAO()
	{
		GLuint boundVAO = 0;
		glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast(int*)&boundVAO);
		if (boundVAO != _vao) {
			glBindVertexArray(_vao);
		}
		_vaoStored = boundVAO;
	}

	/// unbinds this objects vao
	void _unbindVAO()
	{
		if (_vaoStored != _vao) {
			glBindVertexArray(_vaoStored);
			_vaoStored = 0;
		}
	}

private:
	/// the vertex array object
	GLuint _vao;
	/// the stored VAO for binding
	GLuint _vaoStored;
    /// the detail level
    int _detailLevel = 25; // imagine everything is a map

}
