/**
    Holds utility to interact with JSONValues
*/
module d2d.util.jsonutil;

import std.json;

import gl3n.linalg;
import gl3n.util;

// nasty but eh
import d2d.core.base;
import d2d.system.env;

JSONValue vectorToJson(type, int dimension_)(Vector!(type, dimension_) vec)
{
    return JSONValue(vec.vector);
}

T vectorFromJson(T)(JSONValue data)
    if (is_vector!(T))
{
    T vec = 0;
    for (int i = 0; i < vec.dimension; i++) {
        switch(data.array[i].type) {
            case JSON_TYPE.FLOAT:
                vec.vector[i] = cast(vec.vt)data.array[i].floating;
                break;
            case JSON_TYPE.INTEGER:
                vec.vector[i] = cast(vec.vt)data.array[i].integer;
                break;
            case JSON_TYPE.STRING:
                double off = (Base.getService!Env("d2d.env").aspectRatio - 1.0)/2.0;
                switch(data.array[i].str) {
                    case "edgeL":
                        vec.vector[i] = cast(vec.vt)(0.0-off);
                        break;

                    case "edgeR":
                        vec.vector[i] = cast(vec.vt)(1.0+off);
                        break;
                    default:
                        vec.vector[i] = 0;
                }
                break;
            default:
                vec.vector[i] = 0;
                break;
        }
        
    }

    return vec;
}