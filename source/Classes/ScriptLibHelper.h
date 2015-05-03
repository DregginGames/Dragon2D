#pragma once

#include "base.h"

namespace Dragon2D {

	//since chaiscript cant global, and we also need to make shure that global variables are deleted way before chaiscript does it, there is a wrapper
	//every class has its own container for global variables, accessed with Global##classname(identifier) (example: GlobalSprite("s");
	//that returns a shared poninter. For internal stuff, there is AddGlobalReset(std::function<void(void)> f) and ResetGlobals().
	//these make shure everything is deleted properly

	//function: AddGlobalReset
	//note: Adds a resetter for global objects
	void AddGlobalReset(std::function<void(void)> f);
	void ResetGlobals();

#define SCRIPTCLASS_ADD(name, chai) ScriptInfo_##name(chai);
#define SCRIPTFUNCTION_ADD(func,name, chai) chai.add(chaiscript::fun(&func),name)
#define SCRIPTTYPE_ADD(type, name, chai) chai.add(chaiscript::user_type<type>(), name)


#define D2DCLASS_SCRIPTINFO_MEMBER(classname, member) \
	m->add(chaiscript::fun(&classname::member), #member);

#define D2DCLASS_SCRIPTINFO_OPERATOR(classname, operatorfunc, op) \
	m->add(chaiscript::fun(&classname::operatorfunc), #op);

#define D2DCLASS_SCRIPTINFO_CONSTRUCTOR(classname, ...) \
	m->add(chaiscript::constructor<classname(__VA_ARGS__)>(), #classname);

#define D2DCLASS_SCRIPTINFO_PARENTINFO(base, derived) \
	m->add(chaiscript::base_class<base , derived>());

#define D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(name) \
	inline std::map<std::string,std::shared_ptr<name>>& ScriptInfo_##name##_AccessGloalValues() { \
		static std::map<std::string,std::shared_ptr<name>> Values; \
		return Values; \
		} \
	inline std::shared_ptr<name> ScriptInfo_##name##_AccessGloalVar(std::string n) { \
		if(!ScriptInfo_##name##_AccessGloalValues()[n]) ScriptInfo_##name##_AccessGloalValues()[n].reset(new name()); \
		return ScriptInfo_##name##_AccessGloalValues()[n]; \
		} \
	inline void ScriptInfo_##name##_ResetGlobal() { \
		ScriptInfo_##name##_AccessGloalValues().clear(); \
			} \
	inline void ScriptInfo_##name(chaiscript::ChaiScript&chai) { \
	chaiscript::ModulePtr m = chaiscript::ModulePtr(new chaiscript::Module()); \
	m->add(chaiscript::user_type<name>(), #name ); \
	m->add(chaiscript::constructor<name()>(), #name); \
	m->add(chaiscript::constructor<name(const name &)>(), #name); \
	m->add(chaiscript::fun(&ScriptInfo_##name##_AccessGloalVar), "Global"#name); \
	m->add(chaiscript::fun(&ScriptInfo_##name##_ResetGlobal), "GlobalReset"#name); \
	AddGlobalReset(ScriptInfo_##name##_ResetGlobal); \

#define D2DCLASS_SCRIPTINFO_BEGIN_GENERAL_GAMECLASS(name) \
	D2DCLASS_SCRIPTINFO_BEGIN_GENERAL(name) \
	m->add(chaiscript::fun(&NewD2DObject<name>), "New" #name "Object"); 

#define D2DCLASS_SCRIPTINFO_BEGIN(name, parent) \
	D2DCLASS_SCRIPTINFO_BEGIN_GENERAL_GAMECLASS(name) \
	D2DCLASS_SCRIPTINFO_PARENTINFO(parent, name) \
	chai.add(chaiscript::type_conversion<name##Ptr,parent##Ptr>([](const name##Ptr in) { return std::dynamic_pointer_cast<parent>(in);})); \
	chai.add(chaiscript::type_conversion<name##Ptr, BaseClassPtr>([](const name##Ptr in) { return std::dynamic_pointer_cast<BaseClass>(in);}));

#define D2DCLASS_SCRIPTINFO_END chai.add(m); }

#define D2DCLASS_NOSCRIPT(classname) inline void ScriptInfo_##name(chaiscript::ChaiScript&chai) {}

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
