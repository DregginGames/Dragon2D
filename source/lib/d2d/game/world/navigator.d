/// Classes for in-map navigation
module d2d.game.world.navigator;

import gl3n.linalg;

import std.container.dlist;
import std.math;
import std.algorithm;

import d2d.core.base;
import d2d.game.world;
import d2d.game.entity;

/// Generates a list of points (vec2) in the world to create a route between two points
class Navigator
{
    /// no constructor, all methods are static
    @disable this();
    
    /// Builds a Route between Two Positions/Entities on the map. 
    /// The algorithm in use is A*. So A* performance can be applied
    /// Return: a list of vec2 that starts at the origin and ends at the target, with grid space inbetween the nodes
    static vec2[] getRoute(vec2 orig, vec2 target, vec2 grid=vec2(0.5,0.5)) {
        return buildRoute(orig,target,grid);
    }
    /// Ditto
    static vec2[] getRoute(vec2 orig, Entity target, vec2 grid=vec2(0.5,0.5)) {
        return buildRoute(orig,target.pos,grid);
    }
    /// Ditto
    static vec2[] getRoute(Entity orig, vec2 target, vec2 grid=vec2(0.5,0.5)) {
        return buildRoute(orig.pos,target,grid);
    }
    /// Ditto
    static vec2[] getRoute(Entity orig, Entity target, vec2 grid=vec2(0.5,0.5)) {
        return buildRoute(orig.pos,target.pos,grid);
    }

private: 
    /// helper for the nav functions
    alias NavNode = vec2i;
    static nothrow size_t toHash(NavNode n) {
        size_t res = n.x;
        (cast(short*)(&res))[0] = cast(short)n.x;
        (cast(short*)(&res))[1] = cast(short)n.y;

        return res;
    }

    /// base for all routings - the a* implementation
    /// link: https://en.wikipedia.org/wiki/A*_search_algorithm
    static vec2[] buildRoute(vec2 orig, vec2 target, vec2 grid)  
    {
        vec2[] result;
        auto world = Base.getService!World("d2d.world");
        // helper funcs 
        vec2 posForNode(NavNode n) {
            return vec2(grid.x*n.x,grid.y*n.y);
        }
        bool nodeWalkable(NavNode n) {
            return world.isWalkable(posForNode(n));
        }
        NavNode nodeFromPos(vec2 p) {
            // +.5 because center of tiles etc
            return NavNode(cast(int)floor(p.x/grid.x+0.5),cast(int)floor(p.y/grid.y+0.5));
        }
        double dist(NavNode a, NavNode b) {
            return (a-b).magnitude_squared;
        }
        // returns all walkable (!!!) neighburs
        NavNode[] genNeighburs(NavNode n) {
            NavNode[] neigh;
            for (short x = -1; x <= 1; x++) {
                for( short y = -1; y <= 1; y++) {
                    NavNode newNode = NavNode((n.x+x),(n.y+y));
                    if (newNode != n && nodeWalkable(newNode)) {
                        neigh ~= newNode;
                    }
                }
            }
            return neigh;
        }

        NavNode start = nodeFromPos(orig);
        NavNode end = nodeFromPos(target);

        // make sure the route is possible at all
        if (!nodeWalkable(end)) {
            return result;
        }

        double[size_t] gScore;
        gScore[toHash(start)] = 0.0;
        double[size_t] fScore;
        fScore[toHash(start)] = dist(start,end);

        NavNode[size_t] closedSet;
        NavNode[size_t] openSet;
        NavNode[size_t] cameFrom;
        openSet[toHash(start)] = start;
        // actual A*
        while (openSet.length!=0) {
            // select node in the openSet with the lowest fScore value
            NavNode current = openSet.values[0];
            foreach(n; openSet) {
                if (fScore[toHash(n)] < fScore[toHash(current)]) {
                    current = n;
                }
            }
            if (current == end) { // reconstruct route
                NavNode[] reversePath;
                reversePath ~= current;
                while ((toHash(current) in cameFrom) !is null) {
                    current = cameFrom[toHash(current)];
                    reversePath ~= current;
                }
                // to vec2 and into result it goes
                foreach_reverse(n; reversePath) {
                    result ~= posForNode(n);
                }
                break;
            }
            size_t currentHash = toHash(current);

            openSet.remove(currentHash);
            closedSet[currentHash] = current;

            NavNode[] neighburs = genNeighburs(current);
            foreach(n; neighburs) {
                size_t nHash = toHash(n);
                if (nHash in closedSet) {
                    continue;
                }
                // distance from start 
                double sDist = gScore[currentHash] + dist(current,n);
                // new node or worse path or?
                if ((nHash in openSet) is null) {
                    openSet[nHash] = n;
                } else if (sDist >= gScore[nHash]) {
                    continue;
                }

                cameFrom[nHash] = current;
                gScore[nHash] = sDist;
                fScore[nHash] = sDist + dist(n,end);
            }
        }
        
        return result;
    }
}