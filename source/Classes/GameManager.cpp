#include "GameManager.h"

namespace Dragon2D {

GameManager* GameManager::activeGameManager = nullptr;

GameManager::GameManager() 
	: resourceManager(), isRunning(false)
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

ResourceManager& GameManager::GetResourceManager()
{
	return resourceManager;
}

void GameManager::Add(BaseClassPtr e)
{
	elements.push_back(e);
}

void GameManager::Remove(BaseClassPtr e)
{
	for (auto c = elements.begin(); c != elements.end(); c++) {
		if (*c == e) {
			elements.erase(c);
			break;
		}
	}
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
			switch (e.type) {
			case SDL_QUIT:
				isRunning = false;
			default:
				break;
			}
		}

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
		for (auto e : elements) {
			e->Render();
		}
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