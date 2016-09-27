/** 
  d2d.core.resources.texture holds the texture resource types 
  */
module d2d.core.resources.texture;

import gl3n.linalg;

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
                _res = vec2i(surface.w,surface.h);
                _tex = new GPUTexture(surface, true);
            }
        } else {
            Logger.log("Could not load texture " ~ name);
        }
        super(name);
    }

    /** 
       Maps an input positoin and size to be a square wichs
       edges will not sample outside of the uv bounds that 
       were given by the input. 
       This is achieved by mapping the edge positions to the 
       center of the pixels that they include. 

       Usefull for texture atlases in tilesets etc. 
    */
    void toPixelCenter(ref vec2 pos, ref vec2 size)
    {
        import std.math;
        double pixelx = (1.0/cast(double)_res.x);   
        double pixely = (1.0/cast(double)_res.y);
        pos = vec2( floor(pos.x/pixelx)*pixelx+pixelx*0.5,
                    floor(pos.y/pixely)*pixely+pixely*0.5);
        size = size+pos;
        size = vec2(floor(size.x/pixelx)*pixelx-pixelx*0.5,
                    floor(size.y/pixely)*pixely-pixely*0.5);
        size = size-pos;
    }

    @property GPUTexture gpuTexture()
    {
        return _tex;
    }   

    @property vec2i resolution()
    {
        return _res;
    }
private:
    /// the id of the texture
    GPUTexture _tex;
    /// the resolution of the texture
    vec2i      _res;
}
