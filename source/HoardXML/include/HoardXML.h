//File: HoardXML.hpp
//Info: Contains the library "HoardXML", a header based library for XML loading
//Info: HoardXML does NOT follow the complete w3c definition of xml 1.0. It does not verify the document using a DTD, nor it needs any kind of version tag for the XML.

#pragma once
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <list>
#include <regex>
#include <algorithm>

//namespace: HoardXML
//info: holds all the classes and functions used by HoardXML
namespace HoardXML {

//class: Tag
//info: Tag contains a document-tag. 
class Tag 
{
public:
	//constructor: Tag
	//note: Creates an empty Tag
	Tag() 
	: name(""), isEmptyTag(false) 
	{
	
	}
	
	//constructor: Tag
	//note: Creates an Tag with the name "tagName"
	//param: name: name of the new Tag
	Tag(std::string tagName) 
	: name(tagName), isEmptyTag(false)
	{
		
	}
	
	//constructor: Tag
	//note: Creates an Tag with the name "tagName" and parses the string "toParse" to fill itself with content
	//param: 	name: name of the new Tag
	//		toParse: the string to parse into the tag. 
	Tag(std::string tagName, std::string toParse) 
	: name(tagName), isEmptyTag(false)
	{
		Load(toParse);
	}

	//destructor: ~Tag
	//note: does not much since all subclasses are self-deliting
	virtual ~Tag() 
	{
		//nothing 
	}
	

	//function: GetName
	//note: returns the name of the Tag
	std::string GetName() const
	{
		return name;
	}
	
	//function: SetName
	//note: Sets the name of the Tag. 
	//param: 	newName: name to set the tags to. 
	void SetName(std::string newName) 
	{
		name=newName;
	}

	//function: GetAttribute 
	//note: Returns a specific attribute. Returns an empty string if the Attribute is unknown.
	std::string GetAttribute(std::string attribute)
	{
		return attributes[attribute];
	}

	//function: SetAttribute
	//note: sets a specific attribute to value "data"
	//param: 	attribute: the attribute to set 
	//		data: the data to set the value of the attribute to.		
	void SetAttribute(std::string attribute, std::string data) 
	{
		attributes[attribute] = data;
	}

	//function: GetData
	//note: returns the data of this tag 
	std::string GetData() const
	{
		return data;
	}

	//function: SetData
	//note: sets the data of this Tag
	//param:	newData: data to set 
	void SetData(std::string newData) 
	{
		data = newData;
	}

	//function: GetAttributes()
	//note: returns a reference to the attributes of the tag. All of them, packed in a std::map 
	std::map<std::string, std::string>& GetAttributes() 
	{
		return attributes;
	}

	//function: GetChildren
	//note: returns a reference to the children of this tag. 
	std::vector<Tag>& GetChildren() 
	{
		return children;
	}
	
	//function: SetEmptyTag
	//note: Sets this tag to be witout data and children. 
	//note: it will be Serialized as <name [attributes]\>. 
	//note: SETTING TO TRUE ERASES ALL DATA AND CHILD ELEMENTS!
	//param:	b: Parameter to set isEmptyTag to.
	void SetEmptyTag(bool b)
	{
		isEmptyTag = b;
		if(isEmptyTag) {
			data = "";
			children.clear();
		}
	}

	//function: GetEmptyTag
	//note: Returns if this tag is stand-alone without data and children 
	bool GetEmptyTag() 
	{
		return isEmptyTag;
	}
	

	//function: AddChild
	//note: Adds a child to this tag. 
	//param:	c: Tag to add
	void AddChild(Tag& c) 
	{
		children.push_back(c);
	}
 	
	//function: Serialize 
	//note: serializes the tag and its subtags including the data into a xml-tree
	//param:	depth: The depth of this operation. causes depth times '/t's added at the biginning to every line of the output 
	virtual std::string Serialize(int depth=0)
	{
		std::string tabs;
		for (int i = 0; i<depth;i++) {
			tabs+='\t';
		}
		std::string result;
		result += tabs+std::string("<")+name+std::string(" ");
		for (auto elem = attributes.begin(); elem!=attributes.end(); elem++) {
			result += elem->first+std::string("=\"")+elem->second+std::string("\" ");
		}
		if(isEmptyTag) {
			result+=std::string("/>\n");
			return result;
		}
		result+=std::string(">");
		if(children.size()!=0) {
			result += "\n";
			for (Tag t : children) {
				result+=t.Serialize(depth+1);
			}
			if(data!="") {
				result += tabs+data+std::string("\n")+tabs;
			}
		}
		else {
			result+=data;
		}
		result+=std::string("</")+name+std::string(">\n");
		return result;
	}
	
	//operator: []
	//note: reurns a vector of pointers to child tags with matching namepath.
	//	 if there are multiple tags of one name in a layer AND you want tags from deeper layers, it will use the first known.
	//	 if you want to get all of them, use GetChildren and search them yourself. 
	//	 syntax is name(.name2(.name3...))
	//param:	tagName: name of the tag to get, as dom-path (foo.bar.blahrg) 	
	std::vector<Tag*> operator[](std::string tagName)  
	{
		std::vector<Tag*> resultlist;
		static std::regex nameRE("[.]?([\\w\\d]+)([\\w\\d.]*)");
		std::smatch m;
		if(std::regex_search(tagName, m, nameRE)) {
			if(m[1]!="") {
				for(auto t = children.begin(); t!=children.end(); t++) {
					if(m[1]==t->GetName()) {
						if(m[2]=="") {
							resultlist.push_back(&(*t));
						}
						else {
							std::vector<Tag*> l = (*t)[m[2]];
							resultlist.insert(resultlist.end(), l.begin(), l.end());
							break;
						}
					}
				}
			}
		}
		return resultlist;
	}

