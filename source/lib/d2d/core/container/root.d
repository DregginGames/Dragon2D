/**
    d2d.root holds the root element of the engine 
    */
module d2d.core.container.root;

import d2d.core.base;

import d2d.core.event;

/**
    Root is a pure container class. its children should be the enviourent, input manager, event manager and stuff like that. 
  */
class Root : Base 
{
    /// ctor for event enabling
    this()
    {
        enableEventHandling();
    }

    override void update()
    {
        import d2d.util.logger;
        auto events = pollEvents();
        foreach (e; events) {
            /// remove all our children in case we are killed
            if(cast(KillEngineEvent) e) {
               Logger.log("Killing engine!"); 
               isAlive = false;
            }

        }
    }

    /// if flase, the engine is dead because it was killed
    @property bool alive() const 
    {
        return isAlive;
    }
private: 
    /// since this is the root element its the only place that knows if the engine has been killed in this tick 
    bool    isAlive = true;
}
