/**
    Holds the classes and functions used to play sounds
    Not for music, see d2d.game.audio.music 
*/
module d2d.game.audio.sound;

import derelict.sdl2.mixer;

import d2d.core.base;
import d2d.core.resources.sample;
import d2d.core.resource;

/// A sound 
class Sound : Base 
{
    ///Creates a sound from the given resource name
    this(string resourceName) 
    {
        _name = resourceName;
        Resource.preload!Sample(_name);
    }

    /// Cleanup
    ~this()
    {
        if(_started) {
            stop();
        }
        Resource.free(_name);
    }

    /**
        Will start playing the sound from the beginning.
        Params:
            loops = The amount of times the sound shall be repeated (so 1 means played twice). -1 will cause the sound to loop infinite times
            fadeInTime = The time (in ms) that it should take to fade in the sound
            maxLength = The maximal time (in ms) that the sound will be played until its disabled 
    */
    void play(int loops=-1, int fadeInTime=0, int maxLength=-1) 
    {
        if (started && _channel!=-1) {
            Mix_HaltChannel(_channel);
        }
        
        auto sample = Resource.create!Sample(_name);
        _channel = Mix_FadeInChannelTimed(-1,sample.chunk,loops,fadeInTime,maxLength);
        if (_channel == -1) {
            import d2d.util.logger, std.string;
            Logger.log("Cant play Sample " ~ _name ~ " : " ~ fromStringz(Mix_GetError()));
        } else {
            Mix_Volume(_channel, volume);
        }
    }

    /**
        This will pause a paying Sound. 
        If the sound is already paused or not playing, this will have no effect
    */
    void pause()
    {
        if (playing&&_channel!=-1) {
            Mix_Pause(_channel);
        }
    }

    /**
        This will resume a paused Sound.
        If the sound is not paused or not playing in the first place this will have no effect 
    */
    void resume()
    {
        if (paused && started && _channel!=-1) {
            Mix_Resume(_channel);
        }
    }

    /**
        Stops a started sound. 
        If the sound is not started (so can be paused but play should have been called at least once), nothing will happen
    */
    void stop()
    {
        if (started) {
            if (_channel!=-1) {
                Mix_HaltChannel(_channel);
                _channel = -1;
            }
            _paused = _started = false;
        }
    }

    /// If the sound is paused. Since paused is reserved by base, this name is a bit silly
    @property bool samplePaused()
    {
        return _paused;
    }

    /// If the sound is started, regardless if it later has been paused or not
    @property bool started()
    {
        return _started;
    }

    /// If the sound has been started and is not paused
    @property bool playing()
    {
        return _started && (!_paused);
    }

    /// The volume with wich the sound should be played, from 0-128. Values above or below will map to the nearest valid value
    @property int volume()
    {
        return _volume;
    }

    /// Ditto
    @property int volume(int v) 
    {
        _volume = v>=0?v<=128?v:128:0; // clamps v to 0..128
        if (_started && _channel != -1) {
            Mix_Volume(_channel, _volume);
        }

        return _volume;
    }

private:
    /// The name of the sound resource
    string _name;

    /// If this sound has been started
    bool _started;
    /// If a sound is paused
    bool _paused;

    /// The volume of the sound
    int _volume = 128;

    /// The channel that this sound is being played on
    int _channel = -1;
}