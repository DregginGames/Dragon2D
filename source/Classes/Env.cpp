//file: Env.cpp
//contains functions for the env class 

#include "Env.h"

namespace Dragon2D {

	static const GLfloat g_quad[] = {
		-1.0f, -1.0f, 0.0f,
		1.0f, -1.0f, 0.0f,
		-1.0f, 1.0f, 0.0f,
		-1.0f, 1.0f, 0.0f,
		1.0f, -1.0f, 0.0f,
		1.0f, 1.0f, 0.0f,
	};

	Env*			Env::ActiveEnv = nullptr;
	std::ostream	Env::streamOut(NULL);
	std::ostream	Env::streamOutError(NULL);
	std::ofstream	Env::logfile;
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

		//outputstreams 
		//Normally we want to write to the logfile, but if that isn't possible well write to stdfoo
		try {
			logfile.open("log.txt", std::ios::out);
			streamOut.rdbuf(logfile.rdbuf());
			streamOutError.rdbuf(logfile.rdbuf());
		}
		catch (std::exception e) {
			std::cerr << "Cannot Open logfile, will write to stdout and strerr!" << std::endl;
			streamOut.rdbuf(std::cout.rdbuf());
			streamOutError.rdbuf(std::cerr.rdbuf());
		}


		//Defualt the arguments
		isDebug = false;
		gamepath = "./";
		engineInitName = "";

		try {
			//Parse the input arguments 
			for (int i = 1; i < argc; i++) {
				std::string arg(argv[i]);
				std::string argparam("");
				if (i + 1 < argc) {
					argparam = std::string(argv[i + 1]);
				}
				//-d setting enables debug, so text is written directly to the console
				if (arg == std::string("-d")) {
					isDebug = true;
				}
				//-c sets a custom path to an engine settings file
				if (arg == std::string("-c")) {
					engineInitName = argparam;
					i++;
				}
				//otherwise we assume that the stuff is the games path
				else {
					gamepath = arg;
				}
			}
			if (engineInitName == "") {
				engineInitName = gamepath + "cfg/settings.cfg";
			}

		}
		catch (std::exception e) {
			throw EnvException("Cannot Parse Arguments! Syntax is \"Dragon2D [options] <gamepath> [options]\"");
		}

		if (isDebug) {
			//In case we're debugging we want stuff directly on the console!
			streamOut.rdbuf(std::cout.rdbuf());
			streamOutError.rdbuf(std::cerr.rdbuf());
		}

		Out() << "Starting Init of the ENV" << std::endl;

		Out() << "Loading Settings" << std::endl;
		//read in the engine setting file
		settings.insert(std::make_pair(std::string(engineInitName), SettingFile(engineInitName)));

		//read in the game setting file
		gameInitName = gamepath;
		gameInitName += "GameInit.txt";
		settings.insert(std::make_pair(gameInitName, SettingFile(gameInitName)));

		Out() << "Starting SDL" << std::endl;
		//fire up SDL
		if (SDL_Init(SDL_INIT_EVERYTHING) < 0) {
			throw EnvException("Cannot Initialize SDL2!");
		}

		Out() << "Opening Window" << std::endl;
		//shall the window be fullscreem?
		bool isFullscreen = false;
		if (settings[engineInitName]["isFullscreen"] == std::string("true")) {
			isFullscreen = true;
		}

		int width = stoi(settings[engineInitName]["width"]);
		int height = stoi(settings[engineInitName]["height"]);

		//try out some opengl-configs and fire up the window
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

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

		resolution = glm::vec2(width, height);

		Out() << "Init OpenGL" << std::endl;
		//Fire up glew and the context!
		context = SDL_GL_CreateContext(window);
		if (!context) {
			throw EnvException("Cannot create context!");
		}

		//check if we use vsync
		if (settings[engineInitName]["isVsync"] == std::string("true")) {
			SDL_GL_SetSwapInterval(1);
		}

		Out() << "Init glew" << std::endl;
		//from here, opengl is working!
		//But we need glew for the fancy shader stuff, so
		glewExperimental = GL_TRUE;
		GLenum err = glewInit();
		if (GLEW_OK != err) {
			std::string glewError = (char*)(glewGetErrorString(err));
			throw EnvException((std::string("Cannot Init glew: ") + glewError).c_str());
		}

		glGenVertexArrays(1, &vertexArray);
		std::cout << glGetError() << std::endl;
		glBindVertexArray(vertexArray);
		glGenBuffers(1, &quadBuffer);
		glBindBuffer(GL_ARRAY_BUFFER, quadBuffer);
		glBufferData(GL_ARRAY_BUFFER, sizeof(g_quad), g_quad, GL_STATIC_DRAW);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


