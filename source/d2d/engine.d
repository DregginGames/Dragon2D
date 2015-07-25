/**
    The d2d.engine module conains the absoute basesystem of the Draon2D engine.
*/
module d2d.engine;

import d2d.logger;
import d2d.settings;

/// The engine class loads the basic system. Also the main loop lives here
class Engine  
{
    
    /// Loads the settings and the root element and populates it with the base system classes 
    this(char[][] args) 
    {
        Settings.init(args);
        Logger.init(Settings.get("logfile"));

        Logger.log("Engine startup...");

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


        Logger.log("Exitted mainloop!");  
    }

private:
    
}
