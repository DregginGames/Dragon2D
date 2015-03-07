

#pragma once
#include <TailTipUI.h>
#include <TailTipUI_text.h>
#include <TailTipUI_area.h>
#include <TailTipUI_button.h>

namespace TailTipUI {

	typedef std::function<TTF_Font*(std::string, int)> FontLoaderFunctionType;
	TTF_Font* defaultFontLoader(std::string name, int size);

	//class XMLLoader
	//info: Loads an xml-file and creates a Tree-structure.
	class XMLLoader
	{
	public:
		XMLLoader(GLuint destinationFramebuffer);
		XMLLoader(GLuint destinationFramebuffer, std::string infile, MouseinfoCallbackType mouseInfoCallback = MouseinfoCallbackType(), ButtoninfoCallbackType buttonInfoCallback = ButtoninfoCallbackType(), FontLoaderFunctionType f = defaultFontLoader);
		~XMLLoader();

		void Load(std::string infile, MouseinfoCallbackType mouseInfoCallback = MouseinfoCallbackType(), ButtoninfoCallbackType buttonInfoCallback = ButtoninfoCallbackType(), FontLoaderFunctionType f = defaultFontLoader);
	
		void RegisterCallback(std::string name, ElementCallbackType c);
		void RemoveCallback(std::string name);


		void RenderElements();

		void HoverCallbackEventHandler(GeneralElement* elem);
		void LeftclickCallbackEventHandler(GeneralElement* elem);
		void RightclickCallbackEventHandler(GeneralElement* elem);
		void AddHoverEvent(std::string id, std::string e);
		void AddLeftclickEvent(std::string id, std::string e);
		void AddRightclickEvent(std::string id, std::string e);

		GeneralElement* GetElementById(std::string id);
		
		static TTF_Font* LoadFont(std::string name, int size);
		static glm::vec4 MouseCallback();
		static SDL_Keycode ButtonCallback();
	private:
		static FontLoaderFunctionType fontLoader;
		static MouseinfoCallbackType mouseCallback;
		static ButtoninfoCallbackType buttonCallback;

		GLuint framebuffer;
		Root* rootElelent;

		std::map<std::string, ElementCallbackType> callbacks;
		std::vector<GeneralElement*> elements;
		std::map<std::string, std::string> hoverEvents;
		std::map<std::string, std::string> lClickEvents;
		std::map<std::string, std::string> rClickEvents;
	protected:
		void _HandleGeneralCallback(GeneralElement* caller, std::string callbackString);
	};

};
