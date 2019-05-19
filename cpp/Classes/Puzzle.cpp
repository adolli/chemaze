
#include "Puzzle.h"

const Puzzle::TablePos Puzzle::MOVE_UP(-1, 0);
const Puzzle::TablePos Puzzle::MOVE_DOWN(1, 0);
const Puzzle::TablePos Puzzle::MOVE_LEFT(0, -1);
const Puzzle::TablePos Puzzle::MOVE_RIGHT(0, 1);
const Puzzle::TablePos Puzzle::MOVE_ACTION[4] = 
{ 
    MOVE_UP, MOVE_LEFT, MOVE_DOWN, MOVE_RIGHT 
};

