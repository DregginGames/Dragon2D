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
class RawTexturedQuad : Renderable
{
	this(string program="shader.default")
	{
		// we dont store the resources, we just get them. allows reloading on demand etc. 
		_program = program;
		Resource.preload!GLProgram(_program); 
        auto prg = Resource.create!GLProgram(_program);
        auto posAttr = prg.getAttribute("in_pos");
        auto uvAttr = prg.getAttribute("in_uv");

		_bindVAO();
		glGenBuffers(1, &_vertexVBO);
		glGenBuffers(1, &_uvVBO);       
        _setVBO();

         glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
		glVertexAttribPointer(posAttr, 4, GL_FLOAT, GL_FALSE, 0, cast(const void*)0);
       

        glEnableVertexAttribArray(1);
        glBindBuffer(GL_ARRAY_BUFFER, _uvVBO);
		glVertexAttribPointer(uvAttr, 2, GL_FLOAT, GL_FALSE, 0, cast(const void*)0);
        

		glBindBuffer(GL_ARRAY_BUFFER, 0);
		_unbindVAO();
	}

	~this()
	{
		glDeleteBuffers(1, &_vertexVBO);
		glDeleteBuffers(1, &_uvVBO);
		Resource.free(_program);

	}
	override void render(ref View view)
	{
		auto prg = Resource.create!GLProgram(_program);
		prg.bind();
		auto m = gen2DModelToWorld(_pos, _rotation, _size);
        auto mvp = view.worldToView*m;
        prg.setUniformValue("MVP", mvp.value_ptr);
        //texture voodo
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _tex.id);
        int texPos = 0;
        prg.setUniformValue("textureSampler", &texPos);

		//actually render 
		_bindVAO();
		glDrawArrays(GL_TRIANGLES, 0, 6);
		_unbindVAO();
		//somethin somethin might be needed dont know still in concept
		super.render(view);
	}

    /// Vertices and UVs 
    @property GLuint vertexVBO()
    {
        return _vertexVBO;
    }
    @property GLuint uvVBO()
    {
        return _uvVBO;
    }

    /**
    The position of this quad.    /-- totally not stolen from entity.d
	*/
	@property vec2 pos()
	{
		return _pos;
	}
	@property vec2 pos(vec2 p)
	{
		return _pos = p;
	}

    /**
        The texture of this quad
    */
    @property GPUTexture texture()
    {
        return _tex;
    }
    @property GPUTexture texture(GPUTexture tex)
    {
        return _tex=tex;
    }
        
    /**
        The uv-offset of this quad
    */
    void getUVOffset(out vec2 uvpos, out vec2 uvsize)
    {
        uvpos = _uvpos;
        uvsize = _uvsize;
    }

    void setUVOffset(vec2 uvpos, vec2 uvsize)
    {
        _uvpos = uvpos;
        _uvsize = uvsize;
        _setVBO();
    }

protected:
    /// Fills the UV- and Vertex buffers with thier Data. 
    void _setVBO()
    {
        vec4[] vertices;
		vec2[] uvs;
		genUVMappedVertexArray(vertices, uvs, vec2(0,0), _uvpos, _uvsize);

        glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
		glBufferData(GL_ARRAY_BUFFER, vec4.sizeof*vertices.length, vertices.ptr, GL_STATIC_DRAW);

        glBindBuffer(GL_ARRAY_BUFFER, _uvVBO);
		glBufferData(GL_ARRAY_BUFFER, vec2.sizeof*uvs.length, uvs.ptr, GL_STATIC_DRAW);

        glBindBuffer(GL_ARRAY_BUFFER,  0);
    }
private:
    /// this quads texture
    GPUTexture _tex;
	/// this quads program
	string _program;
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
    /// the uv-offset
    vec2 _uvpos = vec2(0.0f,0.0f);
    vec2 _uvsize = vec2(1.0f,1.0f);
}

class TexturedQuad : RawTexturedQuad
{
    this(string texture, string program="shader.default")
    {
        _texture = texture;
        Resource.preload!Texture(_texture);
        super(program);
    }

    override void render(ref View view) 
    {
        auto tex = Resource.create!Texture(_texture);
        this.texture=tex.gpuTexture;
        super.render(view);
    }

    ~this()
    {
        Resource.free(_texture);
    }
private:
    /// this quads texture
	string _texture;
}

/**
    A batch of textured quads from one texture - a Tileset basically
*/
class TexturedQuadBatch : TexturedQuad
{
    this(string texture, string program="shalder.default")
    {
        super(texture, program);
    }

    /// Adds a new Textured Quad to the set. Changes made here need to be flusehed with flush().
    /// This quad shall not be used by other TexturedQuadBatches
    void addQuad(ref BatchQuad quad)
    {
        updateQuad(quad);
    }

    /// Updates a quad. Changes made here need to be flusehed with flush().
    /// If the quad does not exist its added to the Batch
    void updateQuad(ref BatchQuad quad)
    {
        auto p = quad.id in _quads;
        if (null == p || quad.id == 0) { //quad.id can only be null if it has not beed added to a batch yet. 
            _maxQuadId++;
            quad.id = _maxQuadId;
        } else {
            _quads[quad.id] = quad;
        }
    }

    /// removes a quad. Changes made here need to be flusehed with flush().
    void removeQuad(ref BatchQuad quad)
    {
        _quads.remove(quad.id);
    }

    /// Changes the buffers to reflect the changes made to this Batch
    void flush()
    {
        _setVBO();
    }

protected:
    override void _setVBO()
    {
        if( 0 == _quads.length) { //we are empty? we are lazy.
            return; 
        }
        vec4[] vertices;
		vec2[] uvs;

        foreach(ref q; _quads) {
            genUVMappedVertexArray(vertices, uvs, q.pos, q.uvpos, q.uvsize);
        }
        
        glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
		glBufferData(GL_ARRAY_BUFFER, vec4.sizeof*vertices.length, vertices.ptr, GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, _uvVBO);
		glBufferData(GL_ARRAY_BUFFER, vec2.sizeof*uvs.length, uvs.ptr, GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER,  0);
    }
private:
    ulong _maxQuadId = 0;
    BatchQuad[ulong] _quads;
}

/**
    Helper fpr TexturedQuadBatch
*/
struct BatchQuad
{
    bool opEquals()(auto ref const S s) const
    {
        return _id == s.id;
    }

    ulong   id = 0;
    vec2    pos;
    vec2    uvpos;
    vec2    uvsize;
}