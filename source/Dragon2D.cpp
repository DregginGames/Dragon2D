#include "Dragon2D.h"
#include "./Classes/Env.h"
#include "./Classes/GameManager.h"
//function: main
//note: entry point. Starts Env and GameManager
//note: Returns 0 if everything goes well, 1 in case of a Dragon2D exception, 2 in case of a std exception and 3 if the world burned down
int main(int argc, char* argv[])
{
	try {
		Dragon2D::Env EngineEnv(argc, argv);
		Dragon2D::GameManager CurrentManager;
	}
	catch (Dragon2D::Exception e ) {
		Dragon2D::Env::Err() << "CRITICAL ERROR: \n\t" << e.what() << std::endl;
		return 1;
	}
	catch (std::exception e) {
		std::cerr << "CRITICAL ERROR BY STANDARD LIBARY: \n\t" << e.what() << std::endl;
		return 2;
	}
	catch (...) {
		std::cerr << "I HAVE NO IDEA WHAT HAPPEND EXPECT EXPLOSIONS\n"<< std::endl;
		return 3;
	}
	return 0;
}
