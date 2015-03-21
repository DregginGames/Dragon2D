#include "Tileset.h"

#include "Env.h"
namespace Dragon2D
{
	Tileset::Tileset()
		: name(""), defaultId(0), tiles()
	{

	}

	Tileset::Tileset(std::string name)
		: name(name), defaultId(0), tiles()
	{
		Load(name);
	}

	void Tileset::Load(std::string loadName)
	{
		name = loadName;
		std::string texture;
		std::string infilename = Env::GetGamepath() + std::string("tilesets/") + name + ".xml";
		Uint32 bt = SDL_GetTicks();
		HoardXML::Document indoc(infilename);
		Uint32 tges = SDL_GetTicks() - bt;
		std::cout << "LoadTime:" << tges;
		//we silently quit if we cant find what we load. used for editing in the editor when creating new tilesets.
		if (indoc["tileset"].size() < 1) {
			return;
		}

		auto contentTags = indoc["tileset"][0]->GetChildren();
		for (auto tag : contentTags) {
			std::string tagname = tag.GetName();
			if (tagname == "texture") {
				texture = tag.GetAttribute("name");
			} 
			else if (tagname == "default") {
				std::string idString = tag.GetAttribute("id");
				defaultId = atoi(idString.c_str());
			}
			else if (tagname == "tiles") {
				auto tileTags = tag.GetChildren();
				for (auto tileTag : tileTags) {
					std::string tileTagName = tileTag.GetName();
					if (tileTagName == "tile") {
						std::string idString = tileTag.GetAttribute("id");
						std::string xString = tileTag.GetAttribute("x");
						std::string yString = tileTag.GetAttribute("y");
						std::string wString = tileTag.GetAttribute("w");
						std::string hString = tileTag.GetAttribute("h");
						unsigned int newId = atoi(idString.c_str());
						tiles[newId] = glm::vec4(atof(xString.c_str()), atof(yString.c_str()), atof(wString.c_str()), atof(hString.c_str()));
					}
					else {
						Env::Out() << "WARNING: unknown tag \"" << tagname << "\" in tileset " << name << std::endl;
					}
				}
			}
			else {
				Env::Out() << "WARNING: unknown tag \"" << tagname << "\" in tileset " << name << std::endl;
			}
		}
		UseTexture(texture);
	}

	//we dont render. normally. 
	void Tileset::Render() 
	{

	}

	std::string Tileset::GetName() const
	{
		return name;
	}

	void Tileset::SetName(std::string n)
	{
		name = n;
	}
	
	void Tileset::Save()
	{
		HoardXML::Document outdoc;
		HoardXML::Tag baseTag, textureTag, defaultTag, tilesTag;
		baseTag.SetName("tileset");
		baseTag.SetAttribute("name", name);
		defaultTag.SetName("default");
		defaultTag.SetAttribute("id", std::to_string(defaultId));
		defaultTag.SetEmptyTag(true);
		textureTag.SetName("texture");
		textureTag.SetAttribute("name", GetTexture());
		textureTag.SetEmptyTag(true);
		tilesTag.SetName("tiles");
		for (auto tPair : tiles) {
			HoardXML::Tag newTileTag;
			newTileTag.SetName("tile");
			newTileTag.SetAttribute("id", std::to_string(tPair.first));
			newTileTag.SetAttribute("x", std::to_string(tPair.second[0]));
			newTileTag.SetAttribute("y", std::to_string(tPair.second[1]));
			newTileTag.SetAttribute("w", std::to_string(tPair.second[2]));
			newTileTag.SetAttribute("h", std::to_string(tPair.second[3]));
			newTileTag.SetEmptyTag(true);
			tilesTag.AddChild(newTileTag);
		}
		baseTag.AddChild(textureTag);
		baseTag.AddChild(defaultTag);
		baseTag.AddChild(tilesTag);
		outdoc.AddChild(baseTag);
		std::string outfilename = Env::GetGamepath() + std::string("tilesets/") + name + ".xml";
		outdoc.Save(outfilename);
	}

	void Tileset::Render(int id, glm::vec4 pos)
	{
		auto tileIterator = tiles.find(id);
		if (tileIterator == tiles.end()) {
			SetOffset(GetTile(defaultId));
		}
		else {
			SetOffset(tileIterator->second);
		}
		SetPosition(pos);
		Sprite::Render();
	}

