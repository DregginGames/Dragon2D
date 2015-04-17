#include "Map.h"
#include "Env.h"
namespace Dragon2D
{

	Map::Map()
		: name(""), forceStreamTeleport(false), keepTileRatio(true), tilesize(0.0f),
		walkarea(0), width(0), height(0), ox(0), oy(0), dox(0), doy(0), ticksLeftMapMovement(0), movementLength(0), mapMovementOffset(0)
	{
		 
	}

	Map::Map(std::string name)
		: name(name),forceStreamTeleport(false),keepTileRatio(true), tilesize(0.0f),
		walkarea(0), width(0), height(0), ox(0), oy(0), dox(0), doy(0), ticksLeftMapMovement(0), movementLength(0), mapMovementOffset(0.0f)
	{
		Load(name);
	}

	Map::~Map()
	{
		std::string filename = std::string("map/") + name + ".xml";
		Env::GetResourceManager().FreeXMLResource(filename);
	}

	void Map::Load(std::string name)
	{
		std::string filename = std::string("map/") + name + ".xml";
		Env::GetResourceManager().RequestXMLResource(filename);
		HoardXML::Document& xmlDoc = Env::GetResourceManager().GetXMLResource(filename).GetDocument();
		this->name = name;

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
						walkarea.x = atoi(infotag.GetAttribute("x").c_str());
						walkarea.y = atoi(infotag.GetAttribute("y").c_str());
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
								box.isTeleport = streamBoxAttributes["teleport"] == "true";
								streamBoxes.push_back(box);
							}
							else {
								Env::Out() << "WARNING: unknown Map-streaming tag in map file: " << streamTag.GetName() << "! " << filename << std::endl;
							}
						}
					}
					//clipping clayer (non-walkable areas)
					else if (layertype == "clippinglayer") {
						auto clipTags = l.GetChildren();
						for (auto clipTag : clipTags) {
							if (clipTag.GetName() == "clipbox") {
								MapClipBox box;
								box.pos.x = (float)atof(clipTag.GetAttribute("x").c_str());
								box.pos.y = (float)atof(clipTag.GetAttribute("y").c_str());
								box.pos[2] = (float)atof(clipTag.GetAttribute("w").c_str());
								box.pos[3] = (float)atof(clipTag.GetAttribute("h").c_str());
								clipBoxes.push_back(box);
							}
							else {
								Env::Out() << "WARNING: unknown Map-clipping tag in map file: " << clipTag.GetName() << "! " << filename << std::endl;
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
			width = (int)floor(0.5f+1.0f/tilesize[2]);
			tilesize.x = 0.0f-(1.0f-width*tilesize[2])*0.5f;
		} else if(ar<1.0f && keepTileRatio) {
			tilesize[3] = tilesize[2]*ar;
			height = (int)floor(0.5f+1.0f/tilesize[3]);
			tilesize.y = 0.0f-(1.0f-height*tilesize[3])*0.5f;
		}	
		//clamp tilesize to pixels
		res.x = 1.0f / res.x;
		res.y = 1.0f / res.y;
		tilesize.x = ceilf(tilesize.x / res.x)*res.x;
		tilesize[2] = ceilf(tilesize[2] / res.x)*res.x;
		tilesize[3] = ceilf(tilesize[3] / res.y)*res.y;
		tilesize.y = ceilf(tilesize.y / res.y)*res.y;
	}

	void Map::Render()
	{

		for (auto layer : layers) {
			//for each tile
			for (int y = oy - std::abs(doy); y < height + oy + std::abs(doy); y++) {
				for (int x = ox - std::abs(dox); x < width + ox + std::abs(dox); x++) {
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
						layer.tileset->SetPosition(Tilepos(x, y));
						layer.tileset->Render(tile);
					}
				}
			}
			layer.tileset->FlushBatched();
		}

		BaseClass::Render();
	}
	
	void Map::Update()
	{
		GameObjectPtr focusedObject = GameObject::GetFocusedObject();
		if (focusedObject) {	//TODO: Dynamic timing or something. 20ticks are somehow random...
			int mx, my;
			int dx=0, dy=0;
			focusedObject->GetMapPosition(mx, my);
			if (mx - dox < ox+walkarea.x) {
				Move(mx - dox - (ox+walkarea.x), 0, 20);
			}
			else if (mx - dox + walkarea.x > width+ox) {
				Move(mx - dox + walkarea.x - (width + ox), 0, 20);
			}
			if (my - doy < oy + walkarea.y) {
				Move(0, my - doy - (oy + walkarea.y), 20);
			}
			else if (my - doy + walkarea.y > width + oy) {
				Move(0, my - doy + walkarea.y - (width + oy), 20);
			}
		}
		if (ticksLeftMapMovement > 0) {
			float dx = (float)dox*(float)(movementLength-ticksLeftMapMovement) / (float)movementLength;
			float dy = (float)doy*(float)(movementLength - ticksLeftMapMovement) / (float)movementLength;
			mapMovementOffset = glm::vec4(tilesize[2] *dx, tilesize[3] * dy, 0.0f, 0.0f);
			glm::vec2 res = Env::GetResolution();
			res.x = 1.0f / res.x;
			res.y = 1.0f / res.y;
			mapMovementOffset.x = floorf(mapMovementOffset.x / res.x)*res.x;
			mapMovementOffset.y = floorf(mapMovementOffset.y / res.y)*res.y;
			//clamp offset to pixels
			ticksLeftMapMovement--;
		}
		else if (ticksLeftMapMovement==0) {
			ticksLeftMapMovement--;
			mapMovementOffset = glm::vec4(0.0f);
			ox += dox;
			oy += doy;
			dox = 0;
			doy = 0;
			movementLength = 0;
		}

		for (auto c : children) {
			GameObjectPtr cPtr = std::dynamic_pointer_cast<GameObject>(c);
			if (cPtr) {
				cPtr->UpdatePositionFromMap();
			}
		}
		BaseClass::Update();
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

	void Map::GetMapDimensions(int&w, int&h, float&tw, float&th) const
	{
		w = width;
		h = height;
		tw = tilesize[2];
		th = tilesize[3];
	}

	glm::vec4 Map::Tilepos(int x, int y) const 
	{
		glm::vec4 tilepos = glm::vec4(tilesize.x + (x - ox)*tilesize[2], tilesize.y + (y - oy)*tilesize[3], tilesize[2], tilesize[3]) - mapMovementOffset;
		return tilepos;
	}

	void Map::Move(int x, int y, int ticks)
	{
		dox += x;
		doy += y;
		ticksLeftMapMovement = 0+ticks;
		movementLength += ticks;
		mapMovementOffset = glm::vec4(0.0f);
	}

	std::vector<GameObjectPtr> Map::GetObjectsAtPosition(int x, int y) const
	{
		glm::vec4 p = Tilepos(x, y);
		std::vector<GameObjectPtr> result;
		for (auto c : children) {
			if (c) {
				GameObjectPtr cPtr = std::dynamic_pointer_cast<GameObject>(c);
				glm::vec4 cPos = cPtr->GetPosition();
				if (cPos.x >= p.x && cPos.y >= p.y && cPos.x <= p[2] && cPos.y <= p[3]) {
					result.push_back(cPtr);
				}
			}
		}
		return result;
	}

	bool Map::IsPositionWalkable(int x, int y) const
	{
		//search the clipboxes
		for (auto box : clipBoxes) {
			if (x >= box.pos.x && y >= box.pos.y && x <= box.pos.x + box.pos[2] && y <= box.pos.y + box.pos[4]) {
				return false;
			}
		}
		return true;
	}

};
