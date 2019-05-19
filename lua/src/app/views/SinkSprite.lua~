
-- extend this class if need
local SinkSprite = class("SinkSprite", cc.Node)

SinkSprite.ACTION_INTERVAL = 0.15

function SinkSprite:ctor(sinkDir)
    self.active_ = cc.Sprite:create("sink-"..sinkDir..".png")
        :setOpacity(0)
        :addTo(self)
    self.inactive_ = cc.Sprite:create("sink-"..sinkDir.."-gray.png")
        :addTo(self)
    self.onActivated_ = function(_self) end
    self.onDeactivated_ = function(_self) end
end

function SinkSprite:activate()
    local fadeOut = cc.FadeOut:create(SinkSprite.ACTION_INTERVAL)
    local actionDone = cc.CallFunc:create(handler(self, self.onActivated_))
    local seq = cc.Sequence:create(fadeOut, actionDone)
    self.inactive_:runAction(seq)

    local fadeIn = cc.FadeIn:create(SinkSprite.ACTION_INTERVAL)
    self.active_:runAction(fadeIn)
    return self
end

function SinkSprite:deactivate()
    local fadeOut = cc.FadeOut:create(SinkSprite.ACTION_INTERVAL)
    local actionDone = cc.CallFunc:create(handler(self, self.onDeactivated_))
    local seq = cc.Sequence:create(fadeOut, actionDone)
    self.active_:runAction(seq)

    local fadeIn = cc.FadeIn:create(SinkSprite.ACTION_INTERVAL)
    self.inactive_:runAction(fadeIn)
    return self
end

function SinkSprite:setOnActivatedDelegate(delegate)
    self.onActivated_ = delegate
    return self
end

function SinkSprite:setOnDectivatedDelegate(delegate)
    self.onDeactivated_ = delegate
    return self
end

return SinkSprite

