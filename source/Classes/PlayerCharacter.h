#pragma once

#include "base.h"
#include "Player.h"

namespace Dragon2D
{

	//class: PlayerCharacter
	//note: Class for the PlayerCharacter, the "player" of the game. Controled by the "user"
	D2DCLASS(PlayerCharacter,public Player)
	{
	public:
		PlayerCharacter();
		PlayerCharacter(std::string name);
		
		virtual void Load(std::string name) override;
		
		virtual void RegisterInputHooks() override;
		virtual void RemoveInputHooks() override;

		virtual void Update() override;
		virtual void Render() override;
	private:

		std::string name;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(PlayerCharacter, Player)
		D2DCLASS_SCRIPTINFO_MEMBER(PlayerCharacter, Load);
	D2DCLASS_SCRIPTINFO_END

}; //namespace Dragon2D