module d2d.util.serialize;

import std.traits;
import gl3n.linalg;
import std.json;
import d2d.util.jsonutil;

interface Serializeable {
    JSONValue serialize();
    void deserialize(JSONValue v);
}

template createSerialize(bool hasParent, T...)
{
    override JSONValue serialize()
    {
        static if (hasParent) {
            JSONValue res = super.serialize();
        } else {
            JSONValue res = [ "typename" : to!string(typeid(this))];
        }
        foreach(t; T) {
            mixin("pragma(msg, \"Building serialize for " ~ t ~ " - \", typeof(" ~ t ~ "));");
            mixin("res.object[\"" ~ t ~ "\"] = toJson(" ~ t ~ ");");
        }

        return res;
    }

    override void deserialize(JSONValue v)
    {
        static if (hasParent) {
            super.deserialize(v);
        }
        foreach(t; T) {
            mixin("pragma(msg, \"Building deserialize for " ~ t ~ " - \", typeof(" ~ t ~ "));");
            try {
                // needed because properties are f****
                mixin(" auto x = " ~ t ~ ";\n
                        fromJson(v.object[\"" ~ t ~ "\"], x );\n
                        " ~ t ~ " = x;
                ");
            } catch(Exception e) {
                // if it fails we should give everything so it doesnt die.
                mixin("
                    static if(__traits(compiles," ~ t ~ " = 0)) {
                        " ~ t ~ " = 0;
                    }
                    else static if(__traits(compiles," ~ t ~ " = 0.0)) {
                        " ~ t ~ " = 0.0;
                    }
                    else static if(__traits(compiles," ~ t ~ " = \"\")) {
                        " ~ t ~ " = \"\";
                    }
                    else {
                        throw e;
                    }
                ");
            }   
        }
    }
}

template ConverterPair(T, const string from, const string to)
{
    pragma(msg,"Building Serialize/Convert pair for ", T);

    void fromJson(JSONValue v, ref T res) {
        mixin(from ~ ";");
    }

    void fromJson(JSONValue v, void delegate(T) property) {
        T res;
        mixin(from ~ ";");
        property(res);
    }
    JSONValue toJson(T v) {
        JSONValue res;
        mixin(to ~ ";");
        return res;
    }
}

mixin ConverterPair!(int, "res = cast(int)v.integer", "res = v");
mixin ConverterPair!(float, "res = cast(float)v.floating", "res = v");
mixin ConverterPair!(string, "res = v.str", "res = v");
mixin ConverterPair!(vec2, "res = vectorFromJson!(vec2)(v)", "res = vectorToJson(v)");
mixin ConverterPair!(vec3, "res = vectorFromJson!(vec3)(v)", "res = vectorToJson(v)");
mixin ConverterPair!(vec4, "res =  vectorFromJson!(vec4)(v)", "res = vectorToJson(v)");