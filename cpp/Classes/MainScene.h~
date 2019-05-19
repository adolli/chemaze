
#ifndef _CHEMAZE_MAINSCENE_H_
#define _CHEMAZE_MAINSCENE_H_

#include "cocos2d.h"
#include "StageScene.h"

using cocos2d::log;
using cocos2d::Size;
using cocos2d::Point;

using cocos2d::Director;
using cocos2d::Scene;
using cocos2d::Layer;
using cocos2d::Sprite;

using cocos2d::MenuItemImage;
using cocos2d::Menu;

class MainScene: public Scene
{
public:
    
    virtual bool init()
    {
        if (!Scene::init())
        {
            return false;
        }
        
        Size visibleSize = Director::getInstance()->getVisibleSize();
        Point origin = Director::getInstance()->getVisibleOrigin();

        auto layer = Layer::create();
        this->addChild(layer);
        
        auto bg = Sprite::create("mainscene.png");
        bg->setPosition(visibleSize / 2);
        layer->addChild(bg);
       
        auto playButton = MenuItemImage::create("PlayButton.png", "PlayButton.png", CC_CALLBACK_0(MainScene::playGameCallback, this));
        auto exitButton = MenuItemImage::create("ExitButton.png", "ExitButton.png", CC_CALLBACK_0(MainScene::exitGameCallback, this));
        exitButton->setPosition(0, -120);
        auto mainMenu = Menu::create(playButton, exitButton, nullptr);
        mainMenu->setPosition(origin.x + visibleSize.width / 2 + 150, 
                origin.y + visibleSize.height / 2 - 120);
        layer->addChild(mainMenu);

        log("[INFO] [MainScene] origin(%.1f, %.1f)", origin.x, origin.y); 

        auto copyright = Label::createWithSystemFont("adolli   ^.^", "Arial", 25);
        copyright->setPosition(visibleSize.width - 100, 25);
        layer->addChild(copyright);
        return true;
    }

    void playGameCallback()
    {
        log("[INFO] [MainScene] [playGameCallback]");
        Director::getInstance()->pushScene(StageScene::create());
    }

    void exitGameCallback()
    {
        Director::getInstance()->end();
    }

    CREATE_FUNC(MainScene);

};

#endif  //_CHEMAZE_MAINSCENE_H_

