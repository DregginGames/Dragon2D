/**
  d2d.core.resources.glprogram holds the resource that represents a glprogram;
  */
module d2d.core.resources.glprogram;

import std.string;
import std.regex;
import std.conv;

import derelict.opengl3.gl3;

import d2d.core.resource;
import d2d.util.fileio;
import d2d.util.logger;

//some aliases for function types
alias glVecFunc = void function (GLint, GLsizei, void*);
alias glMatFunc = void function (GLint, GLsizei, bool, void*);
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

			//compile and link
			auto vShader = compileShader(vSource.idup, GL_VERTEX_SHADER);
			auto fShader = compileShader(fSource.idup, GL_FRAGMENT_SHADER);
			if (0 != vShader && 0 != fShader) {
				_program = glCreateProgram();
				glAttachShader(_program, vShader);
				glAttachShader(_program, fShader);
				glLinkProgram(_program);
				
				// Ugly error check
				GLint isLinked = 0;
				glGetProgramiv(_program, GL_LINK_STATUS, cast(int *)&isLinked);
				if(isLinked == GL_FALSE)
				{
					GLint maxLength = 0;
					glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &maxLength);
					char[] infoLog;
					infoLog.length = maxLength;
					glGetProgramInfoLog(_program, maxLength, &maxLength, &infoLog[0]);
					// im anti mem-leak
					glDeleteProgram(_program);
					_program = 0;
					// log them all
					Logger.log("Could not link program:");
					Logger.log(infoLog);
					Logger.log("FOR SOURCE FILE (ignore the #define on top)");
					Logger.log(vSource);
				}
				else {
					//last step is extracting and binding the uniforms
					_uniforms = extractUniforms(source.idup, _program); 
				}
				glDeleteShader(vShader);
				glDeleteShader(fShader);
			} else {
				Logger.log("Could not compile shaders for " ~ name);
			}

            
			
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

	/// The uniforms of the program
	Uniform[string] _uniforms;
}

/// Holds/Represents a uniform. Based on the uniform type it automatically selects the assignment function
struct Uniform
{
    /// Creates the uniform and binds the assignment function. 
    this (string type, string ident, string arr, GLuint program) 
    {
		auto sIdent = toStringz(ident);
        _location = glGetUniformLocation(program, sIdent);
		// is this an array?
		if (arr.length > 0 && isNumeric(arr)) {
			_arrSize = to!int(arr);
		}
        // break type into "typename[N]" where n is a nuber. used for vecSOMETHING etc. 
        auto r = regex(r"([A-z]*)([2-4]x?[2-4]?)");
        auto c = matchFirst(type, r);
        auto baseType = c[1];
        auto typeN = c[2];

        // this might be the uglyest switch statement ive ever made. 
        switch (baseType) {
        // Basic types
		case "sampler":  //sampler does have some a suffix but that dosnt change the fact its an integer. 
			_vecFunc = cast(glVecFunc)glUniform1uiv;
			break;
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
		case "uvec":
			_vecFunc = vecUniformFunc!"ui"(typeN);
			break;
		case "mat":
			_matFunc = matUniformFunc(typeN);
			break;
        default: // assume integer
            _vecFunc = cast(glVecFunc)glUniform1fv;
            break;
        }
    }

	void setUniformValue(T) (T* valuePtr)
	{
		if (null != _vecFunc) {
			_vecFunc(_location, _arrSize, cast(void*)valuePtr);
		}
		else if (null != _matFunc) {
			_matFunc(_location, _arrSize, false, cast(void*)valuePtr);
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
	/// the function in case of a matrix
	glMatFunc _matFunc = null;
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

/** The following functions are really ugly. The alternative would be to create an associative array.
	However even with optimization that array would need some catching in case of invalid shader code, and it would actually do a lookup.
	Also someone would have to pre-propulate the array. This is probably faster but in my opinion way easyer (Malte, September 2015. Famous last words)
*/

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
        default:  //default to float
            mixin(vecMixin!(typeIdent, "1"));
    }

    assert(0);  // should never happen
}

/// helper for matrix function that should reduce code duplication
private glMatFunc matUniformFunc(string num)
{
	switch (num) {
		case "2":
			mixin(matMixin!"2");
		case "3":
			mixin(matMixin!"3");
		case "4":
			mixin(matMixin!"4");
		case "2x3":
			mixin(matMixin!"2x3");
		case "2x4":
			mixin(matMixin!"2x4");
		case "3x2":
			mixin(matMixin!"3x2");
		case "3x4":
			mixin(matMixin!"3x4");
		case "4x2":
			mixin(matMixin!"4x2");
		case "4x3":
			mixin(matMixin!"4x3");
		default:	// we are a bit ugh ass and default to mat4
			mixin(matMixin!"4");
	}

	assert(0);  // should never happen
}

/// Generates return statements for vecUniformFunc
private template vecMixin(string typeIdent, string num)
{
	const char[] vecMixin = "return cast(glVecFunc) (glUniform" ~ num ~ typeIdent ~ "v);";
}

/// Generates return statemenst for matUniformFunc
private template matMixin(string num)
{
	const char[] matMixin = "return cast(glMatFunc) (glUniformMatrix" ~ num ~ "fv);";
}
/**
	Compiles a shader source.
	In case of an error it logs the error.
*/	
private GLuint compileShader(string source, GLenum type)
{
	GLuint shader = glCreateShader(type);
	auto s = toStringz(source);
	glShaderSource(shader, 1, &s, null);
	glCompileShader(shader);

	GLint isCompiled = 0;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &isCompiled);
	if(isCompiled == GL_FALSE)
	{
		GLint maxLength = 0;
		glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &maxLength);

		// The maxLength includes the NULL character
		char[] errorLog;
		errorLog.length = maxLength;
		glGetShaderInfoLog(shader, maxLength, &maxLength, &errorLog[0]);

		// Provide the infolog in whatever manor you deem best.
		// Exit with failure.
		glDeleteShader(shader); // Don't leak the shader.
		shader = 0;

		//Log the error
		Logger.log("SHADER COMPILATION ERROR:");
		Logger.log(errorLog);
		Logger.log("FOR SOURCE FILE");
		Logger.log(source);
	}

	return shader;
}