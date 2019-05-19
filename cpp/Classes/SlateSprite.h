
#ifndef _CHEMAZE_SLATESPRITE_H_
#define _CHEMAZE_SLATESPRITE_H_


#include "cocos2d.h"

using cocos2d::log;
using cocos2d::Size;
using cocos2d::Point;

using cocos2d::Director;
using cocos2d::Scene;
using cocos2d::Layer;
using cocos2d::Sprite;
using cocos2d::Label;

using cocos2d::MenuItemImage;
using cocos2d::Menu;

#include <cstdio>
#include <cstdlib>
#include <string>
using std::string;
using std::sprintf;

class SlateSprite: public Sprite 
{
public:
   
    enum
    {
        FACE_WIDTH = 167,
        FACE_HEIGHT = 172
    };
     
    SlateSprite()
        : number_(-1)
    {
        char buf[33];
        sprintf(buf, "%d", number_); 
        numberLabel_ = Label::createWithSystemFont(buf, "Arial", 25);
        numberLabel_->setPosition(30, 30);
        addChild(numberLabel_);
    }

    void setNumber(int number)
    {
        char buf[35];
        number_ = number;
        sprintf(buf, "%d", number_);
        numberLabel_->setString(buf);
    }

    int getNumber() const
    {
        return number_;
    }

    virtual bool initWithFile(const string& filename)
    {
        return Sprite::initWithFile(filename);
    }


    static SlateSprite* create(const string& filename)
    {
        SlateSprite* slate = new SlateSprite();
        if (slate && slate->initWithFile(filename))
        {
            slate->autorelease();
            return slate;
        }
        CC_SAFE_DELETE(slate);
        return nullptr;
    }

private:

    // the number represents the puzzle's number
    int number_;
    Label* numberLabel_;

};

#endif  //_CHEMAZE_SLATESPRITE_H_

