
#ifndef _CHEMAZE_PUZZLE_H_
#define _CHEMAZE_PUZZLE_H_

#include "cocos2d.h"
using cocos2d::log;

#include <vector>
using std::vector;
using std::size_t;
using std::swap;

class Puzzle
{
public:

    struct TablePos
    {
        TablePos(int _r = 0, int _c = 0): r(_r), c(_c) {}
        int r, c;
    };

    
    enum MoveDirection
    {
        NOOP = -1,
        UP = 0,
        DOWN = 2,
        LEFT = 1,
        RIGHT = 3
    };

    typedef vector<vector<int>> PuzzleState;

    static const TablePos MOVE_UP;
    static const TablePos MOVE_DOWN;
    static const TablePos MOVE_LEFT;
    static const TablePos MOVE_RIGHT;
    static const TablePos MOVE_ACTION[4];

    Puzzle(const PuzzleState& origin, const PuzzleState& target, int holeMark = 0)
        : table_(origin), targetState_(target), holeMark_(holeMark), estimateStpes_(0), totalSteps_(0)
    {
        height_ = origin.size();
        CCAssert(height_ > 0, "puzzle height must be greater than 0.");
        width_ = origin[0].size();

        targetList_.resize(width_ * height_);
        for (int r = 0; r < height_; ++r)
        {
            for (int c = 0; c < width_; ++c)
            {
                if (table_[r][c] == holeMark_)
                {
                    hole_.r = r;
                    hole_.c = c;
                }
                targetList_[target[r][c]] = TablePos(r, c);
            }
        }
    }

    int getManhattonDistance() const
    {
        int distance = 0;
        for (int r = 0; r < height_; ++r)
        {
            for (int c = 0; c < width_; ++c)
            {
                int val = table_[r][c];
                if (val != holeMark_)
                {
                    const TablePos& targetPosition = targetList_[val];
                    distance += abs(targetPosition.r - r) + abs(targetPosition.c - c);
                }
            }
        }
        return distance;
    }

    const vector<MoveDirection>& solve()
    {
        int firstIncrease = 10;
        int nextIncrease = 5;

        estimateStpes_ = getManhattonDistance();
        estimateStpes_ += firstIncrease;
        int initSteps = estimateStpes_;
        moveRecord_.resize(2, NOOP);
        moveRecord_[0] = NOOP;
        log("[INFO] [Puzzle] [solve] first estimate=%d", initSteps);
        while (!solveImpl(table_, hole_, 0, NOOP, initSteps))
        {
            estimateStpes_ += nextIncrease;
        }
        log("[INFO] [Puzzle] [solve] final estimate=%d", estimateStpes_);
        return moveRecord_;
    }

    static int fuck_mod(int num, int den) 
    {
        if (num < 0)
        {
            return -((-num) % den);
        }
        else
        {
            return num % den;
        }
    }



    bool isSolved() const
    {
        for (int r = 0; r < height_; ++r)
        {
            for (int c = 0; c < width_; ++c)
            {
                if (table_[r][c] != targetState_[r][c])
                {
                    return false;
                }
            }
        }
        return true;
    }

    TablePos getHolePosition() const
    {
        return hole_;
    }

    TablePos getPositionOf(int val) const
    {
        for (int r = 0; r < height_; ++r)
        {
            for (int c = 0; c < width_; ++c)
            {
                if (table_[r][c] == val) 
                {
                    return TablePos(r, c);
                }
            }
        }
        return TablePos();
    }

    void printTable() const
    {
        log("------------------");
        for (int r = 0; r < width_; ++r)
        {
            log("%d %d %d", table_[r][0], table_[r][1], table_[r][2]);
        }
    }


    /**
     * @brief   get the tag close to the hole,
     *          to the U/D/L/R direction
     * @retval  the tag number. if there's no tag, return -1
     */
    int getTagCloseToHole(MoveDirection dir) const
    {
        int ret = -1;
        switch (dir)
        {
            case UP:
                if (hole_.r == 0) return ret;
                ret = table_[hole_.r - 1][hole_.c];
                break;
            case DOWN:
                if (hole_.r == height_ - 1) return ret;
                ret = table_[hole_.r + 1][hole_.c];
                break;
            case LEFT:
                if (hole_.c == 0) return ret;
                ret = table_[hole_.r][hole_.c - 1];
                break;
            case RIGHT:
                if (hole_.c == width_ - 1) return ret;
                ret = table_[hole_.r][hole_.c + 1];
                break;
            default:;
        }
        return ret;
    }

