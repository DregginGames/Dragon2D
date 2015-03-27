#include "Map.h"
#include "Env.h"
namespace Dragon2D
{

	void testevent(bool b) {
		std::cout << "blah:" << b << std::endl;
	}

	Map::Map()
		: forceStreamTeleport(false),keepTileRatio(true), tilesize(0.0f),
		walkarea(0), width(0),height(0),ox(0), oy(0)
	{
		 
	}

	Map::Map(std::string name)
		: forceStreamTeleport(false),keepTileRatio(true), tilesize(0.0f),
		walkarea(0), width(0),height(0),ox(0), oy(0)	
	{
		Load(name);
	}

	Map::~Map()
	{
	}

	void Map::Load(std::string name)
	{
		std::string filename = Env::GetGamepath() + std::string("map/") + name + ".xml";
		HoardXML::Document xmlDoc(filename);


		if (xmlDoc["map"].size() != 1) {
			Env::Err() << "ERROR: Errors in mapfile " << filename << std::endl;
			return;
		}
		auto mapElements = xmlDoc["map"][0]->GetChildren();
		for (auto c : mapElements) {
			//Info
			if (c.GetName() == "info") {
				auto infotags = c.GetChildren();
				for (auto infotag : infotags) {
					if (infotag.GetName() == "mapsize") {
						width = atoi(infotag.GetAttribute("width").c_str());
						height = atoi(infotag.GetAttribute("height").c_str());
					}
					else if (infotag.GetName() == "walkable") {
						walkarea.x = (float)atof(infotag.GetAttribute("x").c_str());
						walkarea.y = (float)atof(infotag.GetAttribute("y").c_str());
						walkarea[2] = (float)atof(infotag.GetAttribute("w").c_str());
						walkarea[3] = (float)atof(infotag.GetAttribute("h").c_str());
					}
					else if (infotag.GetName() == "tilesize") {
						keepTileRatio = infotag.GetAttribute("keepRatio") == "true" ? true : false;
					}
					else if (infotag.GetName() == "stream") {
						forceStreamTeleport = infotag.GetAttribute("teleport") == "true" ? true : false;
					}
					else {
						Env::Out() << "WARNING: unknown map info tag in map file: " << infotag.GetName() << "! " << filename << std::endl;
					}
				}
			}
			//Tile- and streamdata
			else if (c.GetName() == "mapdata")
			{
				auto tagLayers = c.GetChildren();
				for (auto l : tagLayers) {
					std::string layertype = l.GetName();
					//its a layer. 
					if (layertype == "layer") {
						//layer info
						MapLayer newLayer;
						newLayer.id = atoi(l.GetAttribute("id").c_str());
						newLayer.tileset = NewD2DObject<BatchedTileset>();
						newLayer.tileset->Load(l.GetAttribute("tileset"));
						if (l.GetAttribute("nodefault") == "true") {
							newLayer.defaultId = -1;
						}
						else {
							newLayer.defaultId = atoi(l.GetAttribute("default").c_str());
						}
						//Load tiles
						auto tiles = l.GetChildren();
						for (auto t : tiles) {
							if (t.GetName() == "tile") {
								int x = atoi(t.GetAttribute("x").c_str());
								int y = atoi(t.GetAttribute("y").c_str());
								int id = atoi(t.GetAttribute("id").c_str());
								newLayer.tiles[x][y] = id;
							}
							//thats not a tile
							else {
								Env::Out() << "WARNING: unknown tile tag in map file: " << t.GetName() << "! " << filename << std::endl;
							}
						}

						//insert into list
						auto layerIterator = layers.begin();
						while (layerIterator != layers.end()) {
							if (layerIterator->id >= newLayer.id) {
								layers.insert(layerIterator, newLayer);
								break;
							}
							layerIterator++;
						}
						if (layerIterator == layers.end()) {
							layers.push_back(newLayer);
						}
					}
					//Its a streaming layer!
					else if (layertype == "streaminglayer") {
						auto streamTags = l.GetChildren();
						for (auto streamTag : streamTags) {
							if (streamTag.GetName() == "streambox") {
								MapStreamBox box;
								auto streamBoxAttributes = streamTag.GetAttributes();
								box.parent = name;
								box.streamMap = streamBoxAttributes["map"];
								box.pos.x = (float)atof(streamBoxAttributes["x"].c_str());
								box.pos.y = (float)atof(streamBoxAttributes["y"].c_str());
								box.pos[2] = (float)atof(streamBoxAttributes["w"].c_str());
								box.pos[3] = (float)atof(streamBoxAttributes["h"].c_str());
								box.streamPos.x = (float)atof(streamBoxAttributes["sx"].c_str());
								box.streamPos.y = (float)atof(streamBoxAttributes["sy"].c_str());
								box.streamPos[2] = (float)atof(streamBoxAttributes["sox"].c_str());
								box.streamPos[3] = (float)atof(streamBoxAttributes["soy"].c_str());
								if (streamBoxAttributes["teleport"] == "true") {
									box.isTeleport = true;
								}
								else
								{
									box.isTeleport = false;
								}
								streamBoxes.push_back(box);
							}
							else {
								Env::Out() << "WARNING: unknown Map-streaming tag in map file: " << streamTag.GetName() << "! " << filename << std::endl;
							}
						}
					}
					//thats not a layer
					else {
						Env::Out() << "WARNING: unknown layer tag in map file: " << l.GetName() << "! " << filename << std::endl;
					}
				}
			}
			//i dont know that part of the map
			else {
				Env::Out() << "WARNING: unknown tag in map file: " << c.GetName() << "! " << filename << std::endl;
			}
		}
		
		//recalculate some of the values cause the screen shurl wont be a square 
		glm::vec2 res = Env::GetResolution();
		float ar = res.x/res.y;
		tilesize[2] = 1.0f / (float)width;
		tilesize[3] = 1.0f / (float)height;
		if(ar>1.0f && keepTileRatio) {
			tilesize[2] = tilesize[3]/ar;
			width = floor(0.5f+1.0f/tilesize[2]);
			tilesize.x = 0.0f-(1.0f-width*tilesize[2])*0.5f;
		} else if(ar<1.0f && keepTileRatio) {
			tilesize[3] = tilesize[2]*ar;
			height = floor(0.5f+1.0f/tilesize[3]);
			tilesize.y = 0.0f-(1.0f-height*tilesize[3])*0.5f;
		}	
	}

