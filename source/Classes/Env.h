#pragma once

//File: Env.h: contains classes wich manage the Env of the engine

//includes
#include "base.h"

namespace Dragon2D {
//class: Env
//note: Singleton wich manages the Env of the engine, so things as Settings, pahts, ...

class SettingFile;

class Env 
{
public:
	//constructor: Env
	//note: baseConstructor, should not be used directly
	Env();

	//constructor: Env (int argc, char* argv) 
	//note: parses the command line for arguments. Takes the main()s argc and argv
	Env(int argc, char** argv);
	
	//destructor: ~Env() 
	//note: destroys the Singleton a
	~Env();
	
	//function: IsDebugEnv()
	//note: returns true or false weather if running in a debug env, as stored in IsDebug 
	bool 			IsDebugEnv(); 
	//function: GetGamepath()
	//note: retuns the path to the given game.
	const std::string 	GetGamepath() const;
	
private:
	//var: isDebug. true if the engine is running in debug mode, false if not.
	bool		isDebug;
	//var: gamepath. contains the path to game given as argument to the engine. 
	std::string 	gamepath;
	
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
class EnvException : Exception 
{
public:
	//constructor: EnvException() 
	//note: standart constructor 
	EnvException() : Exception() {}
	
	//constructor:  EnvException(std::string envError)
	//note: takes an env error as argument 
	EnvException(std::string envError) 
	{ 
		SetWhat(std::string("Error in the ENV - ")+envError);
	}
};

} //namespace Dragon2D
