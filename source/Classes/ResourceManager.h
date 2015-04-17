#pragma once

#include "base.h"

#include "ScriptLibHelper.h"

namespace Dragon2D {

class Resource;
class AudioResource;
class VideoResource;
class TextureResource;
class XMLResource;
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

	//function: RequestAudioResource()
	//note: Request Access to an audio resource, causing it to be loaded if it wasnt. Increment ref count if already loaded
	void RequestAudioResource(std::string name);
	//function: FreeAudioResource()
	//note: Free an audio resource, causing its ref count to decrese. 
	void FreeAudioResource(std::string name);

	//function: RequestVideoResource()
	//note: Request Access to an video resource, causing it to be loaded if it wasnt. Increment ref count if already loaded
	void RequestVideoResource(std::string name);
	//function: FreeVideoResource()
	//note: Free an video resource, causing its ref count to decrese. 
	void FreeVideoResource(std::string name);

	//function: RequestTextureResource()
	//note: Request Access to an texture resource, causing it to be loaded if it wasnt. Increment ref count if already loaded
	void RequestTextureResource(std::string name);
	//function: FreeTextureResource()
	//note: Free an texture resource, causing its ref count to decrese. 
	void FreeTextureResource(std::string name);

	//function: RequestXMLResource()
	//note: Request Access to an script resource, causing it to be loaded if it wasnt. Increment ref count if already loaded
	void RequestXMLResource(std::string name);
	//function: FreeXMLResource()
	//note: Free an script resource, causing its ref count to decrese. 
	void FreeXMLResource(std::string name);

	//function: RequestFontResource()
	//note: Request Access to an font resource, causing it to be loaded if it wasnt. Increment ref count if already loaded
	void RequestFontResource(std::string name);
	//function: FreeFontResource()
	//note: Free an font resource, causing its ref count to decrese. 
	void FreeFontResource(std::string name);

	//function: RequestGLProgramResource()
	//note: Request Access to an glprogram resource, causing it to be loaded if it wasnt. Increment ref count if already loaded
	void RequestGLProgramResource(std::string name);
	//function: FreeGLProgramResource()
	//note: Free an glprogram resource, causing its ref count to decrese. 
	void FreeGLProgramResource(std::string name);

	//function: RequestMapResource()
	//note: Request Access to an map resource, causing it to be loaded if it wasnt. Increment ref count if already loaded
	void RequestMapResource(std::string name);
	//function: FreeMapResource()
	//note: Free an map resource, causing its ref count to decrese. 
	void FreeMapResource(std::string name);

	//function: RequestTextResource()
	//note: Request Access to an text resource, causing it to be loaded if it wasnt. Increment ref count if already loaded
	void RequestTextResource(std::string name);
	//function: FreeTextResource()
	//note: Free an text resource, causing its ref count to decrese. 
	void FreeTextResource(std::string name);


	//function: GetAudioResource
	//note: Return a resource
	AudioResource& GetAudioResource(std::string name);
	//function: GetAudioResource
	//note: Return a resource
	VideoResource& GetVideoResource(std::string name);
	//function: GetAudioResource
	//note: Return a resource
	TextureResource& GetTextureResource(std::string name);
	//function: GetAudioResource
	//note: Return a resource
	XMLResource& GetXMLResource(std::string name);
	//function: GetAudioResource
	//note: Return a resource
	FontResource& GetFontResource(std::string name);
	//function: GetAudioResource
	//note: Return a resource
	GLProgramResource& GetGLProgramResource(std::string name);
	//function: GetAudioResource
	//note: Return a resource
	MapResource& GetMapResource(std::string name);
	//function: GetAudioResource
	//note: Return a resource
	TextResource& GetTextResource(std::string name);

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

	//var: audioResources. Contains the currently loaded Audio Resourcess
	std::map<std::string, AudioResource*> audioResources;
	//var: videoResources. Contains the currently loaded Video Resourcess
	std::map<std::string, VideoResource*> videoResources;
	//var: textureResources. Contains the currently loaded Texture Resourcess
	std::map<std::string, TextureResource*> textureResources;
	//var: XMLResources. Contains the currently loaded XML Resourcess
	std::map<std::string, XMLResource*> XMLResources;
	//var: fontResources. Contains the currently loaded Font Resourcess
	std::map<std::string, FontResource*> fontResources;
	//var: glProgramResources. Contains the currently loaded Shader Resourcess
	std::map<std::string, GLProgramResource*> glProgramResources;
	//var: mapResources. Contains the currently loaded Map Resourcess
	std::map<std::string, MapResource*> mapResources;
	//var: textResources. Contains the currently loaded Text Resourcess
	std::map<std::string, TextResource*> textResources;
protected:
	//function: _CheckResMgr
	//note: checks singleton
	static void _CheckResMgr();

