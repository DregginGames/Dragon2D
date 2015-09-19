/**
	d2d.core.render.renderable holds the base classes for object rendering. 
*/
module d2d.core.render.renderable;

import gl3n.linalg;
import gl3n.math;
import derelict.opengl3.gl3;

import d2d.core.render.view;

/**
	Renderable is abstract base for all types of /renderables/. 
	A Renderable is an object that actually is renderd on screen, like a circle, a textured quad, a tile map, ....
	Its one of the few structures that life outside the Base-class hirarchy

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


}
