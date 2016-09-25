module d2d.game.world.trigger;

/**
    Triggers are entities specifically placed react to collisions between entites
*/

import d2d.core.event;
import d2d.core.base;

import d2d.game.entity;

/**
    Event that is fired if a trigger is toggled
*/
class TriggerEvent : EntityEvent
{
    /// Constructs a new trigger event
    this(AbstractTrigger t, Entity e) 
    {
        _trigger = t;
        _entity = e;
    }

    @property AbstractTrigger trigger() 
    {
        return _trigger;
    }

    @property Entity entity() 
    {
        return _entity;
    }

private:
    AbstractTrigger _trigger;
    Entity _entity;
}

/**
    Helper for Trigger-events - we dont want templates everywhere
*/
abstract class AbstractTrigger : Entity
{
    /// Mode how the trigger will handle continuus collision
    enum TriggerMode
    {
        once,
        oncePerCollsion,
        continuus,
    }

    abstract @property TriggerMode triggerMode() const;
    abstract @property TriggerMode triggerMode(TriggerMode m);
    abstract @property bool triggered() const;
}

/**
    A trigger reacts to entites that collide with it, firing TriggerEvents
    The class filter and the filterCompare can be used to specify what the trigger should trigger at.
    filterClass will be used with a simple cast test if( cast(filterClass)ent ), and filterCompare is, if != ""
    put into a mixin: mixin("if (!(filterCompare)) { return; }"); within the event callback. The var to compare with is "ent".
*/
class Trigger(filterClass, string filterCompare="") : AbstractTrigger
{
    

    this(TriggerMode mode = TriggerMode.oncePerCollsion)
    {
        enableEventHandling();
        _triggerMode = mode;
        _triggered = false;
    }

    override void preUpdate() 
    {
        super.preUpdate();

        /// must not do the rest
        if (_triggered && _triggerMode == TriggerMode.once) {
            pollEvents();
            return;
        }

        bool wasTriggered = _triggered;
        _triggered = false;

        foreach(event; pollEvents()) {
            event.on!(EntityCollisionEvent)(delegate(EntityCollisionEvent e) {
                auto entThis = e.ent1 == this ? e.ent1 : e.ent2;
                auto ent = e.ent1 == this ? e.ent2 : e.ent1;
                if (entThis == this) {
                    if (cast(filterClass)ent) { // classes match
                        static if (filterCompare != "") { // filter out
                            mixin("if (!(filterCompare)) { return; }");
                        }       
                        // modes are there, too
                        switch(_triggerMode) {
                            case TriggerMode.continuus:
                                fireEvent(new TriggerEvent(this,ent));
                                break;
                            case TriggerMode.once:
                                if(!_triggered) {
                                    fireEvent(new TriggerEvent(this,ent));
                                }
                                break;
                            case TriggerMode.oncePerCollsion:
                                if(!wasTriggered&&!_triggered) {
                                    fireEvent(new TriggerEvent(this,ent));
                                }
                                break;
                            default:
                                break;
                        }
                        // triggered O:w:O
                        _triggered = true;
                    }
                }
            });
        }

    }

    override @property TriggerMode triggerMode() const
    {
        return _triggerMode;
    }
    override @property TriggerMode triggerMode(TriggerMode m)
    {
        return _triggerMode = m;
    }
    override @property bool triggered() const
    {
        return _triggered;
    }
    
private:
    TriggerMode _triggerMode;
    bool        _triggered;
}