/**
    Holds a font resource
*/

module d2d.core.resources.font;

import d2d.core.resource;
import d2d.util.fileio;
import d2d.util.logger;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

/// This is the resource for loaded fonts
class Font : Resource
{

    //Some possible font sizes
    enum FontSize {
        small = 16,
        medium = 32,
        big = 64,
        huge = 128,
        humongus = 256
    }

    this (string name) 
    {
        auto fresource = FileResource.getFileResource(name);
        if (!fresource.invalid) {
            import std.string; // for toStringz
            _font[FontSize.medium] = TTF_OpenFont(toStringz(fresource.file), FontSize.medium);
            if (_font[FontSize.medium] is null) {
                Logger.log("Could not load font " ~ fresource.file ~ " for " ~ name ~ " - " ~ fromStringz(TTF_GetError()));
            } else {
                _font[FontSize.small] = TTF_OpenFont(toStringz(fresource.file), FontSize.small);
                _font[FontSize.big] = TTF_OpenFont(toStringz(fresource.file), FontSize.big);
                _font[FontSize.huge] = TTF_OpenFont(toStringz(fresource.file), FontSize.huge);
                _font[FontSize.humongus] = TTF_OpenFont(toStringz(fresource.file), FontSize.humongus);
                //yay i guess?
            }
        } else {
            Logger.log("Could not load font "~ name);
        }

        super(name);
    }

    ~this()
    {
        foreach(ref f; _font) {
            TTF_CloseFont(f);
        }
    }

private:
    TTF_Font*[uint] _font;
}