INCPATHS=-Isource/HoardXML/include -I"source/chaiscript 5.6.0/include" -Isource/TailTipUI/include -Isource -Isource/Classes
CXXFLAGS= --std=c++14 $(INCPATHS) -DDEBUG -g -c -Wall
LDFLAGS=-Lsource/TailTipUI/bin -lTailTipUI -lGL -lGLEW -ldl -lpthread -lSDL2 -lSDL2_ttf -lSDL2_image -lSDL2_mixer 
CC=clang++
EXEC=Dragon2D
VPATH=source:source/Classes
BUILDDIR=build
DSTDIR=engine
SRC=$(wildcard source/*.cpp) 
CLASS_SRC=$(wildcard source/Classes/*.cpp)
OBJECTS=$(patsubst source/Classes/%.cpp,build/%.o,$(CLASS_SRC)) $(patsubst source/%.cpp,build/%.o,$(SRC))

all: checkdirs $(OBJECTS)
	$(CC) $(OBJECTS) -o $(BUILDDIR)/$(EXEC) $(LDFLAGS) 
	cp $(BUILDDIR)/$(EXEC) $(DSTDIR)/

$(BUILDDIR)/%.o: %.cpp
	$(CC) $(CXXFLAGS) $< -o $@

checkdirs: $(BUILDDIR) $(DSTDIR)

$(DSTDIR): 
	@mkdir -p $@

$(BUILDDIR): 
	@mkdir -p $@

