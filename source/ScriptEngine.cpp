#include "ScriptEngine.h"
//this include is here since not every file needs to compile the chaiscript stdlib
#include <chaiscript\chaiscript_stdlib.hpp>

namespace Dragon2D
{

	ScriptEngine::ScriptEngine()
		: chai(chaiscript::Std_Lib::library())
	{
		chai.eval("puts(\"test\")");
		LoadClasses(chai);
		std::fstream runfile = Env::Gamefile("script/run.chai", std::ios::in);
		if (!runfile.is_open()) {
			throw ScriptEngineException("Can open runfile. Is there a script/run.chai?");
		}

		std::string filestring = std::string(std::istreambuf_iterator<char>(runfile), std::istreambuf_iterator<char>());
		chai.eval(filestring);
		chai.eval("Init()");
	}

	void ScriptEngine::Run()
	{
		try {
			chai.eval("Run()");
		}
		catch (chaiscript::exception::eval_error e) {
			Env::Err() << e.what() << std::endl;
		}
		catch (...) {
			throw ScriptEngineException("Unknown Script Error!");
		}
	}

	ScriptEngine::~ScriptEngine()
	{
		chai.eval("Stop()");
	}
}; //namespace Dragon2D