		Out() << "Init Sound (sdl_mixer)" << std::endl;
		//Next is sound. We use SDL_mixer.
		int mixerInitFlags = 0;
		if (settings[engineInitName]["requestMP3"] == std::string("true")) {
			mixerInitFlags |= MIX_INIT_MP3;
		}
		if (settings[engineInitName]["requestOGG"] == std::string("true")) {
			mixerInitFlags |= MIX_INIT_OGG;
		}
		if (settings[engineInitName]["requestMOD"] == std::string("true")) {
			mixerInitFlags |= MIX_INIT_MOD;
		}
		if (settings[engineInitName]["requestFLAC"] == std::string("true")) {
			mixerInitFlags |= MIX_INIT_FLAC;
		}
		if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 4096) != 0) {
			throw EnvException("Could not open Audio Device!");
		}
		int inittedMixerFlags = Mix_Init(mixerInitFlags);
		//Hope that all modes were supported, but dont think that it will always work!
		if (mixerInitFlags != inittedMixerFlags) {
			//aand the bad thing happend
			throw EnvException("Could not Load all mixer modules. Did you include all libs for the requested modes?");
		}
		//set channels
		int mixChannels = atoi(settings[engineInitName]["channels"].c_str());
		Mix_AllocateChannels(mixChannels);

		//For image we basically do the same as in the mixer init
		Out() << "Init Image (sdl_image)" << std::endl;
		int imageInitFlags = 0;

		if (settings[engineInitName]["requestJPG"] == std::string("true")) {
			imageInitFlags |= IMG_INIT_JPG;
		}
		if (settings[engineInitName]["requestPNG"] == std::string("true")) {
			imageInitFlags |= IMG_INIT_PNG;
		}
		if (settings[engineInitName]["requestTIF"] == std::string("true")) {
			imageInitFlags |= IMG_INIT_TIF;
		}
		if (settings[engineInitName]["requestWEBP"] == std::string("true")) {
			imageInitFlags |= IMG_INIT_WEBP;
		}
		int imageInitResult = IMG_Init(imageInitFlags);
		if (imageInitFlags != imageInitResult) {
			//aand the bad thing happend
			throw EnvException("Could not Load all image modules. Did you include all libs for the requested modes?");
		}

		//Font is an easy call to the ttf_init function. 
		Out() << "Init Font (sdl_ttf)" << std::endl;
		if (TTF_Init() != 0) {
			throw EnvException("Could not init SDL_TTF!");
		}

		//in the end fire up the resource manager
		resourceManager.reset(new ResourceManager);

		//fire up input
		input.reset(new Input);

		Out() << "Give information to TailTipUI" << std::endl;
		TailTipUI::Info(settings[gameInitName]["title"], width, height);
		TailTipUI::Info::SetMouseCallback(Env::GetCurrentMouseState);
		TailTipUI::Info::SetButtonCallback(Env::GetCurrentKeysRaw);
		TailTipUI::Info::SetImageCallback([this](std::string name) {
			return resourceManager->GetTextureResource(name).GetTextureId();
		});
		TailTipUI::Info::SetFontCallback([this](std::string name, int size) {
			return resourceManager->GetFontResource(name).GetFont(size);
		});
		TailTipUI::Info::SetTextBufferResetCallback(Env::ResetCurrentTextInput);
		TailTipUI::Info::SetGetTextBufferCallback(Env::GetCurrentText);
		SDL_StartTextInput();
		Out() << "Done!" << std::endl;
		//yay
	}

	Env::~Env()
	{
		input.reset();
		resourceManager.reset();
		Mix_Quit();
		SDL_GL_DeleteContext(context);
		SDL_DestroyWindow(window);
		SDL_Quit();
		ActiveEnv = nullptr;
	}

	Env& Env::GetActiveEnv()
	{
		_CheckEnv();
		return *ActiveEnv;
	}

	void Env::_CheckEnv()
	{
		if (ActiveEnv == nullptr) {
			throw EnvException("Tried to call Env function without initialise the Env!");
		}
	}

	bool Env::IsDebugEnv()
	{
		_CheckEnv();
		return ActiveEnv->isDebug;
	}

	const std::string Env::GetGamepath()
	{
		_CheckEnv();
		return ActiveEnv->gamepath;
	}

	void Env::SwapBuffers()
	{
		_CheckEnv();
		SDL_GL_SwapWindow(ActiveEnv->window);
	}

	void Env::ClearFramebuffer(bool colorbuffer, bool depthbuffer)
	{
		_CheckEnv();
		glClear((colorbuffer ? GL_COLOR_BUFFER_BIT : 0) | (depthbuffer ? GL_DEPTH_BUFFER_BIT : 0));
	}

	Framebuffer Env::GenerateFramebuffer(int w, int h)
	{
		_CheckEnv();
		Framebuffer f;

		GLuint FramebufferName = 0;
		glGenFramebuffers(1, &FramebufferName);
		glBindFramebuffer(GL_FRAMEBUFFER, FramebufferName);

		GLuint renderedTexture;
		glGenTextures(1, &renderedTexture);

		// "Bind" the newly created texture : all future texture functions will modify this texture
		glBindTexture(GL_TEXTURE_2D, renderedTexture);

		// Give an empty image to OpenGL ( the last "0" )
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);

		// Poor filtering. Needed !
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

		// The depth buffer
		GLuint depthrenderbuffer;
		glGenRenderbuffers(1, &depthrenderbuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, depthrenderbuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, w, h);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthrenderbuffer);

		// Set "renderedTexture" as our colour attachement #0
		glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, renderedTexture, 0);

		// Set the list of draw buffers.
		GLenum DrawBuffers[1] = { GL_COLOR_ATTACHMENT0 };
		glDrawBuffers(1, DrawBuffers); // "1" is the size of DrawBuffers
		if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) Env::Err() << "Error while Creating Framebuffer!" << std::endl;
		else {
			f.fboId = FramebufferName;
			f.texId = renderedTexture;
			f.depthId = depthrenderbuffer;
		}
		return f;
	}

	void Env::RenderQuad()
	{
		_CheckEnv();
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, ActiveEnv->quadBuffer);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);
		glDrawArrays(GL_TRIANGLES, 0, 6);
		glDisableVertexAttribArray(0);
	}

	glm::vec2 Env::GetResolution()
	{
		_CheckEnv();
		return ActiveEnv->resolution;
	}

	glm::vec4 Env::GetCurrentMouseState()
	{
		_CheckEnv();
		int x, y;
		Uint32 buttonstate = SDL_GetMouseState(&x, &y);
		bool l = buttonstate & SDL_BUTTON(SDL_BUTTON_LEFT);
		bool r = buttonstate & SDL_BUTTON(SDL_BUTTON_RIGHT);
		return glm::vec4(x / ActiveEnv->resolution.x, y / ActiveEnv->resolution.y, l ? 1 : 0, r ? 1 : 0);
	}

	void Env::Gamefile(std::string file, std::ios_base::openmode mode, std::fstream &stream)
	{
		_CheckEnv();
		return stream.open(ActiveEnv->GetGamepath() + file, mode);
	}

	ResourceManager& Env::GetResourceManager()
	{
		_CheckEnv();
		return *(ActiveEnv->resourceManager);
	}

	Input& Env::GetInput()
	{
		_CheckEnv();
		return *(ActiveEnv->input);
	}

	void Env::Enginefile(std::string file, std::ios_base::openmode mode, std::fstream &stream)
	{
		_CheckEnv();
		return stream.open(file, mode);
	}

	SettingFile& Env::Setting(std::string file)
	{
		_CheckEnv();
		std::map<std::string, SettingFile>::iterator pos;
		if ((pos = ActiveEnv->settings.find(file)) == ActiveEnv->settings.end()) {
			ActiveEnv->settings.insert(std::make_pair(file, SettingFile(file)));
			return ActiveEnv->settings[file];
		}
		else {
			return pos->second;
		}
	}

	std::ostream& Env::Out()
	{
		//dont check env since the streams are static
		return streamOut;
	}

	std::ostream& Env::Err()
	{
		//dont check env since the streams are static
		return streamOutError;
	}

	void Env::HandleEvent(SDL_Event&e)
	{
		_CheckEnv();
		ActiveEnv->currentKeyInputs.clear();
		ActiveEnv->input->Update(e);
		switch (e.type) {
		case SDL_TEXTINPUT:
			ActiveEnv->currentText += e.text.text;
			ActiveEnv->currentKeyInputs.push_back(e.text.text);
			break;
		case SDL_TEXTEDITING:
			std::cout << e.edit.text << std::endl;
			break;
		case SDL_KEYDOWN:
			if (e.key.keysym.sym == SDLK_BACKSPACE) {
				if (ActiveEnv->currentText.size() > 0) {
					ActiveEnv->currentText.pop_back();
				}
			}
			break;
		}
	}

	std::list<std::string> Env::GetCurrentKeys()
	{
		_CheckEnv();
		return ActiveEnv->currentKeyInputs;
	}

	void Env::ResetCurrentTextInput()
	{
		_CheckEnv();
		ActiveEnv->currentText = "";
	}

	std::string Env::GetCurrentText()
	{
		_CheckEnv();
		return  ActiveEnv->currentText;
	}

	void Env::SetCurrentTextInput(std::string t)
	{
		_CheckEnv();
		ActiveEnv->currentText = t;
	}

	const Uint8* Env::GetCurrentKeysRaw()
	{
		_CheckEnv();
		SDL_PumpEvents();
		return SDL_GetKeyboardState(NULL);
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
		std::fstream infile(inFile.c_str(), std::ios::in);
		if (!infile.is_open()) {
			throw EnvException("Cannot open a settings file!");
		}
		std::string infileString((std::istreambuf_iterator<char>(infile)), std::istreambuf_iterator<char>());

		std::regex e("\\s*(\\w*[\\w\\d]*)\\s*=\\s*([\\w\\d ]*)\\s*\n*");
		std::smatch m;
		std::string s(infileString);
		while (std::regex_search(s, m, e)) {
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



}; //namespace Dragon2D
