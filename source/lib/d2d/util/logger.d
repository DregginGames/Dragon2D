/**
    d2d.logger holds the basic functions for logging. It supports several output methods. 
  */
module d2d.util.logger; 

//for gl error logging
import derelict.opengl3.gl3;

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

    static void glLog()
    {
        GLenum err = glGetError();
        while(err!=GL_NO_ERROR) {
            switch(err) {
                case GL_NO_ERROR:
                    break;
                case GL_INVALID_ENUM:
                    log("GL_INVALID_ENUM raised!");
                    break;
                case GL_INVALID_VALUE:
                    log("GL_INVALID_VALUE raised!");
                    break;
                case GL_INVALID_OPERATION:
                    log("GL_INVALID_OPERATION raised!");
                    break;
                case GL_INVALID_FRAMEBUFFER_OPERATION:
                    log("GL_INVALID_FRAMEBUFFER_OPERATION raised!");
                    break;
                case GL_OUT_OF_MEMORY:
                    log("GL_OUT_OF_MEMORY raised! You now may hit a programmer with a brick");
                    break;
                /*case GL_STACK_UNDERFLOW:
                    log("GL_STACK_UNDERFLOW raised! Drown your programmer.");
                    break;
                case GL_STACK_OVERFLOW:
                    log("GL_STACK_OVERFLOW raised! Srsly your programmer fucked things up");
                    break; */
                default:
                    log("glGetError is drunk. Tell a programmer.");
                    break;
            }
            err = glGetError();
        }
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
