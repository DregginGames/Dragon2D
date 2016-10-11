#!/bin/sh
sh ./cleanup.sh 

mkdir -p deployPackage/game/

cp -a engine deployPackage/ 
cp -a game/cfg deployPackage/game/
cp -a game/resources deployPackage/game/
cp -a game/game.init deployPackage/game/ 

DFLAGS="-release -O -boundscheck=off" \
    dub build -c game --force --parallel 

cp engine/Dragon2D deployPackage/engine/

echo "#!/bin/sh\nengine/Dragon2D" > deployPackage/runGame.sh
chmod +x deployPackage/runGame.sh 
