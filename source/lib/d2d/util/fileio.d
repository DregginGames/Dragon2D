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

        write(file, data);
        _modified = false;
    }

    /// flushes a file to the system and them removes cached data 
    void flushAndClean()
    {
        if(_invalid) {
            return;
        }
        flush();
        data.length = 0;
        _read = false;
    }

    /// gets the date of i file. if not yet done, reads them from the file system 
    T[] getData(T=ubyte) ()
    {
        if(_invalid) {
            return null;
        }

        if(!_read) {
            data = std.file.read(file);
            _read = true;
        }
        return cast(T[]) data;
    }

    /// sets the data of this file. Since data are overwritten in the end logically causes _read to be set to true. Flush is needed to store them to the system!
    void setData(T=ubyte) (T[] data) 
    {
        if(isInvalid) {
            return;
        }
        data = cast(void[]) data;
        isModified = true;
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
        string basename = "";
        string pathExtension = "";
        auto lastSeperator = lastIndexOf(resourceString, '.');
        if (lastSeperator == -1) {
            basename = resourceString;
        }
        else {
            basename = resourceString[lastSeperator+1..$];
            pathExtension = translate(resourceString[0..lastSeperator], ['.' : '/' ]);
        }

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
    void[]  data;

    /// all file resources live here 
    static FileResource[string] resources;

    /// returns first file ing gamePath with Basename is name (without extension) or emptystring
    static string makeFilePath(in string basePath, in string basename) 
    {
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
