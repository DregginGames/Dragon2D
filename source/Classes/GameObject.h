#pragma once

#include "BaseClass.h"

namespace Dragon2D
{
	//class: GameObject
	//note: abstract(!) BaseClass for all Game-Related objects (players, sprites, ...)
	//		EVERYTHING that is part of the actual game should be a GameObject.
	D2DCLASS(GameObject, public BaseClass)
	{
	public:
		GameObject();
		virtual ~GameObject(){}

		virtual void SetPosition(glm::vec4 pos);
		virtual glm::vec4 GetPosition() const;

		virtual void SetMapPosition(int x, int y);
		virtual void GetMapPosition(int&x, int&y) const;
		virtual void UpdatePositionFromMap();

		virtual void Focus();
		static GameObjectPtr GetFocusedObject();
	protected:
		static GameObjectPtr focusedObject;
		glm::vec4 position;
		int mapX;
		int mapY;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(GameObject, BaseClass)
		D2DCLASS_SCRIPTINFO_MEMBER(GameObject,SetPosition)
		D2DCLASS_SCRIPTINFO_MEMBER(GameObject, GetPosition)
		D2DCLASS_SCRIPTINFO_MEMBER(GameObject, SetMapPosition)
		D2DCLASS_SCRIPTINFO_MEMBER(GameObject, GetMapPosition)
		D2DCLASS_SCRIPTINFO_MEMBER(GameObject, UpdatePositionFromMap)
		D2DCLASS_SCRIPTINFO_MEMBER(GameObject, Focus)
		D2DCLASS_SCRIPTINFO_MEMBER(GameObject, GetFocusedObject)
	D2DCLASS_SCRIPTINFO_END
}; //namespace Dragon2D