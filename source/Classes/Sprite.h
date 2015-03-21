#pragma once
#include "base.h"
#include "BaseClass.h"
namespace Dragon2D
{

	//class: Sprite
	//info: Holds an image to render on the screen
	D2DCLASS(Sprite, public BaseClass)
	{
	public:
		//constructor: Sprite
		//note: Creates an empty sprite
		Sprite();
		//constructor: Sprite
		//note: Creates a sprite with a default shader and the given texture
		Sprite(std::string texture);
		//constructor: Sprite
		//note: Creates a sprite with a texture and a program
		Sprite(std::string texture, std::string program);
		//destructor: ~Sprite
		~Sprite();
		
		//function:UseProgram
		//note: Sets the program wich is used by this sprite
		//param:	program: name of the program to use
		void UseProgram(std::string program);
		//function:GetProgram
		//note: Returns the currently used program
		std::string GetProgram();
		//function:UseTexture
		//note: Sets the texture wich is used by this sprite
		//param:	texture: name of the texture to use
		void UseTexture(std::string texture);
		//function: GetTexture
		//ntoe: Returns the texture wich is used by this sprite
		std::string GetTexture();

		//function: SetPosition
		//note: Sets the position of the sprite on the screen
		//		values are normalized 0-1. For keeping the aspect-ratio use SetAppliesAspectRatio(true)
		//param:	pos: position with [0]=x, [1]=y, [2] = width, [3]=height
		void SetPosition(glm::vec4 pos);
		//function: GetPosition
		//note: Returns the position of the sprite on the screen
		glm::vec4 GetPosition();

		//function: SetOffset
		//note: Sets the render-offset of the sprite. 
		//param:	offset: [0]=x on texture, [1]=y on texture, [2]=width of the rendering-area, [3] = height of the rendering-area
		void SetOffset(glm::vec4 offset);
		//function: GetOffset
		//note: Returns the render-offset of the sprite
		glm::vec4 GetOffset();

		//function: Render
		//note: Renders the sprite.
		virtual void Render() override;

	private:
		std::string programName;
		std::string textureName;

		glm::vec4 position;
		glm::vec4 textureOffset;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(Sprite, BaseClass)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Sprite, std::string)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Sprite, std::string, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, UseProgram);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, UseTexture);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, GetTexture);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, SetPosition);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, GetPosition);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, SetOffset);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, GetOffset);
	D2DCLASS_SCRIPTINFO_END
}; //namespace Dragon2D