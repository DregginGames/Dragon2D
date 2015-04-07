#pragma once

#include "TailTipUI.h"
#include "TailTipUI_area.h"
#include "TailTipUI_text.h"

namespace TailTipUI
{
	class Input : public Text
	{
	public:
		Input();
		~Input();
		
		virtual void SetPos(glm::vec4 p) override;
		virtual glm::vec4 GetPos();

		virtual bool GetHover();
	private:
		glm::vec4 bgpos;
		int maxChars;
		bool wasDeleting;
		std::string intext;
	protected:
		virtual void _Render() override;
		virtual void _Focus() override;
		virtual void _LostFocus() override;
	};
};
