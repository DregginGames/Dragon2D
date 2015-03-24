#include "Input.h"
#include "Env.h"

namespace Dragon2D
{
	SDL_Keycode StringToKeycode(std::string k);

	Input::Input()
	{
		std::string infile = Env::GetGamepath() + "cfg/input.xml";
		HoardXML::Document indoc(infile);
		auto inputs = indoc["input"];
		for (auto input : inputs) {
			if (input->GetName() == "input") {
				InputEvent newEvent;
				newEvent.name = input->GetAttribute("name");
				std::string rawEvent = input->GetAttribute("key");
				newEvent.key = rawEvent;
				//is it a mouseclick?
				unsigned int pos = rawEvent.find("MOUSE");
				if (pos!=rawEvent.npos) {
					pos += 5;
					if (pos < rawEvent.size() && rawEvent[pos] >= '0' && rawEvent[pos] <= '9') {
						newEvent.isMouseEvent = true;
						newEvent.mouseButton = rawEvent[pos] - '0';
					}
				}
				//is it an axis?
				else if (rawEvent=="AXIS") {
					newEvent.isMouseAxisEvent = true;
				}
				//NO, ITS A KEYBOARD INPUT
				else {
					newEvent.isKeyboardEvent = true;
					//turn the strings into keycodes, but only for special keys.
					//normal keys will be checked agains the event->key
					newEvent.keycode = StringToKeycode(rawEvent);
				}
				events[newEvent.name] = newEvent;
			}
			else {
				Env::Out() << "WARNING: Unknown input-tag " << input->GetName() << "!" << infile << std::endl;
			}
		}
	}

	Input::~Input()
	{
		//huh?
	}

	void Input::AddHook(std::string e, BaseClassPtr obj, InputEventFunction f)
	{
		InputEventHook newHook;
		newHook.object = obj;
		newHook.eventfunc = f;
		events[e].hooks.push_back(newHook);
	}

	void Input::AddHook(std::string e, BaseClassPtr obj, InputEventAxisFunction f)
	{
		InputEventHook newHook;
		newHook.object = obj;
		newHook.axiseventfunc = f;
		events[e].hooks.push_back(newHook);
	}

	void Input::RemoveHooks(BaseClassPtr obj)
	{
		for (auto e : events) {
			for (auto hookIter = e.second.hooks.begin(); hookIter != e.second.hooks.end(); hookIter++) {
				if (hookIter->object == obj) {
					hookIter = e.second.hooks.erase(hookIter);
				}
				if (hookIter == e.second.hooks.end()) { 
					break; 
				}
			}
		}
	}

	void Input::Update(SDL_Event e)
	{
		if (e.type == SDL_KEYDOWN || e.type == SDL_KEYUP) {
			for (auto eve : events) {
				if (eve.second.isKeyboardEvent) {
					if (SDL_GetKeyFromName(eve.second.key.c_str()) == e.key.keysym.sym
						|| eve.second.keycode == e.key.keysym.sym
						|| eve.second.key == SDL_GetKeyName(e.key.keysym.sym)) {
						for (auto h : eve.second.hooks) {
							h((e.type == SDL_KEYDOWN), 0.0f, 0.0f);
						}
					}
				}
			}
		}
		else if (e.type == SDL_MOUSEBUTTONDOWN || e.type == SDL_MOUSEBUTTONUP) {
			for (auto eve : events) {
				if (eve.second.isMouseEvent) {
					if (e.button.button == eve.second.mouseButton) {
						for (auto h : eve.second.hooks) {
							//mouse events only make sense with a position, so get it.
							glm::vec4 minfo = Env::GetCurrentMouseState();
							h((e.type == SDL_MOUSEBUTTONDOWN), minfo.x, minfo.y);
						}
					}
				}
			}
		}
		else if (e.type == SDL_MOUSEMOTION) {
			//we are lazy here
			for (auto eve : events) {
				if (eve.second.isMouseAxisEvent) {
					for (auto h : eve.second.hooks) {
						//really lazy. Todo: get the info from the event, not somwhere else
						glm::vec4 minfo = Env::GetCurrentMouseState();
						h(false, minfo.x, minfo.y);
					}
				}
			}
		}
	}

	InputEvent::InputEvent()
		: name(""), isMouseEvent(false), isKeyboardEvent(false), isMouseAxisEvent(false)
	{

	}

	void InputEventHook::operator()(bool down, float x, float y)
	{
		if (eventfunc) {
			eventfunc(down);
		}
		if (axiseventfunc) {
			axiseventfunc(down, x, y);
		}

	}


//string to sdk key cause why not.
//some additional foo cause i dont want to force anyone to use SDLK_FOO-codes (can still be used)

#define KEYHELPER_DIFF(name,result) else if(k=="KEY_"#name) { return result; } 
#define KEYHELPER(name) KEYHELPER_DIFF(name,SDLK_##name)

	SDL_Keycode StringToKeycode(std::string k)
	{
		if (k == "KEY_NONE") {
			return NULL;
		}
		KEYHELPER_DIFF(ESC, SDLK_ESCAPE)
			KEYHELPER(UP)
			KEYHELPER(DOWN)
			KEYHELPER(LEFT)
			KEYHELPER(RIGHT)
			KEYHELPER(RETURN)
			KEYHELPER(BACKSPACE)
			KEYHELPER(SPACE)
			KEYHELPER_DIFF(DEL,SDLK_DELETE)
			KEYHELPER(LSHIFT)
			KEYHELPER(RSHIFT)
			KEYHELPER(CAPSLOCK)
			KEYHELPER(TAB)
			KEYHELPER(LALT)
			KEYHELPER(RALT)
			KEYHELPER(F1)
			KEYHELPER(F2)
			KEYHELPER(F3)
			KEYHELPER(F4)
			KEYHELPER(F5)
			KEYHELPER(F6)
			KEYHELPER(F7)
			KEYHELPER(F8)
			KEYHELPER(F9)
			KEYHELPER(F10)
			KEYHELPER(F11)
			KEYHELPER(F12)
			return SDL_GetKeyFromName(k.c_str());
	}

};//namespace Dragon2D