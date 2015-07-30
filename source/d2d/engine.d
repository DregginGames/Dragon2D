/**
    The d2d.engine module conains the absoute basesystem of the Draon2D engine.
*/
module d2d.engine;

import std.datetime;

import d2d.util.logger;
import d2d.util.settings;
import d2d.core.root;
import d2d.system.env;
/// The engine class loads the basic system. Also the main loop lives here
class Engine  
{
    
    /// Loads the settings and the root element and populates it with the base system classes 
    this(char[][] args) 
    {
        Settings.init(args);
        Logger.init(Settings.get("logfile"));

        Logger.log("Engine startup...");
        root = new Root();
        root.addChild(new Env());

        Logger.log("Engine started!");
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

        try {
            while (root.alive) {

                //only update every tick
                if ( Clock.currStdTime() - curtime >= ticksize) {
                    root.propagateUpdate();
                    curtime = Clock.currStdTime();
                }
                
                //render always (frame rate limits this). Basically allocates the time for the ticks.
                root.propagateRender(); 
            }
        }
        catch (Exception e)
        {
            //execptions that escape the mainloop are... critical. 
            Logger.log("CRITICAL FAILURE - EXCEPTION");
            throw e;
        }

        Logger.log("Exitted mainloop!");  
    }

private:
    
    /// ticksize is length if a tick i hnsecs (100 ns). We use 30 ticks per second.
    immutable long ticksize = 10000 / 30;

    /// the engine root object
    Root root;
}
