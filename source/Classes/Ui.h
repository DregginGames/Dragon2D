#pragma once

#include "BaseClass.h"
#include "ScriptLibHelper.h"
#include "Env.h"

namespace Dragon2D {

	//class: Ui
	//note: Holds a UI-tree form TailTipUI
	D2DCLASS(Ui, public BaseClass)
	{
	public:
		Ui();
		Ui(std::string name);
		~Ui();

		virtual void Render() override;
		virtual void Update() override;

		virtual void Load(std::string name);

		virtual void AddCallback(std::string name, TailTipUI::XMLLoaderEventCallback c);

		virtual void SaveObjectState(SaveStatePtr &out, int startfield = 0) override;
		virtual void RestoreObjectState(SaveStatePtr &in, int startfield = 0) override;

	private:
		std::string name;
		TailTipUI::XMLLoader xmlloader;

	protected:
	};

	D2DCLASS_SCRIPTINFO_BEGIN(Ui, BaseClass)
		D2DCLASS_SCRIPTINFO_MEMBER(Ui, Load)
		D2DCLASS_SCRIPTINFO_MEMBER(Ui, AddCallback)
	D2DCLASS_SCRIPTINFO_END
};