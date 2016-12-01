module d2d.util.serialize;

public import std.traits; // sadly needed - typeid conversion etc
public import std.conv; // ditto
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

    void fromJson(JSONValue v, ref T[] res) {
        foreach(i; v.array) {
            T x;
            fromJson(i,x);
            res ~= x;
        }
    }

    JSONValue toJson(T v) {
        JSONValue res;
        mixin(to ~ ";");
        return res;
    }

    JSONValue toJson(T[] v) {
        JSONValue res;
        JSONValue[] arr;
        foreach(i; v) {
            arr ~= toJson(i);
        }
        res.array = arr;
        return res;
    }

}

template ConverterPairNoConflict(string t, string from, string to)
{
    const char[] ConverterPairNoConflict = "mixin ConverterPair!("~t~",\""~from~"\",\""~to~"\") "~t~"Pair;"
                ~ "alias fromJson = "~t~"Pair.fromJson;"
                ~ "alias toJson = "~t~"Pair.toJson;";
}

// basic types
mixin(ConverterPairNoConflict!("byte","res = cast(byte)v.integer", "res = v"));
mixin(ConverterPairNoConflict!("ubyte","res = cast(ubyte)v.integer", "res = v"));
mixin(ConverterPairNoConflict!("short","res = cast(short)v.integer", "res = v"));
mixin(ConverterPairNoConflict!("ushort","res = cast(ushort)v.integer", "res = v"));
mixin(ConverterPairNoConflict!("int","res = cast(int)v.integer", "res = v"));
mixin(ConverterPairNoConflict!("uint","res = cast(uint)v.integer", "res = v"));
mixin(ConverterPairNoConflict!("long","res = cast(long)v.integer", "res = v"));
mixin(ConverterPairNoConflict!("ulong","res = cast(ulong)v.integer", "res = v"));

mixin(ConverterPairNoConflict!("float","res = cast(float)(v.type == JSON_TYPE.FLOAT ? v.floating : v.integer)", "res = v"));
mixin(ConverterPairNoConflict!("double","res = cast(double)(v.type == JSON_TYPE.FLOAT ? v.floating : v.integer)", "res = v"));

mixin(ConverterPairNoConflict!("string","res = v.str", "res = v"));

// json
mixin(ConverterPairNoConflict!("JSONValue","res = v", "res = v"));

// vectors i guess
mixin(ConverterPairNoConflict!("vec2","res = vectorFromJson!(vec2)(v)", "res = vectorToJson(v)"));
mixin(ConverterPairNoConflict!("vec3","res = vectorFromJson!(vec3)(v)", "res = vectorToJson(v)"));
mixin(ConverterPairNoConflict!("vec4","res = vectorFromJson!(vec4)(v)", "res = vectorToJson(v)"));
/*
mixin ConverterPair!(int, "res = cast(int)v.integer", "res = v");
mixin ConverterPair!(float, "res = cast(float)v.floating", "res = v");
mixin ConverterPair!(string, "res = v.str", "res = v");
mixin ConverterPair!(vec2, "res = vectorFromJson!(vec2)(v)", "res = vectorToJson(v)");
mixin ConverterPair!(vec3, "res = vectorFromJson!(vec3)(v)", "res = vectorToJson(v)");
mixin ConverterPair!(vec4, "res =  vectorFromJson!(vec4)(v)", "res = vectorToJson(v)");
*/