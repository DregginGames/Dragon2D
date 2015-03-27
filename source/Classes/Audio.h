#pragma once

#include "base.h"
#include "BaseClass.h"

namespace Dragon2D 
{
	//class: Music
	//info: Class for playing music 
	D2DCLASS(Music, BaseClass)
	{
	public:
		Music();
		Music(std::string name);
		
		void Load(std::string name);
		void Play(int fadetime);
	private:
		std::string name;
		static int curChannel;
	};
}; //namespace Dragon2D
