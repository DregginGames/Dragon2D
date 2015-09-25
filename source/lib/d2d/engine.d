/**
    The d2d.engine module conains the absoute basesystem of the Draon2D engine.
*/
module d2d.engine;

import std.datetime;

import d2d.util.logger;
import d2d.util.settings;
import d2d.core.callback;
import d2d.core.container.root;
import d2d.core.container.gamecontainer;
import d2d.core.io;
import d2d.system.env;
import d2d.core.services.scheduler;
import d2d.core.render.renderer;

/// The engine class loads the basic system. Also the main loop lives here
class Engine  
{
    
    /// Loads the settings and the root element and populates it with the base system classes 
	/// StartupCallback is called in the last stage before the mainloop and its Object Parameter is the gamecontainer.
    this(char[][] args, ObjectCallback startupCallback) 
    {
        Settings.init(args);
        Logger.init(Settings.get("logfile").str);

        Logger.log("Engine startup...");
        auto gamecontainer = new GameContainer();
        root = new Root()
            .addChild(new Env()
                .addChild(new IOTransformer())
				.addChild(new Scheduler())
                .addChild(gamecontainer))
				.addChild(new Renderer());
        Logger.log("Engine started!");

		if (!startupCallback(gamecontainer)) {
			Logger.log("Startup failed!");
			Logger.log("Trying to run the engine, though the state may already be corrupted.");
		} else {
			Logger.log("Startup successfull!");
		}
    }

    /// 
    ~this()
    {
        Logger.log("Engine shutdown!");
    }

    /// Holds the mainloop. Renders every frame, updates every tick. 
    void run()
    {   
        Logger.log("Reached mainloop!");
        
        // this... clock will be used for the gameloops ticking. 
        long curtime = Clock.currStdTime();
        
        //execptions that escape the mainloop are... critical. 
        scope(failure) Logger.log("CRITICAL FAILURE - EXCEPTION");

        while (root.alive) {
			import std.stdio;
            //only update every tick
            while ( Clock.currStdTime() - curtime >= ticksize) {
				root.preTickDelete();
                root.propagateUpdate();
                curtime += ticksize;
            }

            //render always (frame rate limits this). Basically allocates the time for the ticks.
            root.propagateRender();
        }

		// propagate the deletion event becase then the exit is cleaner: all services are removed
		root.setDeleted();

        Logger.log("Exitted mainloop!");  
    }

private:
    
    /// ticksize is length of a tick i hnsecs (100 ns). We use ~30 ticks per second.
    immutable long ticksize = 10000000/30;

    /// the engine root object
    Root root;
}
