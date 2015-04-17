#pragma once
#include "base.h"
#include "GameObject.h"

namespace Dragon2D
{

	//class: Sprite
	//info: Holds an image to render on the screen
	D2DCLASS(Sprite, public GameObject)
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
		virtual ~Sprite();
		
		//function:UseProgram
		//note: Sets the program wich is used by this sprite
		//param:	program: name of the program to use
		virtual void UseProgram(std::string program);
		//function:GetProgram
		//note: Returns the currently used program
		virtual std::string GetProgram();
		//function:UseTexture
		//note: Sets the texture wich is used by this sprite
		//param:	texture: name of the texture to use
		virtual void UseTexture(std::string texture);
		//function: GetTexture
		//ntoe: Returns the texture wich is used by this sprite
		virtual std::string GetTexture();

		//function: SetOffset
		//note: Sets the render-offset of the sprite. 
		//param:	offset: [0]=x on texture, [1]=y on texture, [2]=width of the rendering-area, [3] = height of the rendering-area
		virtual void SetOffset(glm::vec4 offset);
		//function: GetOffset
		//note: Returns the render-offset of the sprite
		virtual glm::vec4 GetOffset();

		//function: Render
		//note: Renders the sprite.
		virtual void Render() override;

	private:
		std::string programName;
		std::string textureName;

		glm::vec4 textureOffset;
	};

	D2DCLASS_SCRIPTINFO_BEGIN(Sprite, GameObject)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Sprite, std::string)
		D2DCLASS_SCRIPTINFO_CONSTRUCTOR(Sprite, std::string, std::string)
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, UseProgram);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, UseTexture);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, GetTexture);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, SetOffset);
		D2DCLASS_SCRIPTINFO_MEMBER(Sprite, GetOffset);
	D2DCLASS_SCRIPTINFO_END
}; //namespace Dragon2D