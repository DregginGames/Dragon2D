@echo off

REM clean output
dub clean --all-packages
del engine\*.exe /Q
del engine\*.pdb /Q
del engine\*.lib /Q
del engine\*.so /Q
rmdir releasePackage /S /Q

REM just in case we have linux fragments, might throw errors but who cares
del engine\Dragon2D /Q
del engine\uieditor /Q

REM clean rest, including dub tmp dir and docs
rmdir .dub /S /Q
rmdir docs /S /Q
del *.html /Q 
del docs.json /Q