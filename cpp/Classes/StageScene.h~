
#ifndef _CHEMAZE_STAGESCNENE_H_
#define _CHEMAZE_STAGESCNENE_H_

#include "cocos2d.h"
#include "SlateSprite.h"
#include "GameBox.h"
#include "MenuButton.h"

using cocos2d::log;
using cocos2d::Size;
using cocos2d::Point;
using cocos2d::Rect;

using cocos2d::Director;
using cocos2d::Scene;
using cocos2d::Layer;
using cocos2d::Sprite;

using cocos2d::MenuItemImage;
using cocos2d::MenuItemLabel;
using cocos2d::Menu;
using cocos2d::Label;
using cocos2d::Touch;
using cocos2d::Event;
using cocos2d::MoveTo;
using cocos2d::EaseBackOut;
using cocos2d::EaseBackIn;
using cocos2d::FadeIn;
using cocos2d::FadeOut;
using cocos2d::Spawn;
using cocos2d::DelayTime;
using cocos2d::RepeatForever;

#include <cstdio>
using std::sprintf;

class StageScene: public Scene
{
public:
    
    enum
    {
        GAMEBOX_ZINDEX = 10,
        MENU_PANEL_ZINDEX = 15,
        LEVEL_CLEAR_TIPS_ZINDEX = 20,

        TAG_TIMER_UPDATER = 0x1FF,

        GAMEBOX_X = -160,
        GAMEBOX_Y = 160,
        BACK_BUTTON_X_OF_MENU = -440,
        BACK_BUTTON_Y_OF_MENU = 210,
        NEXT_TIPS_BUTTON_X_OF_MENU = BACK_BUTTON_X_OF_MENU,
        NEXT_TIPS_BUTTON_Y_OF_MENU = BACK_BUTTON_Y_OF_MENU - 100,
        CLOCK_LOGO_X_OF_MENU = 360,
        CLOCK_LOGO_Y_OF_MENU = BACK_BUTTON_Y_OF_MENU,
        COUNT_LOGO_X_OF_MENU = CLOCK_LOGO_X_OF_MENU,
        COUNT_LOGO_Y_OF_MENU = NEXT_TIPS_BUTTON_Y_OF_MENU,

    };

    StageScene()
    {
        secondsPast_ = 0;
    }

    ~StageScene()
    {
        gameBox_->setOnLevelClearDelegate(nullptr);
    }

    virtual bool init()
    {
        if (!Scene::init())
        {
            return false;
        }
       
        Size visibleSize = Director::getInstance()->getVisibleSize();

        auto background = Sprite::create("stagescene.png");
        background->setPosition(visibleSize / 2);
        this->addChild(background);

        // init gamebox
        gameBoxInit();
        this->addChild(gameBox_, GAMEBOX_ZINDEX);


        // init menu panel layer
        menuPanel_ = Layer::create();
        menuPanel_->setPosition(visibleSize / 2);
        this->addChild(menuPanel_, MENU_PANEL_ZINDEX);

        auto backBtn = MenuButton::create("back.png", 
                CC_CALLBACK_0(StageScene::backToMainScene, this)); 
        backBtn->setPosition(BACK_BUTTON_X_OF_MENU, BACK_BUTTON_Y_OF_MENU);
        auto nextTipsBtn = MenuButton::create("nextTips.png", 
                CC_CALLBACK_0(StageScene::gameBoxAutoResetCallback, this)); 
        nextTipsBtn->setPosition(NEXT_TIPS_BUTTON_X_OF_MENU, NEXT_TIPS_BUTTON_Y_OF_MENU);
        auto menu = Menu::create(backBtn, nextTipsBtn, nullptr);
        menu->setPosition(0, 0);
        menuPanel_->addChild(menu);

        auto clock = Sprite::create("clock.png");
        clock->setPosition(CLOCK_LOGO_X_OF_MENU, CLOCK_LOGO_Y_OF_MENU);
        menuPanel_->addChild(clock);
        auto counter = Sprite::create("counter.png");
        counter->setPosition(COUNT_LOGO_X_OF_MENU, COUNT_LOGO_Y_OF_MENU);
        menuPanel_->addChild(counter);

        // init timer and counter
        time_ = Label::createWithSystemFont("00:00", "Arial", 50);
        time_->setPosition(CLOCK_LOGO_X_OF_MENU + 60, CLOCK_LOGO_Y_OF_MENU);
        time_->setAnchorPoint(Point(0, 0.5));
        menuPanel_->addChild(time_);
        stepCount_ = Label::createWithSystemFont("000", "Arial", 50);
        stepCount_->setPosition(COUNT_LOGO_X_OF_MENU + 60, COUNT_LOGO_Y_OF_MENU);
        stepCount_->setAnchorPoint(Point(0, 0.5));
        menuPanel_->addChild(stepCount_);

        timerUpdaterInit();

        // init level clear tips layer
        levelClearTips_ = Layer::create();
        levelClearTips_->setPosition(0, 1080);
        auto levelClearBg = Sprite::create("wellDone.png");
        levelClearBg->setPosition(visibleSize / 2);
        levelClearTips_->addChild(levelClearBg);
        this->addChild(levelClearTips_, LEVEL_CLEAR_TIPS_ZINDEX);

        auto retryLevelBtn = MenuItemImage::create("retry.png", "retry.png", 
                CC_CALLBACK_0(StageScene::retryLevel, this));
        retryLevelBtn->setPosition(-120, 0);
        auto nextLevelBtn = MenuItemImage::create("nextLevel.png", "nextLevel.png",
                CC_CALLBACK_0(StageScene::nextLevel, this));
        nextLevelBtn->setPosition(120, 0);
        auto wellDoneMenu = Menu::create(retryLevelBtn, nextLevelBtn, nullptr);
        wellDoneMenu->setPosition(visibleSize.width / 2, visibleSize.height / 2 - 150);
        levelClearTips_->addChild(wellDoneMenu);

        return true;
    }

