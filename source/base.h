#pragma once

//Standart lib includes
#include <iostream>
#include <string>
#include <vector>
#include <list>
#include <map>
#include <exception>
#include <regex>
#include <fstream>
#include <sstream>
#include <cstring>

//Not-So-Standart lib includes
//Sdl-foo
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
//gl-foo
#include <GL/glew.h>
#include <glm/glm.hpp>
//libs
#include <TailTipUI.h>
#include <TailTipUI_text.h>
#include <TailTipUI_area.h>
#include <TailTipUI_xml.h> 
#include <HoardXML.h>

#ifdef _MSC_VER //needed to disable big-name errors caused by chaiscript. they are annoying
#pragma warning(disable:4503)
#endif
#include <chaiscript/chaiscript.hpp>


namespace Dragon2D {
	//Standart definitions, macros and classes 


	//class: Exception
	//note: Dragon2D exception base class.
	//note: Dosnt use std::string cause you MUST NOT use std::string as an possible-exception class wtihin a exception cause it could cause terminate()!
	class Exception
	{
	public:
		Exception() {}
		Exception(const char* whatStringText) : whatString(whatStringText) { }
		~Exception() throw() {};

		void SetWhat(const char* newWhatString) { whatString = newWhatString; }
		virtual const char* what(void) const throw() {
			return whatString;
		};

	private:
		const char* whatString;
	};

#ifndef __func__
#define __func__ __FUNCTION__
#endif

#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
#define Assert(c) (!(c) ? throw Exception("Assert at line"TOSTRING(__LINE__)" in "__func__" in "__FILE__": "#c) : (c))
#ifdef _DEBUG
#define DebugAssert(c) Assert(c)
#else
#define DebugAssert(c) 
#endif

}; //namspace Dragon2D

