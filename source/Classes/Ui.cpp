#include "Ui.h"

namespace Dragon2D
{
	Ui::Ui()
		: xmlloader(0)
	{
		SetRenderLayer(255);
	}

	Ui::Ui(std::string name)
		: xmlloader(0)
	{
		Load(name);
	}

	Ui::~Ui()
	{

	}
	
	void Ui::Load(std::string name)
	{
		std::string xmlfile = Env::GetGamepath() + std::string("ui/") + name + ".xml";
		xmlloader.Load(xmlfile);
	}

	void Ui::Render()
	{
		xmlloader.RenderElements();
	}

	void Ui::Update()
	{

	}

	void Ui::AddCallback(std::string name, TailTipUI::XMLLoaderEventCallback c)
	{
		xmlloader.RegisterCallback(name, c);
	}
}; //namespace Dragon2D