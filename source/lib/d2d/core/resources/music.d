/**
Holds the music resource
*/
module d2d.core.resources.music;

import d2d.core.resource;
import d2d.util.fileio;
import d2d.util.logger;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;

/// Encapsulates an Mix_Music
class Music : Resource
{
    /// Creates a Mix_Music from a file
    this (string name) 
    {
        auto fresource = FileResource.getFileResource(name);
        if (!fresource.invalid) {
            import std.string; // for toStringz
            _music = Mix_LoadMUS(toStringz(fresource.file));
            if (_music is null) {
                Logger.log("Could not load music file " ~ fresource.file ~ " for " ~ name ~ " - " ~ fromStringz(Mix_GetError()));
            }
        } else {
            Logger.log("Could not load font "~ name);
        }

        super(name);
    }

    /// Returns the Mix_Music for this resource
    @property Mix_Music* music()
    {
        return _music;
    }

    /// Cleanup
    ~this()
    {
        if(_music != null) {
            Mix_FreeMusic(_music);
        }
    }

private:
    /// The Mix_Music struct. See SDL2_MIXER documentation
    Mix_Music* _music;
}