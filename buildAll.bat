@echo off
dub build -c game
dub build -c uieditor

call buildDocs.bat
