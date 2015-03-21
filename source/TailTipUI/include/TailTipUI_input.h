#pragma once

#include "TailTipUI.h"
#include "TailTipUI_area.h"
#include "TailTipUI_text.h"

namespace TailTipUI
{
	class Input : public Area
	{
	public:
		Input();
		~Input();

		virtual void SetFont(TTF_Font* newfont) override;
		virtual void SetName(std::string newname) override;
		virtual void SetId(std::string id) override;
		virtual void SetForgroundColor(glm::vec4 color) override;

	private:
		Text* InputText;
		int maxChars;
		bool wasDeleting;
	protected:
		virtual void _Render() override;
		virtual void _Focus() override;
		virtual void _LostFocus() override;
	};
};