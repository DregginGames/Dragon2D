AC_INIT([Dragon2D], [0.1])
AM_INIT_AUTOMAKE

AC_PROG_CXX
AX_CXX_COMPILE_STDCXX_11

AC_CHECK_HEADERS([SDL2/SDL2.h], [],[AC_MSG_ERROR(You need the SDL development library.)])
AC_CHECK_HEADERS([SDL2/SDL_ttf.h], [],[AC_MSG_ERROR(You need the SDL_ttf development library.)])
AC_CHECK_HEADERS([SDL2/SDL_image.h], [],[AC_MSG_ERROR(You need the SDL_image development library.)])
AC_CHECK_HEADERS([SDL2/SDL_mixer.h], [],[AC_MSG_ERROR(You need the SDL_mixer development library.)])
AC_CONFIG_FILES(Makefile source/Makefile)
AC_OUTPUT
