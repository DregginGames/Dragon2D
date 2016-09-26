/**
    A pure container class wich is the top-node of the game-related classes 
  */
module d2d.core.container.gamecontainer;

import d2d.core.base; 

class GameContainer : Base 
{
    this()
    {
        registerAsService("d2d.gameroot");
    }
    /// nothing to do here - were just a helper class
}
