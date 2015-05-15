#pragma once

#include "base.h"
#include "BaseClass.h"

namespace Dragon2D 
{
	//class: Music
	//info: Class for playing music 
	D2DCLASS(Music,public BaseClass)
	{
	public:
		Music();
		Music(std::string name);
		
		void Load(std::string name);
		void Play(int fadetime, int loops);
		void Stop(int fadetime = 0);
	private:
		std::string name;
		static int curChannel;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(Music, BaseClass)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Music, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(Music, Load)
		D2DCLASS_SCRIPTINFO_MEMBER(Music, Play)
	D2DCLASS_SCRIPTINFO_END

}; //namespace Dragon2D
