
local TunnelBase = import("..models.TunnelBase")

local SlateSprite = class("SlateSprite", function(filename)
    local slate = cc.Sprite:create(filename)
    return slate
end)

SlateSprite.FACE_WIDTH = 167
SlateSprite.FACE_HEIGHT = 172

SlateSprite.TAG_FADEOUT_ACTION = 0x100
SlateSprite.TAG_FADEIN_ACTION = 0x200

SlateSprite.ACTIVATION_INTERVAL = 0.10

function SlateSprite:ctor(fileSlate, tunnelClasses)
    printInfo("[SlateSprite] [ctor] slate=%s", fileSlate)
    
    self.number_ = -1
    self.numberLabel_ = cc.Label:createWithSystemFont("-1", "Arial", 25)
        :setOpacity(0)
        :move(30, 30)
        :addTo(self)

    -- the tunnel model
    tunnelClasses = tunnelClasses or { TunnelBase }
    self.tunnels_ = {}
    for i, cls in pairs(tunnelClasses) do
        local tunnel = cls.new()
            :setOnActivatedDelegate(handler(self, self.activate))
            :setOnDeactivatedDelegate(handler(self, self.deactivate))
            :addTo(self)
        tunnel.index = i
        table.insert(self.tunnels_, tunnel)
    end

    -- the tunnel sprite 
    self.symbols_ = {}
    self.symbolsInactive_ = {}
    for _, tunnel in pairs(self.tunnels_) do
        local sym = cc.Sprite:create("link-"..tunnel:getType()..".png")
            :setAnchorPoint(cc.p(0, 0))
            :setOpacity(0)
            :addTo(self)
        local symb = cc.Sprite:create("link-"..tunnel:getInactiveType()..".png")
            :setAnchorPoint(cc.p(0, 0))
            :addTo(self)
        table.insert(self.symbols_, sym)
        table.insert(self.symbolsInactive_, symb)
    end

    self.onActivated_ = function(_self) 
        printInfo("[SlateSprite] [onActivated]")
    end
    self.onDeactivated_ = function(_self) 
        printInfo("[SlateSprite] [onDeactivated]")
    end
end

function SlateSprite:deactivate(_tunnel)
    local tunnels = { _tunnel }
    if not _tunnel then
        tunnels = self.tunnels_ 
    end

    for _, tunnel in pairs(tunnels) do
        -- the color link disapeared
        local fadeOut = cc.FadeOut:create(SlateSprite.ACTIVATION_INTERVAL)
        local actionDoneCallback = cc.CallFunc:create(function()
            self.onDeactivated_(self, tunnel)
        end)
        local seq = cc.Sequence:create(fadeOut, actionDoneCallback)
        if self.symbols_[tunnel.index]:getOpacity() ~= 0 then
            self.symbols_[tunnel.index]:runAction(seq)
            cc.SimpleAudioEngine:getInstance():playEffect("sound/deactivate.wav")
        else
            self.symbols_[tunnel.index]:runAction(actionDoneCallback)
        end

        -- the gray link fade in
        local fadeIn = cc.FadeIn:create(SlateSprite.ACTIVATION_INTERVAL)
        if self.symbolsInactive_[tunnel.index]:getOpacity() == 0 then
            self.symbolsInactive_[tunnel.index]:runAction(fadeIn)
        end
    end
    return self
end

function SlateSprite:activate(tunnel)
    local fadeOut = cc.FadeOut:create(SlateSprite.ACTIVATION_INTERVAL)
    local actionDoneCallback = cc.CallFunc:create(function()
        self.onActivated_(self, tunnel)
    end)
    local seq = cc.Sequence:create(fadeOut, actionDoneCallback)
    if self.symbolsInactive_[tunnel.index]:getOpacity() ~= 0 then
        self.symbolsInactive_[tunnel.index]:runAction(seq)
        cc.SimpleAudioEngine:getInstance():playEffect("sound/activate.wav")
    else
        self.symbolsInactive_[tunnel.index]:runAction(actionDoneCallback)
    end

    local fadeIn = cc.FadeIn:create(SlateSprite.ACTIVATION_INTERVAL)
    if self.symbols_[tunnel.index]:getOpacity() == 0 then
        self.symbols_[tunnel.index]:runAction(fadeIn)
    end
    return self
end

function SlateSprite:disconnect()
    printInfo("[DEBUG] [SlateSprite] [disconnect]")
    self:deactivate()
    for _, tunnel in pairs(self.tunnels_) do
        tunnel.isFloating_ = true
    end
    return self
end

function SlateSprite:setOnActivatedDelegate(delegate)
    self.onActivated_ = delegate
    return self
end

function SlateSprite:setOnDeactivatedDelegate(delegate)
    self.onDeactivated_ = delegate
    return self
end

function SlateSprite:setNumber(num)
    self.number_ = num
    self.numberLabel_:setString(string.format("%d", num))
    return self
end

function SlateSprite:getNumber()
    return self.number_
end

function SlateSprite:getTunnels()
    return self.tunnels_
end

function SlateSprite:isAllTunnelsActive()
    for _, tunnel in pairs(self.tunnels_) do
        if tunnel:getType() ~= TunnelBase.TUNNEL_UNDEFINED then
            if not tunnel:isActive() then
                return false
            end
        end
    end
    return true
end


return SlateSprite

