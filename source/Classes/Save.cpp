#include "Save.h"
#include "BaseClass.h"
#include "Env.h"

namespace Dragon2D
{
	//helper of vector cat
	template<class T>
	void vecCat(std::vector<T> &v1, const std::vector<T> &v2)
	{
		v1.insert(v1.end(), v2.begin(), v2.end());
	}

	template<class T> 
	std::vector<unsigned char> toVec(T data) {
		std::vector<unsigned char> ret(sizeof(T));
		memcpy(ret.data(), &data, sizeof(T));
		return ret;
	}

	template<class T>
	void putData(std::vector<unsigned char> &v, T data) {
		auto v2 = toVec<T>(data);
		vecCat<unsigned char>(v, v2);
	}

	SaveState::SaveState()
		: name(""), children(), datafields()
	{

	}

	SaveState::~SaveState()
	{

	}
	
	SaveState::SaveState(std::string filename)
		: name(""), children(), datafields()
	{
		std::fstream infile;
		Env::Gamefile(filename, std::ios::in | std::ios::binary, infile);
		if (!infile.is_open()) {

		}
		std::vector<unsigned char> inbuffer = std::vector<unsigned char>(std::istreambuf_iterator<char>(infile), std::istreambuf_iterator<char>());
		DeSerialize(inbuffer);
	}

	std::vector<unsigned char> SaveState::Serialize()
	{
		//data-order: 
		//1st unsigned integer: size of this state (including children)
		//2nd unsigned integer: number of fields
		//size of the name-string
		//namestring
		//FIELDS: 
		//  id of field
		//	size of field excluding id
		//	field data
		//CHILDREN: raw dump Serialized children
		std::vector<unsigned char> outdata;
		std::vector<unsigned char> fielddata;
		std::vector<unsigned char> childdata;
		unsigned int size = 0;
		unsigned int fieldCount = 0;
		unsigned int namesize = name.size();
		//count fields
		for (auto i : datafields) {
			fieldCount++;
			putData(fielddata, i.first);
			putData(fielddata, (unsigned int)i.second.size());
			vecCat<unsigned char>(fielddata, i.second); 
		}
		for (auto c : children) {
			vecCat<unsigned char>(childdata, c->Serialize());
		}
		size = fielddata.size() + childdata.size() + sizeof(size) + sizeof(fieldCount) + sizeof(namesize) + namesize;
		putData(outdata, size);
		putData(outdata, fieldCount);
		putData(outdata, namesize);
		outdata.insert(outdata.end(), name.begin(), name.end());
		vecCat(outdata, fielddata);
		vecCat(outdata, childdata);
		Assert(outdata.size() == size);
		return outdata;
	}

	void SaveState::DeSerialize(std::vector<unsigned char> in)
	{
		unsigned int size = *(unsigned int*)&in[0];
		Assert(size == in.size());
		unsigned int fieldCount = *(unsigned int*)&in[sizeof(unsigned int)];
		unsigned int namesize = *(unsigned int*)&in[sizeof(unsigned int)*2];
		std::vector<unsigned char>::iterator pos = in.begin() + sizeof(unsigned int) * 3;
		//read name
		name = std::string(pos, pos + namesize);
		pos += namesize;
		//read in all fields
		for (int i = 0; i < fieldCount; i++) {
			unsigned int fieldId = *(unsigned int*)pos._Ptr;
			pos += sizeof(unsigned int);
			unsigned int fieldSize = *(unsigned int*)pos._Ptr;
			pos += sizeof(unsigned int);
			std::vector<unsigned char> fieldData(pos, pos + fieldSize);
			datafields[fieldId] = fieldData;
			pos += fieldSize;
		}
		//The rest is children
		while (pos < in.end()) {
			unsigned int childSize = *(unsigned int*)pos._Ptr;
			std::vector<unsigned char> childData(pos, pos + childSize);
			SaveStatePtr child(new SaveState);
			child->DeSerialize(childData);
			AddChild(child);
			pos += childSize;
		}
	}

	void SaveState::SetName(std::string n)
	{
		name = n;
	}
	std::string SaveState::GetName() const
	{
		return name;
	}

	void SaveState::SaveToFile(std::string filename)
	{
		std::fstream outfile;
		Env::Gamefile(filename, std::ios::out | std::ios::binary, outfile);
		auto data = Serialize();
		for (auto c : data) {
			outfile << c;
		}
		outfile.close();
	}

	void SaveState::AddChild(SaveStatePtr child)
	{
		children.push_back(child);
	}

	std::vector<SaveStatePtr>& SaveState::GetChildren()
	{
		return children;
	}

	void CreateSaveStateIfEmpty(SaveStatePtr&in, std::string name)
	{
		if (!in) {
			in.reset(new SaveState);
			in->SetName(name);
		}
	}
}; //namepsace Dragon2D
