#!/bin/sh 

cd ./build/
../configure
make

pwd
cp ./source/Dragon2D ../engine/Dragon2D
