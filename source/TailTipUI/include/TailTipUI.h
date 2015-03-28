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
	typedef  std::function<const Uint8*()> ButtoninfoCallbackType;
	//callback set for font-loading
	typedef std::function<TTF_Font*(std::string, int)> FontLoaderFunctionType;
	//callback set for image-loading
	typedef std::function<GLuint(std::string)> ImageLoaderFunctionType;
	//cakkback set for resetting input buffer
	typedef std::function<void(void)> TextBufferResetFunctionType;
	//callback set for getting input buffer
	typedef std::function<std::string(void)> GetTextBufferFunctionType;

	//default font loader
	TTF_Font* defaultFontLoader(std::string name, int size);


	//function: SurfaceToTexture
	//note: Helper function that creates a OpenGL texture from a SDL_Surface-object
	GLuint SurfaceToTexture(SDL_Surface* s);
	//function: RenderElementByTexture
	//note: Renders a texture on the screen
	//param:	text: the GLuint-handle of the texture on the gpu
	//			pos: normalized position of the objct, with [0]=x, [1]=y, [2] = width and [3] = height
	//			radiusComponent: radius-components of the render. See somewhere else to find out how it works
	//			b: radius-parameter. Again, look in the explanations of the radius-rendering
	//			s: smoothing. Paramenter for smooth-step.
	void RenderElementByTexture(GLuint tex, glm::vec4 pos, glm::vec4 radiusKomponent = glm::vec4(0), float b = 0.1f, float s = 0.05f);
	//function: RenderSingleColor
	//note: Renders a rectangle on the screen with color "color"
	//param:	color: the RGBA-color of the rect
	//			pos: normalized position of the objct, with [0]=x, [1]=y, [2] = width and [3] = height
	//			radiusComponent: radius-components of the render. See somewhere else to find out how it works
	//			b: radius-parameter. Again, look in the explanations of the radius-rendering
	//			s: smoothing. Paramenter for smooth-step.
	void RenderSingleColor(glm::vec4 color, glm::vec4 pos, glm::vec4 radiusKomponent = glm::vec4(0), float b = 0.1f, float s = 0.05f);
	//function: RenderLineColored
	//note: Renders a line on the screen with color "color"
	//param:	color: the RGBA-color of the line
	//			pos: position of the line, with [0] and [1] being the beginning and [2] and[3] the end points of the line
	//			s: smoothing of the line
	//			w: thickness of the line
	void RenderLineColored(glm::vec4 color, glm::vec4 pos, float w, float s);

	//class: Info
	//note: Holds infos needed for rendering
	class Info
	{
	public: 
		//constructor: Info
		//note: Sets the static info-vars
		Info(std::string windowname, int w, int h);
		~Info();

		//function: SetMouseCallback
		//note: Sets the callback wich provides information about the Mouse-state
		//param:	c: the function to call
		static void SetMouseCallback(MouseinfoCallbackType c);
		//function: SetButtonCallback
		//note: Sets the callback wich provides information about the button-state
		//param:	c: the function to call
		static void SetButtonCallback(ButtoninfoCallbackType c);
		//function: SetButtonCallback
		//note: Sets the callback wich loads fonts
		//param:	c: the function to call
		static void SetFontCallback(FontLoaderFunctionType c);
		//function: SetButtonCallback
		//note: Sets the callback wich loads images
		//param:	c: the function to call
		static void SetImageCallback(ImageLoaderFunctionType c);

		static void SetTextBufferResetCallback(TextBufferResetFunctionType c);
		static void SetGetTextBufferCallback(GetTextBufferFunctionType c);

		//function: GetMouseInfo
		//note: Used to get the mouseposition. 
		static glm::vec4 GetMouseInfo();
		//function: GetCurrentButton
		//note: Used to get the buttonstate.
		static const Uint8* GetCurrentButton();
		//function: GetFont
		//note: returns a font wiht <name> at size <sizeA>
		//param:	name: name of the font to load
		//			size: the size of the font
		static TTF_Font* GetFont(std::string name, int size);
		//function: GetImage
		//note: Loads a image with name "name"
		//param:	name: image to load
		static GLuint GetImage(std::string name);

		static void ResetTextBuffer();
		static std::string GetTextBuffer();

		//var: width. width of the render-window
		static int width;
		//var: height. height of the render window
		static int height;
		//var: name. name of the render window
		static std::string name;
		//var: mousecallback. callback wich provides the mouse-information 
		static MouseinfoCallbackType mousecallback;
		//var: buttoncallback. callback wich provides the button-information
		static ButtoninfoCallbackType buttoncallback;
		//var: fontCallback. callback wich provides a font from a fontname.
		static FontLoaderFunctionType fontCallback;
		//var: imageCallback. callback wich provides an imgae from a name
		static ImageLoaderFunctionType imageCallback;
		//var: textBufferResetCallback. callback wich provides the reset function for the text buffer
		static TextBufferResetFunctionType textBufferResetCallback;
		//var: getTextBufferCallback. 
		static GetTextBufferFunctionType getTextBufferCallback;
	};

	//class: StandaloneSetup
	//note: a class that holds a standalone window-context
	class StandaloneSetup
	{
	public:
		//constructor: StandaloneSetup
		//note: Creates an sdl-based opengl context from scratch
		//param:	name: name of the window
		//			width: width of the window
		//			height: height of the window
		//			x:	x-position of the window
		//			y: y-position of the window
		//			mayor: mayor-opengl version. minimum is 3!
		//			minor: minor-opengl version. mimimim is 3!
		StandaloneSetup(std::string name, int widht, int height, int x = SDL_WINDOWPOS_CENTERED, int y = SDL_WINDOWPOS_CENTERED, Uint32 flags = SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN, int mayor = 3, int minor = 3, int depth = 24);

		//destructor: ~StandaloneSetup
		//standard destructor
		~StandaloneSetup();

		//function: IsValid
		//note: returns if the window of the standalone-setup could be created
		bool& IsValid();

		//function: Update()
		//note: Updates the screen
		void Update();
	private:
		//var: name of the window
		std::string name;
		//var: window. pointer to the window-handle
		SDL_Window* window;
		//var: valid. 
		bool valid;
	};


	//class: GeneralElement
	//note: Baseclass for all possible elements. holds the basic settings for each element.
	class GeneralElement {
	public:

		//constructor: GeneralElement
		//note: basic constructor. Sets lots of stuff to false, zero, ...
		GeneralElement();

		//destructor: ~GeneralElement
		//note: Destroys element and ALL CHILDELEMNTS(!!)
		virtual ~GeneralElement();
		
		//function: Render
		//note: Updates and renders an element and its childs
		virtual void Render();
		
		//function: SetParent
		//note: Sets the Parent-object of the object
		//param:	parent: Pointer to the parent object
		virtual void SetParent(GeneralElement* parent);
		//function: GetParent
		//note: Returns the Parent-object of the object
		virtual GeneralElement* GetParent();
		//function: AttatchChild
		//note: Adds a new Element as a child to this
		//param:	child: the element to add. should be created with new
		virtual void AttatchChild(GeneralElement* child);
		//function: DeattatchChild
		//note: Removes a elemnt from this object. Note that you have to take care of deleting it yourself from here
		//param:	child: the element to remove
		virtual void DeattatchChild(GeneralElement* child);

		//function: SetHidden
		//note: Sets weather this object is hidden or not
		//param:	isHidden: set to true if hidden, false otherwise
		virtual void SetHidden(bool isHidden);
		//function: GetHidden
		//note: Returns if the object is hidden
		virtual bool GetHidden();

		//function: SetPos
		//note: Sets the normalized positoin. 
		//		Keep in mind that if this object is a child, it will see this position as relative to the parent.
		//		Also it will keep track of transfering it into a absolute position at render time. 
		//param:	position: the position, with [0]=x,[1]=y,[2]=width,[3]=height
		virtual void SetPos(glm::vec4 position);
		//function: GetPos()
		//note: Returns the position of this object. 
		virtual glm::vec4 GetPos();

		//function: SetDraggable
		//note: Sets weather this object can be dragged around with the mouse
		//param:	isdraggable: the value to set it to
		virtual void SetDraggable(bool isdraggable);
		//function: GetDraggable
		//note: Returns if the object can be dragged around
		virtual bool GetDraggable();
		//function: IsCurrentlyDragged
		//note: Returns true if the object is currently dragged around 
		virtual bool IsCurrentlyDragged();
		//function: SetBlockParentdragging
		//note: Set if this object blocks if the parent-object can be dragged around
		//param:	isdraggabble: true if it should block, false otherwise
		virtual void SetBlockParentdragging(bool isdraggable);
		//function: GetBlockParentdraggig
		//note: Returns if this object blocks the parent from dragging
		virtual bool GetBlockParentdragging();

		//function: SetName
		//note: Sets the name of this object
		//param:	newname: the name to set it to
		virtual void SetName(std::string newname);
		//function: GetName
		//note: Returns the name of this object
		virtual std::string GetName();
		//function: SetId
		//note: Sets the Id of this object. note that Name != id! 
		//		Id should be a UNIQUE identification for each object!
		//param:	newid: id to set
		virtual void SetId(std::string newid);
		//function: GetId
		//note: Returns id of the object
		virtual std::string GetId();
		//function: GetElementById
		//note: Returns the element 'below' this one (or this one!) that has the given id
		//param:	searchid: the id to search for
		GeneralElement* GetElementById(std::string searchid);

		//function: RelativePositionToParent()
		//note: Calculates and returns the absolute position from the relative position to the parent. Returns the normal position if doesnt have a parent object.
		virtual glm::vec4 RelativePositionToParent();

		//function: SetForgroundColor
		//note: Sets the forground-color of this element
		//param:	color: the color to set
		virtual void SetForgroundColor(glm::vec4 color);
		//function: SetBackgroundColor
		//note: Sets the background-color of this element
		//param:	color: the color to set
		virtual void SetBackgroundColor(glm::vec4 color);
		//function: SetEventColor
		//note: Sets the event-color of this element (buttons have a hover-color to give an example)
		//param:	color: the color to set
		virtual void SetEventColor(glm::vec4 color);
		//function: GetForgroundColor
		//note: Returns the Forground-color
		virtual glm::vec4 GetForgroundColor();
		//function: GetBackgroundColor
		//note: Returns the background-color
		virtual glm::vec4 GetBackgroundColor();
		//function: GetEventColor
		//note: Returns the event-color
		virtual glm::vec4 GetEventColor();

		//function: SetSmoothing
		//note: Sets the smoothing of the object. Smoothing is a blend on the edges of the object. s is the relative size to-blend area
		//param:	s: the size of the smothing
		virtual void SetSmoothing(float s);
		//function: GetSmoothing
		//note: Returns the objects smoothing parameter
		virtual float GetSmoothing();

		//funciton: SetRadius
		//note: Sets the radius of the function object.
		//param:	r: the radius values for each edge
		virtual void SetRadius(glm::vec4 r);
		//function: SetRadiusParameter
		//note: Sets the radius parameter (radis-calculation distance from the center of the object)
		//param:	b: the parameter
		virtual void SetRadiusParameter(float b);
		//function: GetRadius
		//note: Returns the objects radius
		virtual glm::vec4 GetRadius();
		//function: GetRadiusParameter
		//note: Returns the objects radius parameter
		virtual float GetRadiusParameter();

		//function: SetFont
		//note: Sets the font of this object. will not care about destruction of the font-object!
		//param:	newfont: the font to set
		virtual void SetFont(TTF_Font* newfont);
		//function: GetFont
		//note: Returns the font of this object
		virtual TTF_Font* GetFont();

		//function: GetHover
		//note: Returns the hover-state of this object
		virtual bool GetHover();
		//function: GetLeftclick
		//note: Returns the leftclick-state of this object
		virtual bool GetLeftclick();
		//function: GetRightclick
		//note: Returns the rightclick-state of this object
		virtual bool GetRightclick();

		//function: SetHoverCallback
		//note: Sets the callback wich is called on a hover event
		//param:	c: the function to call
		virtual void SetHoverCallback(ElementCallbackType c);
		//function: SetLeftclickCallback
		//note: Sets the callback wich is called on a leftclick event
		//param:	c: the function to call
		virtual void SetLeftclickCallback(ElementCallbackType c);
		//function: SetRightclickCallback
		//note: Sets the callback wich is called on a rightclick event
		//param:	c: the function to call
		virtual void SetRightclickCallback(ElementCallbackType c);
		//function: SetSpecialCallback
		//note: Sets the callback for an additional event
		//param:	c: the function to call
		virtual void SetSpecialCallback(ElementCallbackType c);

	private:

	protected:
		//var: parent. holds pointer to the parent element
		GeneralElement* parent;
		//var: chidren. holds pointers to the child elements
		std::vector<GeneralElement*> children;

		//var: pos. position of the element
		glm::vec4 pos;

		//var: name. name of the element
		std::string name;
		//var: id. id of the element
		std::string id;

		//var: fgcolor. forgroundcolor of this element
		glm::vec4 fgcolor;
		//var: bgcolor. backgroundcolor of this element
		glm::vec4 bgcolor;
		//var: eventColor. eventcolor of this element
		glm::vec4 eventColor;

		//var: usesEventColor. Set to true by SetEventColor. 
		bool usesEventColor;

		//var: font. font of this element
		TTF_Font* font;

		//var: hidden. is this object hidden?
		bool hidden;
		//var: draggable. is this object draggable?
		bool draggable;
		//var: isDragged. is this object currently dragged?
		bool isDragged;
		//var: blockParentdragging. does this object block parents dragging?
		bool blockParentdragging;

		//var: draggmouse. last mousestade dragged into the current
		glm::vec4 draggmouse;
		//var: draggkey. the last key-state
		Uint8* draggkey;
		//var: oldHoverstate. the last hoverstate
		bool oldHoverstate;
		
		//var: inFocus. true if the element is in focus
		bool inFocus;

		//var: smoothing. smoothing paramenter
		float smoothing;
		
		//var: renderRadius. radius of the rounded edges
		glm::vec4 renderRadius;
		//var: radiusParameter. the radius-calculation parameter
		float radiusParameter;

		//var: HoverCallback. Function called on hover events
		ElementCallbackType HoverCallback;
		//var: LeftCallback. Function called on leftclicks
		ElementCallbackType LeftCallback;
		//var: RightCallback. Function called on rightclicks
		ElementCallbackType RightCallback;
		//var: specialCallback. Function called on special events
		ElementCallbackType specialCallback;
		//function: _Render()
		//note: Internal render function for each element. Her drawing should take place
		virtual void _Render();

		//function: _InternalHoverEvent
		//note: Element-internal function called on hover events
		virtual void _InternalHoverEvent();
		//function: _InternalStopHoverEvent
		//note: Element-internal function called after hover events
		virtual void _InternalStopHoverEvent();
		//function: _InternalLeftclickEvent
		//note: Element-internal function called on leftclick events
		virtual void _InternalLeftclickEvent();
		//function: _InternalRightclickEvent
		//note: Element-internal function called on rightclick events
		virtual void _InternalRightclickEvent();


		virtual void _Focus();
		virtual void _LostFocus();

	};

	//class: childElement
	//note: Helper-class. 
	//TODO: Is this really needed???
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
		//constructor: Root
		//note: Constructor takes the destination-framebuffer (default 0=screen) as an argument
		//param:	destinationFramebuffer: the framebuffer to render on
		Root(GLuint destinationFramebuffer);
		//destructor: ~Root
		~Root();

		//function: Render
		//note: Renders the element and its children
		virtual void Render() override;

	private:
		//var: framebuffer. the framebuffer to render on
		GLuint framebuffer;

	protected:
	};



};