	//function: _LoadDbIntoMap
	//note: Loads a filestring into a std::map. 
	std::map<std::string, std::string> _LoadDbIntoMap(std::string FileString, std::string resFolder);

	//function: _RequestGeneralResource
	//note: helper for Resource access. Used by the Request[ResourceTyoe]Access functions.
	template<class T>
	bool _RequestGeneralResource(std::string name, std::map<std::string, std::string>&db, std::map<std::string, T*>&resources)
	{
		//Since template functions are unreadable, some more comments here
		//Try to get a resource from the given resource set 
		auto res = resources.find(name);
		if (res == resources.end()) {
			//If not in the resource set, try to find it in the db
			auto dbdata = db.find(name);
			if (dbdata == db.end()) {
				//if not there, return false - we cannot add an unknown resource. or can we?
				//try to see if the resource loads when we give that name to it.
				T* newRes = new  T(name, name);
				if (newRes->GetName() != "invalid") { //yay
					resources[name] = newRes;
					return true;
				}
				//ok we tried
				return false;
			}
			//If we know it, Load it. T is our resource-class (i.e. AudioResource)
			T* newRes = new  T(name, dbdata->second);
			resources[name] = newRes;
			return true;
		}
		//If we have the resource in the set, increse ref count
		res->second->Access();
		return true;
	}

	//function: _RequestGeneralResource
	//note: helper for Resource access. Used by the Free[ResourceTyoe]Access functions.
	template<class T>
	void _FreeGeneralResource(std::string name, std::map<std::string, T*>&resources)
	{
		//Find res in the given resource set
		auto res = resources.find(name);
		//If we dont know the resource do nothing
		if (res != resources.end()) {
			//Decres ref count
			res->second->Free();
		}
	}

	//function: _GetGeneralResource
	//note: helper for Resource access. Used by the Get[ResourceType] functions.
	template<class T>
	T& _GetGeneralResource(std::string name, std::map<std::string, std::string>&db, std::map<std::string, T*>&resources)
	{
		//Find res in the given resource set
		auto res = resources.find(name);
		if (res != resources.end()) {
			return *res->second;
		}
		//Try to load it. Will take a long time, but better then having black tiles cause someone cant edit map files
		if (_RequestGeneralResource(name, db, resources)) {
			return *resources[name];
		}

		//Return invalid resource.
		return *(new T);
	}
};

D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(ResourceManager)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, RequestAudioResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, RequestVideoResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, RequestTextureResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, RequestXMLResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, RequestFontResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, RequestGLProgramResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, RequestMapResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, RequestTextResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, FreeAudioResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, FreeVideoResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, FreeTextureResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, FreeXMLResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, FreeFontResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, FreeGLProgramResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, FreeMapResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, FreeTextResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, GetAudioResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, GetVideoResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, GetTextureResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, GetXMLResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, GetFontResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, GetGLProgramResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, GetMapResource)
D2DCLASS_SCRIPTINFO_MEMBER(ResourceManager, GetTextResource)
D2DCLASS_SCRIPTINFO_END

//class: GameManagerException
//note: Exception that happen in the Game Manager or in classes related to it are defined below
class ResourceManagerException : public Exception
{
public:
	//constructor: ResourceManagerException() 
	//note: standart constructor 
	ResourceManagerException() : Exception() {};

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
	Resource();
	Resource(std::string resourceName);
	virtual ~Resource();

	virtual void Access();
	virtual void Free();
	virtual int  GetResourceCount();

	std::string GetName();
private:
	int references;
	std::string name;
	std::vector<char> tmpFilestring;
protected:
	SDL_RWops* _RWFromFile(std::string file);
	
};
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(Resource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Resource, std::string)
D2DCLASS_SCRIPTINFO_MEMBER(Resource, Access)
D2DCLASS_SCRIPTINFO_MEMBER(Resource, Free)
D2DCLASS_SCRIPTINFO_MEMBER(Resource, GetResourceCount)
D2DCLASS_SCRIPTINFO_MEMBER(Resource, GetName)
D2DCLASS_SCRIPTINFO_END

//class: AudioResource
//note: stores audio chunk that is used by sdl stuff
class AudioResource : public Resource
{
public:
	AudioResource();
	AudioResource(std::string name, std::string file);
	~AudioResource();

	Mix_Chunk* GetChunk() const;
private:
	Mix_Chunk* mixChunk;
};

