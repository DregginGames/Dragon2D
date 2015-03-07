#pragma once

#include "base.h"

namespace Dragon2D {

#define SCRIPTCLASS_ADD(name, chai) ScriptInfo_##name(chai);
#define SCRIPTFUNCTION_ADD(func,name, chai) chai.add(chaiscript::fun(&func),name)
#define SCRIPTTYPE_ADD(type, name, chai) chai.add(chaiscript::user_type<type>(), name)


#define D2DCLASS_SCRIPTINFO_MEMBER(classname, member) \
	m->add(chaiscript::fun(&classname::##member), #member);

#define D2DCLASS_SCRIPTINFO_OPERATOR(classname, operatorfunc, op) \
	m->add(chaiscript::fun(&classname::##operatorfunc), #op);

#define D2DCLASS_SCRIPTINFO_CONSTRUCTOR(classname, ...) \
	m->add(chaiscript::constructor<classname(__VA_ARGS__)>(), #classname);

#define D2DCLASS_SCRIPTINFO_PARENTINFO(base, derived) \
	m->add(chaiscript::base_class<base , derived>());

#define D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(name) \
	inline void ScriptInfo_##name(chaiscript::ChaiScript&chai) { \
	chaiscript::ModulePtr m = chaiscript::ModulePtr(new chaiscript::Module()); \
	m->add(chaiscript::user_type<name>(), #name ); \
	m->add(chaiscript::constructor<name()>(), #name); \
	m->add(chaiscript::constructor<name(const name##&)>(), #name);

#define D2DCLASS_SCRIPTINFO_BEGIN_GENERAL_GAMECLASS(name) \
	D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(name) \
	m->add(chaiscript::fun(&NewD2DObject<name>), "New" #name "Object"); 

#define D2DCLASS_SCRIPTINFO_BEGIN(name, parent) \
	D2DCLASS_SCRIPTINFO_BEGIN_GENERAL_GAMECLASS(name) \
	D2DCLASS_SCRIPTINFO_PARENTINFO(parent, name)

#define D2DCLASS_SCRIPTINFO_END chai.add(m); }

	//function: ScriptInfo_vec4
	//note: script-helper for glm::vec4
	void ScriptInfo_vec4(chaiscript::ChaiScript&chai);
	//function: ScriptInfo_XMLUI
	//note: Script-helper for TailTipUI::XMLLoader
	void ScriptInfo_XMLUI(chaiscript::ChaiScript&chai);
	void ScriptInfo_UIElement(chaiscript::ChaiScript&chai);

	//function: LoadClasses
	//note: used by the script engine, loads all game-relevant classes into it. Edit in ScriptLibHelper.cpp!
	void LoadClasses(chaiscript::ChaiScript &chai);

}; //namespace Dragon2D