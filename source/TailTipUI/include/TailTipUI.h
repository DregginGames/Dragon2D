#pragma once

#include <iostream>
#include <vector>
#include <string>
#include <thread>
#include <cmath>
#include <algorithm>
#include <list>
#include <map>
#include <sstream>
#include <functional>
//sdl-foo
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
//gl-foo
#include <GL/glew.h>
#include <glm/glm.hpp>

namespace TailTipUI {

	class GeneralElement;

	//Callbacks that will be called on events (hover, click, ...)
	typedef  std::function<void(GeneralElement*)> ElementCallbackType;
	//callback set in root element that should deliver a mouse position and states of the left and right mousebutton.
	typedef  std::function<glm::vec4()> MouseinfoCallbackType;
	//callback set in root element that shold deliver the current keycodes
	typedef  std::function<SDL_Keycode()> ButtoninfoCallbackType;

	GLuint SurfaceToTexture(SDL_Surface* s);
	void RenderElementByTexture(GLuint tex, glm::vec4 pos, glm::vec4 radiusKomponent = glm::vec4(0), float b = 0.1f, float s = 0.05f);
	void RenderSingleColor(glm::vec4 color, glm::vec4 pos, glm::vec4 radiusKomponent = glm::vec4(0), float b = 0.1f, float s = 0.05f);

	class GeneralElement {
	public:
		GeneralElement();

		virtual ~GeneralElement();
		
		virtual void Render();
		
		virtual void SetParent(GeneralElement *parent);
		virtual GeneralElement* GetParent();
		virtual void AttatchChild(GeneralElement* child);
		virtual void DeattatchChild(GeneralElement* child);

		virtual void SetHidden(bool isHidden);
		virtual bool GetHidden();

		virtual void SetPos(glm::vec4 position);
		virtual glm::vec4 GetPos();

		virtual void SetDraggable(bool isdraggable);
		virtual bool GetDraggable();
		virtual bool IsCurrentlyDragged();
		virtual void SetBlockParentdragging(bool isdraggable);
		virtual bool GetBlockParentdragging();

		virtual void SetName(std::string newname);
		virtual std::string GetName();
		virtual void SetId(std::string newid);
		virtual std::string GetId();
		GeneralElement* GetElementById(std::string searchid);

		virtual glm::vec4 RelativePositionToParent();

		virtual void SetForgroundColor(glm::vec4 color);
		virtual void SetBackgroundColor(glm::vec4 color);
		virtual void SetEventColor(glm::vec4 color);
		virtual glm::vec4 GetForgroundColor();
		virtual glm::vec4 GetBackgroundColor();
		virtual glm::vec4 GetEventColor();

		virtual void SetRadius(glm::vec4 r);
		virtual void SetRadiusSmoothing(float s);
		virtual void SetRadiusParameter(float b);
		virtual glm::vec4 GetRadius();
		virtual float GetRadiusSmoothing();
		virtual float GetRadiusParameter();

		virtual void SetFont(TTF_Font* newfont);
		virtual TTF_Font* GetFont();

		virtual bool GetHover();
		virtual bool GetLeftclick();
		virtual bool GetRightclick();

		virtual void SetHoverCallback(ElementCallbackType c);
		virtual void SetLeftclickCallback(ElementCallbackType c);
		virtual void SetRightclickCallback(ElementCallbackType c);

		virtual glm::vec4 GetMouseInfo();
		virtual SDL_Keycode GetCurrentButton();

	private:

	protected:
		GeneralElement* parent;
		std::vector<GeneralElement*> children;

		glm::vec4 pos;

		std::string name;
		std::string id;

		glm::vec4 fgcolor;
		glm::vec4 bgcolor;
		glm::vec4 eventColor;

		TTF_Font* font;

		bool hidden;
		bool draggable;
		bool isDragged;
		bool blockParentdragging;

		glm::vec4 draggmouse;
		SDL_Keycode draggkey;
		bool oldHoverstate;

		glm::vec4 renderRadius;
		float radiusSmoothing;
		float radiusParameter;

		ElementCallbackType HoverCallback;
		ElementCallbackType LeftCallback;
		ElementCallbackType RightCallback;

		virtual void _Render();

		virtual void _InternalHoverEvent();
		virtual void _InternalStopHoverEvent();
		virtual void _InternalLeftclickEvent();
		virtual void _InternalRightclickEvent();

	};

	class ChildElement : public GeneralElement {
	public:
		ChildElement();
		virtual ~ChildElement();


	private:

	protected:
	};

	//class: Root
	//note: Root element class. Holds the Framebuffer that is the final rendering destination for all elements.
	class Root : public GeneralElement {
	public:
		Root(GLuint destinationFramebuffer);
		~Root();

		virtual void AttatchChild(ChildElement* child);
		virtual void DeattatchChild(ChildElement* child);
		virtual void Render() override;

		virtual glm::vec4 GetMouseInfo() override;
		virtual SDL_Keycode GetCurrentButton() override;

		virtual void SetMouseCallback(MouseinfoCallbackType c);
		virtual void SetButtonCallback(ButtoninfoCallbackType c);
	private:
		GLuint framebuffer;

		MouseinfoCallbackType mousecallback;
		ButtoninfoCallbackType buttoncallback;
	protected:
	};



};
