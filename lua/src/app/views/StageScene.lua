
local StageScene = class("StageScene", cc.load("mvc").ViewBase)

local SlateSprite = import(".SlateSprite")
local MenuButton = import(".MenuButton")
local GameBox = import(".GameBox")
local Levels = import(".Levels")
local BGM = import("..models.BackgroundMusic")

StageScene.GAMEBOX_ZINDEX = 10
StageScene.MENU_PANEL_ZINDEX = 15
StageScene.LEVEL_CLEAR_TIPS_ZINDEX = 20
StageScene.CONGRATULATIONS_ZINDEX = 30

StageScene.TAG_TIMER_UPDATER = 0x1FF

StageScene.GAMEBOX_X = -160
StageScene.GAMEBOX_Y = 160
StageScene.BACK_BUTTON_X_OF_MENU = -440
StageScene.BACK_BUTTON_Y_OF_MENU = 200
StageScene.NEXT_TIPS_BUTTON_X_OF_MENU = StageScene.BACK_BUTTON_X_OF_MENU
StageScene.NEXT_TIPS_BUTTON_Y_OF_MENU = StageScene.BACK_BUTTON_Y_OF_MENU - 120
StageScene.CLOCK_LOGO_X_OF_MENU = 420
StageScene.CLOCK_LOGO_Y_OF_MENU = StageScene.BACK_BUTTON_Y_OF_MENU
StageScene.COUNT_LOGO_X_OF_MENU = StageScene.CLOCK_LOGO_X_OF_MENU
StageScene.COUNT_LOGO_Y_OF_MENU = StageScene.NEXT_TIPS_BUTTON_Y_OF_MENU

function StageScene:gameBoxInit()
    if self.levelIndex_ % 2 == 0 or not self.bgm_:isPlaying() then
        self.bgm_:play(math.random(self.bgm_:count()))
    end

    if self.gameBox_ then
        self.gameBox_:removeFromParent()
    end
    self.gameBox_ = GameBox:create(Levels.level[self.levelIndex_])
        :move(display.cx + StageScene.GAMEBOX_X, display.cy + StageScene.GAMEBOX_Y)
        :onLevelClear(function() 
            -- stop the timer
            self:getActionManager():removeActionByTag(StageScene.TAG_TIMER_UPDATER, self)
            
            -- shoe the clear tips
            local delay = cc.DelayTime:create(0.32)
            local moveDown = cc.MoveTo:create(0.6, cc.p(0, 0))
            local easeMove = cc.EaseBackOut:create(moveDown)
            self.levelClearTips_:runAction(cc.Sequence:create(delay, easeMove))

            -- play effect
            cc.SimpleAudioEngine:getInstance():playEffect("sound/levelclear.wav")
        end)
        :onSlateMoved(function()
            local totalSteps = self.gameBox_:getTotalMoveSteps()
            self.stepCount_:setString(string.format("%03d", totalSteps))
        end)
        :addTo(self, StageScene.GAMEBOX_ZINDEX)
    return self
end

function StageScene:timerUpdaterInit()
    self.timerUpdater_ = cc.RepeatForever:create(
        cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                self.secondsPast_ = self.secondsPast_ + 1
                local sec = self.secondsPast_ % 60
                local min = self.secondsPast_ / 60
                self.time_:setString(string.format("%02d:%02d", min, sec))
                return self
            end)
        )
    ):setTag(StageScene.TAG_TIMER_UPDATER)
    self:runAction(self.timerUpdater_)
end

function StageScene:hideLevelClearTips()
    local moveUp = cc.MoveTo:create(0.4, cc.p(0, 1080))
    local easeMove = cc.EaseBackIn:create(moveUp)
    self.levelClearTips_:runAction(easeMove)

    self.secondsPast_ = 0
    self.time_:setString("00:00")
    self.stepCount_:setString("000")
    self:timerUpdaterInit()
    return self 
end

function StageScene:showCongratulations()
    local scale = cc.ScaleTo:create(0.5, 1)
    local scaleEase = cc.EaseBackOut:create(scale)
    local fade = cc.FadeIn:create(0.4)
    self.congratulationLayer_:runAction(scaleEase) 
    self.congratulationBg_:runAction(fade)
    return self   
end

function StageScene:hideCongratulationsThenExit()
    local scale = cc.ScaleTo:create(0.35, 0)
    local scaleEase = cc.EaseBackIn:create(scale)
    local fade = cc.FadeOut:create(0.35)
    local exitToMainScene = cc.CallFunc:create(function()
        self:getApp():enterScene("MainScene")
    end)
    self.congratulationLayer_:runAction(cc.Sequence:create(scaleEase, exitToMainScene)) 
    self.congratulationBg_:runAction(fade)
    return self   
end


