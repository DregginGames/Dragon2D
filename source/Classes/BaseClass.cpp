#include "BaseClass.h"

namespace Dragon2D
{

	BaseClass::BaseClass() 
	{

	}
	BaseClass::~BaseClass()
	{

	}

	void BaseClass::SetParent(BaseClassPtr newparent)
	{
		parent = newparent;
	}

	BaseClassPtr BaseClass::GetParent()
	{
		return parent;
	}

	void BaseClass::AddChild(BaseClassPtr child)
	{
		child->SetParent(shared_from_this());
		children.push_back(child);
	}

	void BaseClass::RemoveChild(BaseClassPtr child)
	{
		for (auto c = children.begin(); c != children.end(); c++) {
			if (*c == child) {
				children.erase(c);
				child->SetParent(nullptr);
				break;
			}
		}
	}

	void BaseClass::Update()
	{
		for (auto c : children) {
			c->Update();
		}
	}

	void BaseClass::Render()
	{
		for (auto c : children) {
			c->Render();
		}
	}

}; //namespace Dragon2D