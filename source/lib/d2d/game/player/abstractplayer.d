module d2d.game.player.abstractplayer;

import std.json;
import std.algorithm;

import gl3n.linalg;

import d2d.core.resource;
import d2d.core.resources.jsondata;
import d2d.game.entity;
import d2d.game.world;
import d2d.game.simple;
import d2d.util.serialize;

abstract class AbstractPlayerStatsClass : Serializeable
{
    double movementSpeed = 1.0;
    double maxMovementSpeed = 1.0;
    
    mixin createSerialize!(false,"movementSpeed","maxMovementSpeed");
}

abstract class AbstractPlayer : Entity
{
    /// movement directions. Also used for animation names
    enum Direction
    {
        up = "up",
        down = "down",
        left = "left",
        right = "right",
        upLeft = "upLeft",
        upRight = "upRight",
        downLeft = "downLeft",
        downRight = "downRight"
    }

    /// gets/sets the look/walking direction
    @property Direction direction() const
    {
        return _direction;
    }
    /// Ditto
    @property Direction direction(Direction d)
    {
        _direction = d;
        onDirectionChange();
        return _direction;
    }

    /// Gets the direction vector
    @property vec2 directionVector()
    {
        final switch(_direction) {
            case Direction.up:
                return vec2(0.0,1.0);
            case Direction.down:
                return vec2(0.0,-1.0);
            case Direction.left:
                return vec2(-1.0,0.0);
            case Direction.right:
                return vec2(1.0,0.0);
            case Direction.upLeft:
                return vec2(-1.0,1.0);
            case Direction.upRight:
                return vec2(1.0,1.0);
            case Direction.downLeft:
                return vec2(-1.0,-1.0);
            case Direction.downRight:
                return vec2(1.0,-1.0);
        }

        assert(0);
    }

    /// Gets/Sets if the player is moving
    @property bool isMoving() const
    {
        return _isMoving;
    }
    /// Ditto
    @property bool isMoving(bool b) 
    {
        _isMoving = b;
        onMovementChange();
        return _isMoving;
    }

    @property string displayName() const
    {
        return _displayName;
    }
    @property string displayName(string s)
    {
        return _displayName=s;
    }
protected:

    void onDirectionChange()
    {
    }

    void onMovementChange()
    {
    }

private:
    /// display namme of the player
    string          _displayName = "";
    /// the movement/look direction. 
    Direction            _direction = Direction.down;
    /// if the player is moving
    bool            _isMoving = false;
}

abstract class AnimatedPlayer(PlayerStatsClass) : AbstractPlayer, Serializeable
{
    this(string name)
    {
        enableEventHandling();

        auto d = Resource.create!JsonData(name).data;
        deserialize(d);
        _stats = new PlayerStatsClass();
        _stats.deserialize(d["stats"]);
        
        _animation = new AnimatedSprite(_animationName,_tileset);
        _animation.positionMode = Entity.PositionMode.relative;
        _animation.pos = _animationOffset;
        onAnimationUpdate();
        this.addChild(_animation);
    }

    override void update()
    {
        if(_isMoving) {
            auto world = getService!World("d2d.world");
            auto newpos = this.pos + min(_stats.movementSpeed,_stats.maxMovementSpeed)*ticktimeS*directionVector;
            if(world.isWalkable(newpos)) {
                this.pos = newpos;
            }
        }
    }

    /// gets the animation sequence name for the current movement state
    string getMovementSequenceName()
    {
        return _isMoving ? _direction : _direction ~ "Idle";
    }

    /// Gets/Sets the stats class
    @property PlayerStatsClass stats()
    {
        return cast(PlayerStatsClass)_stats;
    }
    /// Ditto
    @property PlayerStatsClass stats(PlayerStatsClass s)
    {
        return cast(PlayerStatsClass)(_stats = cast(AbstractPlayerStatsClass)s);
    }

    /// returns the animation 
    @property AnimatedSprite animation()
    {
        return _animation;
    }

    

    mixin createSerialize!(false,"displayName","_tileset","_animationName","_animationOffset");
protected:
    override void onDirectionChange()
    {
        onAnimationUpdate();
    }

    override void onMovementChange()
    {
        onAnimationUpdate();
    }

    void onAnimationUpdate()
    {
        _animation.play(getMovementSequenceName());
    }
private:
    /// name of the tileset 
    string          _tileset;
    /// name of the animation 
    string          _animationName;

    /// the stats class instance 
    AbstractPlayerStatsClass _stats;
    /// the animated sprite
    AnimatedSprite  _animation;
    /// the offset of the animated sprite to the player
    vec2            _animationOffset = 0.0;

}