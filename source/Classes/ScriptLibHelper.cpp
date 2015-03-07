#include "Env.h"
#include "ResourceManager.h"
#include "GameManager.h"
#include "BaseClass.h"
#include "Ui.h"
#include "ScriptEngine.h"
#include "ScriptLibHelper.h"

namespace Dragon2D {

	void LoadClasses(chaiscript::ChaiScript &chai) {
		SCRIPTFUNCTION_ADD(ScriptEngine::IncludeScript, "Include", chai);
		SCRIPTTYPE_ADD(std::ostream, "ostream", chai);
		SCRIPTTYPE_ADD(TTF_Font, "TTF_Font", chai);
		SCRIPTTYPE_ADD(Mix_Chunk, "Mix_Chunk", chai);
		SCRIPTTYPE_ADD(GLuint, "GLuint", chai);
		SCRIPTTYPE_ADD(GLfloat, "GLfloat", chai);
		SCRIPTFUNCTION_ADD(Env::Gamefile, "Gamefile", chai);
		SCRIPTFUNCTION_ADD(Env::Enginefile, "Enginefile", chai);
		SCRIPTFUNCTION_ADD(Env::GetCurrentMouseState, "Mouseinfo", chai);
		SCRIPTFUNCTION_ADD(Env::SwapBuffers, "UpdateScreen", chai);
		SCRIPTFUNCTION_ADD(Env::ClearFramebuffer, "ClearScreen", chai);
		SCRIPTCLASS_ADD(vec4, chai);
		SCRIPTCLASS_ADD(XMLUI, chai);
		SCRIPTCLASS_ADD(UIElement, chai);
		SCRIPTCLASS_ADD(BaseClass, chai);
		SCRIPTCLASS_ADD(Resource, chai);
		SCRIPTCLASS_ADD(AudioResource, chai);
		SCRIPTCLASS_ADD(VideoResource, chai);
		SCRIPTCLASS_ADD(TextureResource, chai);
		SCRIPTCLASS_ADD(ScriptResource, chai);
		SCRIPTCLASS_ADD(FontResource, chai);
		SCRIPTCLASS_ADD(GLProgramResource, chai);
		SCRIPTCLASS_ADD(MapResource, chai);
		SCRIPTCLASS_ADD(TextResource, chai);
		SCRIPTCLASS_ADD(ResourceManager, chai);
		SCRIPTCLASS_ADD(GameManager, chai);
		SCRIPTCLASS_ADD(Ui, chai);
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
		m->add(chaiscript::constructor<TailTipUI::XMLLoader(int, std::string, TailTipUI::MouseinfoCallbackType)>(), "XMLUI");
		m->add(chaiscript::fun(&TailTipUI::XMLLoader::RenderElements), "RenderElements");
		chai.add(m);
	}

	void ScriptInfo_UIElement(chaiscript::ChaiScript&chai) {
		chaiscript::ModulePtr m = chaiscript::ModulePtr(new chaiscript::Module());
		m->add(chaiscript::user_type<TailTipUI::GeneralElement>(), "UIElement");
		m->add(chaiscript::constructor<TailTipUI::GeneralElement()>(), "UIElement");
		m->add(chaiscript::constructor<TailTipUI::GeneralElement(const TailTipUI::GeneralElement&)>(), "UIElement");
		m->add(chaiscript::fun(&TailTipUI::GeneralElement::Render), "Render");
		chai.add(m);
	}

}; //namespace Dragon2D