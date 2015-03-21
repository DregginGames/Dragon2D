#pragma once

#include "BaseClass.h"
#include "Tileset.h"

namespace Dragon2D
{

	class MapLayer;
	class MapStreamBox;

	//Maps are made of tiles. Tiles themself have a size. 
	//However, the size of a map is not given as a relative size - what you set with SetPos() sets the render area of the map!
	//Its given in tiles per row and number of rows (w,h). 
	//maps generally remove aspect ratio - so if there is a tile with relative size 0.1, 0.1 it will be a square. 
	//that can, however, be toggled. 
	//class: Map
	//note: Holds a map resource: tileset+mapdata
	D2DCLASS(Map, public BaseClass)
	{
	public:
		Map();
		Map(std::string name);
		~Map();

		virtual void Load(std::string name);

		virtual void Render() override;
		virtual void Update() override;

		virtual void Move(int x, int y);
		virtual void SetMapPosition(int x, int y);
		virtual void GetMapPosition(int&x, int&y) const;

	private:
		std::list<MapLayer> layers;

		std::list<MapStreamBox> streamBoxes;
		bool forceStreamTeleport;

		bool keepAspectRatio;
		float ratioModifier;
		float tilesize;

		glm::vec4 walkarea;
		int width;
		int height;
		int ox;
		int oy;
	};
	D2DCLASS_SCRIPTINFO_BEGIN(Map, BaseClass)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Map, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(Map, Load)
		D2DCLASS_SCRIPTINFO_MEMBER(Map, Move)
		D2DCLASS_SCRIPTINFO_MEMBER(Map, SetMapPosition)
		D2DCLASS_SCRIPTINFO_MEMBER(Map, GetMapPosition)
	D2DCLASS_SCRIPTINFO_END

	//class: MapLayer
	//note: Container for layer-information
	class MapLayer
	{
	public:
		
		//var: id. Id of the layer
		int									id;
		//var: defaultId. Id of the default layer. if -1 it dosnt have a default tile -> render black
		int									defaultId;
		//var: tiles. Holds the layers tiles.
		std::map<int, std::map<int, int>>	tiles;
		//var: tileset. Holds the tileset of the layer. 
		BatchedTilesetPtr					tileset;
	};

	//class: MapStreamBox
	//note: Contains information for map streaming. 
	class MapStreamBox
	{
	public:
		//var: parent. The map that causes the mapstreaming
		std::string parent;
		//var: streamMap. The map to stream
		std::string streamMap;
		//var: pos. position and size of the streambox
		glm::vec4 pos;
		//var: streamPos: the position to stream the map at. 0=x, 1=y, 2=x-offset of streamMap, 3=x-offset of streamMap
		glm::vec4 streamPos;
		//var: isTeleport. if true, entering the box causes a teleport and not a mapstream
		bool isTeleport;
	};
}; //namespace Dragon2D

