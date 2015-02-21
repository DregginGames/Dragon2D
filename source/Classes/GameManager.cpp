#include "GameManager.h"

namespace Dragon2D {

GameManager::GameManager() 
: resourceManager()
{
	
}

GameManager::~GameManager()
{

}

ResourceManager& GameManager::GetResourceManager()
{
	return resourceManager;
}

}; //namespace Dragon2D