#include "Sprite.h"
#include "Env.h"

namespace Dragon2D
{

	Sprite::Sprite()
		: textureName(), programName("defaultSprite"), position(.0f, .0f, 1.f, 1.f), textureOffset(.0f, .0f, 1.f, 1.f)
	{
		Env::GetResourceManager().RequestGLProgramResource(programName);
	}

	Sprite::Sprite(std::string name)
		: textureName(name), programName("defaultSprite"), position(.0f, .0f, 1.f, 1.f), textureOffset(.0f, .0f, 1.f, 1.f)
	{
		Env::GetResourceManager().RequestGLProgramResource(programName);
		Env::GetResourceManager().RequestTextureResource(textureName);
	}

	Sprite::Sprite(std::string name, std::string program)
		: textureName(name), programName(program), position(.0f, .0f, 1.f, 1.f), textureOffset(.0f, .0f, 1.f, 1.f)
	{
		Env::GetResourceManager().RequestGLProgramResource(programName);
		Env::GetResourceManager().RequestTextureResource(textureName);
	}

	Sprite::~Sprite()
	{
		Env::GetResourceManager().FreeGLProgramResource(programName);
		Env::GetResourceManager().FreeTextureResource(textureName);
	}

	void Sprite::UseProgram(std::string program)
	{
		Env::GetResourceManager().FreeGLProgramResource(programName);
		programName = program;
		Env::GetResourceManager().RequestGLProgramResource(programName);
	}

	void Sprite::UseTexture(std::string texture)
	{
		Env::GetResourceManager().FreeTextureResource(textureName);
		textureName = texture;
		Env::GetResourceManager().RequestTextureResource(textureName);
	}

	void Sprite::SetPosition(glm::vec4 pos)
	{
		position = pos;
	}

	glm::vec4 Sprite::GetPosition()
	{
		return position;
	}

	void Sprite::SetOffset(glm::vec4 offset)
	{
		textureOffset = offset;
	}

	glm::vec4 Sprite::GetOffset()
	{
		return textureOffset;
	}
	
	void Sprite::Render()
	{
		TextureResource &t = Env::GetResourceManager().GetTextureResource(textureName);
		GLProgramResource &p = Env::GetResourceManager().GetGLProgramResource(programName);

		p.Use();
		glUniform4f(p["position"], position[0], position[1], position[2], position[3]);
		glUniform4f(p["offset"], textureOffset[0], textureOffset[1], textureOffset[2], textureOffset[3]);
		glActiveTexture(GL_TEXTURE0);
		t.Bind();
		glUniform1i(p["textureSampler"], 0);
		Env::RenderQuad();

		BaseClass::Render();
	}

	std::string Sprite::GetTexture()
	{
		return textureName;
	}

	std::string Sprite::GetProgram()
	{
		return programName;
	}
}; //namespace Dragon2D