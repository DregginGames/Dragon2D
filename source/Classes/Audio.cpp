#include "Audio.h"
#include "ResourceManager.h"
#include "Env.h"

namespace Dragon2D
{
	D2DCLASS_REGISTER(Music);  
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
		Env::GetResourceManager().RequestAudioResource(name);		
	}	
	
	void Music::Play(int fadetime, int loops)
	{
		if(curChannel!=-1) {
			Mix_FadeOutChannel(curChannel, fadetime);
		}
		
		AudioResource &res = Env::GetResourceManager().GetAudioResource(name);
		curChannel = Mix_FadeInChannel(-1,res.GetChunk(),loops,fadetime);
	}	

	void Music::Stop(int fadetime)
	{
		if (curChannel != -1) {
			Mix_FadeOutChannel(curChannel, fadetime);
		}
		curChannel = -1;
	}
}; //namespace Dragon2D
