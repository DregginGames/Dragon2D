#pragma once

#include "BaseClass.h"
#include "base.h"
#include "Env.h"
#include "ResourceManager.h"

namespace Dragon2D {

	//The ticksize, also known as DeltaT. It always the same, causing a constant outcome/time for everything
	//Updates happen n times per second, so dt is 1/n.
	const double ticksize = 1.0/30.0;

	typedef std::function<void(void)> UpdateCallback;
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
	//param:	c: a function that will be called at the beginn of every update.
	//			r: a function that will be called at the begin of each render
	void RunGame(UpdateCallback c = UpdateCallback(), UpdateCallback r = UpdateCallback());

	//function: Preload
	//note: loads all contend needed by the game and does what needs to be done. Normally called by RunGame().
	void Preload();

	//function: Add
	//note: Adds a element to this Manager
	//param:	e: the element to add
	void Add(BaseClassPtr e);

	//function: Quit
	//note: Hard-quits the engine, by setting isRunning to false. Not reccomended outside of the main menu (thats where its used...)
	void Quit();

	//function: Remove
	//note: Removes a element from this manager
	//param:	e: the element to remove
	void Remove(BaseClassPtr e);



	//function: CurrentManager()
	//note: Returns the current manager
	static GameManager& CurrentManager();

private:
	//var: ActiveGameManager. current gamemanager
	static GameManager* activeGameManager;

	//var: updateCallback. function to call on every update
	UpdateCallback updateCallback;
	//var: renderCallback. function to call on every update
	UpdateCallback renderCallback;

	//var: elements. holds all the elements of this manager
	std::vector<BaseClassPtr> elements;

	//var: toDelete. holds all the elemeents to remove from this manager. remove is performed every frame
	std::vector<BaseClassPtr> toDelete;
	//var: toAdd. holds all elements that will be added to this manager. add is performed after the remove.
	std::vector<BaseClassPtr> toAdd;

	//var: isRunning
	bool isRunning;
	
	//var: ticks since call to RunGame
	unsigned long ticks; 
protected:
	static void _CheckManager();
};

//Script Info for the game Manager.
D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(GameManager)
D2DCLASS_SCRIPTINFO_MEMBER(GameManager, RunGame)
D2DCLASS_SCRIPTINFO_MEMBER(GameManager, Preload)
D2DCLASS_SCRIPTINFO_MEMBER(GameManager, Add)
D2DCLASS_SCRIPTINFO_MEMBER(GameManager, Remove)
D2DCLASS_SCRIPTINFO_MEMBER(GameManager, CurrentManager)
D2DCLASS_SCRIPTINFO_MEMBER(GameManager, Quit)
D2DCLASS_SCRIPTINFO_END

//class: GameManagerException
//note: Exception that happen in the Game Manager or in classes related to it are defined below
class GameManagerException : public Exception
{
public:
	//constructor: GameManagerException() 
	//note: standart constructor 
	GameManagerException() : Exception() {};

	//constructor:  GameManagerException(std::string managerError)
	//note: takes an manager error as argument 
	GameManagerException(const char* managerError) : Exception(managerError) {};

	~GameManagerException() throw() {};
};

}; //namespace Dragon2D
