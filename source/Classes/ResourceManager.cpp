#include "ResourceManager.h"
#include "Env.h"

namespace Dragon2D {

//filling static vars
ResourceManager* ResourceManager::ActiveManager = nullptr;

ResourceManager::ResourceManager()
{
	Env::Out() << "Init ResourceManager" << std::endl;
	if (ActiveManager != nullptr) {
		throw ResourceManagerException("Cannot create more then one instance of ResouceManager!");
	}
	ActiveManager = this;
	//Load all .db files
	Env::Out() << "Loading Db files..." << std::endl;
	std::fstream audioDbFile = Env::Gamefile("audio/audio.db", std::ios::in);
	if (!audioDbFile.is_open()) throw ResourceManagerException("Can't load Audio DB file");

	std::fstream videoDbFile = Env::Gamefile("video/video.db", std::ios::in);
	if (!videoDbFile.is_open()) throw ResourceManagerException("Can't load Video DB file");

	std::fstream textureDbFile = Env::Gamefile("texture/texture.db", std::ios::in);
	if (!textureDbFile.is_open()) throw ResourceManagerException("Can't load Texture DB file");

	std::fstream scriptDbFile = Env::Gamefile("script/script.db", std::ios::in);
	if (!scriptDbFile.is_open()) throw ResourceManagerException("Can't load Script DB file");

	std::fstream fontDbFile = Env::Gamefile("script/script.db", std::ios::in);
	if (!fontDbFile.is_open()) throw ResourceManagerException("Can't load Font DB file");

	std::fstream glProgramDbFile = Env::Gamefile("script/script.db", std::ios::in);
	if (!glProgramDbFile.is_open()) throw ResourceManagerException("Can't load Shader DB file");

	std::fstream mapDbFile = Env::Gamefile("script/script.db", std::ios::in);
	if (!mapDbFile.is_open()) throw ResourceManagerException("Can't load Map DB file");

	std::fstream textDbFile = Env::Gamefile("script/script.db", std::ios::in);
	if (!textDbFile.is_open()) throw ResourceManagerException("Can't load Text DB file");

	std::string audioDbFileString = std::string(std::istreambuf_iterator<char>(audioDbFile), std::istreambuf_iterator<char>());
	std::string videoDbFileString = std::string(std::istreambuf_iterator<char>(videoDbFile), std::istreambuf_iterator<char>());
	std::string textureDbFileString = std::string(std::istreambuf_iterator<char>(textureDbFile), std::istreambuf_iterator<char>());
	std::string scriptDbFileString = std::string(std::istreambuf_iterator<char>(scriptDbFile), std::istreambuf_iterator<char>());
	std::string fontDbFileString = std::string(std::istreambuf_iterator<char>(fontDbFile), std::istreambuf_iterator<char>());
	std::string glProgramDbFileString = std::string(std::istreambuf_iterator<char>(glProgramDbFile), std::istreambuf_iterator<char>());
	std::string mapDbFileString = std::string(std::istreambuf_iterator<char>(mapDbFile), std::istreambuf_iterator<char>());
	std::string textDbFileString = std::string(std::istreambuf_iterator<char>(textDbFile), std::istreambuf_iterator<char>());

	Env::Out() << "Filling dbs with the info in the files..." << std::endl;
	//actual conversion happens in _LoadDbIntoMap
	audioDb = _LoadDbIntoMap(audioDbFileString);
	videoDb = _LoadDbIntoMap(videoDbFileString);
	textureDb = _LoadDbIntoMap(textureDbFileString);
	scriptDb = _LoadDbIntoMap(scriptDbFileString);
	fontDb = _LoadDbIntoMap(fontDbFileString);
	glProgramDb = _LoadDbIntoMap(glProgramDbFileString);
	mapDb = _LoadDbIntoMap(mapDbFileString);
	textDb = _LoadDbIntoMap(textDbFileString);
	Env::Out() << "Done!" << std::endl;
}

ResourceManager::~ResourceManager()
{
	ActiveManager = nullptr;
}

std::map<std::string, std::string> ResourceManager::_LoadDbIntoMap(std::string FileString)
{
	std::map<std::string, std::string> tmpMap;

	std::regex e("\\s*([\\w\\d/\\\\_]*.[\\w\\d]*)\\s*");
	std::smatch m;
	std::string s(FileString);
	while (std::regex_search(s, m, e)) {
		std::regex e2("([\\w\\d]*)\\.");
		std::smatch m2;
		std::string s2(m[1]);
		std::regex_search(s2, m2, e2);
		tmpMap[m2[1]] = m[1];
		s = m.suffix().str();
	}
	return tmpMap;
}



void ResourceManager::_CheckResMgr()
{
	if (ActiveManager == nullptr) {
		throw ResourceManagerException("Tried to call ResourceManager function without initialising it!");
	}
}

//Subclasses (fml)
//Resource
Resource::Resource(std::string resourceName)
: name(resourceName), tmpFilebuff(nullptr), references(1)
{

}

Resource::~Resource()
{
	if (tmpFilebuff) {
		delete tmpFilebuff;
	}

}

void Resource::Access() {
	references++;
}

void Resource::Free() {
	references--;
}

int Resource::GetResourceCount()
{
	return references;
}

std::string Resource::GetName()
{
	return name;
}

SDL_RWops* Resource::_RWFromFile(std::string file)
{
	SDL_RWops* newRwOps = nullptr;
	std::fstream infile = Env::Gamefile(file, std::ios::in);
	if (!infile.is_open()) {
		Env::Err() << "Cold not open " << file << "Resource will be empty!";
	}
	tmpFilebuff = new char[(int)infile.tellg()];
	memcpy(tmpFilebuff, infile.rdbuf(), (int)infile.tellg());
	newRwOps = SDL_RWFromMem(tmpFilebuff, (int)infile.tellg());
	return newRwOps;
}
//AudioResource
AudioResource::AudioResource()
: Resource("invalid")
{
	mixChunk = nullptr;
}

AudioResource::AudioResource(std::string name, std::string file)
: Resource(name)
{
	SDL_RWops* infile = _RWFromFile(file);
	if (!infile)
	{
		mixChunk = nullptr;
		return;
	}
	mixChunk = Mix_LoadWAV_RW(infile, 1);
	if (!mixChunk) {
		Env::Err() << "Error Loading Mix Chunk for " << file << "! Sound will be empty!" << std::endl;
	}
}

AudioResource::~AudioResource()
{
	Mix_FreeChunk(mixChunk);
}


}; //namespace Dragon2D