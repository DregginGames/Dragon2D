/**
	Simple renderables for rendering quads on screen
*/
module d2d.core.render.objects.quad;

import gl3n.linalg;
import derelict.opengl3.gl3;

import d2d.core.render.view;
import d2d.core.render.util;
import d2d.core.render.renderable;
import d2d.core.resources.texture;
import d2d.core.resources.glprogram;
import d2d.core.resource;
/**
	A simple textured quad
*/
class TexturedQuad : Renderable
{
	this(string texture, string program="shader.default")
	{
		// we dont store the resources, we just get them. allows reloading on demand etc. 
		_texture = texture;
		_program = program;
		Resource.preload!Texture(_texture);
		Resource.preload!GLProgram(_program);
		
		vec4[] vertices;
		vec2[] uvs;
		genUVMappedVertexArray(vertices, uvs);
 		
		_bindVAO();
		glGenBuffers(1, &_vertexVBO);
		glGenBuffers(1, &_uvVBO);
		// set vao data for the vertices
		glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
		glBufferData(GL_ARRAY_BUFFER, vec4.sizeof*vertices.length, vertices.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, cast(const void*)0);
        glEnableVertexAttribArray(0);
		// set vao data for the uv mapping
		glBindBuffer(GL_ARRAY_BUFFER, _uvVBO);
		glBufferData(GL_ARRAY_BUFFER, vec2.sizeof*uvs.length, uvs.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, cast(const void*)0);
        glEnableVertexAttribArray(1);

		glBindBuffer(GL_ARRAY_BUFFER, 0);
		_unbindVAO();
	}

	~this()
	{
		glDeleteBuffers(1, &_vertexVBO);
		glDeleteBuffers(1, &_uvVBO);
		Resource.free(_texture);
		Resource.free(_program);

	}
	override void render(ref View view)
	{
		auto tex = Resource.create!Texture(_texture);
		auto prg = Resource.create!GLProgram(_program);
		prg.bind();
		auto m = gen2DModelToWorld(_pos, _rotation, _size);
        auto mvp = m*view.worldToView;
        prg.setUniformValue("MVP", mvp.value_ptr);
		auto texid = tex.texid;
		prg.setUniformValue("textureSampler", &texid);

		//actually render 
		_bindVAO();
		glDrawArrays(GL_TRIANGLES, 0, 6);
		_unbindVAO();
		//somethin somethin might be needed dont know still in concept
		super.render(view);
	}

private:
	/// this quads program
	string _program;
	/// this quads texture
	string _texture;
	/// the position of this quad.
	vec2	_pos = 0;
	/// the size of this quad
	float	_size = 1.0f;
	/// the rotation of this quad (around z!)
	float	_rotation = 0.0f;
	/// the vbo for the vertices
	GLuint  _vertexVBO;
	/// the vbo for the uv mapping
	GLuint	_uvVBO;
}