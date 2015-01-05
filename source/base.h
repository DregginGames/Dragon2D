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

//Not-So-Standart lib includes
#include <SDL2/SDL.h>

#include <GL/glew.h>
#include <glm/glm.hpp>

namespace Dragon2D {
//Standart definitions, macros and classes 

class Exception : public std::exception
{
public:
	Exception() {}
	Exception(std::string whatString) { SetWhat(whatString); }
	~Exception() throw() {}

	void SetWhat (std::string newWhatString) { whatString = newWhatString; }
	virtual const char* what(void) { return whatString.c_str(); }

private:
	std::string whatString; 
};

}

