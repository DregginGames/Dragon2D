/**
  d2d.core.resources.glprogram holds the resource that represents a glprogram;
  */
module d2d.core.resources.glprogram;

import std.string;
import std.regex;

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
        _location = glGetUniformLocation(program, toStringz(ident));
        // break type into "typename[N]" where n is a nuber. used for vecSOMETHING etc. 
        auto r = regex(r"([A-z]*)([2-4])");
        auto c = matchFirst(type, r);
        auto baseType = c[1];
        auto typeN = c[2];

        // this might be the uglyest switch statement ive ever made. 
        switch (type) {
        // Basic types
        case "bool": 
            _vecFunc = cast(glVecFunc)glUniform1uiv;
            break;
        case "int":
            _vecFunc = cast(glVecFunc)glUniform1iv;
            break;
        case "uint":
            _vecFunc = cast(glVecFunc)glUniform1uiv;
            break;
        case "float":
            _vecFunc = cast(glVecFunc)glUniform1fv;
            break;
        case "double":
            _vecFunc = cast(glVecFunc)glUniform1fv;
            break;
        case "vec":
            _vecFunc = vecUniformFunc!"f"(typeN);
            break;
        case "bvec":
            _vecFunc = vecUniformFunc!"ui"(typeN);
            break;
        case "ivec":
            _vecFunc = vecUniformFunc!"i"(typeN);
            break;
        default: // assume integer
            _vecFunc = cast(glVecFunc)glUniform1fv;
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

    /// the size of the uniform data - 1 for normal values and >1 for arrays
    uint _arrSize = 1;
    /// the function in case this is a vector(or just value) based uniform
    glVecFunc _vecFunc = null;
}

/// Extracts all uniforms from a given shader source
private Uniform[string] extractUniforms (string source, GLuint program)
{
    auto r = regex(r"uniform\s+(\w*)\s+(\w*)\s*?\[?\s*(\d*)\s*]?\s*;");
    auto matches = matchAll(source, r);
    Uniform[string] uniforms;
    foreach (m; matches) {
        uniforms[m[1]] = Uniform(m[1], m[2], m[3], program);
    }       

    return uniforms;
}

/// helper for vector functions that should reduce code-duplication
private glVecFunc vecUniformFunc(string typeIdent)(string num) 
{
    switch (num) {
        case "1":
            mixin(vecMixin!(typeIdent, "1"));
        case "2":
            mixin(vecMixin!(typeIdent, "2"));
        case "3":
            mixin(vecMixin!(typeIdent, "3"));
        case "4":
            mixin(vecMixin!(typeIdent, "4"));
        default: 
            mixin(vecMixin!(typeIdent, "1"));
    }

    assert(0);
}

private template vecMixin(string typeIdent, string num)
{
        const char[] vecMixin = "return cast(glVecFunc) (glUniform" ~ num ~ typeIdent ~ "v);";
}