    CREATE_FUNC(StageScene);


    void backToMainScene()
    {
        Director::getInstance()->popScene();
    }

private:

    GameBox* gameBox_;
    Layer* menuPanel_;
    Layer* levelClearTips_;
    int secondsPast_;
    Label* time_;
    Label* stepCount_;
    Action* timerUpdater_;


    void gameBoxInit()
    {
        auto center = Director::getInstance()->getVisibleSize() / 2;
        gameBox_ = GameBox::create();
        gameBox_->setPosition(center.width + GAMEBOX_X, center.height + GAMEBOX_Y);
        gameBox_->setOnLevelClearDelegate([&]()
        {
            // stop the timer
            getActionManager()->removeActionByTag(TAG_TIMER_UPDATER, this);    

            // show the clear tips
            auto moveDown = MoveTo::create(0.6, Point(0, 0));
            auto easeMove = EaseBackOut::create(moveDown);
            levelClearTips_->runAction(easeMove);
        });
        gameBox_->setOnSlateMovedDelegate([&]()
        {
            int totalsteps = gameBox_->getTotalMoveSteps();
            char buf[33];
            sprintf(buf, "%03d", totalsteps);
            stepCount_->setString(buf);
        });
    }

    void timerUpdaterInit()
    {
        auto tick = CallFunc::create([&]()
        {
            secondsPast_++;
            int sec = secondsPast_ % 60;
            int min = secondsPast_ / 60;
            char buf[33]; 
            sprintf(buf, "%02d:%02d", min, sec);
            time_->setString(buf);
        });
        timerUpdater_ = RepeatForever::create(Sequence::create(DelayTime::create(1), tick, nullptr));
        timerUpdater_->setTag(TAG_TIMER_UPDATER);
        runAction(timerUpdater_);
    }

    void gameBoxAutoResetCallback()
    {
        gameBox_->autoResetSlates();
    }

    void retryLevel()
    {
        auto moveUp = MoveTo::create(0.4, Point(0, 1080));
        auto easeMove = EaseBackIn::create(moveUp);
        levelClearTips_->runAction(easeMove);

        gameBox_->removeFromParent();
        gameBoxInit();
        this->addChild(gameBox_, GAMEBOX_ZINDEX);

        // reset the timer and counter
        secondsPast_ = 0;
        time_->setString("00:00");
        stepCount_->setString("000");
        timerUpdaterInit();
    }

    void nextLevel()
    {
        // TODO
    }

};

#endif  //_CHEMAZE_STAGESCNENE_H_

