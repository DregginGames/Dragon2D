#Makefiel for the Dragon2D engine. basically just a wrapper for rdmd 

all: debug scriptdebug

debug: 
	rdmd --build-only -I./deps/ -of./engine/Dragon2D -g -debug source/game.d

release:
	rdmd --build-only -I./deps/ -of./engine/Dragon2D -O -release -boundscheck=off source/game.d
	strip ./engine/Dragon2D

scriptdebug:
	cd game/scriptbuild/ ; \
	find ../script -name *.d -exec dmd -I../../deps/ -I../../source/ -fPIC -shared -debug -g -defaultlib= {} \;
script:	
	cd game/scriptbuild/ ; \
	find ../script -name *.d -exec dmd -I../../deps/ -I../../source/ -fPIC -shared -release -O -defaultlib= {} \;

pack: release script 
	mkdir -p pack 
	rm -rf ./pack/*
	cp -r engine ./pack/
	cp -r game ./pack/
	cd pack/ ; \
	find . -name *.d -exec rm {} \; ; \
	find . -name *.o -exec rm {} \; ; 

clean: 
	rm -rf ./pack/ 
	rm -rf ./engine/Dragon2D 
	rm -rf ./game/scriptbuild/*
	find . -name log.txt -exec rm {} \;	
