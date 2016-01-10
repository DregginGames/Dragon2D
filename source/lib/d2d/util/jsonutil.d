/**
    Holds utility to interact with JSONValues
*/
module d2d.util.jsonutil;

import std.json;

import gl3n.linalg;
import gl3n.util;

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
            default:
                vec.vector[i] = 0;
                break;
        }
        
    }

    return vec;
}