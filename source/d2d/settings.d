/**
  d2d.settings manages all settings - from command line arguments to the config files of the engine
  */
module d2d.settings;

import file = std.file;

/**
  This Exception is thrown in case that the command line argument list is invalid
 */
class ArgumentListInvalidException : Exception 
{
    /// ctor 
    this(string err)  
    {
        super(err);
    }
};

class Settings
{
    /// constructor is disabled
    @disable this();

    /**
        Inits the settings. Should be called with the arg(v) from main() 
      */
    static void init(in char[][] args)
    {
        //put defaults 
        cmdValues["gameDir"] = "game/";
        cmdValues["engineDir"] = "engine/";
        cmdValues["gameCfgDir"] = "cfg/";
        cmdValues["engineCfgDir"] = "cfg/";
        cmdValues["gameCfg"] = "game.cfg";
        cmdValues["engineCfg"] = "engine.cfg";

        //read args
        for (size_t i = 1; i<args.length; i++) {
            auto arg = args[i];
            if (arg[0] == '-') {
                i++;
                if (i >= args.length) {
                    throw new ArgumentListInvalidException(("No value given for " ~ arg).idup);
                }
                auto value = args[i];
                cmdValues[arg[1..$].idup] = value.idup;
            }
            else {
                throw new ArgumentListInvalidException(("Invalid syntax for argument " ~ arg).idup);
            }
        }
        
        //the logfile is a bit confusing cause its default lives in engineDir... 
        auto logfile = ("logfile" in cmdValues);
        if(logfile is null) {
            cmdValues["logfile"] = cmdValues["engineDir"] ~ "log.txt";
        }
    
        //load the default files 
        loadFile(cmdValues["engineDir"]~cmdValues["engineCfgDir"]~cmdValues["engineCfg"]);
        loadFile(cmdValues["gameDir"]~cmdValues["gameCfgDir"]~cmdValues["gameCfg"]);
        loadFile(cmdValues["gameDir"]~"game.init");
    }

    /**
        Get returns a property with the name "name". 

        After checking command line arguments (wich can overwrite EVERY property, it goes from file to file and searches for each property. 
        Also, if a file has a prefix name (SettingFile.name), it also checks if the property exists with the given prefix. 

      */
    static string get(string name) nothrow 
    {
        //the commandline can overwrite any setting from anywhere
        auto p = (name in cmdValues);
        if (p !is null) {
            return *p;
        } 

        //search the setting files. first match hits. 
        foreach (ref f; settingFiles) {
            //check for both prefixname.settingname and pure settingname
            auto noPrefix = (name in f.values);
            auto withPrefix = ( f.name ~ "." ~ name in f.values);
            if (noPrefix !is null) {
                return *noPrefix;
            } 
            else if(withPrefix !is null) {
                return *withPrefix;
            }
        }

        //default is errorish, but shouldnt kill the engine, so..
        return "invalid";
    }

    /// loads a setting file
    static void loadFile(string name)
    {
        settingFiles ~= SettingFile(name);
    }
    
    /// saves the setting state (all setting files) of the current instance
    static void save()
    {
        foreach (ref f; settingFiles) {
            f.save();
        }
    } 

private:
    static SettingFile[] settingFiles;
    static string[string] cmdValues;
}

/**
    Internal representation of setting files. 
    The syntax of a setting file is: "key: value \n" 
    there is one special key, called nameprefix, wich prefixes all settings in the file its value. 
  */
private struct SettingFile
{
    /// ctor takes the file that should be loaded as argument
    this(string filename) 
    {
        this.filename = filename;
        load();
    }

    void load() {
        import file = std.file;
        import std.string;
        try {
            char[] data = cast(char[])file.read(filename);
            auto lines = splitLines(data);
            string[string] rawValues;
            foreach (ref line; lines) {
                auto splitpos = indexOf(line, ":");
                // simply ignore invalid lines 
                if (splitpos != -1) {
                    char[] l = strip(line[0..splitpos]);
                    char[] r = strip(line[splitpos+1..$]);
                    if (l == "nameprefix") {
                        name = l.idup;
                    }
                    else {
                        rawValues[l.idup] = r.idup;
                    }
                }
            }
            //set date to values
            foreach (string key, string val; rawValues)
            {
                if (name!="") {
                    values[(name ~ "." ~ key).idup] = val.idup;
                }
                else {
                    values[key.idup] = val.idup;
                }
            }
        }
        catch (Exception e)
        {
            // dont throw in release build but fail silently
            debug {
                throw e;
            }
        }
    }

    /// saves settings to the given file
    void save()
    {
        try {
            char[] outstring;
            if (name != "") {
                outstring = ("nameprefix:" ~ name ~ "\n").dup;
            }
            foreach (string key, string val; values) {
                outstring ~= (key ~ ":" ~ val).dup;
            }
            import file = std.file;
            file.write(filename, outstring);
        }
        catch(Exception e)
        {
            // also here: dont throw in release 
            debug {
                throw e;
            }
        }
    }

    /// just an alias function for load. might get extras later in time.
    void reload()
    {
        load();
    }
   
   
    string name; 
    string filename;
    string[string] values;
}
