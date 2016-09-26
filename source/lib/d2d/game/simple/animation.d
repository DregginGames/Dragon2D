module d2d.game.simple.animation;

/** The animation resource 
*/

import gl3n.linalg;
import std.json;

import d2d.core.resource;
import d2d.core.resources.jsondata;
import d2d.util.serialize;

/** An animation resource. Parses json. 
*/
class Animation : Resource
{
    /// a frame in a sequence
    struct AnimationFrame {
        float length = 0.0;
        int  id = 0;
    }
    /// A sequence of frames
    struct AnimationSequence {
        double length = 0.0;
        string name = "";
        AnimationFrame[] frames;
    }

    this (string name) 
    {
        super(name);
        Resource.preload!JsonData(name);
        load();
    }

    override void reload()
    {
        auto json = Resource.create!JsonData(name);
        json.reload();

        load();
    }

    void load()
    {
        _sequences.clear();

        auto d = Resource.create!JsonData(name).data;
        try {
        if( const(JSONValue)* sequences = "sequences" in d ) {
            foreach(s; sequences.array) {
                AnimationSequence seq;
                fromJson(s["name"],seq.name);
                if( const(JSONValue)* frames = "frames" in s ) {
                    foreach(f; frames.array) {
                        AnimationFrame frame;
                        fromJson(f["length"],frame.length);
                        fromJson(f["id"],frame.id);
                        seq.length+=frame.length;
                        seq.frames ~= frame;
                    }
                }
                _sequences[seq.name] = seq;
            }
        }
        } catch(Exception e) {
            import d2d.util.logger;
            Logger.log("Could not load animation " ~ name ~ " - " ~ e.msg);
        }
    }

    AnimationFrame getFrameFromTimestamp(string sequence, double t, bool allowLoop=true)
    {
        import std.algorithm;
        AnimationFrame res;
        auto seq = sequence in _sequences;
        if(seq) {
            auto tClipped = min(seq.length, t);
            if (allowLoop) {
                tClipped = t % seq.length;
            }
            auto frameStartTime = 0.0;
            foreach(ref frame; seq.frames) {
                res = frame;
                if (frame.length+frameStartTime > tClipped) {
                    break;
                }
                frameStartTime += frame.length;
            }
        }

        return res;
    }
private:
    AnimationSequence[string] _sequences;
}