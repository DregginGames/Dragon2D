#include "Ui.h"
#include "ScriptEngine.h"
namespace Dragon2D
{
	D2DCLASS_REGISTER(Ui);
	Ui::Ui()
		: xmlloader(0)
	{
		SetRenderLayer(255);
	}

	Ui::Ui(std::string name)
		: xmlloader(0) , name(name)
	{
		Load(name);
	}

	Ui::~Ui()
	{

	}
	
	void Ui::Load(std::string name)
	{
		this->name = name;
		std::string xmlfile = Env::GetGamepath() + std::string("ui/") + name + ".xml";
		xmlloader.Load(xmlfile);
		//try to find a script for this menu. menuscripts are in script/ui/
		std::string scriptfile = std::string("ui/") + name;
		ScriptEngine::IncludeScript(scriptfile);
		ScriptEngine::Chai().add(chaiscript::var(std::dynamic_pointer_cast<Ui>(Ptr())), "curui");
		ScriptEngine::RawEval(std::string("LoadUI") + name + "(curui);");
	}

	void Ui::Render()
	{
		xmlloader.RenderElements();
		BaseClass::Render();
	}

	void Ui::Update()
	{
		BaseClass::Update();
	}

	void Ui::AddCallback(std::string name, TailTipUI::XMLLoaderEventCallback c)
	{
		xmlloader.RegisterCallback(name, c);
	}

	void Ui::SaveObjectState(SaveStatePtr &out, int startfield)
	{
		CreateSaveStateIfEmpty(out, "Ui");
		out->SetData(startfield++, name);
		BaseClass::SaveObjectState(out, startfield);
	}

	void Ui::RestoreObjectState(SaveStatePtr &in, int startfield)
	{
		if (in) {
			name = in->GetData<std::string>(startfield++);
			BaseClass::RestoreObjectState(in,startfield);
			Load(name);
		}
	}

	TailTipUI::XMLLoader& Ui::GetLoader()
	{
		return xmlloader;
	}
}; //namespace Dragon2D