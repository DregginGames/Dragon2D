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
        screenResolution = 0;
        screenResolution.x = to!int(Settings.get("res.x")); 
        screenResolution.y = to!int(Settings.get("res.y"));
        isFullscreen = to!bool(Settings.get("window.fullscreen"));
        title = Settings.get("window.title");
        
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
        //TODO: gl version based on config? is that needed?
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
       
        //trying if the window can be created is a little ugly
        window = windowCreate();   
        if (window is null) {
            log("Forcing color depth to 16 bits");
            //most likely the color depth shit. Try 16 bits
            SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
            window = windowCreate();
            if(window is null) {
                log("Forcing windowed mode");
                //dont give up hope yet! force windowed mode
                isFullscreen = false;
                window = windowCreate();
                if(window is null) {
                    log("Sorry i messed up the window creation :(");
                    //ok we messed up
                    throw new InitializationErrorException("Could not create window!");
                }
            }
        }
        
        //make the context 
        context = SDL_GL_CreateContext(window);
        if (!context) {
            //this is fatal
            throw new InitializationErrorException("Could not create context");
        }
        //reload opengl for all extensions etc. 
        DerelictGL3.reload();
        //vsync 
        SDL_GL_SetSwapInterval(to!uint(Settings.get("window.vsync")));

        log("Dont Video init");

        //if we survived until here, its time for audio, font and image! (the sdl media stuff)
        //audio 
        uint flags = MIX_INIT_OGG | MIX_INIT_MP3;
        if (Mix_Init(flags) != flags) {
            //meh we messed up 
            log("Cannot init auio!");
            log(fromStringz(Mix_GetError()));
            throw new InitializationErrorException("Could not init audio");
        }
        //FIXME: really put this in a config?
        Mix_AllocateChannels(to!int(Settings.get("audio.channels")));
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
        SDL_GL_DeleteContext(context);
        SDL_DestroyWindow(window);
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

    /// first reder that is called and does something. clean the screen!
    override void render()
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    /**
      Should be the last post-render that is called and swaps all buffers.
     */
    override void postRender()
    {
        // swap buffers
        SDL_GL_SwapWindow(window);
    }   
     

private:
    //System basic stuff 
    /// the window
    SDL_Window* window;
    /// the opengl context
    SDL_GLContext   context;
    //more specific things (window title, resolution)
    
    /// the resolution of the screen (/render context/window/...)
    vec2i   screenResolution;
    /// if the engine runs in fullscreen mode
    bool    isFullscreen;
    /// title of the engine window
    string  title;

    /// windowCreate is a helper that creates a window based on the settings. Used to reduce code duplication
    SDL_Window* windowCreate() 
    {
        return SDL_CreateWindow(toStringz(title), 
                SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 
                screenResolution.x, screenResolution.y, 
                SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | (isFullscreen ? SDL_WINDOW_FULLSCREEN : 0)
                );
    }
}
