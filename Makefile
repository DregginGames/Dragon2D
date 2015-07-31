#Makefiel for the Dragon2D engine. basically just a wrapper for rdmd 

all: debug scriptdebug

debug: 
	rdmd --build-only -I./deps/ -of./engine/Dragon2D -g -debug source/game.d

release:
	rdmd --build-only -I./deps/ -of./engine/Dragon2D -O -release -boundscheck=off source/game.d

scriptdebug:
	cd game/scriptbuild/
	find ../script -name *.d -exec dmd -I../../deps/ -I../../source/ -fPIC -shared -debug -g -defaultlib= {} \;
	cd ../../  
script:	
	cd game/scriptbuild/
	find ../script -name *.d -exec dmd -I../../deps/ -I../../source/ -fPIC -shared -release -O -defaultlib= {} \;
	strip game/scriptbuild/*
	cd ../../

pack: release script 
	mkdir -p pack 
	rm -rf ./pack/*
	cp -r engine ./pack/
	cp -r game ./pack/
	cd pack/
	find . -name *.d -exec rm {} \;
	cd ../
	
