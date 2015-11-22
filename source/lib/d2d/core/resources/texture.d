/** 
  d2d.core.resources.texture holds the texture resource types 
  */
module d2d.core.resources.texture;

import d2d.core.resource;
import d2d.util.fileio;
import d2d.util.logger;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import d2d.core.render.lowlevel.gputexture;

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
                _tex = new GPUTexture(surface, true);              
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
