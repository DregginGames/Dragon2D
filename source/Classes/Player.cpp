#include "Player.h"
#include "Env.h"
#include "Map.h"

namespace Dragon2D
{
	Player::Player()
		: level(0)
	{
	}

	Player::Player(std::string name)
		: level(0)
	{
		AnimatedTileset::Load(name);
	}

	Player::~Player()
	{

	}

	void Player::Update()
	{
		AnimatedTileset::Update();
	}

	void Player::Load(std::string name)
	{
		AnimatedTileset::Load(name);
	}

	void Player::Render()
	{
		AnimatedTileset::Render();
	}

	void Player::RegisterInputHooks()
	{
	}

	void Player::RemoveInputHooks()
	{
		if (hasInputsRegisterd) {
			Env::GetInput().RemoveHooks(Ptr());
			BaseClass::RemoveInputHooks();
		}
	}
}; //namespace Dragon2D