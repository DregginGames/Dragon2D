#include "GameObject.h"
#include "Map.h"

namespace Dragon2D
{
	D2DCLASS_REGISTER(GameObject);
	GameObjectPtr GameObject::focusedObject = GameObjectPtr();

	GameObject::GameObject()
		: position(-1.0f), mapX(-1), mapY(-1)
	{

	}
	
	glm::vec4 GameObject::GetPosition() const
	{
		return position;
	}

	void GameObject::SetPosition(glm::vec4 pos)
	{
		position = pos;
		//Set map pos from screen pos
		if (parent) {
			MapPtr map = std::dynamic_pointer_cast<Map>(parent);
			if (map) {
				int x, y, mx,my;
				float tw, th;
				map->GetMapDimensions(x, y, tw, th);
				map->GetMapPosition(mx, my);
				mapX = mx + (int)(pos.x / (float)mx);
				mapY = my + (int)(pos.y / (float)my);
			}
		}
	}

	void GameObject::SetMapPosition(int x, int y)
	{
		mapX = x;
		mapY = y;
		//set screen pos
		UpdatePositionFromMap();
	}

	void GameObject::UpdatePositionFromMap()
	{
		if (parent) {
			MapPtr map = std::dynamic_pointer_cast<Map>(parent);
			if (map) {
				position = map->Tilepos(mapX, mapY);
			}
		}
	}

	void GameObject::GetMapPosition(int&x, int&y) const
	{
		x = mapX;
		y = mapY;
	}

	void GameObject::Focus()
	{
		focusedObject = std::dynamic_pointer_cast<GameObject>(Ptr());
	}

	GameObjectPtr GameObject::GetFocusedObject()
	{
		return focusedObject;
	}
}; //namespace Dragon2D