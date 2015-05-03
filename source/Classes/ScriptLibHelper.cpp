#include "Env.h"
#include "ResourceManager.h"
#include "GameManager.h"
#include "BaseClass.h"
#include "ScriptEngine.h"
#include "ScriptLibHelper.h"

namespace Dragon2D {
	std::vector <std::function<void(void)>> gResetters;
	int StrToInt(std::string s) {
		return atoi(s.c_str());
	}
	float StrToFloat(std::string s) {
		return (float)atof(s.c_str());
	}


	void AddGlobalReset(std::function<void(void)> f) {
		gResetters.push_back(f);
	}

	void ResetGlobals() 
	{
		for (auto r : gResetters) {
			if (r) r();
		}
	}

	void LoadClasses(chaiscript::ChaiScript &chai) {
		//Script engine foo
		SCRIPTFUNCTION_ADD(ScriptEngine::IncludeScript, "Include", chai);
		SCRIPTFUNCTION_ADD(ScriptEngine::RawEval, "RawEval", chai);
		SCRIPTTYPE_ADD(std::ostream, "ostream", chai);
		//Some stuff		
		SCRIPTFUNCTION_ADD(StrToInt, "StrToInt", chai);
		SCRIPTFUNCTION_ADD(StrToFloat, "StrToFloat", chai);
		//ENV functions
		SCRIPTFUNCTION_ADD(Env::Gamefile, "Gamefile", chai);
		SCRIPTFUNCTION_ADD(Env::Enginefile, "Enginefile", chai);
		SCRIPTFUNCTION_ADD(Env::GetCurrentMouseState, "Mouseinfo", chai);
		SCRIPTFUNCTION_ADD(Env::SwapBuffers, "UpdateScreen", chai);
		SCRIPTFUNCTION_ADD(Env::ClearFramebuffer, "ClearScreen", chai);
		SCRIPTFUNCTION_ADD(Env::ResetCurrentTextInput, "ResetCurrentTextInput", chai);
		SCRIPTFUNCTION_ADD(Env::GetCurrentText, "GetCurrentText", chai);
		//Base Types
		SCRIPTCLASS_ADD(vec4, chai);
		SCRIPTCLASS_ADD(XMLUI, chai);
		SCRIPTCLASS_ADD(UIElement, chai);
		//Base Engine Structures and Resources
		SCRIPTCLASS_ADD(BaseClass, chai);
		SCRIPTCLASS_ADD(Resource, chai);
		SCRIPTCLASS_ADD(AudioResource, chai);
		SCRIPTCLASS_ADD(VideoResource, chai);
		SCRIPTCLASS_ADD(TextureResource, chai);
		SCRIPTCLASS_ADD(XMLResource, chai);
		SCRIPTCLASS_ADD(FontResource, chai);
		SCRIPTCLASS_ADD(GLProgramResource, chai);
		SCRIPTCLASS_ADD(MapResource, chai);
		SCRIPTCLASS_ADD(TextResource, chai);
		SCRIPTCLASS_ADD(ResourceManager, chai);
		//Engine Management
		SCRIPTCLASS_ADD(GameManager, chai);
		Typehelper::ScriptengineRegister(chai); //auto registration
	}


	void ScriptInfo_vec4(chaiscript::ChaiScript&chai) {
		chaiscript::ModulePtr m = chaiscript::ModulePtr(new chaiscript::Module());
		m->add(chaiscript::user_type<glm::vec4>(), "vec4");
		m->add(chaiscript::constructor<glm::vec4()>(), "vec4");
		m->add(chaiscript::constructor<glm::vec4(const glm::vec4&)>(), "vec4");
		m->add(chaiscript::constructor<glm::vec4(float)>(), "vec4");
		m->add(chaiscript::constructor<glm::vec4(float, float, float, float)>(), "vec4");
		m->add(chaiscript::fun(&glm::vec4::x), "x");
		m->add(chaiscript::fun(&glm::vec4::y), "y");
		m->add(chaiscript::fun(&glm::vec4::z), "z");
		m->add(chaiscript::fun(&glm::vec4::w), "w");
		chai.add(m);
	}

	void ScriptInfo_XMLUI(chaiscript::ChaiScript&chai) {
		chaiscript::ModulePtr m = chaiscript::ModulePtr(new chaiscript::Module());
		m->add(chaiscript::user_type<TailTipUI::XMLLoader>(), "XMLUI");
		m->add(chaiscript::constructor<TailTipUI::XMLLoader(const TailTipUI::XMLLoader&)>(), "XMLUI");
		m->add(chaiscript::constructor<TailTipUI::XMLLoader(int, std::string)>(), "XMLUI");
		m->add(chaiscript::fun(&TailTipUI::XMLLoader::RenderElements), "RenderElements");
		m->add(chaiscript::fun(&TailTipUI::XMLLoader::GetElementById), "GetElementById");
		chai.add(m);
	}

	void ScriptInfo_UIElement(chaiscript::ChaiScript&chai) {
		chaiscript::ModulePtr m = chaiscript::ModulePtr(new chaiscript::Module());
		m->add(chaiscript::user_type<TailTipUI::GeneralElement>(), "UIElement");
		m->add(chaiscript::constructor<TailTipUI::GeneralElement()>(), "UIElement");
		m->add(chaiscript::constructor<TailTipUI::GeneralElement(const TailTipUI::GeneralElement&)>(), "UIElement");
		m->add(chaiscript::fun(&TailTipUI::GeneralElement::Render), "Render");
		m->add(chaiscript::fun(&TailTipUI::GeneralElement::SetHidden), "SetHidden");
		m->add(chaiscript::fun(&TailTipUI::GeneralElement::GetName), "GetName");
		m->add(chaiscript::fun(&TailTipUI::GeneralElement::SetName), "SetName");
		m->add(chaiscript::fun(&TailTipUI::GeneralElement::SetPos), "SetPosition");
		chai.add(m);
	}

}; //namespace Dragon2D
