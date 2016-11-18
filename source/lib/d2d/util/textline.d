/// Holds functions/class for textlines
module d2d.util.textline;

import std.regex;

import d2d.core.base;
import d2d.core.resources;
import d2d.core.resource;

class Textlines : Base
{
    @disable this();
    
    static string[] get(string resource, string name) nothrow
    {
        string[] res;
        try {
            auto json = Resource.create!(JsonData)(resource);
            foreach(line; json.data[name].array) {
                res ~= processLine(line.str);
            }
        } catch(Throwable) {
            res ~= (resource ~ " : " ~ name);
        }

        return res;
    }
    
    /// The text vars that will be search/replaced in the target lines
    static @property ref string[string] vars() nothrow
    {
        return _textVars;
    }

protected:
    static string processLine(string line)
    {
        auto templateRegex = regex(r"\$([\w]+)");
        string lookupReplace(Captures!(string) m)
        {
            string *s = m[1] in _textVars;
            if (s) {
                return *s;
            }
            return m[0];
        }
        
        return replaceAll!(lookupReplace)(line,templateRegex);
    }

private:
    static string[string] _textVars;
}
