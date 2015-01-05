//file: Env.cpp
//contains functions for the env class 

#include "Env.h"

namespace Dragon2D {


Env* Env::ActiveEnv = nullptr;
Env::Env() 
{
	//does nothin
}


Env::Env(int argc, char** argv) 
{
	if (ActiveEnv != nullptr) {
		throw EnvException("Cannot create more then one instance of Env!");
	}
	ActiveEnv = this;
	
	//Defualt the arguments
	isDebug = false;
	gamepath = "./";
	
	//Parse the input arguments 
	for(int i = 1;i<argc;i++) {
		std::string arg(argv[i]);
		std::string argparam("");
		if(i+1<argc) {
			argparam = std::string(argv[i+1]);
		}

		if (arg==std::string("-d")) {
			isDebug = true;
		} 
		else {
			gamepath = arg;
		}
	}

	//read in the engine setting file
	settings.insert(std::make_pair(std::string("cfg/settings.cfg"), SettingFile("cfg/settings.cfg")));

	//read in the game setting file
	std::string gameInitName(gamepath);
	gameInitName+="GameInit.txt";
	settings.insert(std::make_pair(gameInitName, SettingFile(gameInitName)));
	
	//fire up SDL
	if (SDL_Init(SDL_INIT_EVERYTHING) < 0) {
		throw EnvException("Cannot Initialize SDL2!");
	}

	//shall the window be fullscreem?
	bool isFullscreen = false;
	if (settings["cfg/settings.cfg"]["isFullscreen"] == std::string("true")) {
		isFullscreen = true;
	}
	
	int width = stoi(settings["cfg/settings.cfg"]["width"]);
	int height = stoi(settings["cfg/settings.cfg"]["height"]);

	//try out some opengl-configs and fire up the window
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);

	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	
	window = SDL_CreateWindow(settings[gameInitName]["title"].c_str(),
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		width, height,
		SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | (isFullscreen ? SDL_WINDOW_FULLSCREEN : 0));
	if (!window) {
		//try somethin else: other  depth buffer size
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
		window = SDL_CreateWindow(settings[gameInitName]["title"].c_str(),
			SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
			width, height,
			SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | (isFullscreen ? SDL_WINDOW_FULLSCREEN : 0));
		if (!window) {
			throw EnvException("Cannot create window!");
		}
	}

	//Fire up glew and the context!
	context = SDL_GL_CreateContext(window);
	if (!context) {
		throw EnvException("Cannot create context!");
	}

	//check if we use vsync
	if (settings["cfg/settings.cfg"]["isVsync"] == std::string("true")) {
		SDL_GL_SetSwapInterval(1);
	}

	//from here, opengl is working!

}

Env::~Env()
{
	SDL_GL_DeleteContext(context);
	SDL_DestroyWindow(window);
	SDL_Quit();
}

//Setting stuff

SettingFile::SettingFile()
{
	//nothing to do here
}

SettingFile::SettingFile(std::string settingFile)
{
	inFile = settingFile;
	_Load();
}

void SettingFile::_Load()
{
	std::fstream infile(inFile.c_str(),std::ios::in);
	std::string infileString((std::istreambuf_iterator<char>(infile)),std::istreambuf_iterator<char>());

	std::regex e("\\s*(\\w*[\\w\\d]*)\\s*=\\s*([\\w\\d ]*)\\s*\n*");
	std::smatch m;
	std::string s(infileString);
	while(std::regex_search(s,m,e)) {
		settings[m[1]] = m[2];
		s = m.suffix().str();
	}
	
}

void SettingFile::Reload()
{
	_Load();
}

std::string& SettingFile::operator[](std::string key)
{
	return settings[key];
}




} //namespace Dragon2D
