module d2d.game.player.abstractplayer;

import std.json;
import std.algorithm;
import std.math;

import gl3n.linalg;

import d2d.core.event;
import d2d.core.resource;
import d2d.core.resources.jsondata;
import d2d.game.entity;
import d2d.game.world;
import d2d.game.simple;
import d2d.util.serialize;

struct DialogLine
{
    AbstractPlayer src = null;
    string line = "";
    bool blocking = false;
    bool isAnswerSuggestion = false;
    int answerId = 0;
}

class DialogEvent : Event
{
    this(DialogLine l) {
        _line = l;
    }
    @property DialogLine line() 
    {
        return _line;
    }
private:
    DialogLine _line;
}

class DialogAnswerEvent : Event 
{
    this(DialogLine l) {
        _line = l;
    }
    @property DialogLine line() 
    {
        return _line;
    }
private:
    DialogLine _line;
}

abstract class AbstractPlayerStatsClass : Serializeable
{
    double movementSpeed = 1.0;
    double maxMovementSpeed = 1.0;
    
    mixin createSerialize!(false,"movementSpeed","maxMovementSpeed");
}

abstract class AbstractPlayer : Entity
{
    this()
    {
        auto world = getService!World("d2d.world");
        _footprint = new Footprint;
        _footprint.pos = this.pos;
        _footprint.r = 0;
        _footprint.collideable = false;
        _footprint.walkable = false;
        world.addFootprint(_footprint);
    }

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

    /// sets the proper direction towards a target
    void turnTowards(vec2 target) 
    {
        vec2 rawDir = (target-footprint.pos).normalized;
        if (abs(rawDir.y) < 0.5) {
            this.direction = rawDir.x > 0 ? Direction.right : Direction.left;
        }
        else {
            if(rawDir.y > 0) {
                if (abs(rawDir.x) < 0.5) {
                    this.direction = Direction.up;
                } else {
                    this.direction = rawDir.x > 0 ? Direction.upRight : Direction.upLeft;
                }
            } else {
                if (abs(rawDir.x) < 0.5) {
                    this.direction = Direction.down;
                } else {
                    this.direction = rawDir.x > 0 ? Direction.downRight : Direction.downLeft;
                }
            }
        }

        _actualDirection = rawDir;
    }

    /// Update them player
    override void update()
    {
        super.update();
        if (_isNavActive && !_isNavPaused && _navNodes.length > 0) {
            vec2 currTarget = _navNodes[0];
            if ((footprint.pos-_navNodes[0]).magnitude < _navEpsilon) {
                if (_navNodes.length > 1) {  // more nodes to move towards to
                    _navNodes = _navNodes[1..$];
                    currTarget = _navNodes[0];
                }
                else {
                    disengageNav();
                    return;
                }
            }
            turnTowards(currTarget);
        }
    }

    /// engage navigation nowards a target. 
    /// Note that the navigation operates independed of the movement-state
    /// So you can enable or disable movent (start/stop walking) while nav is enabled.
    /// Navigation can also be paused via the navPaused property
    /// Navigation can be stopped with disengageNav
    void engageNav(vec2 target, double navEpsilon = 0.1, vec2 grid=vec2(0.5,0.5)) 
    {
        // dont throw nano movements into the navigator 
        if ((target-this.pos).magnitude<navEpsilon) {
            return;
        }
        // get route. route.length = 1 means we already are at the target node.
        footprint.ignored = true;
        vec2[] route = Navigator.getRoute(footprint.pos,target,grid);
        footprint.ignored = false;
        if (route.length > 1) {
            _isNavActive = true;
            _navTarget = target;
            _navNodes = route[1..$]; // drop first node because thats were we are!
            _navEpsilon = navEpsilon;
            if (_navControlsMovement) {
                isMoving(true);
            }
        }
    }

    /// Disengages navigation
    void disengageNav()
    {
        _isNavActive = _isNavPaused = false;
        _navNodes.length = 0;
        if (_navControlsMovement) {
            isMoving(false);
        }
    }

    /// Say a dialog line
    void sayDialogLine(DialogLine l)
    {
        fireEvent(new DialogEvent(l));
    }

    /// Say multiple dialog lines
    void sayDialogLine(string[] lines, bool blocking=false, bool isAnswerSuggestion = false)
    {
        foreach(line; lines) {
            sayDialogLine(line,blocking, isAnswerSuggestion);
        }
    }

    /// Say a dialog line
    void sayDialogLine(string line, bool blocking=false, bool isAnswerSuggestion = false)
    {
        DialogLine l;
        l.line = line;
        l.blocking = blocking;
        l.src = this;
        l.isAnswerSuggestion = isAnswerSuggestion;
        sayDialogLine(l);
    }

    /// gets/sets the look/walking direction
    @property Direction direction() const
    {
        return _direction;
    }
    /// Ditto
    @property Direction direction(Direction d)
    {
        if (_direction==d) {
            return _direction;
        }

        _direction = d;
        _actualDirection = directionVector;
        onDirectionChange();
        return _direction;
    }

