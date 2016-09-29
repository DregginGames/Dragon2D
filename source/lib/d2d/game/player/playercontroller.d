module d2d.game.player.playercontroller;

import d2d.game.player.abstractplayer;

interface PlayerController
{
    void setPlayer(AbstractPlayer p);
}

interface PlayerGroupController
{
    void addPlayer(AbstractPlayer p);
    void removePlayer(AbstractPlayer p);
}