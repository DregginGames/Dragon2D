/**
	Simple renderables for rendering quads on screen
*/
module d2d.core.render.objects.quad;

import gl3n.linalg;
import derelict.opengl3.gl3;

import d2d.core;

/**
    Baseclass for all quads
*/
abstract class Quad : Renderable
{
    this(string program="shader.default")
    {
        _setupVAO(Renderable.VAOMode.classScope);
        _program = program;
        Resource.preload!GLSLProgram(_program); 
    }

    ~this()
    {
        Resource.free(_program);
    }

    /// The program of this quad
    @property GLSLProgram program()
    {
        return Resource.create!GLSLProgram(_program);
    }

protected:
    override void _vboInitClassScope()
    {
        vec4[] vertices;
		vec2[] uvs;
		genUVMappedVertexArray(vertices, uvs);

        Buffer vertex = new Buffer();
        vertex.setData(vertices.ptr, vec4.sizeof*vertices.length);
        vao.attatchBuffer(0,vertex,4);
    }
private:
    string _program;
}

/**
    A simple single colored 
*/
class ColoredQuad : Quad
{
    this(string program="shader.color")
    {
        super(program);
    }

    this(vec4 color, string program="shader.color")
    {
        this(program);
        _color = color;
    }

    override void render(in View view) 
    {
        auto prg = this.program.program;
		prg.bind();
        vao.bind();
		auto m = _standardModelToWorld();
        auto mvp = view.worldToView*m;
        prg.setUniformValueMatrixWorkaround("MVP", mvp);
        prg.setUniformValue("color", _color.value_ptr);
        prg.drawArrays(prg.DrawMode.triangles, 0,6);
    }

    /// The color of the quad
    @property vec4 color() const
    {
        return _color;
    }
    @property vec4 color(vec4 c)
    {
        return _color = c;
    }

private:
    vec4 _color = 0.0f;
}

/**
	A simple textured quad
*/
class RawTexturedQuad : Quad
{
	this(string program="shader.default")
	{
        super(program);       
	}

	override void render(in View view)
	{
		auto prg = this.program.program;
		prg.bind();
        vao.bind();
		auto m = _standardModelToWorld();
        auto mvp = view.worldToView*m;
        prg.setUniformValueMatrixWorkaround("MVP", mvp);
        prg.setUniformValue("uvpos", _uvpos.value_ptr);
        prg.setUniformValue("uvsize", _uvsize.value_ptr);

        _tex.bind();
        int texPos = 0;
        prg.setUniformValue("textureSampler", &texPos);
        
        prg.drawArrays(prg.DrawMode.triangles, _drawOffset.x,_drawOffset.y); //we use a vector for the offset, x is position, y is length in this case
        
		//somethin somethin might be needed dont know still in concept
		super.render(view);
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
    }

protected:
    /// Fills the UV- and Vertex buffers with thier Data. 
    override void _vboInitClassScope()
    {
        vec4[] vertices;
		vec2[] uvs;
		genUVMappedVertexArray(vertices, uvs);

        Buffer vertex = new Buffer();
        Buffer uv = new Buffer();
        vertex.setData(vertices.ptr, vec4.sizeof*vertices.length);
        uv.setData(uvs.ptr, vec2.sizeof*uvs.length);
        vao.attatchBuffer(0,vertex,4);
        vao.attatchBuffer(1,uv,2);
    }

private:
    /// this quads texture
    GPUTexture _tex;
    /// the uv-offset
    vec2 _uvpos = vec2(0.0f,0.0f);
    vec2 _uvsize = vec2(1.0f,1.0f);

protected:
    /// Offset for the draw call. For RawTexture defaults to 0,6 - the stuff needed for a square
    vec2i _drawOffset = vec2i(0,6);
}

class TexturedQuad : RawTexturedQuad
{
    this(string texture, string program="shader.default")
    {
        _texture = texture;
        Resource.preload!Texture(_texture);
        super(program);
    }

    override void render(in View view) 
    {
        auto tex = Resource.create!Texture(_texture);
        this.texture=tex.gpuTexture;
        super.render(view);
    }

    ~this()
    {
        Resource.free(_texture);
    }

    @property string texname()
    {
        return _texture;
    }

    @property string texname(string name)
    {
        if (name == _texture) {
            return _texture;
        }
        Resource.free(_texture);
        Resource.preload!Texture(name);
        return _texture = name;
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
        _setupVAO(Renderable.VAOMode.objectScope);
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
        _updateBuffers();
    }

protected:
    override void _vboInit()
    {
        _vertexBuffer = new Buffer();
        _uvBuffer = new Buffer();
        
        _updateBuffers();

        vao.attatchBuffer(0,_vertexBuffer,4);
        vao.attatchBuffer(1,_uvBuffer,2);
    }

    void _updateBuffers()
    {
        if( 0 == _quads.length) { //we are empty? we are lazy.
            return; 
        }
        vec4[] vertices;
		vec2[] uvs;

        foreach(ref q; _quads) {
            genUVMappedVertexArray(vertices, uvs, q.pos, q.uvpos, q.uvsize,q.size);
        }
        _vertexBuffer.setData(vertices.ptr, vec4.sizeof*vertices.length);
        _uvBuffer.setData(uvs.ptr, vec2.sizeof*uvs.length);

        _drawOffset = vec2i(0,cast(int)vertices.length);
    }
private:
    ulong _maxQuadId = 0;
    BatchQuad[ulong] _quads;
    Buffer _vertexBuffer;
    Buffer _uvBuffer;

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
    vec2    size = vec2(1.0,1.0); // cause thats nice and all
    vec2    uvpos;
    vec2    uvsize;
}
