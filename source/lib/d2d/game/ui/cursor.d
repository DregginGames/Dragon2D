/**
    d2d.game.io.cursor holds the cursor-functions
*/
module d2d.game.ui.cursor;

import gl3n.linalg;

import d2d.core.io;
import d2d.game.entity;
import d2d.game.simple.sprite;
import d2d.game.simple.camera;

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
        import std.stdio;
        foreach (e; pollEvents()) {
            
            if(cast(MouseMotionEvent)e) {
                auto me = cast(MouseMotionEvent) e;
                vec2 transformedPos = vec2(me.npos.x*2.0f-1.0f, (-1.0f)*(me.npos.y*2.0f-1.0f));
                this.pos = transformedPos;
            }
        }
    }
}

/**
    A Reconstructed Cursor is an Entity wich as a position that is relative to a parent camera. Sounds stragge?
    Its absolute position however is calculated by applying the actual position to the cameras size, letting this cursor represent the mouse in the 2dish 3d space.

    Basically a reverse transformation of the MVP-matrix. Yes im talking shit again
*/
class WorldCursor : Cursor
{
    /// Constructor
    this() 
    {
        this.positionMode = PositionMode.relative;
    }
    
    /// Returns the position of the cursor in world-coordinates
    override @property vec2 absolutePos()
    {
        if (!(this.parent is null) && (cast(Camera)this.parent)) {
            auto p = cast(Camera)this.parent;
            auto converted = p.view.worldToView.inverse*vec4(this.pos.x, this.pos.y, 0,1);
            return vec2(converted.x, converted.y);
        }

        return super.absolutePos;
    }
}