	//function: Load
	//note: Loads tag-content into this tag
	//param: 	toParse: data to parse
	std::string Load(std::string toParse)
	{
		unsigned int pos = toParse.npos;
		while((pos=toParse.find("<"))!=toParse.npos) {
			data += toParse.substr(0,pos);
			unsigned int endpos = toParse.find(">", pos);
			std::string tagstring = toParse.substr(pos,endpos-pos+1);
			toParse = toParse.substr(endpos+1, toParse.size()-endpos);
			//create the new Tag
			unsigned int newTagPos = 0;
			if((newTagPos=tagstring.find_first_not_of("<> \n\t"))!=tagstring.npos) {
				//is a end-tag?
				if(tagstring[newTagPos]=='/' ) {
					//get the name of this end-tag. in theory it should be the name of this tag, but who knows
					unsigned int endTagNamePos = tagstring.find_first_not_of("<> \n\t/", newTagPos); 
					unsigned int endTagNameEnd = tagstring.find_first_of("<> \n\t", endTagNamePos);
					std::string endTagName = tagstring.substr(endTagNamePos,endTagNameEnd-endTagNamePos);
					//if its us, were done here. 
					if(endTagName==name) {
						break;
					} else { //otherewise this tag is bad, and it should feel bad. becomes data
						data+=tagstring;
					}
				} else { //no, its a normal tag. parse it, add it as child and let it continue the parsing
					unsigned int tagNamePos = tagstring.find_first_not_of("<> \n\t/", newTagPos); 
					unsigned int tagNameEnd = tagstring.find_first_of("<> \n\t", tagNamePos);
					std::string tagName = tagstring.substr(tagNamePos,tagNameEnd-tagNamePos);
					Tag child(tagName);
					//we have the name, we need the attributes: foo="bar". find the equal, go left, then right, then cut the string to parse.
					std::string attributeString = tagstring.substr(tagNameEnd+1, tagstring.size()-tagNameEnd);
					unsigned int equalPos = attributeString.npos;
					while((equalPos=attributeString.find("="))!=attributeString.npos) {
						std::string l = attributeString.substr(0,equalPos);
						l.erase (std::remove (l.begin(), l.end(), ' '), l.end());
						unsigned int rBegin = attributeString.find_first_of("\"'",equalPos+1);
						unsigned int rEnd = attributeString.find_first_of("\"'",rBegin+1);
						std::string r = attributeString.substr(rBegin+1,rEnd-rBegin-1);
						child.SetAttribute(l,r);
						attributeString = attributeString.substr(rEnd+1,attributeString.size()-rEnd);
					}
					//now check if it is an empty tag (-> <tag bub="blahrg> /> )
					//if not, let it parse.
					if(attributeString.find("/")!=attributeString.npos) {
						child.SetEmptyTag(true);
					} else {
						toParse = child.Load(toParse);
					}
					AddChild(child);
				}
			}
		}
		//last step is to fix the data. remove newlines, double spaces etc. 
		data.erase (std::remove (data.begin(), data.end(), '\n'), data.end());
		data.erase (std::remove (data.begin(), data.end(), '\r'), data.end());
		data.erase (std::remove (data.begin(), data.end(), '\t'), data.end());
		data.erase(std::unique(data.begin(), data.end(), [](char lhs, char rhs) { return (lhs == rhs) && (lhs == ' '); }), data.end());   
		return toParse;
	}
	
private:
	//var: name. Holds the name of this tag. 
	std::string name;
	//var: data. Holds the data of this tag. 
	std::string data;
	//var: attributes. Holds the attributes of this tag. 
	std::map<std::string, std::string> attributes;
	//var: children. Holds the children of this tag. 
	std::vector<Tag> children;
	//var: isEmptyTag. Holds if it is a single tag without data. 
	bool isEmptyTag;
	

};

//class: Document
//info: Document is the "root" tag of a xml. 	
//		while you can do nearly everything with Tag itself, document manages saving, loading and other stuff for you. 
//parent: Tag
class Document : public Tag
{
public:
	//constructor: Document
	//note: Creates an empty document
	Document() 
	{
	
	}
	
	//constructor: Document
	//note: Creates an document form a file with name "filename". 
	//		calling save without argbuments on this will save it to that exact file. 
	//param: the file to load from and save to by name
	Document(std::string filename)
	{
		std::ifstream infile(filename);
		std::string indata = std::string(std::istreambuf_iterator<char>(infile), std::istreambuf_iterator<char>());
		Load(indata);
	}

	//function: Save
	//note: Saves a document to a file named by "filename"
	//param: 	filename: file to save to
	void Save(std::string filename)
	{
		std::fstream outfile(filename, std::ios::out);
		outfile << Serialize();
		outfile.close();
	}
	
	//function: Save
	//note: Saves a Document. Uses method intended by constructor
	void Save() 
	{
			Save(savefile);
	}
	
	//functions: Serialize
	//note: overloaded Tag::Serialize that serializes a document 
	//param: 	depth: tabs to add in the beginning of each line
	virtual std::string Serialize(int depth=0)
	{
		std::string result;
		for (Tag t : GetChildren()) {
			result += t.Serialize(depth+1);
		}
		return result;
	}
	

private:
	std::string savefile;
protected:

};

}; //end of namespace HoardXML
