#pragma once

#include "base.h"
#include "BaseClass.h"
#include "Sprite.h"

namespace Dragon2D
{

	//class: TileAnimation
	//note: Helper to store tilebased animations
	class TileAnimation
	{
	public:
		std::string name; //name of the animation
		bool loop; //will the animation loop?
		std::vector<std::pair<int, int>> tileList; //Holds tile id and number of ticks that tile stays
	};

	//class: Tileset
	//info: holds infos and textures for a specific t
	D2DCLASS(Tileset, public Sprite)
	{
	public:
		Tileset();
		Tileset(std::string name);
		virtual ~Tileset();

		virtual void Load(std::string loadName);

		virtual void SetName(std::string n);
		virtual std::string GetName() const;

		virtual void Render(int id);
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
	protected:
		//var animations. Used by childClass TilesetAnimaiton to animate things.
		std::map<std::string, TileAnimation> animations; 
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

		virtual void Render(int id) override;
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

	//class: AnimatedTileset
	//note: Holds functionality to animate tilesets
	D2DCLASS(AnimatedTileset, public Tileset)
	{
	public:
		AnimatedTileset();
		AnimatedTileset(std::string name);

		virtual void Render() override;
		virtual void Update() override;

		virtual void Play(std::string animationName);
		virtual void TogglePause();
		virtual void Stop();
	private:
		std::string currentAnimation;
		bool paused;
		int curAnimPos;
		int curTile;
		long int ticksToNextFrame;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(AnimatedTileset, Tileset)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(AnimatedTileset, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(AnimatedTileset, Play)
		D2DCLASS_SCRIPTINFO_MEMBER(AnimatedTileset, TogglePause)
		D2DCLASS_SCRIPTINFO_MEMBER(AnimatedTileset, Stop)
	D2DCLASS_SCRIPTINFO_END
}; //namespace Dragon2D