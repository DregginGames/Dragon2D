#include "GameManager.h"

namespace Dragon2D {

GameManager* GameManager::activeGameManager = nullptr;

GameManager::GameManager() 
	: isRunning(false), ticks(0)
{
	if (activeGameManager != nullptr) {
		throw GameManagerException("Only one instance of GameManager is allowed!");
	}
	activeGameManager = this;
}

GameManager::~GameManager()
{
	activeGameManager = nullptr;
}

GameManager& GameManager::CurrentManager()
{
	_CheckManager();
	return *activeGameManager;
}

void GameManager::Add(BaseClassPtr e)
{
	toAdd.push_back(e);
}

void GameManager::Remove(BaseClassPtr e)
{
	toDelete.push_back(e);
}

void GameManager::Preload()
{

}

void GameManager::RunGame(UpdateCallback c, UpdateCallback r)
{
	_CheckManager();
	updateCallback = c;
	renderCallback = r;
	isRunning = true;

	std::chrono::high_resolution_clock::time_point curtime = std::chrono::high_resolution_clock::now();
	double timeLeft = 0.0;
	while (isRunning) {
		std::chrono::high_resolution_clock::time_point newTime = std::chrono::high_resolution_clock::now();
		timeLeft+=std::chrono::duration_cast<std::chrono::duration<double>>(newTime-curtime).count();
		curtime = newTime;

		SDL_Event e;
		//Handle Events. These arnt tick events!
		while (SDL_PollEvent(&e)) {
			Env::HandleEvent(e);
			switch (e.type) {
			case SDL_QUIT:
				isRunning = false;
			default:
				break;
			}
		}

		//remove object marked as to delete
		for (auto e : toDelete) {
			//input hooks are only active while being part of the game manager
			e->RemoveInputHooks();
			for (auto c = elements.begin(); c != elements.end(); c++) {
				if (*c == e) {
					elements.erase(c);
					break;
				}
			}
		}
		toDelete.clear();

		//add objects marked as to add
		for (auto e : toAdd) {
			elements.push_back(e);
			//input hooks are only active while being part of the game manager
			e->RegisterInputHooks();
		}
		toAdd.clear();


		//Update - delta div dt times!
		while(timeLeft>=ticksize) {
			BaseClass::IncTick();
			ticks++;
			if (updateCallback) {
				updateCallback();
			}
			for (auto e : elements) {
				e->Update();
			}
			timeLeft-=ticksize;
		}

		//Render Everything
		Env::ClearFramebuffer();
		if (renderCallback) {
			renderCallback();
		}

		auto stillToRender = elements;
		for (unsigned int curlayer = 0; stillToRender.size() > 0; curlayer++) {
			for (auto c = stillToRender.begin(); c != stillToRender.end(); c++) {
				if ((*c)->GetRenderLayer() <= curlayer) {
					(*c)->Render();
					c = stillToRender.erase(c);
					if (c == stillToRender.end()) break;
				}
			}
		}
		/*
		for (auto e : elements) {
			e->Render();
		}
		*/
		Env::SwapBuffers();

	}
	
	//Elements that are still existent need thier cleanup, too
	//so remove input hooks and stuff
	for (auto e : elements) {
		e->RemoveInputHooks();
	}
	elements.clear();
}

void GameManager::_CheckManager()
{
	if (activeGameManager == nullptr) {
		throw GameManagerException("Tried to use invalid game manager!");
	}
}

void GameManager::Quit()
{
	isRunning = false;
}

void GameManager::Save(std::string name)
{
	SaveState root;
	root.SetName("root");
	for (auto e : elements) {
		SaveStatePtr elemState;
		e->SaveObjectState(elemState);
		root.AddChild(elemState);
	}
	root.SaveToFile(std::string("save/") + name + ".sav");
}

void GameManager::Load(std::string name)
{
	SaveStatePtr root(new SaveState(std::string("save/") + name + ".sav"));
	for (auto e : root->GetChildren()) {
		BaseClassPtr elem = Typehelper::Create(e->GetName());
		if (elem) {
			elem->RestoreObjectState(e);
			Add(elem);
		}
	}
}


}; //namespace Dragon2D
