#include "BaseClass.h"

namespace Dragon2D
{

	BaseClass::BaseClass() 
		: renderLayer(0)
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
		auto stillToRender = children;
		for (unsigned int curlayer = 0; stillToRender.size() > 0; curlayer++) {
			for (auto c = stillToRender.begin(); c != stillToRender.end(); c++) {
				if ((*c)->GetRenderLayer() <= curlayer) {
					(*c)->Render();
					c = stillToRender.erase(c);
				}
			}
		}
	}

	void BaseClass::SetRenderLayer(unsigned int layer)
	{
		renderLayer = layer;
	}

	unsigned int BaseClass::GetRenderLayer()
	{
		return renderLayer;
	}

}; //namespace Dragon2D