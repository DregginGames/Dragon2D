/**
    Renders text on screen
*/

module d2d.core.render.objects.text;

import std.string;
import std.ascii;

import gl3n.linalg;
import derelict.opengl3.gl3;
import derelict.sdl2.ttf;

import d2d.core.render.objects.view;
import d2d.core.render.util;
import d2d.core.render.objects.renderable;
import d2d.core.resources.glslprogram;
import d2d.core.resource;
import d2d.core.render.lowlevel;

public import d2d.core.resources.font; //is this ugly? yes this is ugly. i feel good. 

private struct Line {
    vec2 pos=vec2(0.0,0.0);
    vec2 size = vec2(1.0,1.0);
    string text;
    GPUTexture tex;
}

// Holds a text, renders it on screen and manages the width-thingy
// Uses RawTexturedQuad, but does so many things that i belive it deserves to be a renderable
class Text : Renderable
{
    enum OverflowBehaviour {
        showBegin,
        showEnd,
        scroll
    }
    
    enum Positioning {
        centered,
        left,
        right
    }

    this(string font, string program="shader.default") 
    {
        _setupVAO(VAOMode.classScope);
        _program = program;
        _font = font;
        Resource.preload!Font(font);
        Resource.preload!GLSLProgram(program);
    }

    this(string text,  string font, float height, Font.FontSize size=Font.FontSize.medium, string shader="shader.default")
    {
        this(font, shader);
        _text = text;
        _size = size;
        _height = height;
        regenerate();
    }

    override void render(ref View view) 
    {
        auto prg = Resource.create!GLSLProgram(_program).program;
		prg.bind();
        vao.bind();		
        int texPos = 0;
        prg.setUniformValue("textureSampler", &texPos);
        
        foreach(ref line;_lines) {
            auto m = gen2DModelToWorld(_pos+line.pos);
            auto sm = m.scale(line.size.x,line.size.y,1.0f);
            auto mvp = view.worldToView*m;
            prg.setUniformValue("MVP", mvp.value_ptr);
            line.tex.bind();
            prg.drawArrays(prg.DrawMode.triangles, 0,6);
        }
    }

    @property vec2 pos()
    {
        return _pos;
    }
    @property vec2 pos(vec2 p) 
    {
        return _pos=p;
    }

    @property float height()
    {
        return _height;
    }
    @property float height(float h)
    {
        _height = h;
        regenerate();
        return _height;
    }

    @property float maxwidth()
    {
        return _maxwidth;
    }
    @property float maxwidth(float m)
    {
        _maxwidth = m;
        regenerate();
        return _maxwidth;
    }

    @property float maxheight()
    {
        return _maxheight;
    }
    @property float maxheight(float h)
    {
        _maxheight = h;
        regenerate();
        return h;
    }

    @property bool linebreak()
    {
        return _linebreak;
    }
    @property bool linebreak(bool b)
    {
        _linebreak = b;
        regenerate();
        return _linebreak;
    }
    /// The lineoffset is the factpr for the additional distance between lines that is added if linebreak is enabled
    /// the actual distance is calculated height*lineOffset
    @property float lineOffset(float f)
    {
        return _lineOffset = f;
    }
    @property float lineOffset()
    {
        return _lineOffset;
    }
protected:
    //does what the name says with the text. regenerates the quads for the text rendering. Dont run near companion.
    void regenerate()  
    {
        auto font = Resource.create!Font(_font).getFont(_size);

        char[] textLeft = _text.dup;
        _lines.length = 0;

        if(_maxwidth <= 0.0f) {
            Line line;
            line.text = textLeft.idup;
            _lines ~= line;
        }
        else {
            do {
                string res = stripTextOnLength(textLeft,font,_linebreak ? OverflowBehaviour.showBegin : _overflow,_height,_maxwidth);
                Line line;
                line.pos = vec2(0.0,0.0-cast(float)_lines.length*(_height+_lineOffset*_height));
                
                if(res.length==0) {
                    line.text = textLeft.idup;
                    _lines ~= line;
                    break;
                }
                line.text = res;
                _lines ~= line;
            } while(textLeft.length!=0 && _linebreak);
        }

        auto col = sdlColor(_color);
        foreach(ref line; _lines) {
            auto surface = TTF_RenderUTF8_Blended(font,toStringz(line.text),col);
            line.tex = new GPUTexture(surface);
            float w = _height * cast(float)surface.w / cast(float)surface.h;
            line.size = vec2(w,_height);
            final switch(_position) {
                case Positioning.centered:
                    break;
                case Positioning.left:
                    line.pos.x=w/2.0;
                    break;
                case Positioning.right:
                    line.pos.x=0.0-w/2.0;
                    break;
            }
        }       
    }