	void Map::Render()
	{

		for (auto layer : layers) {
			//for each tile
			for (int y = ox; y < height+ox; y++) {
				for (int x = oy; x < width+oy; x++) {
					//check if the tile exists
					auto xiter = layer.tiles.find(x);
					int tile = layer.defaultId;
					if (xiter != layer.tiles.end()) {
						auto yiter = xiter->second.find(y);
						if (yiter != xiter->second.end()) {
							tile = yiter->second;
						}
					}
							
					if (tile != -1) {
						glm::vec4 tilepos(tilesize.x + x*tilesize[2], tilesize.y+ y*tilesize[3], tilesize[2], tilesize[3]);
						layer.tileset->Render(tile, tilepos);
					}
				}
			}
			layer.tileset->FlushBatched();
		}
	}
	
	void Map::Update()
	{

	}

	void Map::SetMapPosition(int x, int y)
	{
		ox = x;
		oy = y;
	}

	void Map::GetMapPosition(int&x, int&y) const
	{
		x = ox;
		y = oy;
	}

	void Map::Move(int x, int y)
	{
		ox += x;
		oy += y;
	}

	void Map::RegisterInputHooks()
	{
		std::function<void(bool)> f = testevent;
		Env::GetInput().AddHook("testclick", Ptr(), f);
	}

	void Map::RemoveInputHooks()
	{
		Env::GetInput().RemoveHooks(Ptr());
	}
};
