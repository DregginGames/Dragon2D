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

	void BaseClass::RestoreObjectState(SaveStatePtr &in, int startfield)
	{
		if (in) {
			renderLayer = in->GetData<int>(startfield++);
			hasInputsRegisterd = in->GetData<bool>(startfield++);

			for (auto c : in->GetChildren()) {
				BaseClassPtr child = Typehelper::Create(c->GetName());
				if (child) {
					child->RestoreObjectState(c);
					AddChild(child);
				}
			}
		}
	}

	void BaseClass::SaveObjectState(SaveStatePtr &out, int startfield)
	{
		//We are called from a baseclass
		CreateSaveStateIfEmpty(out, "BaseClass");
		out->SetData<unsigned int>(startfield++, renderLayer);
		out->SetData<unsigned int>(startfield++, renderLayer);
		for (auto c : children) {
			SaveStatePtr childState;
			c->SaveObjectState(childState);
			out->AddChild(childState);
		}
	}

	//typehelper foo
	std::vector<std::function<void(chaiscript::ChaiScript&)>>* Typehelper::scriptfuncs = NULL;
	std::map<std::string, std::function<BaseClassPtr(void)>>* Typehelper::createfuncs = NULL; 

	Typehelper::Typehelper(std::string name, std::function<void(chaiscript::ChaiScript&)>scriptFunc, std::function<BaseClassPtr(void)> createFunc)
	{
		if (!scriptfuncs) {
			scriptfuncs = new std::vector <std::function<void(chaiscript::ChaiScript&)>>();
		}
		if (!createfuncs) {
			createfuncs = new std::map <std::string, std::function<BaseClassPtr(void)>>();
		}
		if (scriptFunc) {
			scriptfuncs->push_back(scriptFunc);
		}
		if (createFunc) {
			(*createfuncs)[name] = createFunc; 
		}
	}

	BaseClassPtr Typehelper::Create(std::string name) 
	{
		if ((*createfuncs)[name]) {
			return (*createfuncs)[name]();
		}
		return BaseClassPtr();
	}

	void Typehelper::ScriptengineRegister(chaiscript::ChaiScript&chai) 
	{
		for (auto f : (*scriptfuncs)) {
			f(chai);
		}
	}
}; //namespace Dragon2D
