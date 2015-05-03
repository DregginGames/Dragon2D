#include "PlayerCharacter.h"

#include "Env.h"

namespace Dragon2D
{
	PlayerCharacter::PlayerCharacter()
		: name("")
	{ 

	}

	PlayerCharacter::PlayerCharacter(std::string name)
		: name(name)
	{
		Load(name);
	}

	void PlayerCharacter::Load(std::string name)
	{
		this->name = name;
		

		Player::Load(name);
	}

	void PlayerCharacter::Update()
	{

	}

	void PlayerCharacter::Render()
	{

	}

	void PlayerCharacter::RegisterInputHooks()
	{

	}

	void PlayerCharacter::RemoveInputHooks()
	{

	}


}; //namespace Dragon2D