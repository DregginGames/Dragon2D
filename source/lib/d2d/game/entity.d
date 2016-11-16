/**
	d2d.game.entity holds the base class for all objects actually appearing ingame: entitys
*/
module d2d.game.entity;

import std.math;
import gl3n.linalg;


import d2d.core.base;
import d2d.core.event;


/**
    Base for all entity events
*/
abstract class EntityEvent : Event
{
}

/**
    Event fired if 2 entities collide
*/
class EntityCollisionEvent : EntityEvent
{
    /// Creates a new Entity event
    this(Entity e1,Entity e2) 
    {
        _ent1 = e1;
        _ent2 = e2;
    }

    /// Returns the first entity in this collision
    @property Entity ent1()
    {
        return _ent1;
    }

    /// Returns the second entity in this collision
    @property Entity ent2()
    {
        return _ent2;
    }
private:
    Entity _ent1;
    Entity _ent2;
}

/**
	The base class for all ingame-objects (entitys)
*/
abstract class Entity : Base
{
    /** the position modes for Entities	*/
	enum PositionMode {
		absolute = 0,	/// position is absolute in world space
		relative = 1,	/// position is relative to the parent, in world space. if no parent is set, it acts like absolute
		parentBound = 3, /// position is the same as the parent; acts like absolute if no parent is set         /__ Why is this 3??
	};

    /** the size mode. Used for collisions and sometimes even for rendering */
    enum SizeMode {
        none,
        radius,
        rect,
    }

    this()
    {
        _allEntities[this.id] = this;
    }
	
	/**
		The position of this object. 
	*/
	@property vec2 pos() const
	{
		return _pos;
	}
	@property vec2 pos(vec2 p)
	{
        _pos = p;
        onPosSizeChange();
		return _pos;
	}

    /** 
        The position-mode of this object
    */
    @property PositionMode positionMode() const
    {
        return positionMode;
    }
    @property PositionMode positionMode(PositionMode mode)
    {
        _positionMode = mode;
        onPosSizeChange();
        return _positionMode;
    }

	/**
		The absolute position of this object
	*/
	@property vec2 absolutePos()
	{
        if (!(this.parent is null) && (cast(Entity)this.parent)) {
            auto p = (cast(Entity)this.parent);
		    switch (_positionMode) {
			    case PositionMode.relative:
                    return p.absolutePos + _pos;
			    case PositionMode.parentBound:
					return p.absolutePos;
			    default:	//just ignore this
				    break;
		    }
        }

		return _pos;
	}

    /// gets/sets the size-mode of this entity
    @property SizeMode sizeMode() const
    {
        return _sizeMode;
    }
    /// ditto
    @property SizeMode sizeMode(SizeMode m)
    {
        _sizeMode = m;
        onPosSizeChange();
        return _sizeMode;
    }

    /// Gets/Sets the size of this entity. Used if sizeMode == SizeMode.rect
    @property vec2 size() const 
    {
        return _size;
    }
    /// Ditto
    @property vec2 size(vec2 s)
    {
        _size = s;
        onPosSizeChange();
        return _size;
    }

    /// Gets/Sets the radius of this entity. Used if sizeMode == SizeMode.radius
    @property double radius() const
    {
        return _radius;
    }
    /// Ditto
    @property double radius(double r)
    {
        _radius = r;
        onPosSizeChange();
        return _radius;
    }

    /// Tests if this entity intersects with another 
    bool intersect(Entity e)
    {
        switch(this.sizeMode) {
            case SizeMode.radius:
                switch(e.sizeMode) {
                    case SizeMode.radius:
                        return testIntersect(this.absolutePos,this.radius,e.absolutePos,e.radius);
                    case SizeMode.rect:
                        return testIntersect(e.absolutePos,e.size,this.absolutePos,this.radius);
                    default:
                        return false;
                }
            case SizeMode.rect:
                switch(e.sizeMode) {
                    case SizeMode.radius:
                        return testIntersect(this.absolutePos,this.size,e.absolutePos,e.radius);
                    case SizeMode.rect:
                        return testIntersect(this.absolutePos,this.size,e.absolutePos,e.size);
                    default:
                        return false;
                }
            default:
                return false;
        }

        assert(0);
    }

    /// Thests if this entity intersects with position p 
    bool intersect(in vec2 p)
    {
        switch(this.sizeMode) {
            case SizeMode.radius:
                return testIntersect(this.absolutePos,this.radius,p);
            case SizeMode.rect:
                return testIntersect(this.absolutePos,this.size,p);
            default:
                return false;
        }
    } 

    /// Tests if this entity intersects with position p or is in the radius around p 
    bool intersect(in vec2 p, in double r)
    {
        switch(this.sizeMode) {
            case SizeMode.radius:
                return testIntersect(this.absolutePos,this.radius,p,r);
            case SizeMode.rect:
                return testIntersect(this.absolutePos,this.size,p,r);
            default:
                return false;
        }
    }

    /// Tests if this entity intersects with position p or is in the rect around p 
    bool intersect(in vec2 p, in vec2 s)
    {
        switch(this.sizeMode) {
            case SizeMode.radius:
                return testIntersect(p,s,this.absolutePos,this.radius);
            case SizeMode.rect:
                return testIntersect(this.absolutePos,this.size,p,s);
            default:
                return false;
        }
    }

    /// Returns all entities this one intersects with
    Entity[] intersectAny()
    {
        Entity[] res;
        
        if(this.sizeMode!=SizeMode.none) {
            foreach(ref e; _allEntities.values) {
                if (e==this) {
                    continue;
                }
                if(e.intersect(this)) {
                    res ~= e;
                }
            }
        }
        return res;
    }

