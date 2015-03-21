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
		//_ParseData(toParse);
	}

	//destructor: ~Tag
	//note: does not much since all subclasses are self-deliting
	virtual ~Tag() 
	{
		//nothing 
	}
	

	//function: GetName
	//note: returns the name of the Tag
	std::string GetName() 
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
	std::string GetData() 
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
	void AddChild(Tag c) 
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
	void Load(std::string toParse)
	{
		static std::regex completeTagRE("(<\\s*/*\\s*[\\w-]*\\s*[^<&>]*>)");
		std::smatch m;
		while(std::regex_search(toParse,m,completeTagRE)) {
			Tag newTag = _ParseTag(m[1]);
			//tag is invalid? remove and handle next
			if(newTag.GetName()=="") {
				toParse = m.prefix().str()+m.suffix().str();	
				continue;
			}
			//its a tag without content? add as child, remove and handle next
			if(newTag.GetEmptyTag()) {
				toParse = m.prefix().str()+m.suffix().str();
				AddChild(newTag);
				continue;
			}
	
			
			std::string tagContent;
			std::string tagSuffix;
			//Get the data inside of the tag. dont panic if we cant find an end tag. if we cant, it will be handeld as a tag without content.
			if(_TagContent(newTag.GetName(), m.suffix().str(), tagContent, tagSuffix)) {
				newTag.Load(tagContent);
				toParse = m.prefix().str()+tagSuffix;
			} else {
				toParse = m.prefix().str()+m.suffix().str();
			}
			AddChild(newTag);
		}
		//Everything that survived the stuff above must be data
		SetData(_ProcessData(toParse));
	}

protected:
	
	//function _TagContent
	//note: This function makes shure that the content between the tag-boundries is parsed right.
	//		Its also responsible for avoiding problems with nested tags.
	//		Returns TRUE if could parse content, false otherwise
	//param:	name: name of the just opend tag
	//			inSuffix: rest of file (!) after the opening tag
	//		OUT outContent: The content between the tags, emptystring if no end-tag found
	//		OUT outSuffix: The string behind the end-tag. undefiened if not found.
	bool _TagContent(std::string name, std::string inSuffix, std::string&outContent, std::string&outSuffix) 
	{
		int tagCount=1;
		static std::regex tagRE("<\\s*/*([\\w-]*)\\s*([^<&>]*)>");
		static std::regex endTagTagRE("<\\s*/+([\\w-]*)\\s*([^<&>]*)>");
		std::smatch m;
		std::string dumped;
		while (std::regex_search(inSuffix, m, tagRE)) {
			//fond a tag. increase tagCount by 1 if its a opening tag, decrese otherwise
			if (m[1].str() == name) {
				std::smatch m2;
				std::string tagString = m[0].str();
				if (std::regex_search(tagString, m2, endTagTagRE)) {
					if (m2[1].str() == name) {
						tagCount--;
					}
				}
				else {
					tagCount++;
				}
			}
			if(tagCount<=0) {
				outContent = dumped+m.prefix().str();
				outSuffix = m.suffix().str();
				return true;
			}
			dumped += m.prefix().str()+m[0].str();
			inSuffix = m.suffix().str();
		}
		return false;
	}
	
	
	//function: _ParseTag
	//note: Parses a tag, meaning the "<tagfoo>"-sequence to extract attributes
	//param:	toParse: the data to  parse 	
	static Tag _ParseTag(std::string toParse)
	{
		static std::regex tagRE("<\\s*([\\w-]*)\\s*([^<&>]*)>");
		static std::regex attributeRE("([\\w-]*)=\"([^<&>\"]*)\"");
		static std::regex noContentRE("(/)");
		std::smatch m;
		if(std::regex_search(toParse,m,tagRE)) {
			Tag newTag(m[1]);
			std::string argsAndTypeString = m[2];
			std::smatch m2;
			while(std::regex_search(argsAndTypeString, m2, attributeRE)) {
				newTag.SetAttribute(m2[1], m2[2]);
				argsAndTypeString = m2.suffix().str();
			}
			if(std::regex_search(argsAndTypeString, m2, noContentRE)) {
				newTag.SetEmptyTag(true);
			}
			return newTag;
		}
		return Tag();
	}

	//function: _ProcessData
	//note: Removes every not wanted character and replaces replacement characters. 
	//param:	toParse: string to process
	static std::string _ProcessData(std::string toParse)
	{
		static std::regex spaceRE("([\\s])[\\s]+");
		
		return std::regex_replace(toParse, spaceRE, "");
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
	: saveToRaw(false)
	{
	
	}
	
	//constructor: Document
	//note: Creates an document form a file with name "filename". 
	//		calling save without argbuments on this will save it to that exact file. 
	//param: the file to load from and save to by name
	Document(std::string filename)
	: saveToRaw(false)
	{
		std::ifstream infile(filename);
		std::string indata = std::string(std::istreambuf_iterator<char>(infile), std::istreambuf_iterator<char>());
		Load(indata);
	}
	
	//constructor: Document
	//note: Creates an document form a file given
	//		calling save without argbuments on this will save it to that exact file.
	//param:	file: the file to load from and save to by std::fstream
	Document(std::fstream file)
	: saveToRaw(true)
	{
		std::string indata = std::string(std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>());
		Load(indata);
	}

	//function: Save
	//note: Saves a document to the given file
	//param: 	outfile: the file to save to
	void Save(std::fstream &outfile)
	{
		outfile << Serialize();
	}


	//function: Save
	//note: Saves a document to a file named by "filename"
	//param: 	filename: file to save to
	void Save(std::string filename)
	{
		std::fstream outfile(filename, std::ios::out);
		Save(outfile);
		outfile.close();
	}
	
	//function: Save
	//note: Saves a Document. Uses method intended by constructor
	void Save() 
	{
		if(saveToRaw) {
			Save(rawSavefile);
		} else {
			Save(savefile);
		}
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
	std::fstream rawSavefile;
	bool saveToRaw;
protected:

};

}; //end of namespace HoardXML
