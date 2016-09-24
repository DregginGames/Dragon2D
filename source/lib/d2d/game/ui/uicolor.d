module d2d.game.ui.uicolor;

import std.json;
import gl3n.linalg;

import S = d2d.util.serialize;

import d2d.util.settings;

/// A ui color is a struct that represents more than a single color 
/// Since ui elements have many different colors, this is the solution
struct UiColor
{
    vec4 background = vec4(0.0);
    vec4 foreground = vec4(1.0);

    vec4 border = vec4(0.0);
    vec4 highlight = vec4(0.0);
    vec4 user1 = vec4(0.0);
    vec4 user2 = vec4(0.0);
    vec4 user3 = vec4(0.0);
}

void fromJson(JSONValue v,ref UiColor res) 
{
    try {
        S.fromJson(v["background"],res.background);
        S.fromJson(v["foreground"],res.foreground);
        S.fromJson(v["border"],res.border);
        S.fromJson(v["highlight"],res.highlight);
        S.fromJson(v["user1"],res.user1);
        S.fromJson(v["user2"],res.user2);
        S.fromJson(v["user3"],res.user3);
    }
    catch (Exception e) {
        res = UiColor();
    }
}

void fromJson(JSONValue v, void delegate(UiColor) property) 
{
    UiColor res;
    fromJson(v,res);
    property(res);
}

JSONValue toJson(UiColor v) 
{
    JSONValue res;
    res["background"] = S.toJson(v.background);
    res["foreground"] = S.toJson(v.foreground);
    res["border"] = S.toJson(v.border);
    res["highlight"] = S.toJson(v.highlight);
    res["user1"] = S.toJson(v.user1);
    res["user2"] = S.toJson(v.user2);
    res["user3"] = S.toJson(v.user3);

    return res;
}

enum UiColorSchemeSelect
{
    BASE = "base", // base (background) elements like boxes, windows etc
    INTERACTION = "interaction", // interaction elements, like texts or edits or buttons
    HIGHLIGHT = "highlight" // elements to specially highlight
}

UiColor defaultUiColorScheme(UiColorSchemeSelect select)
{
    try {
        auto data = Settings["defaultColors"][select];
        UiColor c;
        fromJson(data,c);
        return c;
    }
    catch (Exception e) {
        return UiColor();
    }
}