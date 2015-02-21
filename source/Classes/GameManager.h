#pragma once

#include "BaseClass.h"
#include "base.h"
#include "Env.h"
#include "ResourceManager.h"

namespace Dragon2D {

//class: GameManager
//note: Manages the Game, including Handling the Scene Elements, Maps, Updates, ...
class GameManager
{
public:
	//constructor: GameManager
	//note: Standart Constructor. 
	GameManager();
	
	//destructor: ~GameManager()
	//note: standart destructor
	~GameManager();

	//function: RunGame()
	//note: starts the game
	void RunGame();

	//function: Preload
	//note: loads all contend needed by the game and does what needs to be done. Normally called by RunGame().
	void Preload();

	//function: GetResourcemanager
	//note: returns the resourceManager
	ResourceManager& GetResourceManager();

private:
	//var ResourceManager. The Games ResourceManager
	ResourceManager resourceManager;
protected:

};


//class: GameManagerException
//note: Exception that happen in the Game Manager or in classes related to it are defined below
class GameManagerException : public Exception
{
public:
	//constructor: GameManagerException() 
	//note: standart constructor 
	GameManagerException() : GameManagerException() {};

	//constructor:  GameManagerException(std::string managerError)
	//note: takes an manager error as argument 
	GameManagerException(const char* managerError) : Exception(managerError) {};

	~GameManagerException() throw() {};
};

}; //namespace Dragon2D