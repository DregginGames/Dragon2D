#include "BaseClass.h"

namespace Dragon2D
{

	long int BaseClass::ticks = 0;

	BaseClass::BaseClass() 
		: renderLayer(0), hasInputsRegisterd(false)
	{

	}
	BaseClass::~BaseClass()
	{

	}

	void BaseClass::SetParent(BaseClassPtr newparent)
	{
		parent = newparent;
	}

	BaseClassPtr BaseClass::GetParent() const
	{
		return parent;
	}

	void BaseClass::AddChild(BaseClassPtr child)
	{
		if (child) {
			child->SetParent(shared_from_this());
			children.push_back(child);
			if (hasInputsRegisterd) {
				child->RegisterInputHooks();
			}
			else {
				child->RemoveInputHooks();	//importand cause other behaviour might cause the hooks not to be removed (how awful)
			}
		}
	}

	void BaseClass::RemoveChild(BaseClassPtr child)
	{
		for (auto c = children.begin(); c != children.end(); c++) {
			if (*c == child) {
				children.erase(c);
				child->RemoveInputHooks(); //importand cause other behaviour might cause the hooks not to be removed (still awful)
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
				if (c == stillToRender.end()) {
					break;
				}
			}
		}
	}

	void BaseClass::SetRenderLayer(unsigned int layer)
	{
		renderLayer = layer;
	}

	unsigned int BaseClass::GetRenderLayer() const
	{
		return renderLayer;
	}

	BaseClassPtr BaseClass::Ptr()
	{
		return shared_from_this();
	}

	void BaseClass::RegisterInputHooks()
	{
		if (hasInputsRegisterd) {
			return;
		}
		for (auto c : children) {
			c->RegisterInputHooks();
		}
	}

	void BaseClass::RemoveInputHooks()
	{
		if (!hasInputsRegisterd) {
			return;
		}
		for (auto c : children) {
			c->RegisterInputHooks();
		}
	}

	void BaseClass::IncTick()
	{
		ticks++;
	}
}; //namespace Dragon2D