D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(AudioResource)
D2DCLASS_SCRIPTINFO_PARENTINFO(Resource, AudioResource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(AudioResource, std::string, std::string)
D2DCLASS_SCRIPTINFO_MEMBER(AudioResource, GetChunk)
D2DCLASS_SCRIPTINFO_END

//class: VideoResource
//note: dummy, does nothing cause we dont use videos atm
class VideoResource : public Resource
{
public:
	VideoResource():Resource("invaldi"){}
	VideoResource(std::string name, std::string file):Resource("invaldi"){}
	~VideoResource(){}
private:
	
};
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(VideoResource)
D2DCLASS_SCRIPTINFO_PARENTINFO(Resource, VideoResource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(VideoResource, std::string, std::string)
D2DCLASS_SCRIPTINFO_END

//class: TextureResource
//note: stores texture gluint that is placed on the gpu
class TextureResource : public Resource
{
public:
	TextureResource();
	TextureResource(std::string name, std::string file);
	~TextureResource();

	GLuint		GetTextureId() const;
	void Bind();
private:
	GLuint texId;
	static GLuint boundTexture;
};
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(TextureResource)
D2DCLASS_SCRIPTINFO_PARENTINFO(Resource, TextureResource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(TextureResource, std::string, std::string)
D2DCLASS_SCRIPTINFO_MEMBER(TextureResource, GetTextureId)
D2DCLASS_SCRIPTINFO_END

//class: XMLResource
//note: stores script. //TODO: dont be a dummy!
class XMLResource : public Resource
{
public:
	XMLResource();
	XMLResource(std::string name, std::string file);
	~XMLResource();

	HoardXML::Document& GetDocument();
private:
	HoardXML::Document document;
};
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(XMLResource)
D2DCLASS_SCRIPTINFO_PARENTINFO(Resource, XMLResource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(XMLResource, std::string, std::string)
D2DCLASS_SCRIPTINFO_END

//class: FontResource
//note: stores font
class FontResource : public Resource
{
public:
	FontResource();
	FontResource(std::string name, std::string file);
	~FontResource();

	TTF_Font* GetFont(int size);
private:
	std::map<int,TTF_Font*>		font;
	SDL_RWops*					fontFile;
};
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(FontResource)
D2DCLASS_SCRIPTINFO_PARENTINFO(Resource, FontResource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(FontResource, std::string, std::string)
//D2DCLASS_SCRIPTINFO_MEMBER(FontResource, GetFont)
D2DCLASS_SCRIPTINFO_END

//class: GLProgramResource
//note: stores an ID for an compiled GLProgram
class GLProgramResource : public Resource
{
public:
	GLProgramResource();
	GLProgramResource(std::string name, std::string file);
	~GLProgramResource();

	GLuint GetProgramId() const;
	void Use();
	GLuint operator[](std::string uniformName);
private:
	GLuint programId;
	std::map<std::string, GLuint> uniforms;
	static GLuint boundProgram;
};
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(GLProgramResource)
D2DCLASS_SCRIPTINFO_PARENTINFO(Resource, GLProgramResource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(GLProgramResource, std::string, std::string)
D2DCLASS_SCRIPTINFO_MEMBER(GLProgramResource, GetProgramId)
D2DCLASS_SCRIPTINFO_MEMBER(GLProgramResource, Use)
D2DCLASS_SCRIPTINFO_OPERATOR(GLProgramResource, operator[], [])
D2DCLASS_SCRIPTINFO_END

//class: MapResource
//note:  Stores a map. the thing players walk on. Really. TODO: DONT BE SO DUMMY!!!
class MapResource : public Resource
{
public:
	MapResource() :Resource("invalid"){};
	MapResource(std::string name, std::string file) :Resource("invalid"){}
	~MapResource(){}
private:
};
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(MapResource)
D2DCLASS_SCRIPTINFO_PARENTINFO(Resource, MapResource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(MapResource, std::string, std::string)
D2DCLASS_SCRIPTINFO_END

//class: TextResource
//note: Contains text. The written one. Used for localization and stuff
class TextResource : public Resource
{
public:
	TextResource();
	TextResource(std::string name, std::string file);
	~TextResource();

	std::string operator[](std::string);
private:
	std::map<std::string, std::string> TextContainer;
};
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(TextResource)
D2DCLASS_SCRIPTINFO_PARENTINFO(Resource, TextResource)
D2DCLASS_SCRIPTINFO_CONSTRUCTOR(TextResource, std::string, std::string)
D2DCLASS_SCRIPTINFO_OPERATOR(TextResource, operator[], [])
D2DCLASS_SCRIPTINFO_END

}; //namespace Dragon2D