	glm::vec4 Tileset::GetTile(int id)
	{
		return tiles[id];
	}

	void Tileset::SetTile(int id, glm::vec4 t)
	{
		tiles[id] = t;
	}

	void Tileset::ResetTiles()
	{
		tiles.clear();
	}

	int Tileset::GetTileAtTexturePosition(glm::vec4 p) const
	{
		for (auto tilePair : tiles) {
			glm::vec4 tp = tilePair.second;
			
			if (p.x >= tp.x && p.y >= tp.y && p.x <= tp[2] + tp.x && p.y <= tp[3] + tp.y) {
				return tilePair.first;
			}
		}
		return -1;
	}

	//Batched Tilesets for FASTÖR RENARING

	BatchedTileset::BatchedTileset()
		: Tileset()
	{
		UseProgram("batchedTiles");
		glGenBuffers(1, &vertexBuffer);
		glGenBuffers(1, &uvBuffer);
	}

	BatchedTileset::BatchedTileset(std::string name)
		: Tileset(name)
	{
		UseProgram("batchedTiles");
		glGenBuffers(1, &vertexBuffer);
		glGenBuffers(1, &uvBuffer);
	}

	void BatchedTileset::Render(int id, glm::vec4 pos)
	{
		//We render quads, so we need to 1st scale it, 2nd move it and 3rd push it to the rawVertexBuffer
		//glm::vec2 rpos(pos.x * 2 - 1, (1.0f-pos.y-pos[3]) * 2.0f - 1.0f);
		//glm::vec2 rsize(pos[2] * 2.0f, pos[3] * 2.0f);
		glm::vec2 rpos(pos.x, (1.0f-pos.y-pos[3])); //we need to invert y and stuff
		glm::vec2 rsize(pos[2], pos[3]);
		rawVertexBuffer.push_back(rpos);
		rawVertexBuffer.push_back(rpos + glm::vec2(rsize.x, 0.0f));
		rawVertexBuffer.push_back(rpos + glm::vec2(0.0f, rsize.y));
		rawVertexBuffer.push_back(rpos + glm::vec2(0.0f, rsize.y));
		rawVertexBuffer.push_back(rpos + glm::vec2(rsize.x, 0.0f));
		rawVertexBuffer.push_back(rpos + glm::vec2(rsize.x, rsize.y));
		//and calcualte the uv
		glm::vec4 rawOffset = GetTile(id);
		glm::vec2 uvpos(rawOffset.x, (1.0f - rawOffset.y - rawOffset[3]));
		glm::vec2 uvsize(rawOffset[2], rawOffset[3]);
		rawUVBuffer.push_back(uvpos);
		rawUVBuffer.push_back(uvpos + glm::vec2(uvsize.x, 0.0f));
		rawUVBuffer.push_back(uvpos + glm::vec2(0.0f, uvsize.y));
		rawUVBuffer.push_back(uvpos + glm::vec2(0.0f, uvsize.y));
		rawUVBuffer.push_back(uvpos + glm::vec2(uvsize.x, 0.0f));
		rawUVBuffer.push_back(uvpos + glm::vec2(uvsize.x, uvsize.y));
		//done, the actual rendering happens in the flush!
	}

	void BatchedTileset::FlushBatched()
	{
		//buffer stuff
		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
		glBufferData(GL_ARRAY_BUFFER, rawVertexBuffer.size()*sizeof(GLfloat) * 2, &rawVertexBuffer[0][0], GL_STREAM_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, uvBuffer);
		glBufferData(GL_ARRAY_BUFFER, rawUVBuffer.size()*sizeof(GLfloat) * 2, &rawUVBuffer[0][0], GL_STREAM_DRAW);
		TextureResource &t = Env::GetResourceManager().GetTextureResource(GetTexture());
		GLProgramResource &p = Env::GetResourceManager().GetGLProgramResource(GetProgram());
		//bind 
		p.Use();
		t.Bind();
		glUniform1i(p["textureSampler"], 0);
		//render
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
		glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);
		glEnableVertexAttribArray(1);
		glBindBuffer(GL_ARRAY_BUFFER, uvBuffer);
		glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);
		glDrawArrays(GL_TRIANGLES, 0, rawVertexBuffer.size());
		glDisableVertexAttribArray(1);
		glDisableVertexAttribArray(0);
		//cleanup
		rawVertexBuffer.clear();
		rawUVBuffer.clear();
	}
}; //Dragon2D