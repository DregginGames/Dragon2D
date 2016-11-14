module d2d.game.player.abstractplayer;

import std.json;
import std.algorithm;
import std.math;

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

    /// sets the proper direction towards a target
    void turnTowards(vec2 target) 
    {
        vec2 rawDir = (target-pos).normalized;
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
    }

    /// Update them player
    override void update()
    {
        super.update();
        if (_isNavActive && !_isNavPaused && _navNodes.length > 0) {
            vec2 currTarget = _navTarget;
            if (_navNodes.length > 1) {  // more nodes to move towards to
                if ((this.pos-_navNodes[0]).magnitude < _navEpsilon) {
                    _navNodes = _navNodes[1..$];
                }
                currTarget = _navNodes[0];
            } else { // already at target last node: target. So use the fixed target just in case.
                if ((this.pos-_navTarget).magnitude < _navEpsilon) { // You have reached you final destination
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
    void engageNav(vec2 target, double navEpsilon = 0.5, vec2 grid=vec2(0.5,0.5)) 
    {
        vec2[] route = Navigator.getRoute(this,target,grid);
        if (route.length > 0) {
            _isNavActive = true;
            _navTarget = target;
            _navNodes = route;
            _navEpsilon = navEpsilon;
        }
    }

    /// Disengages navigation
    void disengageNav()
    {
        _isNavActive = _isNavPaused = false;
        _navNodes.length = 0;
        if (_navCancelMovement) {
            isMoving(false);
        }
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
    @property bool navCancelMovement() const 
    {
        return _navCancelMovement;
    }
    /// Ditto
    @property bool navCancelMovement(bool b) {
        return _navCancelMovement = b;
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
    bool            _navCancelMovement = true;
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
        super.update();
        if(_isMoving) {
            auto world = getService!World("d2d.world");
            auto newpos = this.pos + min(_stats.movementSpeed,_stats.maxMovementSpeed)*ticktimeS*directionVector;

            if(world.isWalkable(newpos+_mapCollisionOffset)) {
                auto castpos = newpos + _mapCollisionOffset+vec2(directionVector.x*_mapCollisionSize.x,directionVector.y*_mapCollisionSize.y)*0.5;
                if(world.isWalkable(castpos)) {
                    this.pos = newpos; 
                }
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

    

    mixin createSerialize!(false,"displayName","_tileset","_animationName","_animationOffset","_mapCollisionOffset","_mapCollisionSize");
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
    /// the offset of the collision rect (for map collisions!)
    vec2            _mapCollisionOffset = 0.0;
    /// the size of the collsision rect
    vec2            _mapCollisionSize = 0.0;

}