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
	std::fstream audioDbFile;
	Env::Gamefile("audio/audio.db", std::ios::in, audioDbFile);
	if (!audioDbFile.is_open()) throw ResourceManagerException("Can't load Audio DB file");

	std::fstream videoDbFile;
	Env::Gamefile("video/video.db", std::ios::in, videoDbFile);
	if (!videoDbFile.is_open()) throw ResourceManagerException("Can't load Video DB file");

	std::fstream textureDbFile;
	Env::Gamefile("texture/texture.db", std::ios::in, textureDbFile);
	if (!textureDbFile.is_open()) throw ResourceManagerException("Can't load Texture DB file");

	std::fstream scriptDbFile;
	Env::Gamefile("script/script.db", std::ios::in, scriptDbFile);
	if (!scriptDbFile.is_open()) throw ResourceManagerException("Can't load Script DB file");

	std::fstream fontDbFile;
	Env::Gamefile("font/font.db", std::ios::in,fontDbFile);
	if (!fontDbFile.is_open()) throw ResourceManagerException("Can't load Font DB file");

	std::fstream glProgramDbFile;
	Env::Gamefile("shader/shader.db", std::ios::in,glProgramDbFile);
	if (!glProgramDbFile.is_open()) throw ResourceManagerException("Can't load Shader DB file");

	std::fstream mapDbFile;
	Env::Gamefile("map/map.db", std::ios::in,mapDbFile);
	if (!mapDbFile.is_open()) throw ResourceManagerException("Can't load Map DB file");

	std::fstream textDbFile;
	Env::Gamefile("text/text.db", std::ios::in, textDbFile);
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
	audioDb = _LoadDbIntoMap(audioDbFileString, "audio/");
	videoDb = _LoadDbIntoMap(videoDbFileString, "video/");
	textureDb = _LoadDbIntoMap(textureDbFileString, "texture/");
	scriptDb = _LoadDbIntoMap(scriptDbFileString, "script/");
	fontDb = _LoadDbIntoMap(fontDbFileString, "font/");
	glProgramDb = _LoadDbIntoMap(glProgramDbFileString, "shader/");
	mapDb = _LoadDbIntoMap(mapDbFileString, "map/");
	textDb = _LoadDbIntoMap(textDbFileString, "text/");
	Env::Out() << "Done!" << std::endl;
}

ResourceManager::~ResourceManager()
{
	ActiveManager = nullptr;
}

void ResourceManager::RequestAudioResource(std::string name)
{

	if (!_RequestGeneralResource<AudioResource>(name,audioDb,audioResources)) {
		Env::Err() << "ERROR: Cannot load Audio Resource: " << name << std::endl;
		return;
	}
}

void ResourceManager::FreeAudioResource(std::string name)
{
	_FreeGeneralResource<AudioResource>(name,  audioResources);
}


void ResourceManager::RequestVideoResource(std::string name)
{
	if (!_RequestGeneralResource<VideoResource>(name, videoDb, videoResources)) {
		Env::Err() << "ERROR: Cannot load Audio Resource: " << name << std::endl;
		return;
	}
}

void ResourceManager::FreeVideoResource(std::string name)
{
	_FreeGeneralResource<VideoResource>(name, videoResources);
}


void ResourceManager::RequestTextureResource(std::string name)
{
	if (!_RequestGeneralResource<TextureResource>(name, textureDb, textureResources)) {
		Env::Err() << "ERROR: Cannot load texture resource: " << name << std::endl;
		return;
	}
}

void ResourceManager::FreeTextureResource(std::string name)
{
	_FreeGeneralResource<TextureResource>(name, textureResources);
}


void ResourceManager::RequestScriptResource(std::string name)
{
	if (!_RequestGeneralResource<ScriptResource>(name, scriptDb, scriptResources)) {
		Env::Err() << "ERROR: Cannot load script resource: " << name << std::endl;
		return;
	}
}

void ResourceManager::FreeScriptResource(std::string name)
{
	_FreeGeneralResource<ScriptResource>(name, scriptResources);
}


void ResourceManager::RequestFontResource(std::string name)
{
	if (!_RequestGeneralResource<FontResource>(name, fontDb, fontResources)) {
		Env::Err() << "ERROR: Cannot load font resource: " << name << std::endl;
		return;
	}
}

void ResourceManager::FreeFontResource(std::string name)
{
	_FreeGeneralResource<FontResource>(name, fontResources);
}


