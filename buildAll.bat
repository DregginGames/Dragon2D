@echo off
dub build -c game
dub build -c uieditor
dub build -c mapeditor
call buildDocs.bat
