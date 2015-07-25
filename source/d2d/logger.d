/**
    d2d.logger holds the basic functions for logging. It supports several output methods. 
  */
module d2d.logger; 

import std.stdio;
import file = std.file;
import std.datetime;

class Logger
{
    /// constructor and destructor are disabled!
    @disable this();

    static void init(in string logfile)
    {
        this.logfile = logfile;
        log("Logger started [" ~ Clock.currTime().toString() ~ "] ");
    }

    static void log(in char[] msg) 
    {   
        debug
        {
            writeln(msg);           
        }
        if (!file.exists(logfile)) {
            file.write(logfile, msg);
        }
        else {
            file.append(logfile, msg);
        }
        file.append(logfile, "\n");
        
    }   

    static string logfile = "log.txt";
}
