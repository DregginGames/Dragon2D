#include "base.h"

#include "Env.h"
#include "ScriptLibHelper.h"
//Heders of everything used within the engine, so it can be piped into chaiscript

namespace Dragon2D
{

#define SCRIPTCLASS_ADD(name, chai) ScriptInfo_##name(chai);
#define SCRIPTFUNCTION_ADD(func,name, chai) chai.add(chaiscript::fun(&func),name)
#define SCRIPTTYPE_ADD(type, name, chai) chai.add(chaiscript::user_type<type>(), name)

	inline void LoadClasses(chaiscript::ChaiScript &chai) {
		SCRIPTTYPE_ADD(std::ostream, "ostream", chai);
		SCRIPTFUNCTION_ADD(Env::Gamefile, "Gamefile", chai);
		SCRIPTFUNCTION_ADD(Env::Enginefile, "Enginefile", chai);
		SCRIPTFUNCTION_ADD(Env::GetCurrentMouseState, "Mouseinfo", chai);
		SCRIPTFUNCTION_ADD(Env::SwapBuffers, "UpdateScreen", chai);
		SCRIPTFUNCTION_ADD(Env::ClearFramebuffer, "ClearScreen", chai);
		SCRIPTCLASS_ADD(vec4, chai);
		SCRIPTCLASS_ADD(XMLUI, chai);
	}


	//class: ScriptEngine
	//note: holds the chaiscript engine and is responsible for the interaction of engine-classes with it
	class ScriptEngine
	{
	public:
		//constructor: ScriptEngine
		//note: basic constructor
		ScriptEngine();
		//destructor: ~ScriptEngine
		//note: destructor
		virtual ~ScriptEngine();

		//function: run
		//note: runs the script engine wich causes Run() to be called in the run.chai-file
		void Run();

		
	private:
		chaiscript::ChaiScript chai;

	protected:
	};

	//class: ScriptEngine
	//note: Exception that happen in the scriptengine or are related to it are defined below
	class ScriptEngineException : public Exception
	{
	public:
		//constructor: ScriptEngineException() 
		//note: standart constructor 
		ScriptEngineException() : Exception() {};

		//constructor:  ScriptEngineException(std::string envError)
		//note: takes an script error as argument 
		ScriptEngineException(const char* scriptError) : Exception(scriptError) {};

		~ScriptEngineException() throw() {};
	};

}; //namespace Dragon2D