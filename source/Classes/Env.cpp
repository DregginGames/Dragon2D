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
	
	//create window and stuff 
}

Env::~Env()
{

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


}
