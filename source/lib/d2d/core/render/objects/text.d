/**
    Renders text on screen
*/

module d2d.core.render.objects.text;

import gl3n.linalg;
import derelict.opengl3.gl3;

import d2d.core.render.view;
import d2d.core.render.util;
import d2d.core.render.renderable;
import d2d.core.resources.texture;
import d2d.core.resources.glprogram;
import d2d.core.resource;
import d2d.core.render.objects.quad;    //for them TexturedQuad

public import d2d.core.resources.font; //is this ugly? yes this is ugly. i feel good. 

// Holds a text, renders it on screen and manages the width-thingy
class Text : Renderable
{
    enum OverflowBehaviour {
        showBegin,
        showEnd,
        scroll
    }
    
    this(string font, string shader="shader.default") 
    {
        _shader = shader;
        _font = font;
    }

    this(string text,  string font, Font.FontSize size=Font.FontSize.medium, string shader="shader.default")
    {
        this(font, shader);
        // do the loading
    }

protected:
    void regenerate()   //does what the name says. regenerates the quads for the text rendering
    {

    }
private:
    // The maximal length of the text. if not set (<=0), the whole text will render in one line until its end, no matter how long it is
    float _maxlength = 0.0f;
    // If the text will break on linefeeds. If set to true, multiline text becomes possible
    bool _linebreak = false;
    // The maximal height of a text - used when _linebreak is true. if set (>=0) the textnoxes height wont exeed a specific value
    float _maxheight = 0.0f;
    // Specifes how text-overflows will be handled
    OverflowBehaviour _overflow = OverflowBehaviour.showBegin;
    
    string _shader;
    string _font;

    TexturedQuad[] _renderObjects;
}