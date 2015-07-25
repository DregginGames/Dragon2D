#Makefiel for the Dragon2D engine. basically just a wrapper for rdmd 

all: debug 

debug: 
	rdmd --build-only -I./deps/ -of./engine/Dragon2D -debug source/game.d
release:
	rdmd --build-only -I./deps/ -of./engine/Dragon2D -O -release -boundscheck=off source/game.d
