#pragma once

#include "TailTipUI.h"


namespace TailTipUI
{
	class Image : public ChildElement
	{
	public:
		Image();
		Image(GLuint id, bool freeOnDelete = false);
		~Image();

		void SetImage(GLuint id, bool free = false);
		GLuint GetImage();

	protected:

		bool freeOnDelete;
		GLuint texId;

		virtual void _Render() override;
	};

}; //namespace TailTipUI
