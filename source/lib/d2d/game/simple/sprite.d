/**
	d2d.game.simple.sprite holds the sprite class: a simple class to display images on screen
*/
module d2d.game.simple.sprite;

import gl3n.linalg;

import d2d.core.resource;
import d2d.core.render.renderer;
import d2d.core.render.objects.quad;
import d2d.game.entity;
import d2d.game.simple.animation;
import d2d.game.world.tileset;

class Sprite : Entity
{
    this(string texture)
	{
		_quad = new TexturedQuad(texture);
        _quad.detailLevel = 70; // sprites start of high i guess
	}

	override void render()
	{
		auto renderer = getService!Renderer("d2d.renderer");
        _quad.pos = this.absolutePos;
		renderer.pushObject(_quad);
	}

    @property TexturedQuad quad()
    {
        return _quad;
    }

private:
	TexturedQuad _quad;
}

/**
    An animated sprite plays a tileset animation
    It will pause if the object update is paused!
*/
class AnimatedSprite : Sprite
{
    /// Creates a new animated sprite. Set an animation and a tileset
    this(string animation, string tileset)
    {
        _animation = animation;
        _tileset = tileset;
        Resource.preload!Animation(_animation);
        auto s = Resource.create!Tileset(_tileset);
        
        super(s.texture);
        _playing = false;
    }

    /*
        starts playing the animation an animation sequence
        Parameters:
            seq = name of the sequence in the set animation to play
            loop = if the animation can loop or if it should end at the last sprite
            tOffset = offset for animation start
    */
    void play(string seq="", bool loop = true, double tOffset=0.0) 
    {
        _playing = true;
        _startTime = objCurtimeS+tOffset;
        _looping = loop;
        _sequence = seq;
    }

    /// stops playing the animation sequence
    void stop()
    {
        _playing = false;
    }

    /// updates the animation
    override void update()
    {
        if(_playing) {
            auto anim = Resource.create!Animation(_animation);
            auto tset = Resource.create!Tileset(_tileset);
            double t = objCurtimeS-_startTime;
            auto f = anim.getFrameFromTimestamp(_sequence,t,_looping);

            auto tdata = tset.getTileData(f.id);
            quad.setUVOffset(tdata.uvpos,tdata.uvsize);
            quad.scale = vec3(tdata.size.x,tdata.size.y,1.0);
        }
    }

    /// render
    override void render()
    {
        if(_playing) {
            super.render();
        }
    }

    /// Gets if the animation is currently playing
    @property bool isPlaying()
    {
        return _playing;
    }
private:
    /// resource names
    string _animation;
    string _tileset;

    /// properties needed for successfull playing
    bool   _playing;
    double _startTime;
    string _sequence;
    bool   _looping;
}
