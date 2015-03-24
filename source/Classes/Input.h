#pragma once

#include "base.h"
#include "BaseClass.h"

namespace Dragon2D
{
	typedef std::function<void(bool)> InputEventFunction;
	typedef std::function<void(bool, float, float)> InputEventAxisFunction;
	
	class InputEvent;
	class InputEventHook;

	//class: Input
	//note: Input management.
	class Input
	{
	public:
		Input();
		~Input();

		void Update(SDL_Event e);

		void AddHook(std::string e, BaseClassPtr obj, InputEventFunction f);
		void AddHook(std::string e, BaseClassPtr obj, InputEventAxisFunction f);

		void RemoveHooks(BaseClassPtr obj);
		
	private:
		std::map<std::string, InputEvent> events;
	protected:

	};

	class InputEvent
	{
	public:
		InputEvent();
		std::string name;
		bool isKeyboardEvent;
		bool isMouseEvent;
		bool isMouseAxisEvent;
		std::string key;
		SDL_Keycode keycode;
		int mouseButton;
		std::vector<InputEventHook> hooks;
	};

	class InputEventHook
	{
	public:
		BaseClassPtr object;
		void operator()(bool down, float x, float y);
		InputEventFunction eventfunc;
		InputEventAxisFunction axiseventfunc;
	};

	class InputException : public Exception
	{
	public:
		//constructor: GameManagerException() 
		//note: standart constructor 
		InputException() : Exception() {};

		//constructor:  GameManagerException(std::string managerError)
		//note: takes an manager error as argument 
		InputException(const char* managerError) : Exception(managerError) {};

		~InputException() throw() {};
	};
}; //namespace Dragon2D