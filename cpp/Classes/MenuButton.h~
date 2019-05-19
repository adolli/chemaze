
#ifndef _CHEMAZE_BUTTONSPRITE_H_
#define _CHEMAZE_BUTTONSPRITE_H_

#include "cocos2d.h"
using cocos2d::MenuItemSprite;
using cocos2d::ccMenuCallback;

#include <string>
using std::string;

class MenuButton: public MenuItemSprite 
{
public:

    MenuButton()
    {
    }

    virtual bool init(const string& logo, const ccMenuCallback& callback)
    {
        auto normal = Sprite::create("darkBtnBack.png");
        auto logo1 = Sprite::create(logo);
        logo1->setPosition(normal->getContentSize() / 2);
        normal->addChild(logo1);
        auto selected = Sprite::create("lightedBtnBack.png");
        auto logo2 = Sprite::create(logo);
        logo2->setPosition(selected->getContentSize() / 2);
        selected->addChild(logo2);

        if (!MenuItemSprite::initWithNormalSprite(normal, selected, nullptr, callback))
        {
            return false;
        }

        return true;
    }    

    static MenuButton* create(const string& logo, const ccMenuCallback& callback)
    {
        auto ret = new MenuButton();
        if (ret && ret->init(logo, callback))
        {
            ret->autorelease();
            return ret;
        }
        CC_SAFE_DELETE(ret);
        return nullptr;
    }


};

#endif  //_CHEMAZE_BUTTONSPRITE_H_