void ResourceManager::RequestGLProgramResource(std::string name)
{
	if (!_RequestGeneralResource<GLProgramResource>(name, glProgramDb, glProgramResources)) {
		Env::Err() << "ERROR: Cannot load shader resource: " << name << std::endl;
		return;
	}
}

void ResourceManager::FreeGLProgramResource(std::string name)
{
	_FreeGeneralResource<GLProgramResource>(name, glProgramResources);
}


void ResourceManager::RequestMapResource(std::string name)
{
	if (!_RequestGeneralResource<MapResource>(name, mapDb, mapResources)) {
		Env::Err() << "ERROR: Cannot load map resource: " << name << std::endl;
		return;
	}
}

void ResourceManager::FreeMapResource(std::string name)
{
	_FreeGeneralResource<MapResource>(name, mapResources);
}


void ResourceManager::RequestTextResource(std::string name)
{
	if (!_RequestGeneralResource<TextResource>(name, textDb, textResources)) {
		Env::Err() << "ERROR: Cannot load text resource: " << name << std::endl;
		return;
	}
}

void ResourceManager::FreeTextResource(std::string name)
{
	_FreeGeneralResource<TextResource>(name, textResources);
}


AudioResource& ResourceManager::GetAudioResource(std::string name)
{
	return _GetGeneralResource<AudioResource>(name, audioDb, audioResources);
}

VideoResource& ResourceManager::GetVideoResource(std::string name)
{
	return _GetGeneralResource<VideoResource>(name, videoDb, videoResources);
}

TextureResource& ResourceManager::GetTextureResource(std::string name)
{
	return _GetGeneralResource<TextureResource>(name, textureDb, textureResources);
}

ScriptResource& ResourceManager::GetScriptResource(std::string name)
{
	return _GetGeneralResource<ScriptResource>(name, scriptDb, scriptResources);
}

FontResource& ResourceManager::GetFontResource(std::string name)
{
	return _GetGeneralResource<FontResource>(name, fontDb, fontResources);
}

GLProgramResource& ResourceManager::GetGLProgramResource(std::string name)
{
	return _GetGeneralResource<GLProgramResource>(name, glProgramDb, glProgramResources);
}

MapResource& ResourceManager::GetMapResource(std::string name)
{
	return _GetGeneralResource<MapResource>(name, mapDb, mapResources);
}

TextResource& ResourceManager::GetTextResource(std::string name)
{
	return _GetGeneralResource<TextResource>(name, textDb, textResources);
}


std::map<std::string, std::string> ResourceManager::_LoadDbIntoMap(std::string FileString, std::string resFolder)
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
		tmpMap[m2[1]] = resFolder+m[1].str();
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
Resource::Resource()
	: references(-1), name("invalid")
{

}

Resource::Resource(std::string resourceName)
: references(1), name("invalid")
{

}

Resource::~Resource()
{

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
	std::fstream infile;
	Env::Gamefile(file, std::ios::in | std::ios::binary, infile);
	if (!infile.is_open()) {
		Env::Err() << "Cold not open " << file << "Resource will be empty!";
		return nullptr;
	}
	tmpFilestring = std::vector<char>(std::istreambuf_iterator<char>(infile), std::istreambuf_iterator<char>());
	newRwOps = SDL_RWFromMem((void*)&tmpFilestring.data()[0], tmpFilestring.size());
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
		Env::Err() << "Error Loading Mix Chunk for " << file << "! Sound will be empty! " << Mix_GetError() << std::endl;
	}
}

AudioResource::~AudioResource() 
{
	Mix_FreeChunk(mixChunk);
}

Mix_Chunk* AudioResource::GetChunk() const
{
	return mixChunk;
}

GLuint TextureResource::boundTexture = 0;

TextureResource::TextureResource()
: Resource("invalid")
{

}

TextureResource::TextureResource(std::string name, std::string file)
: Resource(name)
{
	texId = GL_INVALID_VALUE;
	//Create SDL_Surface from input file
	SDL_RWops *textureFile = _RWFromFile(file);
	if (!textureFile) {
		Env::Err() << "Could not Load Texture, using dummy texture" << std::endl;
		return;
	}
	SDL_Surface *newTexture = IMG_Load_RW(textureFile, 1);
	if (!newTexture) {
		Env::Err() << "Could not Load Texture, using dummy texture" << std::endl;
		return;
	}
	

	texId = TailTipUI::SurfaceToTexture(newTexture);
}

