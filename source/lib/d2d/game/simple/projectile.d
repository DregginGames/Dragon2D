///
module d2d.game.simple.projectile;

import gl3n.linalg;

import d2d.game.entity;
import d2d.core.event;

import d2d.game.world;

/// Base class for all types of Projectile related evetns
class ProjectileEvent : Event 
{
    this(Projectile p)
    {
        _projectile = p;
    }

    @property Projectile projectile()
    {
        return _projectile;
    }

private:
    Projectile  _projectile;
}

/// Event that is thrown if a projectile collides with an entity
class ProjectileCollisionEvent : ProjectileEvent
{
    this(Projectile p, Entity e) {
        _ent = e;
        super(p);
    }

    @property Entity entity()
    {
        return _ent;
    }

private:
    Entity      _ent;
}

/// Event that is thrown if a projectile collides with the world
class ProjectileWorldCollisionEvent : ProjectileEvent 
{
    this(Projectile p)
    {
        super(p);
    }
}

/// A projectile is a moving entity that has comes with some helpers for collisions
/// Internal range representation uses squared values cause its faster
class Projectile : Entity
{
    /// Default range of a projectile
    enum double DEFAULT_RANGE = 100.0;
    /// Default Size (radius) of a projectile
    enum double DEFAULT_SIZE = 0.01;

    /// Constructor
    this()
    {
        this.sizeMode = SizeMode.radius;
        this.radius = DEFAULT_SIZE;
        enableEventHandling();
        _rangeSquared = DEFAULT_RANGE*DEFAULT_RANGE;
    }

    /// Constructor that takes the range of the projectile as argument
    this(double r) {
        this.sizeMode = SizeMode.radius;
        this.radius = DEFAULT_SIZE;
        enableEventHandling();
        _rangeSquared = r*r;
    }

    /// Update position and status of a projectile
    override void update() 
    {
        super.update();
        this.pos = this.pos + _velocity*ticktimeS;
        _distanceTraveledSquared += _velocity.magnitude_squared*ticktimeS;

        // entity-entity collisions
        foreach(event; pollEvents()) {
            event.on!(EntityCollisionEvent)( delegate(EntityCollisionEvent e) {
                if (e.ent1 == this || e.ent2 == this) {
                    auto ent = e.ent1 == this ? e.ent2 : e.ent1;
                    onCollision(ent);
                    fireEvent(new ProjectileCollisionEvent(this,ent));
                }
            });
        }

        // world collsisions
        auto w = getService!World("d2d.world");
        if (w.isCollideable(pos)) {
            onWorldCollision();
        }


        // make sure we dont travel forever
        if (_distanceTraveledSquared > _rangeSquared) {
            onRangeExceeded();
        }
    }
    
    /// Emits a projectile towards to, from source
    void emitTowards(vec2 src, vec2 to, double speed, double offset = 0.0)
    {
        pos = src + (to-src).normalized*offset;
        velocity = (to-src).normalized*speed;
    }
    /// Emits a projectile from entity e towards to 
    void emitTowards(Entity src, vec2 to, double speed, double offset = 0.0)
    {
        emitTowards(src.pos,to,speed,offset);
    }
    /// Emits a projectile from one entity towards another 
    void emitTowards(Entity src, Entity to, double speed, double offset = 0.0) 
    {
        emitTowards(src.pos,to.pos,speed,offset);
    }

    /// Gets/Sets the velocity vector of this projectile
    @property vec2 velocity() const 
    {
        return _velocity;
    }
    @property vec2 velocity(vec2 s) 
    {
        return _velocity = s;
    }

    /// Gets/Sets the range
    @property double range() const 
    {
        return sqrt(_rangeSquared);
    }
    /// Dito
    @property double range(double r) 
    {
        _rangeSquared = r*r;
        return r;
    }

    /// Gets the distance the projectile has traveld
    @property double traveledDistance()
    {
        return sqrt(_distanceTraveledSquared);
    }
protected: 
    /// Gets called if the projectile has traveld further than range allows
    void onRangeExceeded()
    {
        setDeleted();
    }

    /// Gets called if the projectile is colliding with an entity
    void onCollision(Entity e)
    {
        setDeleted();
    }

    /// Gets called if the projectile is colliding with the world 
    void onWorldCollision()
    {
        setDeleted();
    }

private:
    vec2    _velocity = 0.0;
    double  _rangeSquared = 0.0;
    double  _distanceTraveledSquared = 0.0;
}