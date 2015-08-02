/**
  d2d.system.script hods the basic classes for script interaction with the engine. 
  */
module d2d.system.script;

import derelict.util.system;
import derelict.util.sharedlib;
import d2d.util.settings;
import d2d.core.base;
import d2d.util.logger;

static if(Derelict_OS_Windows) {
    private static string libExt = ".dll";
} 
else {
    private static string libExt = ".so";
}

/// this exeption is thrown in case a script cannot be found
class UnknownScriptException : Exception
{
    // sets the error
    
    public this(string name, string err) 
    {
        super("Cannot load script with the name " ~ name ~ " (" ~ err ~ ") \n\n make shure that the engine modules you use are either already being used in the engine itself or have a line in d2d.game.knownclasses! \n" );   
    }
}

/** script is the abseclass for as scripts. it manages the communication with derelict.util.sharedlib 
  */
class Script
{
    /// Creates a new script by loading the shared object (dll) associated with it
    this(string name)
    {
        // script files always live inside gamedir/scriptbuild 
        //lib = new SharedLib();
        try {
            string path = Settings.get("gameDir") ~ "scriptbuild/" ~ name ~ libExt;
            _lib.load([path]);
        }
        catch(Exception e)
        {
            throw new UnknownScriptException(name, e.msg);
        }     

        // every module must have a run function
        attatchSymbol(cast(void**)&runFunction, "run");
    }
    
    ~this()
    {
        _lib.unload();
    }
    /// run is a funcion every scrpt should have.
    final void run(Base src) 
    {
        if(runFunction) {
            runFunction(src);
        }
    }

    @property final string name() const 
    {
        return _name;
    }
protected:
    /// attaches a symol to a container 
    final void attatchSymbol(void**dst, string name) 
    {
        try {
            *dst = _lib.loadSymbol(name);
        }
        catch(Exception e)
        {
            Logger.log("Could not load the symbol " ~ name ~ " from script " ~this._name);
        }
    }
private:
    /// the loaded lib 
    SharedLib   _lib;
    /// the name of this script
    string      _name; 

    /// symbol-container-meh for the run function
    void function(Base) runFunction;
}

