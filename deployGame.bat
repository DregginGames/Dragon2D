call cleanup.bat

mkdir deployPackage
mkdir deployPackage\engine 
mkdir deployPackage\game 
mkdir deployPackage\game\resources
mkdir deployPackage\game\cfg

xcopy engine deployPackage\engine /S
xcopy game\cfg deployPackage\game\cfg /S
xcopy game\resources deployPackage\game\resources /S
xcopy game\game.init deployPackage\game /S

dub build -c game

xcopy engine\Dragon2D.exe deployPackage\engine /S

echo engine\Dragon2D.exe > deployPackage\runGame.bat

pause