    /// Gets the actual direction vector
    @property vec2 actualDirectionVector()
    {
        return _actualDirection;
    }

    /// Gets the direction vector for the 8-way movement direction
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
                return vec2(-1.0,1.0).normalized;
            case Direction.upRight:
                return vec2(1.0,1.0).normalized;
            case Direction.downLeft:
                return vec2(-1.0,-1.0).normalized;
            case Direction.downRight:
                return vec2(1.0,-1.0).normalized;
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
        if (_isMoving == b) {
            return _isMoving;
        }
        _isMoving = b;
        onMovementChange();
        return _isMoving;
    }

    /// Gets/Sets the display name of this player
    @property string displayName() const
    {
        return _displayName;
    }
    @property string displayName(string s)
    {
        return _displayName=s;
    }

    /// Gets if navigation is currently active
    @property bool isNavActive() const 
    {
        return _isNavActive;
    }

    /// Gets/Sets if the navigation is currently paused
    @property bool isNavPaused() const 
    {
        return _isNavPaused;
    }
    /// Ditto
    @property bool isNavPaused(bool b) 
    {
        return _isNavPaused = b;
    }

    /// Gets the current nav target. Set while engaging
    @property vec2 navTarget() const 
    {
        return _navTarget;
    }

    /// Gets/Sets if the navigation cancels movement when done 
    @property bool navControlsMovement() const 
    {
        return _navControlsMovement;
    }
    /// Ditto
    @property bool navControlsMovement(bool b) {
        return _navControlsMovement = b;
    }
protected:
    override void onPosSizeChange() 
    {
        footprint.pos = this.pos;
    }


    void onDirectionChange()
    {
    }

    void onMovementChange()
    {
    }

    @property ref Footprint footprint()
    {
        return _footprint;
    }

private:
    /// display namme of the player
    string          _displayName = "";
    /// the movement/look direction. 
    Direction            _direction = Direction.down;
    /// the actual movement direction (movement vector)
    vec2            _actualDirection = vec2(0,0);
    /// if the player is moving
    bool            _isMoving = false;
    // navitation variables below
    /// if the player is in navigation mode 
    bool            _isNavActive = false;
    /// if the navigation is just paused and not canceled
    bool            _isNavPaused = false;
    /// target of a navigation action
    vec2            _navTarget = vec2(0.0,0.0);
    /// nav epsilon - how close to the navigation nodes the player has to be
    double          _navEpsilon = 0.05;
    /// navigation nodes 
    vec2[]          _navNodes;
    /// if being done with a navigation cancels movement
    bool            _navControlsMovement = true;
    /// Footprint of this player
    Footprint       _footprint;
}

abstract class AnimatedPlayer(PlayerStatsClass) : AbstractPlayer, Serializeable
{
    this(string name)
    {
        _name = name;
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

        // bit meh but is a compomise between the radius (to big) and only one side (not big enough)
        footprint.r = (_mapCollisionOffset.x+_mapCollisionOffset.y)/4.1; 
        this.sizeMode = Entity.SizeMode.rect;
    }

    override void onDelete()
    {
        auto world = getService!World("d2d.world");
        world.removeFootprint(_footprint);
        super.onDelete();
    }

    override void update()
    {
        super.update();
        if(_isMoving) {
            auto world = getService!World("d2d.world");
            auto newpos = this.pos + min(_stats.movementSpeed,_stats.maxMovementSpeed)*ticktimeS*actualDirectionVector;
            
            footprint.ignored = true;
            if(world.isWalkable(newpos+_mapCollisionOffset)) {
                auto castpos = newpos + _mapCollisionOffset + vec2(directionVector.x*_mapCollisionSize.x,directionVector.y*_mapCollisionSize.y)*0.5;
                auto castpos1 = castpos + vec2(-directionVector.y*_mapCollisionSize.y,directionVector.x*_mapCollisionSize.x)*0.5;
                auto castpos2 = castpos + vec2(directionVector.y*_mapCollisionSize.y,-directionVector.x*_mapCollisionSize.x)*0.5;
                if(world.isWalkable(castpos)&&world.isWalkable(castpos1)&&world.isWalkable(castpos2)) {
                    this.pos = newpos; 
                }
            }
            footprint.ignored = true;
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

    /// Gets the players name (resource that is loaded)
    @property string name() const
    {
        return _name;
    }

    mixin createSerialize!(false,"displayName","_tileset","_animationName","_animationOffset","_mapCollisionOffset","_mapCollisionSize","size");
protected:

    override void onPosSizeChange() 
    {
        footprint.pos = this.pos+_mapCollisionOffset;
    }

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
    /// name of this player
    string          _name;
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
    /// the offset of the collision rect (for map collisions!)
    vec2            _mapCollisionOffset = 0.0;
    /// the size of the collsision rect
    vec2            _mapCollisionSize = 0.0;
}