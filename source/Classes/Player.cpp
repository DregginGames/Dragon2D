#include "Player.h"
#include "Env.h"
#include "Map.h"

namespace Dragon2D
{
	D2DCLASS_REGISTER(Player);
	
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
		//LevelUpHandling
		if (xpForNextLevel <= xp) {
			xpForNextLevel = GetXPForLevel(level + 1);
			level++;
			OnLevelUp();
		}
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

	//The Attribute foo is here. Run away!
	void Player::AddXP(int x)
	{
		xp += x;
	}
	
	int Player::GetXP() const
	{
		return xp;
	}

	int Player::GetXPForLevel(int l) const
	{
		if (l <= 1) return 0;
		return (int)floor(100.0*std::pow(1.3, (double)l)) + GetXPForLevel(l - 1);
	}

	void Player::SetXP(int x)
	{
		xp = x;
	}

	int Player::GetLevel() const
	{
		return level;
	}

	void Player::SetLevel(int x)
	{
		level = x;
	}

	int Player::GetStrength() const
	{
		return strength;
	}

	void Player::SetStrength(int x) 
	{
		strength = x;
	}

	void Player::AddStrength(int x)
	{
		strength += x;
	}

	int Player::GetIntelligence() const
	{
		return intelligence;
	}

	void Player::SetIntelligence(int x)
	{
		intelligence = x;
	}

	void Player::AddIntelligence(int x)
	{
		intelligence += x;
	}
	int Player::GetResilience() const
	{
		return resilience;
	}

	void Player::SetResilience(int x)
	{
		resilience = x;
	}

	void Player::AddResilience(int x)
	{
		resilience += x;
	}

	int Player::GetMaxHP() const
	{
		return 20 + 10 * strength + 5 * resilience + 3 * level;
	}

	int Player::GetHP() const
	{
		return hp;
	}

	void Player::AddHP(int x)
	{
		hp += x;
		if (hp > GetMaxHP()) {
			hp = GetMaxHP();
		}
	}

	void Player::SetHP(int x)
	{
		hp = x;
	}

	int Player::GetMaxST() const
	{
		return 30 + 10 * strength + 3 * level;
	}

	int Player::GetST() const
	{
		return st;
	}

	void Player::AddST(int x)
	{
		st += x;
		if (st > GetMaxST()) {
			st = GetMaxST();
		}
	}

	void Player::SetST(int x)
	{
		st = x;
	}

	int Player::GetMaxEN() const
	{
		return 20 + 10 * intelligence + 4 * level;
	}

	int Player::GetEN() const
	{
		return en;
	}

	void Player::AddEN(int x)
	{
		en += x;
		if (en > GetMaxEN()) {
			en = GetMaxEN();
		}
	}

	void Player::SetEN(int x)
	{
		en = x;
	}


	int Player::GetAP() const
	{
		return 15 + 10 * strength + 4 * resilience + 2 * level;
	}

	int Player::GetDP() const
	{
		return 15 + 4 * strength + 10 * resilience + 2 * level;
	}

	int Player::GetCN() const
	{
		return 15 + 10 * intelligence + GetEN() + 4 * level;
	}

	int Player::Attack(PlayerPtr target, int baseDamage)
	{
		int attackDamage = baseDamage; //todo: let level have an effect on this
		int rd = attackDamage/2 + rand() % (attackDamage + 1 / 2);
		int causedDamage = rd - rand() % target->GetDP();
		target->OnDamage(causedDamage, std::dynamic_pointer_cast<GameObject>(Ptr()));
		return causedDamage;
	}

	void Player::OnDamage(int damage, GameObjectPtr cause)
	{
		hp -= damage;
		if (hp <= 0) {
			OnKilled(cause);
			return;
		}
	}

	void Player::OnKilled(GameObjectPtr cause)
	{
		if (parent) {
			parent->RemoveChild(Ptr());
		}
	}

	void Player::OnLevelUp()
	{
		hp = GetMaxHP();
		en = GetMaxEN();
		st = GetMaxST();
	}
}; //namespace Dragon2D