TextureResource::~TextureResource()
{
	//Free the texture on the gpu
	glDeleteTextures(1, &texId);
}

GLuint TextureResource::GetTextureId() const
{
	return texId;
}

void TextureResource::Bind()
{
	if (texId != boundTexture && texId != 0) {
		glBindTexture(GL_TEXTURE_2D, texId);
		boundTexture = texId;
	}
}

//Script resource is still a dummy. Will be implemetet as soon as the scripting system has been written/implementet/whatever
ScriptResource::ScriptResource() 
: Resource("invalid")
{
}
ScriptResource::ScriptResource(std::string name, std::string file) 
: Resource("invalid")
{
}
ScriptResource::~ScriptResource()
{
}


//Font rescource stores fonts for text rendering
FontResource::FontResource()
: Resource("invalid")
{
}

FontResource::FontResource(std::string name, std::string file)
: Resource(name)
{
	fontFile = _RWFromFile(file);
	if (!fontFile)
	{
		return;
	}
	//TODO: fixed font size? dosnt seem like a good idea
	font[16] = TTF_OpenFontRW(fontFile, 0, 16);
	if (!font[16]) {
		Env::Err() << "Error loading 16-points-sized testfont " << file << "!(" << TTF_GetError() << ") Font will cause errors!" << std::endl;
		return;
	}
}

FontResource::~FontResource()
{ 
	for (auto fontPair = font.begin(); fontPair != font.end(); fontPair++) {
		if (fontPair->second != NULL) {  
			TTF_CloseFont(fontPair->second); 
		}

		if (fontFile != NULL) {
			SDL_RWclose(fontFile);
		}
	}
}

TTF_Font* FontResource::GetFont(int size)
{
	for (auto fontPair = font.begin(); fontPair != font.end(); fontPair++) {
		if (fontPair->first == size) {
			return fontPair->second;
		}
	}
	TTF_Font* newFont = nullptr;
	if (fontFile) {
		newFont = TTF_OpenFontRW(fontFile, 0, size);
	}
	if (!newFont) {
		Env::Out() << "Error Loading fong, will use empty (error) font!" << TTF_GetError() << std::endl;
	}
	font[size] = newFont;
	return newFont;
}

GLuint _CompileShader(std::string source, GLenum shaderType)
{
	//Create Shader and compile
	GLuint shaderObject = glCreateShader(shaderType);
	const char* src = source.c_str();
	glShaderSource(shaderObject, 1, &src, NULL);
	int compileResult = 0;
	glCompileShader(shaderObject);
	glGetShaderiv(shaderObject, GL_COMPILE_STATUS, &compileResult);
	//If we have an error, get the result. A little foo, but hey
	if (compileResult == GL_FALSE) {
		GLint logSize = 0;
		glGetShaderiv(shaderObject, GL_INFO_LOG_LENGTH, &logSize);
		std::vector<GLchar> errorLog(logSize);
		glGetShaderInfoLog(shaderObject, logSize, &logSize, &errorLog[0]);
		glDeleteShader(shaderObject);
		std::string errorString(errorLog.begin(), errorLog.end());
		Env::Err() << "Error compiling shader:\n" << errorString << std::endl;
		return 0;
	}
	return shaderObject;
}

GLuint GLProgramResource::boundProgram = 0;

GLProgramResource::GLProgramResource()
: Resource("invalid")
{
}

