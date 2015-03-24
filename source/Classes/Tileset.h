#pragma once

#include "base.h"
#include "BaseClass.h"
#include "Sprite.h"

namespace Dragon2D
{

	//class: Tileset
	//info: holds infos and textures for a specific t
	D2DCLASS(Tileset, public Sprite)
	{
	public:
		Tileset();
		Tileset(std::string name);

		void Load(std::string loadName);

		virtual void SetName(std::string n);
		virtual std::string GetName() const;

		virtual void Render(int id, glm::vec4 pos);
		virtual void Render() override;

		virtual void Save();

		virtual glm::vec4 GetTile(int id);
		virtual void SetTile(int id, glm::vec4 t);
		virtual void ResetTiles();

		virtual int GetTileAtTexturePosition(glm::vec4 p) const;
	private:
		std::string name;

		int defaultId;
		std::map<int,glm::vec4> tiles;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(Tileset, Sprite)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Tileset, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(Tileset, Load)
		D2DCLASS_SCRIPTINFO_MEMBER(Tileset, GetName)
		D2DCLASS_SCRIPTINFO_MEMBER(Tileset, SetName)
		D2DCLASS_SCRIPTINFO_MEMBER(Tileset, Save)
		D2DCLASS_SCRIPTINFO_MEMBER(Tileset, GetTile)
		D2DCLASS_SCRIPTINFO_MEMBER(Tileset, SetTile)
		D2DCLASS_SCRIPTINFO_MEMBER(Tileset, GetTileAtTexturePosition)
		D2DCLASS_SCRIPTINFO_MEMBER(Tileset, ResetTiles)
	D2DCLASS_SCRIPTINFO_END


	D2DCLASS(BatchedTileset, public Tileset)
	{
	public:
		BatchedTileset();
		BatchedTileset(std::string name);

		virtual void Render(int id, glm::vec4 pos) override;
		virtual void FlushBatched();
	private:
		GLuint vertexBuffer;
		GLuint uvBuffer;

		std::vector<glm::vec2> rawVertexBuffer;
		std::vector<glm::vec2> rawUVBuffer;
	protected:

	};

	D2DCLASS_SCRIPTINFO_BEGIN(BatchedTileset, Tileset)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(BatchedTileset, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(BatchedTileset, FlushBatched)
	D2DCLASS_SCRIPTINFO_END
}; //namespace Dragon2D