    /// finds all entities at position p
    static Entity[] findAll(in vec2 p)
    {
        Entity[] res;
        foreach(ref e; _allEntities.values) {
            if(!e.deleted) {
                if (e.intersect(p)) {
                    res ~= e;
                }
            }
        }
        return res;
    }

    /// finds all entites at or around point p (radius)
    static Entity[] findAll(in vec2 p, in double r)
    {
        Entity[] res;
        foreach(ref e; _allEntities.values) {
            if(!e.deleted) {
                if (e.intersect(p,r)) {
                    res ~= e;
                }
            }
        }
        return res;
    }

    /// finds all entites at or around point p (rect)
    static Entity[] findAll(in vec2 p, in vec2 s)
    {
        Entity[] res;
        foreach(ref e; _allEntities.values) {
            if(!e.deleted) {
                if (e.intersect(p,s)) {
                    res ~= e;
                }
            }
        }
        return res;
    }
protected:
    /// called when position or size of this entity is changed. overload to make usefull
    void onPosSizeChange()
    {
    }

    /**
        does the full intersection test between all entities
        dont ever call manually - it fires collision events. 
        placed here because of some vars; called once from the object instanced by the world
    */
    void doFullIntersectionTest()
    {
        auto ent = _allEntities.values;
        for(int i = 0; i < ent.length; i++) {
            auto a = ent[i];
            for(int j = i+1; j < ent.length; j++) {
                auto b = ent[j];
                if(a.intersect(b)) {
                    fireEvent(new EntityCollisionEvent(a,b));
                }
            }
        }
    }

    override void onDelete()
    {
        _allEntities.remove(this.id);
    }

private:
	/// the position-mode of this entity
	PositionMode _positionMode = PositionMode.absolute;
    /// the size-mode of this entity
    SizeMode _sizeMode = SizeMode.none;

	/// the position of this entity
	vec2 _pos = 0;
	/// the size of this entity. Used if sizeMode == SizeMode.rect
    vec2 _size = 0;
    /// the radius of this entity. Used if sizeMode == SizeMode.radius
    double _radius = 0;

    /// all known entities. 
    static Entity[size_t] _allEntities;
}

/// This class manages the intersection testing. Instance somewhere usefull - engine is a place...
final class EntityCollisionTester : Entity
{
    final override void preUpdate() 
    {
        super.preUpdate();
        doFullIntersectionTest();
    }
    
}

// below: collision helpers. might get oursourced

/** Helper function to test for intersection
    Parameters:
        p1: the positions that has a radius around it
        r1: the radius around p
        p2: the position that is to test if its near p
*/
bool testIntersect(in vec2 p1, in double r1, in vec2 p2)
{
    return abs((p1-p2).length) <= r1;
}

/** Helper function to test for intersection
    Parameters:
        p1: position 1
        r1: radius around p1
        p2: pos2
        r2: radius around p2
*/
bool testIntersect(in vec2 p1, in double r1, in vec2 p2, in double r2)
{
    return abs((p1-p2).length) <= (r1+r2);
}

/** Helper function to test for intersection
    Parameters:
        p1: position 1
        s1: size of the rect around p
        p2: position to test if in the rect around p
*/
bool testIntersect(in vec2 p1, in vec2 s1, in vec2 p2)
{
    vec2 s1half = s1*0.5;
    return p1.x-s1half.x <= p2.x 
        && p1.x+s1half.x >= p2.x 
        && p1.y-s1half.y <= p2.y 
        && p1.y+s1half.y >= p2.y;
}

/** Helper function to test for intersection
    Parameters:
        p1: position 1
        s1: size of the rect around p1
        p2: position to intersect with 
        s2: size of the rect around p2
*/
bool testIntersect(in vec2 p1, in vec2 s1, in vec2 p2, in vec2 s2)
{
    // quick test in front. covers the cases where the points are within the areas and not only the edges are overlapping
    if(testIntersect(p1,s1,p2) || testIntersect(p2,s2,p1)) { 
        return true;
    }

    /// well. Test the edges of the rect. no rotation obviously
    vec2 s1half = s1*0.5;
    vec2 a = vec2(p1.x-s1half.x,p1.y-s1half.y);
    vec2 b = vec2(p1.x+s1half.x,p1.y-s1half.y);
    vec2 c = vec2(p1.x-s1half.x,p1.y+s1half.y);
    vec2 d = vec2(p1.x+s1half.x,p1.y+s1half.y);
    return testIntersect(p2,s2,a)
        || testIntersect(p2,s2,b)
        || testIntersect(p2,s2,c)
        || testIntersect(p2,s2,d);
}

/** Helper function to test for intersection
    Parameters:
        p1: position 1
        s1: size of the rect around p1
        p2: position to intersect with 
        r2: radius around p2
*/
bool testIntersect(in vec2 p1, in vec2 s1, in vec2 p2, in double r2)
{
    // quick test in front. covers the cases where the points are within the areas and not only the edges are overlapping
    if(testIntersect(p1,s1,p2) || testIntersect(p2,r2,p1)) {
        return true;
    }

    // well. Test the edges of the rect. no rotation obviously
    vec2 s1half = s1*0.5;
    vec2 a = vec2(p1.x-s1half.x,p1.y-s1half.y);
    vec2 b = vec2(p1.x+s1half.x,p1.y-s1half.y);
    vec2 c = vec2(p1.x-s1half.x,p1.y+s1half.y);
    vec2 d = vec2(p1.x+s1half.x,p1.y+s1half.y);
    return testIntersect(p2,r2,a)
        || testIntersect(p2,r2,b)
        || testIntersect(p2,r2,c)
        || testIntersect(p2,r2,d);
}