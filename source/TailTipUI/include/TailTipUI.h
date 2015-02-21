#pragma once

#include <iostream>
#include <vector>
#include <string>
#include <thread>
//sdl-foo
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
//gl-foo
#include <GL/glew.h>
#include <glm/glm.hpp>

namespace TailTipUI {

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

	private:

	protected:
		GeneralElement* parent;
		std::vector<GeneralElement*> children;

		glm::vec4 pos;

		bool hidden;
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
		virtual void Render();
	private:
		GLuint framebuffer;

	protected:
	};



};
