/**
  d2d.util.fileio provides structs and functions for efficient file resoure management
  */
module d2d.util.fileio;

import std.file;
import std.string;
import d2d.util.settings;

/// this class manages and reprresents all files that are read/written to the system 
class FileResource
{
    /// ctor is private, resources cant be created directly.
    private this()
    {
    }

    /// flushes a file to the system 
    void flush()
    {
        if(!_modified || _invalid) {
            return;
        }

        write(file, _data);
        _modified = false;
    }

    /// flushes a file to the system and them removes cached data 
    void flushAndClean()
    {
        if(_invalid) {
            return;
        }
        flush();
        _data.length = 0;
        _read = false;
    }

    /// gets the date of i file. if not yet done, reads them from the file system 
    T[] getData(T=ubyte) ()
    {
        if(_invalid) {
            return null;
        }

        if(!_read) {
            _data = std.file.read(file);
            _read = true;
        }
        return cast(T[]) _data;
    }

    /// sets the data of this file. Since data are overwritten in the end logically causes _read to be set to true. Flush is needed to store them to the system!
    void setData(T=ubyte) (T[] data) 
    {
        if(_invalid) {
            return;
        }
        _data = cast(ubyte[]) data;
        _modified = true;
        _read = true;
    }

// static stuff for file resource management below 

    /// we only write changes on the system if 1st flush is called or 2nd we exit the program 
    static ~this()
    {
        // just call flush 
        flushAll();
    }

    /// flushes all know resources. might be slow... 
    static void flushAll()
    {
        foreach (ref r; resources) {
            r.flush();
        }   
    }

    /// returns string[2], [0] is the basename, [1] is the path
    static string[2] nameToPath(string resourceString)
    {
        string[2] result;
        result[0] = "";
        result[1] = "";
        auto lastSeperator = lastIndexOf(resourceString, '.');
        if (lastSeperator == -1) {
            result[0] = resourceString;
        }
        else {
            result[0] = resourceString[lastSeperator+1..$];
            result[1] = translate(resourceString[0..lastSeperator], ['.' : '/' ]);
        }

        return result;
    }

    /** returns a FileResource for the given resource stirng
        resource strings have the format resourcetype.name or resourcetype.subtpe.name or foo.bar.x.y.z - importand is that this is transformed into a path without file extension (foo/bar/x/y/z.*). 
        THAT MEANS THAT FILENAMES WITHOUT EXTENSION MUST BE UNIQUE IN A DIRECTORY! THE FUNCTION WILL IGNORE ALL BUT THE FIRST ENTRY FOUND!
    */  
    static FileResource getFileResource(string resourceString)
    {
        //see if we know that resource
        auto p = (resourceString in resources);
        if( p !is null) {
            return *p;
        }

        // ok ok new resource 
        auto newResource = new FileResource;
        newResource._name = resourceString;

        // we need to transfor the string into a path. 
        string[2] convRes = nameToPath(resourceString);
        string basename = convRes[0];
        string pathExtension = convRes[1];
        

        // resources can be searched for in 3 places: the engine resource directory, the game resource directory and in the run directory (wich should be the root for engine and game but whatsoever) 
        string filePath;
        string enginePath = Settings.get("engineDir").str ~ Settings.get("engineResourceDir").str ~ pathExtension;
        string gamePath = Settings.get("gameDir").str ~ Settings.get("gameResourceDir").str ~ pathExtension;
        string generalPath = "./" ~ pathExtension;
        
        // game > engine > genral path 
        filePath = makeFilePath(gamePath, basename);
        if (filePath == "") {
            filePath = makeFilePath(enginePath, basename);
            if (filePath == "") {
                filePath = makeFilePath(generalPath, basename);
            }
        }

        if (filePath == "") {
            newResource._invalid = true;
        }
        else {
            newResource._file = filePath;
        }
        return resources[newResource.name] = newResource;
    }

    /// creates a new (read as: never exsisted) resource in game path
    static bool createGameResource(string resourceString, string resourceExtension)
    {
        import d2d.util.logger;
        auto p = (resourceString in resources);
        if( p !is null) {
            if (!p.invalid) {
                return true;
            }            
        }

        auto newResource = new FileResource;
        newResource._invalid = true;

        try {
            auto path = nameToPath(resourceString);
            string fileDir = Settings.get("gameDir").str ~ Settings.get("gameResourceDir").str ~ path[1] ~ "/";
            if(!exists(fileDir)) {
                Logger.log("Dir to create " ~ resourceString ~ " in does not exsist. - " ~ fileDir);
                return false;
            }
            string fullFile = fileDir ~ path[0] ~ "." ~ resourceExtension;
            
            newResource._name = resourceString;
            newResource._file = fullFile;
            newResource._invalid = false;
            newResource._modified = true;
            newResource.flush();
            resources[newResource.name] = 
            resources[newResource.name] = newResource;
            return true;
        }
        catch(Exception e)
        {
            Logger.log("Cannot create new filesystem resource " ~ resourceString);
        }

        return false;
    }

    /// gets the name of the file resource
    @property string name() 
    {
        return _name;
    }

    /// gets the file that this resource belongs to
    @property string file()
    {
        return _file;
    }

    /// gets if the file resource is invalid
    @property bool invalid()
    {
        return _invalid;
    }

    /// gets if the resource has been read
    @property bool read()
    {
        return _read;
    }

    /// get if the resource was modified
    @property bool modified() 
    {
        return _modified;
    }
private:
    /// name of the file resource
    string _name;
    /// name of the file that this resource belongs to 
    string _file;
    /// if the file was read
    bool    _read = false; 
    /// if true the file has been modifed since the init/flush
    bool    _modified = false;
    /// if true the resource is invalid and all operations dont have an effect 
    bool    _invalid = false; 
    /// the actual data
    void[]  _data;

    /// all file resources live here 
    static FileResource[string] resources;

    /// returns first file ing gamePath with Basename is name (without extension) or emptystring
    static string makeFilePath(in string basePath, in string basename) 
    {
        if (!exists(basePath)) {
            return "";
        }
        try {
            auto gameFiles = dirEntries(basePath.idup, (basename ~ ".*").idup, SpanMode.shallow);
            // FIXME: a little diry here
            foreach (ref f; gameFiles) {
                return f;
            }
        }
        catch(Exception e)
        {
            return "";
        }
        
        return "";   
    }
}
