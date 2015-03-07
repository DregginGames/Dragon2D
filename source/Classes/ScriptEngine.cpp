#include "ScriptEngine.h"
//this include is here since not every file needs to compile the chaiscript stdlib
#include <chaiscript\chaiscript_stdlib.hpp>

namespace Dragon2D
{
	ScriptEngine* ScriptEngine::activeEngine = nullptr;

	ScriptEngine::ScriptEngine()
		: chai(chaiscript::Std_Lib::library())
	{
		if (activeEngine != nullptr) {
			throw ScriptEngineException("Cant have more then one active script engine!");
		}
		activeEngine = this;
		LoadClasses(chai);
		std::fstream runfile = Env::Gamefile("script/run.chai", std::ios::in);
		if (!runfile.is_open()) {
			throw ScriptEngineException("Can open runfile. Is there a script/run.chai?");
		}

		std::string filestring = std::string(std::istreambuf_iterator<char>(runfile), std::istreambuf_iterator<char>());
		try {
			chai.eval(filestring);
			chai.eval("Init()");
		}
		catch (chaiscript::exception::eval_error e) {
			Env::Err() << e.what() << std::endl;
		}
		catch (Exception e) {
			Env::Err() << "CRITICAL WARNING: Dragon2D::Exception in ScriptHandler. Will try to ignore it." << std::endl;
			Env::Err() << "\n" << e.what() << std::endl;
		}
		catch (...) {
			throw ScriptEngineException("Unknown Script Error!");
		}
	}

	void ScriptEngine::Run()
	{
		try {
			chai.eval("Run()");
		}
		catch (chaiscript::exception::eval_error e) {
			Env::Err() << e.what() << std::endl;
		}
		catch (Exception e) {
			Env::Err() << "CRITICAL WARNING: Dragon2D::Exception in ScriptHandler. Will try to ignore it." << std::endl;
			Env::Err() << "\t" << e.what() << std::endl;
		}
		catch (...) {
			throw ScriptEngineException("Unknown Script Error!");
		}
	}

	ScriptEngine::~ScriptEngine()
	{
		chai.eval("Stop()");
		activeEngine = nullptr;
	}

	void ScriptEngine::IncludeScript(std::string name)
	{
		if (activeEngine == nullptr) {
			throw ScriptEngineException("Cannot include script without valid engine!");
		}

		activeEngine->_IncludeScript(name);
	}

	void ScriptEngine::_IncludeScript(std::string name)
	{
		//Prevent including something twice
		for (auto f : knownFiles) {
			if (f == name) {
				return;
			}
		}
		knownFiles.push_back(name);

		std::fstream includefile = Env::Gamefile(std::string("script/")+name+".chai", std::ios::in);
		if (!includefile.is_open()) {
			Env::Err() << "WARNING: cannot open script " << name << std::endl;
			return;
		}
		std::string filestring = std::string(std::istreambuf_iterator<char>(includefile), std::istreambuf_iterator<char>());

		try {
			chai.eval(filestring);
		}
		catch (chaiscript::exception::eval_error e) {
			Env::Err() << e.what() << std::endl;
		}
		catch (Exception e) {
			Env::Err() << "CRITICAL WARNING: Dragon2D::Exception in ScriptHandler. Will try to ignore it." << std::endl;
			Env::Err() << "\n" << e.what() << std::endl;
		}
		catch (...) {
			throw ScriptEngineException("Unknown Script Error!");
		}
	}

}; //namespace Dragon2D