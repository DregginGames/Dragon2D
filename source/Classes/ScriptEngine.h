#include "base.h"

#include "Env.h"
#include "ScriptLibHelper.h"
//Heders of everything used within the engine, so it can be piped into chaiscript

namespace Dragon2D
{

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

		//function: IncludeScript
		//note: includes a script file and evals it
		static void IncludeScript(std::string name);

		//function: RawEval
		//note: evals a script 
		//param:	command: the stuff to eval. should be chaiscript.
		static void RawEval(std::string command);

		//function: Chai
		//note: direct access to the Chaiscript instance. Usefull for var-adding and stuff like that
		static chaiscript::ChaiScript& Chai();
	private:
		//var: chai. Hods the chai interpreter
		chaiscript::ChaiScript chai;
		//var: activeEngine. Holds the active script engine
		static ScriptEngine* activeEngine;
		//var: knownFiles. Holds names of the included files. used to avoid inlcludes breaking the engine
		std::vector<std::string> knownFiles;
	protected:
		void _IncludeScript(std::string name);
		void _RawEval(std::string command);
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