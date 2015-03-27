#include "Audio.h"
#include "ResourceManager.h"
#include "Env.h"

namespace Dragon2D
{
	int Music::curChannel = -1;
	Music::Music()
		: name("")
	{
		
	}

	Music::Music(std::string loadname)
		: name(loadname)
	{
		Load(loadname);
	}
	
	void Music::Load(std::string loadname)
	{
		name = loadname;
		//Env::GetResourceManager().RequestAudioResource(name);		
	}	
	
	void Music::Play(int fadetime)
	{

	}	
}; //namespace Dragon2D
