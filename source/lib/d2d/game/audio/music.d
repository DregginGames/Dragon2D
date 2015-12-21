/**
Holds the classes and functions used to play musics
Not for music, see d2d.game.audio.music 
*/
module d2d.game.audio.music;

import derelict.sdl2.mixer;

import d2d.core.base;
import res = d2d.core.resources.music;
import d2d.core.resource;

/// A music 
class Music : Base 
{
    ///Creates a music from the given resource name
    this(string resourceName) 
    {
        _name = resourceName;
        Resource.preload!(res.Music)(_name);
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
        Will start playing the music from the beginning.
            Params:
                loops = The amount of times the music shall be repeated (so 1 means played twice). -1 will cause the music to loop infinite times
                fadeInTime = The time (in ms) that it should take to fade in the music
                startTime = The time (in ms) from the begginning to start the music from
            */
    void play(int loops=-1, int fadeInTime=0, int startTime=0) 
    {
        auto r = Resource.create!(res.Music)(_name);
        if (Mix_PlayingMusic()==1) {
            stopActive();
            _currActive = null;
        }
        if (Mix_FadeInMusicPos(r.music, loops, fadeInTime, startTime)==-1) {
            import std.string, d2d.util.logger;
            Logger.log("Cannot play music " ~ _name ~ " - " ~ fromStringz(Mix_GetError()));
            _started = _paused = false;
        } else {
            _started = true;
            _paused = false;
            _currActive = this;
        }
        
    }

    /**
        This will pause a paying Music. 
        If the music is already paused or not playing, this will have no effect
    */
    void pause()
    {
        if (playing) {
            Mix_PauseMusic();
        }
    }

    /**
        This will resume a paused Music.
        If the music is not paused or not playing in the first place this will have no effect 
    */
    void resume()
    {
        if (paused && started) {
            Mix_ResumeMusic();
        }
    }

    /**
        Stops a started music. 
        If the music is not started (so can be paused but play should have been called at least once), nothing will happen
        Params:
            fadeOutTime = time (in ms) it takes until music stops (fades out)
    */
    void stop(int fadeOutTime = 0)
    {
        if (started) {
            Mix_FadeOutMusic(fadeOutTime);
            _paused = _started = false;
        }
    }

    /// Stops the currently active music 
    static void stopActive(int fadeOutTime=0)
    {
        if(_currActive !is null) {
            _currActive.stop(fadeOutTime);
        }   
    }

    /// Pauses the currently active music
    static void pauseActive()
    {
        if(_currActive !is null) {
            _currActive.pause();
        }   
    }

    /// Resumes the currently active music
    static void resumeActive()
    {
        if(_currActive !is null) {
            _currActive.resume();
        }   
    }

    /// If the music is paused. Since paused is reserved by base, this name is a bit silly
    @property bool musicPaused()
    {
        return _paused;
    }

    /// If the music is the active one and started, regardless if it later has been paused or not
    @property bool started()
    {
        return _started&&this==_currActive;
    }

    /// If the music ist the active one, has been started and is not paused
    @property bool playing()
    {
        return started && (!_paused);
    }

    /// The volume with wich the music should be played, from 0-128. Values above or below will map to the nearest valid value
    @property int volume()
    {
        return _volume;
    }

    /// Ditto
    @property int volume(int v) 
    {
        _volume = v>=0?v<=128?v:128:0; // clamps v to 0..128
        if (started) {
            Mix_VolumeMusic(_volume);
        }

        return _volume;
    }

private:
    /// The name of the music resource
    string _name;

    /// If this music has been started
    bool _started;
    /// If a music is paused
    bool _paused;

    /// The volume of the music
    int _volume = 128;

    /// The music that is currently playing. Null if none is
    static Music _currActive;
}