#pragma once

#include "BaseClass.h"
#include "Tileset.h"


namespace Dragon2D
{

	//class: Player
	//note: Base Class for all kinds of players (NPCs too)
	D2DCLASS(Player, public AnimatedTileset)
	{
	public:
		Player();
		Player(std::string name);
		~Player();

		void SetTileset(std::string tilsetName);
		std::string GetTileset();

		virtual void Load(std::string name) override;

		virtual void Render() override;
		virtual void Update() override;

		virtual void RegisterInputHooks() override;
		virtual void RemoveInputHooks() override;

		enum MOVEMENT {
			MOVEMENT_NONE=0,
			MOVEMENT_UP,
			MOVEMENT_DOWN,
			MOVEMENT_RIGHT,
			MOVEMENT_LEFT,
			MOVEMENT_COUNT
		};

	private:
		int movementState;
		glm::vec2 movementOffset;

		int level;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(Player, AnimatedTileset)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Player, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(Player, Load)
	D2DCLASS_SCRIPTINFO_END

}; //namepsace Dragon2D