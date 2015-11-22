/**
    Contains the abstraction for gls textures
*/
module d2d.core.render.lowlevel.gputexture;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import derelict.sdl2.image;

import d2d.util.logger;

/// Helper function to create a  Opengl Texture from an SDL_Surface 
private GLuint SurfaceToTexture(SDL_Surface* surface)
{
    ///juuust to make shure
    if (surface is null) {
        return 0;
    }
    GLenum textureFormat = GL_BGR;
    GLenum internalFormat = GL_RGB8;
    if (surface.format.BytesPerPixel == 4) {
        if(surface.format.Rmask == 0x000000ff) {
            textureFormat = GL_RGBA;
        }
        else {
            textureFormat = GL_BGRA;
        }
        internalFormat = GL_RGBA8;
    } else {
        if(surface.format.Rmask == 0x000000ff) {
            textureFormat = GL_RGB;
        }
        else {
            textureFormat = GL_BGR;
        }
        internalFormat = GL_RGB8;
    }

    GLuint texId = 0;
    glGenTextures(1, &texId);
    //not good but might happen 
    if (texId == 0) {
        Logger.log("Texture generation (from sdl surface) failed.");
        return 0;
    }
    glBindTexture(GL_TEXTURE_2D, texId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, surface.w, surface.h, 0, textureFormat, GL_UNSIGNED_BYTE, surface.pixels);
    return texId;
}

/// Simple wrapper for GLuint that automatically calls glDeleteTextures - avoids nasty leeks   TODO: texture from raw data?
class GPUTexture
{
    /// The abstraction for the opengl texture target. cause fuck you, thats why.
    enum TextureTarget {
        simple1D = GL_TEXTURE_1D,
        simple2D = GL_TEXTURE_2D,
        simple3D = GL_TEXTURE_3D,
        rectangle = GL_TEXTURE_RECTANGLE,
        buffer = GL_TEXTURE_BUFFER,
        cubeMap = GL_TEXTURE_CUBE_MAP,
        array1D = GL_TEXTURE_1D_ARRAY,
        array2D = GL_TEXTURE_2D_ARRAY,
        cubeMapArray = GL_TEXTURE_CUBE_MAP_ARRAY,
        multisample2D = GL_TEXTURE_2D_MULTISAMPLE,
        multisampleArray = GL_TEXTURE_2D_MULTISAMPLE_ARRAY
    }

    /// Creates a GPUTexture
    this(TextureTarget target = TextureTarget.simple2D) 
    {
        glGenTextures(1,&_texId);
        target = target;
    }

    /// Takes over the management of a raw texture. Dangerous thingy this is
    this(GLuint texId,TextureTarget target = TextureTarget.simple2D) 
    {
        _texId = texId;
        _target = target;
    }

    /// Creates a GPU Texture from an SDL_Surface. If free is true, it will also automatically free the SDL Texture
    this(SDL_Surface* surface, bool free=false) 
    {
        _target = TextureTarget.simple2D;
        _texId = SurfaceToTexture(surface);
        if (free) {
            SDL_FreeSurface(surface);
        }
    }

    /// destroy them texture
    ~this()
    {
        if (_texId != 0) {
            glDeleteTextures(1,&_texId);
            auto b = _target in _currTexBinding;
            if (b && *b == _texId) {
                _currTexBinding[_target] = 0;
            }
        }
    }

    ///Only gets the ID. The id cant be changed after creation
    @property GLuint id() {
        return _texId;
    }

    /// Binds texture if not already bound.
    void bind(uint unit = 0)
    {
        auto b = _target in _currTexBinding;
        if (b) {
            if(*b!=0 && *b==_texId) {
                return;
            }
        }
        if (_currTextureUnit!=unit) {
            glActiveTexture(GL_TEXTURE0+unit);
            _currTextureUnit = unit;
        }
        glBindTexture(_target,_texId);
        _currTexBinding[_target] = _texId;
    }

    private:
        GLuint _texId;
        TextureTarget _target;
        static uint _currTextureUnit = 0;
        static GLuint[TextureTarget] _currTexBinding;
    }