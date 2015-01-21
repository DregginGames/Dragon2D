#pragma once

#include "base.h"
#include "Env.h"

namespace Dragon2D {

class Resource;
class AudioResource;
class VideoResource;
class TextureResource;
class ScriptResource;
class FontResource;
class GLProgramResource;
class MapResource;
class TextResource;

//class: ResourceManager
//note: The ResouceManager manages Game Resources (as sounds, images, ...)
//note: it acutally retunrs the SDL or OpenGL formats for the resources (gluints, sdl_samples,...) and manages the memory of them
//note: its harldy reccomend to , at loading level, Request() files so they are loaded into memory before they are Acces()ed
class ResourceManager
{
public:
	//constructor:ResourceManager
	//note: standart constructor. loads all resources from files and makes shure the singleton is initialised properly
	ResourceManager();

	//deconstructor: ~ResourceManager
	//note: closes files, ...
	~ResourceManager();
private:
	//var: ActiveManager. Pointer containting the active instance
	static ResourceManager* ActiveManager;

	//var: audioDb. Contais list of all audio files
	std::map<std::string, std::string> audioDb;
	//var: videoDb. Contais list of all video files
	std::map<std::string, std::string> videoDb;
	//var: textureDb. Contais list of all texture files
	std::map<std::string, std::string> textureDb;
	//var: scriptDb. Contais list of all script files
	std::map<std::string, std::string> scriptDb;
	//var: fontDb. Contains list of all font files
	std::map<std::string, std::string> fontDb;
	//var: glProgramDb. Contains list of all shader files
	std::map<std::string, std::string> glProgramDb;
	//var: mapDb. Contains list of all map files
	std::map<std::string, std::string> mapDb;
	//var: textDb. Contains list of all text files
	std::map<std::string, std::string> textDb;

	//var: scriptResources
protected:
	//function: _CheckResMgr
	//note: checks singleton
	void _CheckResMgr();

	//function: _LoadDbIntoMap
	//note: Loads a filestring into a std::map. 
	std::map<std::string, std::string> _LoadDbIntoMap(std::string FileString);
};

//class: GameManagerException
//note: Exception that happen in the Game Manager or in classes related to it are defined below
class ResourceManagerException : public Exception
{
public:
	//constructor: ResourceManagerException() 
	//note: standart constructor 
	ResourceManagerException() : ResourceManagerException() {};

	//constructor:  ResourceManagerException(std::string managerError)
	//note: takes an manager error as argument 
	ResourceManagerException(const char* managerError) : Exception(managerError) {};

	~ResourceManagerException() throw() {};
};

//below the resource types

//class: Resource
//note: base class for resource classes
class Resource 
{
public:
	Resource(std::string resourceName);
	virtual ~Resource();

	virtual void Access();
	virtual void Free();
	virtual int  GetResourceCount();

	std::string GetName();
private:
	int references;
	std::string name;
	char* tmpFilebuff;
protected:
	SDL_RWops* _RWFromFile(std::string file);
	
};

//class: AudioResource
//note: stores audio chunk that is used by sdl stuff
class AudioResource : public Resource
{
public:
	AudioResource();
	AudioResource(std::string name, std::string file);
	~AudioResource();
private:
	Mix_Chunk* mixChunk;
};

//class: VideoResource
//note: dummy, does nothing cause we dont use videos atm
class VideoResource
{
public:
	VideoResource();
	VideoResource(std::string name, std::string file);
	~VideoResource();
private:
	
};

//class: TextureResource
//note: stores texture gluint that is placed on the gpu
class TextureResource : public Resource
{
public:
	TextureResource();
	TextureResource(std::string name, std::string file);
	~TextureResource();
private:
	GLuint texId;
};

//class: ScriptResource
//note: stores script
class ScriptResource : public Resource
{
public:
	ScriptResource();
	ScriptResource(std::string name, std::string file);
	~ScriptResource();
private:
	
};

//class: ScriptResource
//note: stores font
class FontResource : public Resource
{
public:
	FontResource();
	FontResource(std::string name, std::string file);
	~FontResource();
private:
	TTF_Font*	font;
};


}; //namespace Dragon2D