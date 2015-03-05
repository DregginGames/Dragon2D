#pragma once

#include "base.h"

inline void ScriptInfo_vec4(chaiscript::ChaiScript&chai) {
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

inline void ScriptInfo_XMLUI(chaiscript::ChaiScript&chai) {
	chaiscript::ModulePtr m = chaiscript::ModulePtr(new chaiscript::Module());
	m->add(chaiscript::user_type<TailTipUI::XMLLoader>(), "XMLUI");
	m->add(chaiscript::constructor<TailTipUI::XMLLoader(const TailTipUI::XMLLoader&)> (), "XMLUI");
	m->add(chaiscript::constructor<TailTipUI::XMLLoader(int,std::string, TailTipUI::MouseinfoCallbackType)>(), "XMLUI");
	m->add(chaiscript::fun(&TailTipUI::XMLLoader::RenderElements), "RenderElements");
	chai.add(m);
}