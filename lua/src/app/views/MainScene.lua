
local BGM = import("..models.BackgroundMusic")
local Levels = import(".Levels")
local StageScene = import(".StageScene")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:showLevelSelection()
    local getDown = cc.MoveTo:create(0.8, cc.p(0, 0))
    local bounce = cc.EaseBounceOut:create(getDown)
    self.levelSelectLayer_:runAction(bounce)

    self.exitButton_:moveTo({time=0.3, x=200, y=-120})
    self.playButton_:moveTo({time=0.3, x=200, y=0})
end

function MainScene:hideLevelSelection()
    local getUp = cc.MoveTo:create(0.6, cc.p(0, 720))
    self.levelSelectLayer_:runAction(getUp)

    self.exitButton_:moveTo({time=0.3, x=0, y=-120})
    self.playButton_:moveTo({time=0.3, x=0, y=0})
end

function MainScene:onCreate()

    cc.Sprite:create("mainscene.png")
        :move(display.center)
        :addTo(self)
        
    -- add play button and exit button
    self.playButton_ = cc.MenuItemImage:create("PlayButton.png", "PlayButton.png")
        :onClicked(function()
            self:showLevelSelection()
        end)
    self.exitButton_ = cc.MenuItemImage:create("ExitButton.png", "ExitButton.png")
        :move(0, -120)
        :onClicked(function()
            cc.Director:getInstance():endToLua()
        end)
    cc.Menu:create(self.playButton_, self.exitButton_)
        :move(display.cx + 150, display.cy - 120)
        :addTo(self)

    local visibleSize = cc.Director:getInstance():getVisibleSize()
        
    self.levelSelectLayer_ = cc.Layer:create()
        :move(0, 720)
        :addTo(self)

    cc.Sprite:create("graybg.png")
        :move(display.center)
        :addTo(self.levelSelectLayer_)

    local levelSelectMenu = cc.Menu:create()
        :move(display.cx, 0)
        :addTo(self.levelSelectLayer_)
    local selectLevelTitle = cc.Label:createWithSystemFont("Select a level", Arial, 45)
        :setTextColor(cc.c4b(20, 150, 20, 255))
        :move(180, 650)
        :addTo(self.levelSelectLayer_)
    local labelBack = cc.Label:createWithSystemFont("<< Back", "Arial", 45)
    local backBtn = cc.MenuItemLabel:create(labelBack)
        :move(-400, 580)
        :addTo(levelSelectMenu)
        :onClicked(function() 
            self:hideLevelSelection()
        end)
    for i, level in pairs(Levels.level) do
        local label = cc.Label:createWithSystemFont(string.format("(%d) ", i)..level.name, "Arial", 35)
        local labelBtn = cc.MenuItemLabel:create(label)
            :move(0, i * 50)
            :addTo(levelSelectMenu)
            :onClicked(function()
                Levels.recentPlay = i
                self:getApp():enterScene("StageScene")
            end)
    end
        

    self.bgm_ = BGM:create()
    self.bgm_:play("Wet Hands")

end

return MainScene

