/**
    d2d.system.env holds the enviourment of D2D - opengl, sdl, sound system and all this stuff get insitialized by the env class. 
  */
module d2d.system.env;

import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.sdl2.ttf;
import derelict.opengl3.gl3;

import gl3n.linalg;

import d2d.core.base;
import d2d.core.event;
import d2d.util.logger;
import d2d.util.settings;
import d2d.util.fileio;
alias log = Logger.log;

// on Posix based systems we need the dl library. Dont use linker flag cause that sucks 
version(Posix) {
    pragma(lib, "dl");
}

/**
    This Exception is thrown in case of an initialization error in early initialization (base systems like sdl, opengl, ...)
  */
class InitializationErrorException : Exception
{
    /// ctor
    this(string err)
    {
        super(err);
    }
}

/**
    Env Manages the "env" - that means all basic librarys. that includes the SDL subfoo, opengl, ... 
  */
class Env : Base
{
    this()
    {
        try {
            //Load the shared librarys
            DerelictSDL2.load();
            DerelictSDL2Image.load();
            DerelictSDL2Mixer.load();
            DerelictSDL2ttf.load();
            DerelictGL3.load();
        } catch(Exception e) {
            log("Could not load all required libraries. Are you shure that you have the needed .dll or .so files installed*");
            throw e;
        }

        //The setting should have loaded the configs at the initialization 
        //read all the basic stuff
        _resolution = 0;
        _resolution.x = cast(int) Settings["window"].object["width"].integer; 
        _resolution.y = cast(int) Settings["window"].object["height"].integer;
		_aspectRatio = to!float(_resolution.x) / to!float(_resolution.y);
        _fullscreen = Settings["window"].object["fullscreen"].integer != 0;
        _title = Settings["title"].str;
        
        //Init base systems
        int sdlSuccess = SDL_Init(SDL_INIT_EVERYTHING);
        if (sdlSuccess != 0) {
           auto err = SDL_GetError(); 
           log("Could not load SDL");
           throw new InitializationErrorException(fromStringz(err).idup);
        }
        log("Done SDL init");
        
        //set the gl specific settings. 
        //also try out some settings because not everything works every time
        //TODO: gl version based on config? is that needed? NOO! Because will just use gl es
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
       
        //trying if the window can be created is a little ugly
        _window = windowCreate();   
        if (_window is null) {
            log("Forcing color depth to 16 bits");
            //most likely the color depth shit. Try 16 bits
            SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
            _window = windowCreate();
            if(_window is null) {
                log("Forcing windowed mode");
                //dont give up hope yet! force windowed mode
                _fullscreen = false;
                _window = windowCreate();
                if(_window is null) {
                    log("Sorry i messed up the window creation :(");
                    //ok we messed up
                    throw new InitializationErrorException("Could not create window!");
                }
            }
        }

        //make the context 
        _context = SDL_GL_CreateContext(_window);
        if (!_context) {
            //this is fatal
            throw new InitializationErrorException("Could not create context");
        }
        //reload opengl for all extensions etc. 
        DerelictGL3.reload();
        //vsync 
        SDL_GL_SetSwapInterval(cast(int) Settings["window"].object["vsync"].integer);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        log("Dont Video init");
        

        //if we survived until here, its time for audio, font and image! (the sdl media stuff)
        //audio 
        uint flags = MIX_INIT_OGG | MIX_INIT_MP3;
        uint actualFlags = Mix_Init(flags);
        if (actualFlags != flags) {
            //meh we messed up 
            log("Cannot init auio!");
            log(fromStringz(Mix_GetError()));
            log("Will try OGG-only mode, but that WILL break things");
            if (actualFlags&MIX_INIT_OGG) {
                log("Ok, that worked. Still nothing sound related is good...");
            } else {
                throw new InitializationErrorException("Could not init audio!");
            }
        }
        if (Mix_OpenAudio(44100 , MIX_DEFAULT_FORMAT, 2, 1024) != 0) {
            log("Cannot Open Audio:");
            log(fromStringz(Mix_GetError()));
            throw new InitializationErrorException("Could not init audio!");
        }
        //FIXME: really put this in a config?
        Mix_AllocateChannels(cast(int) Settings["audio"].object["channels"].integer);
        log("Done Audio init");
        
        //sdl image
        flags = IMG_INIT_PNG | IMG_INIT_JPG;
        if (IMG_Init(flags) != flags) {
            //again, we messed up
            log("Cannot init image!");
            log(fromStringz(IMG_GetError()));
            throw new InitializationErrorException("Could not init img");
        }
        log("Done Image init");

        //sdl ttf
        if (TTF_Init() != 0) {
            //we got til here aaand still messed up
            log("Cannot init font!");
            log(fromStringz(TTF_GetError()));
            throw new InitializationErrorException("Could not init font");
        }
        log("Done Font init");

		registerAsService("d2d.env");
        //we are done here!
    }   

    ~this()
    {
        //gotta kill em all
        TTF_Quit();
        IMG_Quit();
        Mix_Quit();
        SDL_GL_DeleteContext(_context);
        SDL_DestroyWindow(_window);
        SDL_Quit();
    }   

    /// Env update only polls the events (and refieres them)
    override void update()
    {
		import std.stdio; 
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            SDLEvent event = new SDLEvent(e);
            fireEvent(event);

            //FIXME: this is ugly and only for debug
            if(e.type==SDL_QUIT) {
                fireEvent( new KillEngineEvent );
            }
        }
    }

    /**
      Should be the last post-render that is called and swaps all buffers.
     */
    override void postRender()
    {
        // swap buffers.
		// doesnt belong into the render because reasons. 
        SDL_GL_SwapWindow(_window);
    }   
    
	/// returns the resolution of the screen
	final @property vec2i resolution() const
	{
		return _resolution;
	}

	/// returns the aspect ratio of the window
	final @property float aspectRatio() const
	{
		return _aspectRatio;
	}
    
    /// returns the title of the engine window
	final @property string title() const
	{
		return _title;
	}

    /**
    If the mouse cursor shall be displayed. 
    */
    final @property bool cursor() const
    {
        return SDL_ShowCursor(-1)==1;
    }
    /// Ditto
    final @property bool cursor(bool b)
    {
        return SDL_ShowCursor(b ? 1 : 0)==1;
    }

private:
    //System basic stuff 
    /// the window
    SDL_Window*		_window;
    /// the opengl context
    SDL_GLContext   _context;
    //more specific things (window title, resolution)
    
    /// the resolution of the screen (/render context/window/...)
    vec2i   _resolution;
	/// the aspect ration of the screen (calculated once)
	float	_aspectRatio;

    /// if the engine runs in fullscreen mode
    bool    _fullscreen;
    /// title of the engine window
    string  _title;

    /// windowCreate is a helper that creates a window based on the settings. Used to reduce code duplication
    SDL_Window* windowCreate() 
    {
        return SDL_CreateWindow(toStringz(_title), 
                SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 
                _resolution.x, _resolution.y, 
                SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | (_fullscreen ? SDL_WINDOW_FULLSCREEN : 0)
                );
    }
}
