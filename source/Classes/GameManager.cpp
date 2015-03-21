#include "GameManager.h"

namespace Dragon2D {

GameManager* GameManager::activeGameManager = nullptr;

GameManager::GameManager() 
	: isRunning(false)
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
	while (isRunning) {
		SDL_Event e;
		//Handle Events
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
		}
		toAdd.clear();


		//Update
		if (updateCallback) {
			updateCallback(0.0f);
		}
		for (auto e : elements) {
			e->Update();
		}

		//Render Everything
		Env::ClearFramebuffer();
		if (renderCallback) {
			renderCallback(0.0f);
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


}; //namespace Dragon2D