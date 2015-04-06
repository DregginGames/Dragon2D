#include "TailTipUI.h"
#include "TailTipUI_text.h"
#include "TailTipUI_area.h"

namespace TailTipUI {

	class Button : public Text
	{
	public:
		Button();
		Button(std::string text);
		~Button();
	
		void SetTextScale(float s);	
		float GetTextScale();	
	private:
		float 		textScale;
	protected:
		virtual void _Render() override;
		virtual void _InternalHoverEvent();
		virtual void _InternalStopHoverEvent();	
	};

};
