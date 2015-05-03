#pragma once
#include "base.h"

namespace Dragon2D
{
	
	class SaveState;
	//type: SaveStatePtr
	//note: smart pointer for the SaveState type
	typedef std::shared_ptr<SaveState> SaveStatePtr;
	//class SaveState
	//note: Holds save data for specific classes
	class SaveState
	{
	public:
		//constructor: SaveState
		//note: Creates an empty SaveState wich can be filled with data
		SaveState();
		//constructor: SaveState
		//param:	file: file to load the saveState from
		//note: Loads an save state from a file
		SaveState(std::string file);
		//destructor: ~SaveState
		~SaveState();

		//function: SaveToFile
		//note: Saves a SaveState and its children to a file
		//param:	file: the name of the file to write to. will be relative to the gamepath
		void SaveToFile(std::string file);
		//function: Serialize
		//note: Serializees a SaveState and its children into a std::vector<unsigned char>
		std::vector<unsigned char> Serialize();
		//function: DeSerialize
		//note: Creates a SaveState from an std::vector<unsigned char>
		void DeSerialize(std::vector<unsigned char> in);

		//function: AddChild
		//note: Adds a child-savestate
		//param:	child: pointer to a SaveState
		void AddChild(SaveStatePtr child);
		//function: GetChildren
		//note: returns a vecotr of pointers to the children of the SaveState
		std::vector<SaveStatePtr>& GetChildren();

		//function: SetName
		//note: Sets the name of this saveState. Usefull for class-specific save-states
		//param:	name
		void SetName(std::string name);
		//function: GetName
		//note: Returns the name of the SaveState
		std::string GetName() const;

		//function: SetData
		//note: Sets a datafield
		//param:	field: wich field to set the data to
		//			data: data to set. can be any non-pointer number type. Specifications for strings and boolean exsist.
		template<class T>
		void SetData(int field, T data) {
			std::vector<unsigned char> indata(sizeof(T));
			memcpy(indata.data(), &data, sizeof(T));
			datafields[field] = indata;
		}
		//Specification for boolean
		template<>
		void SetData<bool>(int field, bool data) {
			SetData<char>(field, data);
		}
		//specification for strings
		template<>
		void SetData<std::string>(int field, std::string data) {
			std::vector<unsigned char> indata(data.begin(), data.end());
			datafields[field] = indata;
		}

		//function: GetData
		//note: Returns a datafield, data casted to type T
		//		T can be any non-pointer number type. Specifications for strings and boolean exist.
		template<class T>
		T GetData(int field)
		{
			Assert(sizeof(T) == datafields[field].size());
			T outdata = *((T*)datafields[field].data());
			return outdata;
		}
		//specification for boolean
		template<>
		bool GetData<bool>(int field)
		{
			return datafields[field][0] != 0;
		}
		//specification for strings
		template<>
		std::string GetData<std::string>(int field)
		{
			std::string s(datafields[field].begin(), datafields[field].end());
			return s;
		}

	private:
		//var: name. name of the saveState
		std::string name;
		//var: children. holds the children of this SaveState
		std::vector<SaveStatePtr> children;
		//var: datafields. hilds the datafields of this SaveState.
		std::map<int, std::vector<unsigned char>> datafields;
	};

	//function: CreateSaveStateIfEmpty
	//note: Creates a new SaveState-object if the given SaveStatePtr is empty
	//param:	SaveStatePtr: ref to the SaveStatePtr that will be created
	void CreateSaveStateIfEmpty(SaveStatePtr&in, std::string name);
}; //namespace Dragon2D