function StageScene:onCreate()
    
    self.bgm_ = BGM:create()

    self.menuPanel_ = cc.Layer:create()
        :move(display.center)
        :addTo(self, StageScene.MENU_PANEL_ZINDEX)

    self.levelClearTips_ = cc.Layer:create()
        :move(0, 1080)  -- FIXME: is this high enough?
        :addTo(self, StageScene.LEVEL_CLEAR_TIPS_ZINDEX)

    self.congratulationLayer_ = cc.Layer:create()
        :move(0, 0)
        :setScale(0)
        :addTo(self, StageScene.CONGRATULATIONS_ZINDEX)
    self.congratulationBg_ = cc.Sprite:create("congratulation.png")
        :move(display.center)
        :setOpacity(0)
        :addTo(self.congratulationLayer_)
    local okBtn = cc.MenuItemImage:create("okbtn.png", "okbtn.png")
        :onClicked(function()
            self:hideCongratulationsThenExit()  
        end)
    cc.Menu:create(okBtn)
        :move(display.cx - 250, display.cy - 150)
        :addTo(self.congratulationLayer_)

    self.time_ = cc.Label:createWithSystemFont("00:00", "Arial", 50)
        :move(StageScene.CLOCK_LOGO_X_OF_MENU + 60, StageScene.CLOCK_LOGO_Y_OF_MENU)
        :setAnchorPoint(cc.p(0, 0.5))
        :addTo(self.menuPanel_)

    self.stepCount_ = cc.Label:createWithSystemFont("000", "Arial", 50)
        :move(StageScene.COUNT_LOGO_X_OF_MENU + 60, StageScene.COUNT_LOGO_Y_OF_MENU)
        :setAnchorPoint(cc.p(0, 0.5))
        :addTo(self.menuPanel_)

    self.timerUpdater_ = nil 
    self.secondsPast_ = 0
    self.levelIndex_ = Levels.recentPlay


    -- init gamebox
    self.gameBox_ = nil
    self:gameBoxInit()

    -- init menu panel layer
    local backBtn = MenuButton:create("back.png")
        :move(StageScene.BACK_BUTTON_X_OF_MENU, StageScene.BACK_BUTTON_Y_OF_MENU)
        :onClicked(function()
            self:getApp():enterScene("MainScene")
        end)
    local nextTipsBtn = MenuButton:create("nextTips.png")
        :move(StageScene.NEXT_TIPS_BUTTON_X_OF_MENU, StageScene.NEXT_TIPS_BUTTON_Y_OF_MENU)
        :onClicked(function()
            self.gameBox_:autoResetSlates()
        end)
    cc.Menu:create(backBtn, nextTipsBtn)
        :move(0, 0)
        :addTo(self.menuPanel_)

    -- init timer and counter
    cc.Sprite:create("clock.png")
        :move(StageScene.CLOCK_LOGO_X_OF_MENU, StageScene.CLOCK_LOGO_Y_OF_MENU)
        :addTo(self.menuPanel_)
    cc.Sprite:create("counter.png")
        :move(StageScene.COUNT_LOGO_X_OF_MENU, StageScene.COUNT_LOGO_Y_OF_MENU)
        :addTo(self.menuPanel_)

    -- init timer updater
    self:timerUpdaterInit()

    -- inti level clear tips layer
    cc.Sprite:create("wellDone.png")
        :setOpacity(0.8 * 255)
        :move(display.center)
        :addTo(self.levelClearTips_)
    local retryBtn = cc.MenuItemImage:create("retry.png", "retry.png")
        :move(-120, 0)
        :onClicked(function()
            self:hideLevelClearTips()
            self:gameBoxInit()
        end)
    local nextLevelBtn = cc.MenuItemImage:create("nextLevel.png", "nextLevel.png")
        :move(120, 0)
        :onClicked(function()
            if self.levelIndex_ == #Levels.level then
                -- reach the final level
                -- show a congratulation layer
                self:hideLevelClearTips()
                self:showCongratulations()
            else
                self.levelIndex_ = self.levelIndex_ + 1
                self:hideLevelClearTips()
                self:gameBoxInit()
            end
        end)
    cc.Menu:create(retryBtn, nextLevelBtn)
        :move(display.cx, display.cy - 150)
        :addTo(self.levelClearTips_)


    display.newSprite("stagescene.png")
        :move(display.center)
        :addTo(self)

    -- preload sound effect
    cc.SimpleAudioEngine:getInstance():preloadEffect("sound/activate.wav")
    cc.SimpleAudioEngine:getInstance():preloadEffect("sound/deactivate.wav")
    cc.SimpleAudioEngine:getInstance():preloadEffect("sound/levelclear.wav")
    cc.SimpleAudioEngine:getInstance():preloadEffect("sound/pick.wav")
    cc.SimpleAudioEngine:getInstance():preloadEffect("sound/release.wav")

end


return StageScene

