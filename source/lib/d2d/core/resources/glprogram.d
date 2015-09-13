/**
  d2d.core.resources.glprogram holds the resource that represents a glprogram;
  */
module d2d.core.resources.glprogram;

import derelict.opengl3.gl3;

import d2d.core.resource;
import d2d.util.fileio;
import d2d.util.logger;

//some aliases for function types
alias glVecFunc = void function (GLuint, GLuint, void*);

/// A GLProgram that loads uniform bindings automaically
class GLProgram : Resource
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
            auto source = header ~ "// " ~ name ~ "\n" ~ fresource.getData!char();
            auto vSource = _shaderDefaultVersion ~ _vertexDefine ~ source;
            auto fSource = _shaderDefaultVersion ~ _fragmentDefine ~ source;

            //last step is extracting and binding the uniforms
            auto u = extractUniforms(source.idup, _program); 
        }
        else {
            Logger.log("Could not load shader " ~ name ~"!");
        }
        super(name);
    }
    
private:
    /// the default version for all shaders. Is appended after load.
    static string _shaderDefaultVersion = "#version 330\n";
    /// the default defines for the vertex- and fragment stage
    static string _vertexDefine = "#define STAGE_VERTEX\n";
    static string _fragmentDefine = "#define STAGE_FRAGMENT\n";

    /// The ID of the program
    GLuint _program = 0; 
}

/// Holds/Represents a uniform. Based on the uniform type it automatically selects the assignment function
struct Uniform
{
    /// Creates the uniform and binds the assignment function. 
    this (string type, string ident, string arr, GLuint program) 
    {
        import std.string;
        import std.regex;
        _location = glGetUniformLocation(program, toStringz(ident));
        // break type into "typename[N]" where n is a nuber. used for vecSOMETHING etc. 
        auto r = regex(r"([A-z]*)([2-4])");
        auto c = matchFirst(type, r);
        auto baseType = c[1];
        int typeN = to!int(c[2]);

        // this might be the uglyest switch statement ive ever made. 
        switch (type) {
        // Basic types
        case "bool": 
            break;
        case "int":
            break;
        case "uint":
            break;
        case "float":
            break;
        case "double":
            break;
        case "vec":
            vecUniformFunc!"f"(typeN);
        default: // assume integer
            break;
        }
    }

    @property GLuint location()
    {
        return _location;
    }

private:
    /// the location of the uniform in the assinged shader
    GLuint _location = 0;
}

/// Extracts all uniforms from a given shader source
private Uniform[] extractUniforms (string source, GLuint program)
{
    import std.regex;
    Uniform[] uniforms;
    auto r = regex(r"uniform\s+(\w*)\s+(\w*)\s*?\[?\s*(\d*)\s*]?\s*;");
    auto matches = matchAll(source, r);
    foreach (m; matches) {
        uniforms ~= Uniform(m[1], m[2], m[3], program);
    }       

    return uniforms;
}

/// helper for vector functions that should reduce code-duplication
private glVecFunc vecUniformFunc(string typeIdent)(const int num) 
{
    switch (num) {
        case 1:
            mixin(vecMixin!(typeIdent, 1));
            break;
        case 2:
            mixin(vecMixin!(typeIdent, 2));
            break;
        case 3:
            mixin(vecMixin!(typeIdent, 3));
            break;
        case 4:
            mixin(vecMixin!(typeIdent, 4));
            break;
        default: 
            mixin(vecMixin!(typeIdent, 1));
    }

    assert(0);
}

private template vecMixin(string typeIdent, int num)
{
        const char[] vecMixin = "return glUniform" ~ to!string(num) ~ typeIdent ~ "v;";
}

