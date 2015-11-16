/** 
  d2d.core.resources.texture holds the texture resource types 
  */
module d2d.core.resources.texture;

import derelict.opengl3.gl3;
import derelict.sdl2.image;
import derelict.sdl2.sdl;

import d2d.core.resource;
import d2d.util.fileio;
import d2d.util.logger;

/// Simple wrapper for GLuint that automatically calls glDeleteTextures - avoids nasty leeks
class GPUTexture
{
    this() 
    {
        glGenTextures(1,&_texId);
    }

    this(GLuint texId) 
    {
        _texId = texId;
    }

    ~this()
    {
        if (_texId != 0) {
            glDeleteTextures(1,&_texId);
        }
    }

    ///Only gets the ID. The id cant be changed after creation
    @property GLuint id() {
        return _texId;
    }


private:
    GLuint _texId;
}

/// Helper function to create a  Opengl Texture from an SDL_Surface 
GLuint SurfaceToTexture(SDL_Surface* surface)
{
    ///juuust to make shure
    if (surface is null) {
        return 0;
    }
    GLenum textureFormat = GL_BGR;
    if (surface.format.BytesPerPixel == 4) {
        if(surface.format.Rmask == 0x000000ff) {
            textureFormat = GL_RGBA;
        }
        else {
            textureFormat = GL_BGRA;
        }
    } else {
        if(surface.format.Rmask == 0x000000ff) {
            textureFormat = GL_RGB;
        }
        else {
            textureFormat = GL_BGR;
        }
    }

    GLuint texId = 0;
    glGenTextures(1, &texId);
    //not good but might happen 
    if (texId == 0) {
        Logger.log("Texture generation failed.");
        return 0;
    }
    glBindTexture(GL_TEXTURE_2D, texId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, surface.w, surface.h, 0, textureFormat, GL_UNSIGNED_BYTE, surface.pixels);
    return texId;
}

/// A simple opengl texture loaded from a file 
class Texture : Resource
{
    /// Loads the texture from a file system resource with sdl_image
    this(string name)
    {
        SDL_Surface* surface;
        auto fresource = FileResource.getFileResource(name);
        if (!fresource.invalid) {
            import std.string; // for toStringz
            surface = IMG_Load(toStringz(fresource.file));
            if (surface is null) {
                Logger.log("Could not load image " ~ fresource.file ~ " for " ~ name ~ " - " ~ fromStringz(IMG_GetError()));
            } else {
                _tex = new GPUTexture(SurfaceToTexture(surface));
                SDL_FreeSurface(surface);
            }
        } else {
            Logger.log("Could not load texture " ~ name);
        }
        super(name);
    }

    @property GPUTexture gpuTexture()
    {
        return _tex;
    }   
private:
    /// the id of the texture
    GPUTexture _tex;
}
