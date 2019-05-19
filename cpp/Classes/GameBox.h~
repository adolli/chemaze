
#ifndef _CHEMAZE_GAMEBOX_H_
#define _CHEMAZE_GAMEBOX_H_

#include "cocos2d.h"
#include "SlateSprite.h"
#include "Puzzle.h"
#include <vector>
#include <cmath>
#include <functional>
using std::function;
using std::vector;
using std::size_t;
using std::pow;

using cocos2d::log;
using cocos2d::Size;
using cocos2d::Point;
using cocos2d::Rect;

using cocos2d::Director;
using cocos2d::Scene;
using cocos2d::Layer;
using cocos2d::Sprite;
using cocos2d::Node;
using cocos2d::Vector;

using cocos2d::MenuItemImage;
using cocos2d::Menu;
using cocos2d::Touch;
using cocos2d::Event;

using cocos2d::Action;
using cocos2d::FiniteTimeAction;
using cocos2d::MoveTo;
using cocos2d::Sequence;
using cocos2d::CallFunc;
using cocos2d::CallFuncN;


/**
 * @brief   the slate box view
 */
class GameBox: public Node 
{
public:

    enum { DEFAULT_HOLE_MARK = 0 };

    GameBox(size_t w = 3, size_t h = 3): movingOperation_(Puzzle::NOOP), isOperating_(false),
                                         draged_(false), isCleared_(false),
                                         moveRecordIndex_(0), onLevelClear_(nullptr),
                                         onSlateMoved_(nullptr)
    {
        Puzzle::PuzzleState origin = {
            {8, 7, 6},
            {5, 4, 3},
            {2, 1, 0}
        };
        Puzzle::PuzzleState target = {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 0}
        };
        puzzle_ = new Puzzle(origin, target, DEFAULT_HOLE_MARK); 
    }

    ~GameBox()
    {
        delete puzzle_;
    }

    virtual bool init()
    {
        if (!Node::init())
        {
            return false;
        }
       
        isCleared_ = false;

        auto touchListener = cocos2d::EventListenerTouchOneByOne::create();
        touchListener->setSwallowTouches(true);
        touchListener->onTouchBegan = [&](Touch* touch, Event* event)
        {
            log("[INFO] [GameBox] [init] onTouchBegan");
            if (isOperating_ || isCleared_)
            {
                return false;
            }

            auto target = dynamic_cast<SlateSprite*>(event->getCurrentTarget());
            CCAssert(target != nullptr, "class cast exception, need a SlateSprite Object.");

            Point locationInNode = target->convertToNodeSpace(touch->getLocation());
            Size s = target->getContentSize();
            Rect rect = Rect(0, 0, s.width, s.height);
            if (rect.containsPoint(locationInNode))
            {
                bool accept = prepareToMove(target);
                return accept; 
            }
            return false;
        };
        touchListener->onTouchMoved = [&](Touch* touch, Event* event)
        {
            auto target = dynamic_cast<SlateSprite*>(event->getCurrentTarget());
            CCAssert(target != nullptr, "class cast exception, need a SlateSprite Object.");

            draged_ = true;
            auto hole = puzzle_->getHolePosition();
            auto holePosition = Point(hole.c * SlateSprite::FACE_WIDTH, hole.r * -SlateSprite::FACE_HEIGHT); 
            auto touchedPosition = this->convertToNodeSpace(touch->getLocation()); 
            auto targetPosition = target->getPosition();

            // limit the slate dragging position
            switch(movingOperation_)
            {
                case Puzzle::RIGHT:
                    touchedPosition.y = targetPosition.y;
                    if (touchedPosition.x < holePosition.x)
                    {
                        touchedPosition.x = holePosition.x;
                    }
                    else if (touchedPosition.x > holePosition.x + SlateSprite::FACE_WIDTH)
                    {
                        touchedPosition.x = holePosition.x + SlateSprite::FACE_WIDTH;
                    }
                    break;
                case Puzzle::LEFT:
                    touchedPosition.y = targetPosition.y;
                    if (touchedPosition.x < holePosition.x - SlateSprite::FACE_WIDTH)
                    {
                        touchedPosition.x = holePosition.x - SlateSprite::FACE_WIDTH;
                    }
                    else if (touchedPosition.x > holePosition.x)
                    {
                        touchedPosition.x = holePosition.x;
                    }
                    break;
                case Puzzle::UP:
                    touchedPosition.x = targetPosition.x;
                    if (touchedPosition.y < holePosition.y)
                    {
                        touchedPosition.y = holePosition.y;
                    }
                    else if (touchedPosition.y > holePosition.y + SlateSprite::FACE_HEIGHT)
                    {
                        touchedPosition.y = holePosition.y + SlateSprite::FACE_HEIGHT;
                    }
                    break;
                case Puzzle::DOWN:
                    touchedPosition.x = targetPosition.x;
                    if (touchedPosition.y < holePosition.y - SlateSprite::FACE_HEIGHT)
                    {
                        touchedPosition.y = holePosition.y - SlateSprite::FACE_HEIGHT;
                    }
                    else if (touchedPosition.y > holePosition.y)
                    {
                        touchedPosition.y = holePosition.y;
                    }
                    break;
                default:;
            }

            target->setPosition(touchedPosition);
            log("[INFO] [GameBox] [onTouchMoved] target(%.1f, %.1f) hole(%.1f, %.1f) touch(%.1f, %.1f)", 
                    target->getPosition().x, target->getPosition().y,
                    holePosition.x, holePosition.y,
                    touchedPosition.x, touchedPosition.y);
        };
        touchListener->onTouchEnded = [&](Touch* touch, Event* event)
        {
            // this target action will only be performed when there is a valid touch
            // that is the slate we touched was posible to move
            auto target = dynamic_cast<SlateSprite*>(event->getCurrentTarget());
            CCAssert(target != nullptr, "class cast exception, need a SlateSprite Object.");

            // set the operating flag
            isOperating_ = true;

            FiniteTimeAction* moveTo = nullptr;
            bool moveToHole = genSlateMotion(target, movingOperation_, moveTo);
            if (!moveToHole)
            {
                movingOperation_ = Puzzle::NOOP;
            }
            auto updatePuzzle = CallFunc::create(std::bind(&GameBox::updatePuzzleState, this)); 
            auto resetZOrder = CallFunc::create(std::bind(&GameBox::resetSlateZOrder, this));
            auto clearOperating = CallFunc::create(std::bind(&GameBox::clearOperatingFlag, this));
            auto clearDragging = CallFunc::create(std::bind(&GameBox::clearDraggedFlag, this));
            auto levelClear = CallFunc::create(std::bind(&GameBox::levelClearProc, this));

            // run the action
            auto action = Sequence::create(moveTo, updatePuzzle, resetZOrder, 
                    clearOperating, clearDragging, levelClear,
                    nullptr);
            target->runAction(action);
        };

        for (int i = 0; i < puzzle_->getHeight(); ++i)
        {
            for (int j = 0; j < puzzle_->getWidth(); ++j)
            {
                int puzzleNumber = puzzle_->get(i, j);
                if (puzzleNumber != DEFAULT_HOLE_MARK)
                {
                    auto slate = SlateSprite::create("slate.png");
                    slate->setPosition(j * 167, i * -172);
                    slate->setNumber(puzzleNumber);
                    this->addChild(slate, pow(2, i + j + 1));
                    _eventDispatcher->addEventListenerWithSceneGraphPriority(touchListener->clone(), slate);
                    slateContainer_.push_back(slate); 
                }
            }
        }

        return true;
    }


    static GameBox* create()
    {
        auto box = new GameBox();
        if (box && box->init())
        {
            box->autorelease();
            return box;
        }
        CC_SAFE_DELETE(box);
        return nullptr;
    }


    void autoResetSlates()
    {
        if (isOperating_) 
        {
            return;
        }

        moveRecordIndex_ = 0;
        moveRecord_ = puzzle_->solve();
        nextMoveOperation();
    }


    void setOnLevelClearDelegate(const function<void()>& delegate)
    {
        onLevelClear_ = delegate;
    }

    void setOnSlateMovedDelegate(const function<void()>& delegate)
    {
        onSlateMoved_ = delegate;
    }

    bool isLevelCleared() const
    {
        return puzzle_->isSolved();
    }

    int getTotalMoveSteps() const 
    {
        return puzzle_->getTotalSteps();
    }

