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

private struct TextSplitSettings
{
    TTF_Font* font;
    Text.OverflowBehaviour overflow;
    float height = 0.0;
    float maxwidth = 0.0;
    bool breakWords = true;
    bool parseControl = false;
    float scroll = 0.0; 
}

/// Holds a text, renders it on screen and manages the width-thingy
class Text : Renderable
{

    /** This struct holds the settings for structs.
    Why this is needed you would ask? There are two ways to update text object. After every setting changed, the text needs to be rebuilt.
    That takes time. See the functions why thats not an easy thing. Next would be: why dont flush() the text? 
    Flushing the text after each change forces one to carry the whole flush function, along with the setters to the object hierarchy. Thats not nice.
    I decidet it would be much nicer to just carry the Setting struct - a thing that cant be broken that easyly and the setter then takes care of the updates. 
    */
    public struct TextSettings
    {
        /// The maximal length of the text. if not set (<=0), the whole text will render in one line until its end, no matter how long it is
        float maxwidth = 0.0f;
        /// If the text will break on linefeeds. If set to true, multiline text becomes possible
        bool linebreak = false;
        /// The maximal height of a text - used when linebreak is true. if set (>=0) the textnoxes height wont exeed a specific value
        float maxheight = 0.0f;
        /// Specifes how text-overflows will be handled
        OverflowBehaviour overflow = OverflowBehaviour.showBegin;
        /// How far the text is scrolled - if overflow is scroll. Better use texts scrollUp and scrollDown functions since these dont regenerate the text. 
        float scroll = 0.0;
        /// How big a single scrolling unit is (basically how far one line is in world coordinates. yes. )
        float scrollUnit = 0.0;
        /// Offset-factor between different lines. 
        float lineOffset = 0.5;
        /// The size of the text
        float height = 1.0f;
        /// THe color of the text
        vec4 color = vec4(1.0f,1.0f,1.0f,1.0f);    
        /// Positioning of the text.
        Positioning positioning = Positioning.centered;
        /// font resource name
        string font;
        /// font size name
        Font.FontSize size = Font.FontSize.medium;
        //the raw text
        string text = "";
    }

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
        _settings.font = font;
        Resource.preload!Font(font);
        Resource.preload!GLSLProgram(program);
    }

    this(string text,  string font, float height, Font.FontSize size=Font.FontSize.medium, string shader="shader.default")
    {
        this(font, shader);
        _settings.text = text;
        _settings.size = size;
        _settings.height = height;
        regenerate();
    }

    override void render(in View view) 
    {
        auto prg = Resource.create!GLSLProgram(_program).program;
		prg.bind();
        vao.bind();		
        int texPos = 0;
        prg.setUniformValue("textureSampler", &texPos);
        
        foreach(ref line;_lines) {
            auto m = gen2DModelToWorld(pos+line.pos);
            m.scale(line.size.x,line.size.y,1.0f);
            auto mvp = view.worldToView*m;
            prg.setUniformValueMatrixWorkaround("MVP", mvp);
            line.tex.bind();
            prg.drawArrays(prg.DrawMode.triangles, 0,6);
        }
    }

    @property TextSettings settings()
    {
        return _settings;
    }
    @property TextSettings settings(TextSettings s)
    {
        _settings = s;
        regenerate();
        return _settings;
    }
protected:
    //does what the name says with the text. regenerates the quads for the text rendering. Dont run near companion.
    void regenerate()  
    {
        auto font = Resource.create!Font(_settings.font).getFont(_settings.size);

        char[] textLeft = _settings.text.dup;
        _lines.length = 0;

        if(_settings.maxwidth <= 0.0f) {
            Line line;
            line.text = textLeft.idup;
            _lines ~= line;
        }
        else {
            TextSplitSettings splitSettings = { font, _settings.linebreak ? OverflowBehaviour.showBegin : _settings.overflow, 
                                        _settings.height, _settings.maxwidth, !_settings.linebreak, _settings.linebreak,
                                        _settings.scroll };
            do {
                string res = stripTextOnLength(textLeft,splitSettings);
                Line line;
                line.pos = vec2(0.0,0.0-cast(float)_lines.length*(_settings.height+_settings.lineOffset*_settings.height));
                
                if(res.length==0) {
                    line.text = textLeft.idup;
                    _lines ~= line;
                    break;
                }
                line.text = res;
                _lines ~= line;
            } while(textLeft.length!=0 && _settings.linebreak);
        }

        auto col = sdlColor(_settings.color);
        foreach(ref line; _lines) {
            auto surface = TTF_RenderUTF8_Blended(font,toStringz(line.text),col);
            line.tex = new GPUTexture(surface);
            float w = _settings.height * cast(float)surface.w / cast(float)surface.h;
            line.size = vec2(w,_settings.height);
            final switch(_settings.positioning) {
                case Positioning.centered:
                    break;
                case Positioning.left:
                    //line.pos.x=w/4.0;
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
    /// program resource name
    string _program;
    /// holds the renderable lines
    Line[] _lines;    
    /// The text settings. See The TextSettings struct
    TextSettings _settings;
}

// sets str to the stuff thats left of the input string and returns the string that matches or is smaller then the max length
// It tries NOT to break words
private string stripTextOnLength(ref char[] str, TextSplitSettings settings)
{
    int w,h;
    TTF_SizeUTF8(settings.font,toStringz(str),&w,&h);
    if(settings.height * cast(float)w/cast(float)h <= settings.maxwidth || settings.maxwidth <= 0.0f || str.length < 2) {
        auto tmp = str.idup;
        str.length = 0;
        return tmp;
    }

    size_t p = 1;
    string result = str.idup;

    while(p<=str.length) {
        auto a = str[0..p];
        auto b = str[p..str.length];
        TTF_SizeUTF8(settings.font,toStringz(a),&w,&h);
        float lena = settings.height * cast(float)w/cast(float)h;
        TTF_SizeUTF8(settings.font,toStringz(b),&w,&h);
        float lenb = settings.height * cast(float)w/cast(float)h;

        if(settings.overflow == Text.OverflowBehaviour.showBegin) {
            if(lena>settings.maxwidth) {
                p = p-1;
                size_t breakpos = p;
                //try to find whitespace
                while(breakpos>0&&settings.breakWords == false) {
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
        } else if (settings.overflow == Text.OverflowBehaviour.showEnd) {
            if(lenb<=settings.maxwidth) {
                size_t breakpos = p;
                //try to find whitespace
                while(breakpos<str.length&&settings.breakWords == false) {
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
        else if (settings.overflow == Text.OverflowBehaviour.scroll) {
            throw new Exception("Scrolling not yet implement - hit the programmer with a brick please");
        }
        p++;
    }

    return result;
}
