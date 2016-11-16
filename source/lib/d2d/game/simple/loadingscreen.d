/** 
  Holds implementation for a simple loading screen

*/
module d2d.game.simple.loadingscreen;

import d2d.core.base;
import d2d.core.container.gamecontainer;
import d2d.game.simple.sprite;
import d2d.game.simple.camera;

class LoadingScreen : Sprite 
{
    alias LoadingScreenCallback = void delegate(GameContainer); /// Callback type for loading screen callbacks 
    static enum tickWait = 5; /// fixed number of ticks to wait before loading begins

    this(string texture, LoadingScreenCallback callback)
    {
        super(texture);
        quad.detailLevel = 99; //yes!
        quad.ignoreView = true;
        _callback = callback;
        this.addChild(new Camera(1.0));
    }

    override void update() 
    {
        ticksWaited++;
        if (ticksWaited >= tickWait) {
            auto gameroot = getService!GameContainer("d2d.gameroot");
            _callback(gameroot);
            this.setDeleted();
        }
    }
private:
    LoadingScreenCallback _callback;
    int ticksWaited = 0;
}