private:

    void nextMoveOperation()
    {
        auto dir = moveRecord_[moveRecordIndex_++];
        if (dir == Puzzle::NOOP)
        {
            isOperating_ = false;
            return;
        }
        isOperating_ = true;

        int number = puzzle_->getTagCloseToHole(dir);
        auto slate = getSlateByNumber(number);
        CCAssert(slate != nullptr, "there must be a slate to the given direction of the hole");

        prepareToMove(slate);
        auto hole = puzzle_->getHolePosition();
        auto moveToPos = Point(hole.c * SlateSprite::FACE_WIDTH, hole.r * -SlateSprite::FACE_HEIGHT);
        auto moveTo = MoveTo::create(0.3, moveToPos);
        auto updatePuzzle = CallFunc::create(std::bind(&GameBox::updatePuzzleState, this));
        auto resetZOrder = CallFunc::create(std::bind(&GameBox::resetSlateZOrder, this));
        auto levelClear = CallFunc::create(std::bind(&GameBox::levelClearProc, this));
        auto doNextMove = CallFunc::create(std::bind(&GameBox::nextMoveOperation, this));
        auto action = Sequence::create(moveTo, updatePuzzle, resetZOrder, levelClear, doNextMove, nullptr);
        slate->runAction(action);
    }

    SlateSprite* getSlateByNumber(int number)
    {
        for (SlateSprite* slate : slateContainer_)
        {
            if (slate->getNumber() == number)
            {
                return slate;
            }
        }
        return nullptr;
    }

    /**
     * @brief   get a posible moving direction of a slate at current
     *          puzzle state
     * @retval  posible move direction
     */
    Puzzle::MoveDirection getMoveDirectionOf(SlateSprite* slate)
    {
        Puzzle::MoveDirection dir = Puzzle::NOOP;
        int puzzleNumber = slate->getNumber();
        auto hole = puzzle_->getHolePosition();
        auto slateTabPos = puzzle_->getPositionOf(puzzleNumber);

        // test whether the hole is near the slate touched
        if (hole.r - slateTabPos.r == 1 && hole.c == slateTabPos.c) 
        {
            // slate below the hole               
            dir = Puzzle::UP;
        }
        else if (hole.r - slateTabPos.r == -1 && hole.c == slateTabPos.c) 
        {
            // slate over the hole               
            dir = Puzzle::DOWN;
        }
        else if (hole.c - slateTabPos.c == 1 && hole.r == slateTabPos.r) 
        {
            // slate to the left of the hole               
            dir = Puzzle::LEFT;
        }
        else if (hole.c - slateTabPos.c == -1 && hole.r == slateTabPos.r) 
        {
            // slate to the right of the hole               
            dir = Puzzle::RIGHT;
        }
        return dir;
    }


    /**
     * @brief   make preparation for the slate to move 
     *          1. find which direction to move
     *          2. modify the z-order of the slate,  if it is 
     *             accepted by the moving operation 
     * @retval  true if the touch action is accepted by the target
     *          false otherwise 
     */
    bool prepareToMove(SlateSprite* target)
    {
        bool acceptMoving = true;
        auto dir = getMoveDirectionOf(target);
        movingOperation_ = dir;
        switch (dir)
        {
            case Puzzle::UP:
            case Puzzle::LEFT:
                // change the z-order to prevent being sheltered from other
                // the changing law due to arrangement of the reseted z-order
                // @see updatePuzzleAndSlateContainerCallback
                // the similar as below 
                target->setLocalZOrder(target->getLocalZOrder() * 2 - 1);
                break;

            case Puzzle::DOWN:
            case Puzzle::RIGHT:
                target->setLocalZOrder(target->getLocalZOrder() / 2 + 1);
                break;

            default:
                acceptMoving = false;
        }
        return acceptMoving;
    }

    /**
     * @brief   get a motion action of the slate touched
     *          if the slate is still far from the hole, the slate will
     *          return to its origin place
     * @param   target [in] the slate touched
     * @param   posibleMovingDirection [in] the direction that the slate 
     *          can move
     * @param   result [out] the slate motion action generated
     * @retval  true if the slate move to the hole, 
     *          false if the slate return to its origin place
     */
    bool genSlateMotion(SlateSprite* target, 
            Puzzle::MoveDirection posibleMovingDirection,
            FiniteTimeAction*& result) const
    {
        bool moveToHole = true;

        // find the hole position before moving
        auto hole = puzzle_->getHolePosition();
        auto holePosition = Point(hole.c * SlateSprite::FACE_WIDTH, hole.r * -SlateSprite::FACE_HEIGHT); 

        Point moveToPos;
        if (draged_)
        {
            // calculate the dragging slate's nearest placement position
            float distanceToHole = target->getPosition().getDistance(holePosition); 
            if (distanceToHole > SlateSprite::FACE_WIDTH / 2)
            {
                // if the distance to the hole is to far
                // then the slate will not move to the hole
                // According to its origin moving intention
                // moveToHoleurn back to its origin placement and
                switch (posibleMovingDirection)
                {
                    case Puzzle::LEFT:
                        moveToPos = Point(
                                (hole.c - 1) * SlateSprite::FACE_WIDTH, 
                                hole.r * -SlateSprite::FACE_HEIGHT);
                        break;
                    case Puzzle::RIGHT:
                        moveToPos = Point(
                                (hole.c + 1) * SlateSprite::FACE_WIDTH, 
                                hole.r * -SlateSprite::FACE_HEIGHT);
                        break;
                    case Puzzle::UP:
                        moveToPos = Point(
                                hole.c * SlateSprite::FACE_WIDTH, 
                                (hole.r - 1) * -SlateSprite::FACE_HEIGHT);
                        break;
                    case Puzzle::DOWN:
                        moveToPos = Point(
                                hole.c * SlateSprite::FACE_WIDTH, 
                                (hole.r + 1) * -SlateSprite::FACE_HEIGHT);
                        break;
                    default:
                        log("[ERROR] [GameBox] [onTouchEnded] should not get here.");
                }
                moveToHole = false;
            }
            else
            {
                moveToPos = Point(hole.c * SlateSprite::FACE_WIDTH, hole.r * -SlateSprite::FACE_HEIGHT);
            }
        }
        else
        {
            moveToPos = Point(hole.c * SlateSprite::FACE_WIDTH, hole.r * -SlateSprite::FACE_HEIGHT);
        }

        result = MoveTo::create(0.1, moveToPos);
        return moveToHole;
    }


    void updatePuzzleState()
    {
        log("[INFO] [GameBox] [updatePuzzle] puzzle moved, hole(%d, %d)", puzzle_->getHolePosition().r, puzzle_->getHolePosition().c);    
        puzzle_->move(movingOperation_);

        if (movingOperation_ != Puzzle::NOOP && onSlateMoved_ != nullptr)
        {
            onSlateMoved_();
        }
    }

    void resetSlateZOrder()
    {
        // also reset the z-order of each slate
        // like this way
        // 2  4  8
        // 4  8 16
        // 8 16 32
        for (auto& slate : slateContainer_)
        {
            if (slate != nullptr)
            {
                auto pos = puzzle_->getPositionOf(slate->getNumber());
                slate->setLocalZOrder(pow(2, pos.r + pos.c + 1));
            }
        }
    }

    void clearOperatingFlag()
    {
        isOperating_ = false;
    }

    void clearDraggedFlag()
    {
        draged_ = false;
    }

    void levelClearProc()
    {
        if (isLevelCleared())
        {
            isCleared_ = true;

            // invoke the level clear callback
            if (onLevelClear_)
            {
                onLevelClear_();
            }
        }
    }

protected:

    vector<SlateSprite*> slateContainer_; 
    Puzzle *puzzle_;
    Puzzle::MoveDirection movingOperation_;
    bool isOperating_;
    bool isCleared_;
    bool draged_;
    function<void()> onLevelClear_;
    function<void()> onSlateMoved_;

    vector<Puzzle::MoveDirection> moveRecord_;
    int moveRecordIndex_;
};

#endif  //_CHEMAZE_GAMEBOX_H_
