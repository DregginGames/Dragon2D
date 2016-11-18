/**
    The d2d.engine module conains the absoute basesystem of the Draon2D engine.
*/
module d2d.engine;

import std.datetime;

// pollute all the namespace
// usually we dont, but importing engine should enforce this once again. we need all classes to be compiled into the final binary
public import d2d; 

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
        root = new Root() // container. engine is not root - this is intended.
            .addChild(new Env() // env - we need to live some where
                .addChild(new IOTransformer()) // sld->d2d events
				.addChild(new Scheduler()) // anyone use this
                .addChild(new World()) // world rendering (maps etc) 
                .addChild(new EntityCollisionTester()) // collision tests 
                .addChild(gamecontainer)) // game below here 
				.addChild(new Renderer()); // rendering
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
        import core.memory; // for gc
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
                long preUpdate = Clock.currStdTime();
                root.propagateUpdate(ticksize);
                double updateTime = cast(double)(Clock.currStdTime()-preUpdate)/10000000.00;
                curtime += ticksize;

                // force garbage collection after every tick   
                long preGC = Clock.currStdTime();
                GC.collect();
                double gcTime = cast(double)(Clock.currStdTime()-preGC)/10000000.00;
                
                if ((gcTime+updateTime) >= 0.8*(ticksize/10000000.00)) {
                    Logger.log("LONG TICK WARNING: GC(" ~ to!string(gcTime) ~ ") - UPDATE(" ~ to!string(updateTime) ~ ")");
                }
            }

            //render always (frame rate limits this). Basically allocates the time for the ticks.
            root.propagateRender();
        }

        // and enforce cleanup
        root = null;
        Resource.freeAll();
        GC.collect();

        Logger.log("Exitted mainloop!"); 
    }

private:
    
    /// ticksize is length of a tick i hnsecs (100 ns). We use ~30 ticks per second.
    immutable long ticksize = 10000000/30;

    /// the engine root object
    Root root;
}
