/**
    d2d.game.io.cursor holds the cursor-functions
*/
module d2d.game.io.cursor;

import gl3n.linalg;

import d2d.core.io;
import d2d.game.entity;
import d2d.game.simple.sprite;

/**
    A Cursor is an Entity wich has a position that is absolute and bound to the position of the users mouse
*/
class Cursor : Entity
{
    this()
    {
        enableEventHandling();
    }

    override void update()
    {
        foreach (e; pollEvents()) {
            if(cast(MouseMotionEvent)e) {
                auto me = cast(MouseMotionEvent) e;
                vec2 transformedPos = vec2(me.npos.x*2.0f-1.0f, (-1.0f)*(me.npos.y*2.0f-1.0f));
                this.pos = transformedPos;
            }
        }
    }
}