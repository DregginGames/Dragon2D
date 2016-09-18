module d2d.game.ui.edit;

import std.utf;
import std.string;

import gl3n.linalg;
import derelict.sdl2.sdl;

import d2d.util.serialize;
import d2d.core.render.objects.quad;
import d2d.core.render.objects.text;
import d2d.core.render.renderer;
import d2d.game.ui.box;
import d2d.core.event;
import d2d.core.io;

alias std.algorithm.max max;
alias std.algorithm.min min;

class Edit : Box
{
    this() 
    {
        _textColor = vec4(1.0,1.0,1.0,1.0);
        _cursorQuad = new ColoredQuad();
    }

    /// constructor that allows font and string to be set
    this(string font, string text="")
	{
        _textColor = vec4(1.0,1.0,1.0,1.0);
        _cursorQuad = new ColoredQuad();
        _cursorQuad.color = _textColor;
		_text = new Text(text,font, 1.0f);
        _textStr = text;
        _placeholder = "";
        _font = font;
        _cursor = count!char(_textStr);
        _updateText();
	}

    /// renders the text
	override void render()
	{
        super.render();
		auto renderer = getService!Renderer("d2d.renderer");
        _text.pos = this.viewPos-vec2(0.0,_text.settings.height/2.0); // fix this in text?
		renderer.pushObject(_text);
        if (this.focus()) {
            _cursorQuad.pos = _cursorPos;
            _cursorQuad.scale = vec3(0.005,this.viewSize.y,1.0);
            renderer.pushObject(_cursorQuad);
        }
	}

    /// update etc 
    override void preUpdate() 
    {
        if (!this.focus()) {
            super.preUpdate();
            return;
        }

        auto events = this.peekEvents();
        foreach(e; events) {
            // some things needed everywhere
            uint len = count!char(_textStr);

            // we want text edit events
            auto sdle = cast(SDLEvent)e;
            auto keye = cast(KeyDownEvent)e;
            if (sdle) {
                if (sdle.event.type == SDL_TEXTINPUT) {
                    char[] instr = fromStringz(sdle.event.text.text.ptr);
                    char[] result;
                    if (len==0) {
                        result = instr;
                    }
                    if (_cursor > len) {
                        _cursor = max(0,len-1);
                    }
                    if(_cursor == len) {
                        result = _textStr ~ instr;
                    } else if(_cursor == 0) {
                        result = instr ~ _textStr;
                    } else {
                        uint pos = toUTFindex!char(_textStr,_cursor);
                        result = _textStr[0..pos] ~ instr ~ _textStr[pos..$];                        
                    }
                    _cursor += count!char(instr);
                    _textStr = result.idup;
                    _updateText();
                }
            }
            else if(keye) {
                switch(keye.key) {
                    
                    case SDLK_BACKSPACE: // remove a char. a bit complicated but hey
                        if (_cursor==0 || len==0) {
                            break;
                        }
                        if(_cursor == len) {
                            uint pos = toUTFindex!char(_textStr,_cursor-1);
                            _textStr = _textStr[0..pos];
                        } 
                        else if (_cursor == 1) {
                            _textStr = _textStr[1..$];
                        }
                        else {
                            uint pos1 = toUTFindex!char(_textStr,_cursor-1);
                            uint pos2 = toUTFindex!char(_textStr,_cursor);
                            _textStr = _textStr[0..pos1] ~ _textStr[pos2..$];
                        }
                        _cursor--;
                        _updateText();
                        break;
                    
                    case SDLK_DELETE: // same as above, but char right of the curser is dropped
                        if (len==0 || _cursor==len ) {
                            break;
                        }
                        if(_cursor == len-1) {
                            uint pos = toUTFindex!char(_textStr,_cursor);
                            _textStr = _textStr[0..pos];
                        }
                        else if (_cursor == 0) {
                            _textStr = _textStr[1..$];
                        }
                        else {
                            uint pos1 = toUTFindex!char(_textStr,_cursor);
                            uint pos2 = toUTFindex!char(_textStr,_cursor+1);
                            _textStr = _textStr[0..pos1] ~ _textStr[pos2..$];
                        }
                        _updateText();
                        break;

                    case SDLK_RIGHT:
                        _cursor++;
                        _cursor = max(0,min(len,_cursor));
                        _updateText();
                        break;
                    case SDLK_LEFT:
                        if (_cursor == 0) {
                            break;
                        }
                        _cursor--;
                        _cursor = max(0,min(len,_cursor));
                        _updateText();
                        break;
                    default:
                        break;
                }
            }
        }

        super.preUpdate();
    }
    

    
    /// returns the text object of this placeholder text
    @property Text text()
    {
        return _text;
    }   

    /// sets the paceholder text of this text edit
    @property string placeholder() 
    {
        return _placeholder;
    }
    /// ditto
    @property string placeholder(string s) 
    {
        return _placeholder = s;
    }

protected:
    void _updateText()
    {
        _text.ignoreView = true;
        string t = _textStr;
        string f = _font;
        if (t == "") {
            t = _placeholder;
        }
        if (f != "") {
            if (_text is null) {
                _text = new Text(t,f, 1.0f);
            }
            // fix cursor - just in case
            _cursor = max(0,min(count!char(t),_cursor));

            // math that calculates the stuff noone likes
            auto p = this.viewPos;
            auto s = this.viewSize;
            auto settings = _text.settings;
            settings.text = t;
            settings.font = f;
            settings.linebreak = false;
            settings.maxwidth = s.x;
            settings.height = s.y;
            settings.overflow = Text.OverflowBehaviour.scroll;
            settings.positioning = Text.Positioning.left;
            if (t.length == 0) {
                settings.scroll = 0.0;
            } else {
                settings.scroll = cast(float)(_cursor)/cast(float)(count!char(t));
            }
            _text.settings = settings;
            _cursorPos = _text.getCursorPos(0,_cursor);
        }
    }

    override void _onPosSizeChange()  
    {
        _updateText();
    }

    override void _onFocus() 
    {
        _updateText();
    }
    

private:
    ColoredQuad _cursorQuad;
	Text _text;
    bool _hasText;
    string _font;
    string _textStr;
    string _placeholder;
    vec4 _textColor;
    vec2 _cursorPos;
    uint _cursor;
}