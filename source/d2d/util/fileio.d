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
        if(!isModified || isInvalid) {
            return;
        }

        write(file, data);
        isModified = false;
    }

    /// flushes a file to the system and them removes cached data 
    void flushAndClean()
    {
        if(isInvalid) {
            return;
        }
        flush();
        data.length = 0;
    }

    /// gets the date of i file. if not yet done, reads them from the file system 
    T[] getData(T=ubyte) ()
    {
        if(isInvalid) {
            return null;
        }

        if(!isRead) {
            data = read(file);
            isRead = true;
        }
        return cast(T[]) data;
    }

    /// sets the data of this file. Since data are overwritten in the end logically causes isRead to be set to true. Flush is needed to store them to the system!
    void setData(T=ubyte) (T[] data) 
    {
        if(isInvalid) {
            return;
        }
        data = cast(void[]) data;
        isModified = true;
        isRead = true;
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
        newResource.name = resourceString;

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
        string enginePath = Settings.get("engineDir") ~ Settings.get("engineResourceDir") ~ pathExtension;
        string gamePath = Settings.get("gameDir") ~ Settings.get("gameResourceDir") ~ pathExtension;
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
            newResource.isInvalid = true;
        }
        else {
            newResource.file = filePath;
        }
        return resources[newResource.name] = newResource;
    }

private:
    /// name of the file resource
    string name;
    /// name of the file that this resource belongs to 
    string file;
    /// if the file was read
    bool    isRead = false; 
    /// if true the file has been modifed since the init/flush
    bool    isModified = false;
    /// if true the resource is invalid and all operations dont have an effect 
    bool    isInvalid = false; 
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
