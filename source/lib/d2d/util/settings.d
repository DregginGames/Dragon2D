/**
  d2d.settings manages all settings - from command line arguments to the config files of the engine
  */
module d2d.util.settings;

import file = std.file;
public import std.json;

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

/**
    This Exception is thrown in case that a setting simply does not exist. SHOULD NO be thrown in release
  */
class UnknownSettingException : Exception 
{
    /// cotr 
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
        jsonBody = ["cmd": JSONValue( [
            "gameDir": "game/",
            "engineDir": "engine/",
            "gameCfgDir": "cfg/",
            "engineCfgDir": "cfg/",
            "gameCfg": "game.cfg",
            "engineCfg": "engine.cfg",
            "gameResourceDir": "resources/",
            "engineResourceDir": "resources/"
        ])];


        //read args
        for (size_t i = 1; i<args.length; i++) {
            auto arg = args[i];
            if (arg[0] == '-') {
                i++;
                if (i >= args.length) {
                    throw new ArgumentListInvalidException(("No value given for " ~ arg).idup);
                }
                auto value = args[i];
                jsonBody["cmd"].object[arg[1..$].idup] = JSONValue(value.idup);
            }
            else {
                throw new ArgumentListInvalidException(("Invalid syntax for argument " ~ arg).idup);
            }
        }

        //the logfile is a bit confusing cause its default lives in engineDir... 
        auto logfile = ("logfile" in jsonBody["cmd"].object);
        if(logfile is null) {
            auto filestr = jsonBody["cmd"].object["engineDir"].str ~ "log.txt";
            jsonBody["cmd"].object["logfile"] = JSONValue(filestr);
        }
    
        //load the default files 
        loadFile(jsonBody["cmd"].object["engineDir"].str~jsonBody["cmd"].object["engineCfgDir"].str~jsonBody["cmd"].object["engineCfg"].str);
        loadFile(jsonBody["cmd"].object["gameDir"].str~jsonBody["cmd"].object["gameCfgDir"].str~jsonBody["cmd"].object["gameCfg"].str);
        loadFile(jsonBody["cmd"].object["gameDir"].str~"game.init");

        auto foo = toJSON(&jsonBody, true);
        foo = foo;
    }

    /**
        Get returns a property with the name "name". 

        After checking command line arguments (wich can overwrite EVERY property, it goes from file to file and searches for each property.  
    Params:
        name = the name of the setting to get 
        canBeEmpty = if true (default is false) get wont throw an exception if the setting is not found but insted will return emptystring.  
    Throws:
        UnknownSettingException if a setting is not found. Carefully adding stuff should avoid this!
      */
    static JSONValue get(string name, bool canBeEmpty=false) 
    {
        //search the setting files. first match hits. Every Memeber of value is an object representing a file
        foreach (ref o; jsonBody.object) {
            if (o.type == JSON_TYPE.NULL) {
                continue;
            }
            //check for both prefixname.settingname and pure settingname
            auto obj = (name in o.object);
            if (obj !is null) {
                return *obj;
            } 
        }
        
        if (canBeEmpty) {
            return JSONValue(["":""]);
        }
        debug
        {
            throw new UnknownSettingException("Unknown Setting " ~ name);
		}
		else {
			//default is errorish, but shouldnt kill the engine - at least in release, so..
			return JSONValue(["invalid":"invalid"]);
		}
    }

    /// loads a setting file
    static void loadFile(string name)
    {
        try {
            char[] data = cast(char[])file.read(name);
            jsonBody.object[name] = parseJSON(data);
        } 
        catch (Exception e) {
            debug {
                throw e;    // only in debug we want to know about the failing file-reads
            }
        }
    }
    
    /// saves the setting state (all setting files) of the current instance
    static void save()
    {
        foreach (string key, ref o; jsonBody.object) {
            if ("cmd" != key) {
                file.write(key, toJSON(&o,true));
            }
        }
    } 

    /// the get operator for [name]-access
    static JSONValue opIndex(string name)
    {
        return get(name, true);
    }

private:
    static JSONValue jsonBody;
}
