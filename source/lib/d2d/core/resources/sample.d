/**
    Holds the sample resource
*/
module d2d.core.resources.sample;

import d2d.core.resource;
import d2d.util.fileio;
import d2d.util.logger;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;

/// Encapsulates an MIX_Chunk
class Sample : Resource
{
    /// Creates an Mix_Chunk from the resource name
    this (string name) 
    {
        auto fresource = FileResource.getFileResource(name);
        if (!fresource.invalid) {
            import std.string; // for toStringz
            _chunk = Mix_LoadWAV(toStringz(fresource.file));
            if (_chunk is null) {
                Logger.log("Could not load sample file " ~ fresource.file ~ " for " ~ name ~ " - " ~ fromStringz(Mix_GetError()));
            }
        } else {
            Logger.log("Could not load font "~ name);
        }

        super(name);
    }

    /// The sdl Mix_Chunk 
    @property Mix_Chunk* chunk()
    {
        return _chunk;
    }

    /// Cleanup
    ~this()
    {
        if(_chunk != null) {
            Mix_FreeChunk(_chunk);
        }
    }

private:
    /// An SDL2_MIXER internal MixChunk. See SDL2_MIXER documentation
    Mix_Chunk* _chunk;
}