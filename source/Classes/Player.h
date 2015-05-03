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

		virtual void OnKilled(GameObjectPtr killer);
		virtual void OnLevelUp();
		virtual void OnDamage(int damage, GameObjectPtr cause);
		
		//Attribute functions
		virtual void AddXP(int x);
		virtual int GetXP() const;
		virtual int GetXPForLevel(int l) const;
		virtual void SetXP(int x);
		virtual int GetLevel() const;
		virtual void SetLevel(int x);

		virtual int GetStrength() const;
		virtual void SetStrength(int x);
		virtual void AddStrength(int x);
		virtual int GetIntelligence() const;
		virtual void SetIntelligence(int x);
		virtual void AddIntelligence(int x);
		virtual int GetResilience() const;
		virtual void SetResilience(int x);
		virtual void AddResilience(int x);

		virtual int GetMaxHP() const;
		virtual int GetHP() const;
		virtual void AddHP(int x);
		virtual void SetHP(int x);

		virtual int GetMaxST() const;
		virtual int GetST() const;
		virtual void AddST(int x);
		virtual void SetST(int x);

		virtual int GetMaxEN() const;
		virtual int GetEN() const;
		virtual void AddEN(int x);
		virtual void SetEN(int x);

		virtual int GetAP() const;
		virtual int GetDP() const;
		virtual int GetCN() const;

		virtual int Attack(PlayerPtr target, int baseDamage);
		

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
	
	protected:
		//Player attributes
		int level;
		int xpForNextLevel;
		int xp;
		int strength;
		int intelligence;
		int resilience;
		int hp;
		int st;
		int en;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(Player, AnimatedTileset)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Player, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(Player, Load)
	D2DCLASS_SCRIPTINFO_END

}; //namepsace Dragon2D