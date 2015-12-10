@echo off

call cleanup.bat

del dub.selections.json /Q
del *.visualdproj /Q
del *.sln /Q
rmdir .vs /S /Q



