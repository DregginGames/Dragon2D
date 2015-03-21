#include "TailTipUI.h"
#include "TailTipUI_text.h"
#include "TailTipUI_area.h"

namespace TailTipUI {

	class Button : public Area
	{
	public:
		Button();
		Button(std::string text);
		~Button();

		virtual void SetFont(TTF_Font* newfont) override;
		virtual void SetName(std::string newname) override;
		virtual void SetId(std::string id) override;
		virtual void SetForgroundColor(glm::vec4 color) override;
		virtual void SetPos(glm::vec4 newpos) override;

		virtual void SetTextWidthlock(bool b);
		virtual bool GetTextWidthlock();
	private:
		Text* buttonText;
		bool widthlockText;

	protected:

		virtual void _InternalHoverEvent();
		virtual void _InternalStopHoverEvent();
		void _UpdateText();
	};

};