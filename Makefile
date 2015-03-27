INCPATHS=-Isource/HoardXML/include -I"source/chaiscript 5.6.0/include" -Isource/TailTipUI/include -Isource -Isource/Classes
CXXFLAGS= --std=c++14 $(INCPATHS) -DDEBUG -g -c -Wall
RELEASEFLAGS= --std=c++14 $(INCPATHS) -DRELEASE -O3 -c -Wall
LDFLAGS=-Lsource/TailTipUI/bin -lTailTipUI -lGL -lGLEW -ldl -lpthread -lSDL2 -lSDL2_ttf -lSDL2_image -lSDL2_mixer 
CC=clang++
EXEC=Dragon2D
VPATH=source:source/Classes
BUILDDIR=build
DSTDIR=engine
GAMEFOLDER=engine/demogame
RELEASEFOLDER=ReleaseBuild
RELEASEDEPS=libglew1.10 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0 libsdl2-mixer-2.0-0 libsdl2-2.0-0
SRC=$(wildcard source/*.cpp) 
CLASS_SRC=$(wildcard source/Classes/*.cpp)
OBJECTS=$(patsubst source/Classes/%.cpp,build/%.o,$(CLASS_SRC)) $(patsubst source/%.cpp,build/%.o,$(SRC))
RELEASEOBJECTS=$(patsubst source/Classes/%.cpp,build/R.%.o,$(CLASS_SRC)) $(patsubst source/%.cpp,build/R.%.o,$(SRC))


all: debug 

pack: cleanPack 
	@mkdir -p $(RELEASEFOLDER)
	@mkdir -p $(RELEASEFOLDER)/game
	@mkdir -p $(RELEASEFOLDER)/engine 
	-cp $(DSTDIR)/* $(RELEASEFOLDER)/engine/
	-cp -a $(GAMEFOLDER)/. $(RELEASEFOLDER)/game/
	touch $(RELEASEFOLDER)/Launch.sh 
	touch $(RELEASEFOLDER)/InstallDeps.sh 
	@echo "sudo apt-get install $(RELEASEDEPS)" > $(RELEASEFOLDER)/InstallDeps.sh
	@echo "engine/$(EXEC) game/" > $(RELEASEFOLDER)/Launch.sh 
	chmod +x $(RELEASEFOLDER)/Launch.sh
	chmod +x $(RELEASEFOLDER)/InstallDeps.sh
	-tar -zcvf $(RELEASEFOLDER).tar.gz $(RELEASEFOLDER)

cleanPack:
	-rm -rf $(RELEASEFOLDER)
	-rm -f $(RELEASEFOLDER).tar.gz

release: clean $(RELEASEOBJECTS)
	$(CC) $(RELEASEOBJECTS) -o $(BUILDDIR)/$(EXEC) $(LDFLAGS)
	cp $(BUILDDIR)/$(EXEC) $(DSTDIR)/



debug: checkdirs $(OBJECTS)
	$(CC) $(OBJECTS) -o $(BUILDDIR)/$(EXEC) $(LDFLAGS) 
	cp $(BUILDDIR)/$(EXEC) $(DSTDIR)/

clean: checkdirs
	-rm -rf $(BUILDDIR)/*
	-rm -f $(DSTDIR)/$(EXEC)

$(BUILDDIR)/%.o: %.cpp
	$(CC) $(CXXFLAGS) $< -o $@

$(BUILDDIR)/R.%.o: %.cpp
	$(CC) $(RELEASEFLAGS) $< -o $@

checkdirs: $(BUILDDIR) $(DSTDIR)

$(DSTDIR): 
	@mkdir -p $@

$(BUILDDIR): 
	@mkdir -p $@

