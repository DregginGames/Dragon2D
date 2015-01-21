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
#include <strstream>
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
		return whatString; };

private:
	const char* whatString; 
};

}

