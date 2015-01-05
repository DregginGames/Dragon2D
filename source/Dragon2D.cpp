#include "Dragon2D.h"
#include "./Classes/Env.h"

int main(int argc, char* argv[])
{
	try {
		Dragon2D::Env EngineEnv(argc, argv);
	}
	catch (Dragon2D::Exception e ) {
		std::cerr << "CRITICAL ERROR: \n\t" << e.what() << std::endl;
		return 1;
	}
	catch (std::exception e) {
		std::cerr << "CRITICAL ERROR BY STANDAT LIBARY: \n\t" << e.what() << std::endl;
		return 2;
	}
	return 0;
}
