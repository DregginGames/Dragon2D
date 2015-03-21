# HoardXML
A Small and simple header based XML library. 

## How to use it
HoardXML is headerbased, so you only need the HoardXML.h file to use it in your project. However, please dont forget the terms of the MIT license: credit please :D

## How to USE it
The lib uses 2 classes, and you need to know them. 

### Tags
The first is `HoardXML::Tag`. Its, as its name sayes, a tag as you find it in XML. 
You can set/access attributes of Tags via the functions `SetAttribute(name,value)` and `GetAttribute(name)`.
Also you can set/get the Data (content) of a tag by `SetData(data)` and GetData
Adding childs to elements is possible by using `AddChild(c)`, where c is a child tag.

Currently there is no way to remove a Tag from a parent, but normally that isn't needed at all. Raw access to the children is provided by `GetChildren()`, wich returns a vector of tags. 

Maybe most importandly is the `[]`, wich tages a string and returns a vector of pointers (!) to the sub-elements thats name match the string. Since you dont want to go throgh every tag with `tag["foo"]["baar"]`, it accepts multiple names seperated by `.`, with every one going deeper on layer. You should also notice that the vector will be empty it cant find a matching child class and that, if you have multiple tags with the same name but you go deeper in the structure, it will only return the children of the first one found. 

### Documents 
A document is not that different from a tag. In fact, `HoardXML::Document` is a child class of `HoardXML::Tag`.
So you have all functions of Tag, though they might not be that sensefull here. 
What is new is that you can Load a Document by passing a fstream or a filepath to its constructor, and that you can save it. 
`HoardXML::Tag::Save()` does use the method used for constructing the Document, however there are functions for saving into fstreams and directly via filepaths. 

### Thats it?
Yes, i am lazy. Im happy to forward you to the examples/example.cpp and to the header file cause they are commented. 
Also, beside the loading code (REGEX!) everything should be more or less well understandable


Greetings

Malte "mkalte" Kießling