    override void _vboInitClassScope()
    {
        vec4[] vertices;
		vec2[] uvs;
		genUVMappedVertexArray(vertices, uvs);

        Buffer vertex = new Buffer();
        Buffer uv = new Buffer();
        vertex.setData(vertices.ptr, vec4.sizeof*vertices.length);
        uv.setData(uvs.ptr, vec2.sizeof*uvs.length);
        vao.attatchBuffer(0,vertex,4);
        vao.attatchBuffer(1,uv,2);
    }

private:
    /// The maximal length of the text. if not set (<=0), the whole text will render in one line until its end, no matter how long it is
    float _maxwidth = 0.0f;
    /// If the text will break on linefeeds. If set to true, multiline text becomes possible
    bool _linebreak = false;
    /// The maximal height of a text - used when _linebreak is true. if set (>=0) the textnoxes height wont exeed a specific value
    float _maxheight = 0.0f;
    /// Specifes how text-overflows will be handled
    OverflowBehaviour _overflow = OverflowBehaviour.showBegin;
    /// Offset-factor between different lines. 
    float _lineOffset = 0.5;
    /// The size of the text
    float _height = 1.0f;
    /// THe color of the tet
    vec4 _color = vec4(1.0f,1.0f,1.0f,1.0f);
    /// the position of the text
    vec2 _pos;
    /// Positioning of the text.
    Positioning _position = Positioning.centered;
    /// program resource name
    string _program;
    /// font resource name
    string _font;
    /// font size name
    Font.FontSize _size;
    /// holds the renderable lines
    Line[] _lines;
    //the raw text
    string _text;
}

// sets str to the stuff thats left of the input string and returns the string that matches or is smaller then the max length
// It tries NOT to break words
private string stripTextOnLength(ref char[] str, TTF_Font* font, Text.OverflowBehaviour overflow, float height, float maxlen)
{
    int w,h;
    TTF_SizeUTF8(font,toStringz(str),&w,&h);
    if(height * cast(float)w/cast(float)h <= maxlen || maxlen <= 0.0f || str.length < 2) {
        auto tmp = str.idup;
        str.length = 0;
        return tmp;
    }

    size_t p = 1;
    string result = str.idup;

    while(p<=str.length) {
        auto a = str[0..p];
        auto b = str[p..str.length];
        TTF_SizeUTF8(font,toStringz(a),&w,&h);
        float lena = height * cast(float)w/cast(float)h;
        TTF_SizeUTF8(font,toStringz(b),&w,&h);
        float lenb = height * cast(float)w/cast(float)h;

        if(overflow == Text.OverflowBehaviour.showBegin) {
            if(lena>maxlen) {
                p = p-1;
                size_t breakpos = p;
                //try to find whitespace
                while(breakpos>0) {
                    if(isWhite(str[breakpos])) {
                        result = str[0..breakpos].idup;
                        str = str[breakpos..str.length];
                        return result;
                    }
                    breakpos--;
                }
                
                result = str[0..p].idup;
                str = str[p..str.length];
                break;
            }
        } else if (overflow == Text.OverflowBehaviour.showEnd) {
            if(lenb<=maxlen) {
                size_t breakpos = p;
                //try to find whitespace
                while(breakpos<str.length) {
                    if(isWhite(str[breakpos])) {
                        result = str[0..breakpos].idup;
                        str = str[breakpos..str.length];
                        return result;
                    }
                    breakpos++;
                }
                result = a.idup;
                str = b;
                break;
            }
        }
        p++;
    }

    return result;

}