    /**
     * @brief   move the hole in the puzzle
     */
    void move(MoveDirection dir)
    {
        switch (dir)
        {
            case UP:
                if (hole_.r == 0) return;
                swap(table_[hole_.r][hole_.c], table_[hole_.r - 1][hole_.c]);
                hole_.r--;
                totalSteps_++;
                break;
            case DOWN:
                if (hole_.r == height_ - 1) return;
                swap(table_[hole_.r][hole_.c], table_[hole_.r + 1][hole_.c]);
                hole_.r++;
                totalSteps_++;
                break;
            case LEFT:
                if (hole_.c == 0) return;
                swap(table_[hole_.r][hole_.c], table_[hole_.r][hole_.c - 1]);
                hole_.c--;
                totalSteps_++;
                break;
            case RIGHT:
                if (hole_.c == width_ - 1) return;
                swap(table_[hole_.r][hole_.c], table_[hole_.r][hole_.c + 1]);
                hole_.c++;
                totalSteps_++;
                break;
            default:;
        }

        // log.info
        printTable();
    }

    int getEstimateSteps() const 
    {
        return estimateStpes_;
    }

    void increaseEstimateStepsBy(int step)
    {
        estimateStpes_ += step;
    }
    
    size_t getWidth() const
    {
        return width_;
    }

    size_t getHeight() const
    {
        return height_;
    }

    int get(int r, int c) const
    {
        return table_[r][c];
    }

    const vector<MoveDirection>& getMoveRecord() const
    {
        return moveRecord_;
    }

    int getTotalSteps() const
    {
        return totalSteps_;
    }

    void resetTotalSteps()
    {
        totalSteps_ = 0;
    }

private:

    bool solveImpl(const PuzzleState& state, 
            const TablePos& hole, int depth, MoveDirection direction, int estimate)
    {
        bool solved = true;
        for (int r = 0; r < height_; ++r)
        {
            for (int c = 0; c < width_; ++c)
            {
                if (state[r][c] != targetState_[r][c])
                {
                    solved = false;
                    break;
                }
            }
            if (!solved)
            {
                break;
            }
        }
        if (solved)
        {
            return true;
        }

        TablePos hole1 = hole;
        PuzzleState state1;
        for (int dir = 0; dir <= 3; ++dir)
        {
            state1 = state;
            if (dir == direction || 
                    fuck_mod(dir, 2) != fuck_mod(direction, 2))
            {
                hole1.r = hole.r + MOVE_ACTION[dir].r;
                hole1.c = hole.c + MOVE_ACTION[dir].c;

                if (hole1.r >= 0 && hole1.c >= 0 && 
                        hole1.r < height_ && hole1.c < width_)
                {
                    swap(state1[hole.r][hole.c], state1[hole1.r][hole1.c]);
                    int estimate1;
                    int movedValue = state[hole1.r][hole1.c];
                    if (dir == DOWN  && hole1.r > targetList_[movedValue].r ||
                            dir == UP    && hole1.r < targetList_[movedValue].r ||
                            dir == RIGHT && hole1.c > targetList_[movedValue].c ||
                            dir == LEFT  && hole1.c < targetList_[movedValue].c)
                    {
                        estimate1 = estimate - 1;
                    }
                    else
                    {
                        estimate1 = estimate + 1;
                    }

                    if (estimate1 + depth + 1 <= estimateStpes_)
                    {
                        if (moveRecord_.size() <= depth + 1)
                        {
                            moveRecord_.resize(depth + 2);
                        }
                        moveRecord_[depth] = MoveDirection(dir);
                        moveRecord_[depth + 1] = NOOP;
                        if (solveImpl(state1, hole1, depth + 1, MoveDirection(dir), estimate1))
                        {
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }


    size_t width_, height_;
    int holeMark_;
    int estimateStpes_;
    int totalSteps_;        // the times we invoke move() and the move is valid 
    
    PuzzleState table_;
    PuzzleState targetState_;
    vector<TablePos> targetList_;
    vector<MoveDirection> moveRecord_;
    TablePos hole_;

};

#endif  //_CHEMAZE_PUZZLE_H_

