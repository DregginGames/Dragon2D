call cleanup.bat

mkdir releasePackage
mkdir releasePackage\engine 
mkdir releasePackage\game 
xcopy engine releasePackage\engine /S
xcopy game releasePackage\game /S

dub build -c game -b release

copy engine\Dragon2D.exe releasePackage\engine\Dragon2D.exe 

pause