GLProgramResource::GLProgramResource(std::string name, std::string file)
: Resource(name)
{
	std::list<GLuint> shaderList;
	programId = 0;

	std::fstream infile;
	Env::Gamefile(file, std::ios::in, infile);
	std::string instring = std::string(std::istreambuf_iterator<char>(infile), std::istreambuf_iterator<char>());
	//well need to remove some of the comments, those that are definitly surrounding our config makros
	std::regex removeCommentRe("\\/\\/.*|\\/\\*[\\w\\d#\\s]*\\*\\/");
	std::regex configMakroRe("#define (CONFIG_\\w*)");
	std::string noCommetInString = std::regex_replace(instring, removeCommentRe, "");
	std::smatch m;
	std::string s = noCommetInString;
	while (std::regex_search(s, m, configMakroRe)) {
		std::string configName = m[1];
		GLuint newShader = 0;
		//check the config macos
		if (configName == "CONFIG_HAS_VERTEX") {
			newShader =  _CompileShader(std::string("#define CONTROL_COMPILE_VERTEX\n") + instring, GL_VERTEX_SHADER);
		}
		else if (configName == "CONFIG_HAS_FRAGMENT") {
			newShader = _CompileShader(std::string("#define CONTROL_COMPILE_FRAGMENT\n") + instring, GL_FRAGMENT_SHADER);
		}
		else if (configName == "CONFIG_HAS_GEOMETRY") {
			newShader = _CompileShader(std::string("#define CONTROL_COMPILE_GEOMETRY\n") + instring, GL_GEOMETRY_SHADER);
		}
		else if (configName == "CONFIG_HAS_TESS_EVALUATION") {
			newShader = _CompileShader(std::string("#define CONTROL_COMPILE_TESS_EVALUATION\n") + instring, GL_TESS_EVALUATION_SHADER);
		}
		else if (configName == "CONFIG_HAS_TESS_CONTROL") {
			newShader = _CompileShader(std::string("#define CONTROL_COMPILE_VERTEX_TESS_CONTROL\n") + instring, GL_TESS_CONTROL_SHADER);
		}
		else if (configName == "CONFIG_HAS_COMPUTE") {
			newShader = _CompileShader(std::string("#define CONTROL_COMPILE_VERTEX_COMPUTE\n") + instring, GL_COMPUTE_SHADER);
		}
		else {
			Env::Err() << "WARNING: unknown shader config makro: " << configName << std::endl;
		}
		//error checking
		if (newShader == 0) {
			Env::Err() << "ERROR: Shader Compilation Error in " << file << std::endl;
			//we should delete all the other shaders
			for (GLuint s : shaderList) {
				glDeleteShader(s);
			}
			shaderList.clear();
			return;
		}

		shaderList.push_back(newShader);
		s = m.suffix().str();
	}

	//Create program and add all shaders to it
	programId = glCreateProgram();
	for (GLuint shaderId : shaderList) {
		glAttachShader(programId, shaderId);
	}
	//Link them and check for errors
	glLinkProgram(programId);
	GLint isLinked = 0;
	glGetProgramiv(programId, GL_LINK_STATUS, (int*)&isLinked);
	if (isLinked == GL_FALSE) {
		GLint maxLength = 0;
		glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &maxLength);
		std::vector<char> errorLog(maxLength);
		glGetProgramInfoLog(programId, maxLength, &maxLength, &errorLog[0]);
		std::string errorString(errorLog.begin(), errorLog.end());
		Env::Err() << "Error Linking " << file << "\n" << errorString << std::endl;
		Env::Err() << "WARNING: ShaderResource will be invalid!";
		glDeleteProgram(programId);
		programId = 0;
	}
	for (GLuint shaderId : shaderList) {
		glDeleteShader(shaderId);
	}
	shaderList.clear();
}

GLProgramResource::~GLProgramResource()
{
	glDeleteProgram(programId);
}

GLuint GLProgramResource::GetProgramId() const
{
	return programId;
}


void GLProgramResource::Use()
{
	if (programId != 0 && boundProgram!=programId) {
		glUseProgram(programId);
		boundProgram = programId;
	}
}

GLuint GLProgramResource::operator[](std::string uniformName) 
{
	if (programId == 0) {
		return 0;
	}
	auto p = uniforms.find(uniformName);
	if (p == uniforms.end()) {
		GLuint newPos = glGetUniformLocation(programId, uniformName.c_str());
		uniforms[uniformName] = newPos;
		return newPos;
	}
	return p->second;
}

TextResource::TextResource()
: Resource("invalid")
{

}

TextResource::TextResource(std::string name, std::string file)
: Resource(name)
{
	std::fstream infile;
	Env::Gamefile(file, std::ios::in, infile);
	std::string filestring = std::string(std::istreambuf_iterator<char>(infile), std::istreambuf_iterator<char>());
	std::regex textRE("([\\w.])*\\s*=\\s*(.*)");
	std::smatch m;
	std::string s(filestring);
	while (std::regex_search(s, m, textRE)) {
		TextContainer[m[1]] = m[2];
		s = m.suffix().str();
	}
}

TextResource::~TextResource()
{

}

std::string TextResource::operator[](std::string key)
{
	return TextContainer[key];
}


}; //namespace Dragon2D

