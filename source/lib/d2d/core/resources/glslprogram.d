/**
  d2d.core.resources.glprogram holds the resource that represents a glprogram;
  */
module d2d.core.resources.glslprogram;

import std.string;
import std.regex;
import std.conv;

import d2d.core.resource;
import d2d.core.render.lowlevel.program;
import d2d.util.fileio;
import d2d.util.logger;

/// A GLProgram that loads uniform bindings automaically
class GLSLProgram : Resource
{
    ///Loads a shader from a shader source file 
    this(string name) 
    {
        auto fresource = FileResource.getFileResource(name);
        auto programHeaderResource = FileResource.getFileResource("shader.header");
        if (programHeaderResource.invalid) {
            throw new Exception("Default shader header not found. Check engine files!");
        }
        if (!fresource.invalid) {
            //generate the source
            auto header = "//GENERATED SHADER FILE\n//shader.default\n" 
                ~ programHeaderResource.getData!char();
            auto vSource = Program.versionString ~ _vertexDefine ~ source;
            auto fSource = Program.versionString ~ _fragmentDefine ~ source;

			_program = new Program(vSource, fSource);
            if (!_program.valid) {
                Logger.log("Error Compiling/Linking Shaders for " ~ name ~ "!");
            }
        }
        else {
            Logger.log("Could not load glsl program " ~ name ~"!");
        }
            
        super(name);
    }
    
    @property Program program()
    {
        return _program;
    }
private:
    /// the default defines for the vertex- and fragment stage
    static string _vertexDefine = "#define STAGE_VERTEX\n";
    static string _fragmentDefine = "#define STAGE_FRAGMENT\n";

    /// The ID of the program
    Program _program; 
}