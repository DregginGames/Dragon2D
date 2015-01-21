#pragma once

//File: Env.h: contains classes wich manage the Env of the engine

//includes
#include "base.h"

namespace Dragon2D {

class SettingFile;

//class: Env
//note: Singleton wich manages the Env of the engine, so things as Settings, pahts, ...
class Env 
{
public:
	//Basic stuff for class init and foo

	//constructor: Env
	//note: baseConstructor, should not be used directly
	Env();

	//constructor: Env (int argc, char* argv) 
	//note: parses the command line for arguments. Takes the main()s argc and argv
	Env(int argc, char** argv);
	
	//destructor: ~Env() 
	//note: destroys the Singleton a
	~Env();
	
	//function: ActiveEnv()
	//note: returns reference to the singleton
	Env& GetActiveEnv();

	//Toplevel general stuff

	//function: IsDebugEnv()
	//note: returns true or false weather if running in a debug env, as stored in IsDebug 
	static bool 			IsDebugEnv(); 
	//function: GetGamepath()
	//note: retuns the path to the given game.
	static const std::string 	GetGamepath();
	//function: Out();
	//note: Standart output. Does nothin if not debugging
	static std::ostream&	Out();
	//function: Err();
	//note: Error output
	static std::ostream&	Err();

	//File Management

	//function: Gamefile(std::string file, std::ios_base::openmode mode);
	//note: opens file from the game directory
	static std::fstream Gamefile(std::string file, std::ios_base::openmode mode);
	//function: Enginefile(std::string file, std::ios_base::openmode mode);
	//note: opens file from the engine directory
	static std::fstream Enginefile(std::string file, std::ios_base::openmode mode);

	//Setting Management

	//function: Setting(file)
	//note: returns a seeting file. If not open yet, it opens the file. 
	static SettingFile& Setting(std::string file);

	//OpenGL foo

	//function: swapBuffers()
	//note: swaps the screen buffers
	static void SwapBuffers();
	//function: clearScreen()
	//note: cleans the active Framebuffer
	static void ClearFramebuffer(bool colorbuffer = true, bool depthbuffer = true);

protected:
	static void _CheckEnv();

private:
	//var: isDebug. true if the engine is running in debug mode, false if not.
	bool			isDebug;
	//var: gamepath. contains the path to game given as argument to the engine. 
	std::string 	gamepath;
	//var: engineInitName. Contains the path to the engine settings file
	std::string engineInitName;
	//var: gameInitName. contains the path to the game init file
	std::string gameInitName;

	//var: streamOut. contains the std::ostream where to write on in general cases. log.txt if not in debug
	static std::ostream	streamOut;
	//var: streamOutError contains the std::ostream where to write on in error cases. should be std::cerr
	static std::ostream	streamOutError;
	//var: logfile. 
	static std::ofstream	logfile;

	//var: ActiveEnv. Pointer to make shure there is only one instance 
	static Env* 	ActiveEnv;

	//var: settings. Contains all the settings, in order of the files
	std::map<std::string, SettingFile> settings;

	//var: window - SDL Window of this env.
	SDL_Window *	window;
	//var: glContext - GLContext of this env. 
	SDL_GLContext	context;

};

//class: ;
//note: Class for reading settings from files
class SettingFile
{
public:	
	//constructor: SettingFile()
	SettingFile();
	//constructor: SettingFile(std::string file)
	//note: takes the file to read the settings from as input 
	SettingFile(std::string settingFile);
	
	//function: Reload()
	//note: Reloads the settings 
	void 		Reload();
	//function: Save() 
	//note: Saves the settings to the file. 
	//warning: Destroys the comments in the given file
	void 		Save();

	//operator [std::string]
	//note: returns string of the setting requested
	std::string& operator[](std::string key);

private:
	//function: _Load() 
	//note: Loads the file 
	void _Load();
	//var file. The file that contains the settings 
	std::string inFile;
	//var map. Stores all the settings 
	std::map<std::string, std::string> settings;
};



//class: EnvException
//note: Exception that happen in the env or are related to it are defined below
class EnvException : public Exception 
{
public:
	//constructor: EnvException() 
	//note: standart constructor 
	EnvException() : Exception() {};
	
	//constructor:  EnvException(std::string envError)
	//note: takes an env error as argument 
	EnvException(const char* envError) : Exception(envError) {};

	~EnvException() throw() {};
};

} //namespace Dragon2D
