/**
  d2d.system.script hods the basic classes for script interaction with the engine. 
  */
module d2d.system.script;

import derelict.util.system;
import derelict.util.sharedlib;
import d2d.util.settings;
import d2d.core.base;

static if(Derelict_OS_Windows) {
    private static string libExt = ".dll";
} 
else {
    private static string libExt = ".so";
}

/** script is the abseclass for as scripts. it manages the communication with derelict.util.sharedlib 
  */
class Script
{
    public this(string name)
    {
        // script files always live inside gamedir/scriptbuild 
        //lib = new SharedLib();
        string path = Settings.get("gameDir") ~ "scriptbuild/" ~ name ~ libExt;
        lib.load([path]);     

        // every module must have a run function
        attatchSymbol(cast(void**)&runFunction, "run"); 
        if(runFunction is null) {
            throw new Exception("shit");
        } 
    }

    /// run is a funcion every scrpt should have.
   void Run(Base src) {
        runFunction(src);
   } 
protected:
    /// attaches a symol to a container 
    void attatchSymbol(void**dst, string name) {
        *dst = lib.loadSymbol(name, true);
    }
private:
    /// the loaded lib 
    SharedLib lib;
    

    /// symbol-container-meh for the run function
    void function(Base) runFunction;
}
