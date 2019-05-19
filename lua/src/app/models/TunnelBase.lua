
local TunnelBase = class("TunnelBase", cc.Node)

TunnelBase.PASSIVE = 0
TunnelBase.SOURCE = 1
TunnelBase.SINK = 2

TunnelBase.PU = 0
TunnelBase.PD = 1
TunnelBase.PL = 2
TunnelBase.PR = 3

TunnelBase.ACTIVATED = 1
TunnelBase.DEACTIVATED = 0

TunnelBase.TUNNEL_UNDEFINED = ""
TunnelBase.TUNNEL_UD = "UD"
TunnelBase.TUNNEL_LR = "LR"
TunnelBase.TUNNEL_UL = "UL"
TunnelBase.TUNNEL_UR = "UR"
TunnelBase.TUNNEL_LD = "LD"
TunnelBase.TUNNEL_RD = "RD"

TunnelBase.PAIRED_PORT = {
    [TunnelBase.PU] = TunnelBase.PD ,
    [TunnelBase.PD] = TunnelBase.PU ,
    [TunnelBase.PL] = TunnelBase.PR ,
    [TunnelBase.PR] = TunnelBase.PL
}
function TunnelBase:ctor()
    self.port_ = {
        [TunnelBase.PU] = { status = TunnelBase.PASSIVE },
        [TunnelBase.PD] = { status = TunnelBase.PASSIVE },
        [TunnelBase.PL] = { status = TunnelBase.PASSIVE },
        [TunnelBase.PR] = { status = TunnelBase.PASSIVE }
    }
    self.link_ = {}
    self.status_ = TunnelBase.DEACTIVATED
    self.type_ = TunnelBase.TUNNEL_UNDEFINED
    self.typeInactive_ = TunnelBase.TUNNEL_UNDEFINED
    self.isFloating_ = false -- indicate that the host slate began touching 
    self.onActivated_ = function(_self) end
    self.onDeactivated_ = function(_self) end
    
    -- debug sink/source mark
    -- if you don't need the tips, just set font-size to 1 
    self.port_[TunnelBase.PU].label = cc.Label:createWithSystemFont("", "Arial", 20)
        :move(167 / 2, 172)
        :addTo(self)
    self.port_[TunnelBase.PD].label = cc.Label:createWithSystemFont("", "Arial", 20)
        :move(167 / 2, 30)
        :addTo(self)
    self.port_[TunnelBase.PL].label = cc.Label:createWithSystemFont("", "Arial", 20)
        :move(10, 172 / 2 + 20)
        :addTo(self)
    self.port_[TunnelBase.PR].label = cc.Label:createWithSystemFont("", "Arial", 20)
        :move(167 - 10, 172 / 2 + 20)
        :addTo(self)
end

function TunnelBase:disconnectAllPorts()
    for edge, v in pairs(self.port_) do
        self:setPortStatus(edge, TunnelBase.PASSIVE)
    end
    self.status_ = TunnelBase.DEACTIVATED
end

-- if there's no change on the ports, then return false
function TunnelBase:setPortStatus(port, status)
    -- if the slate began touch, then the slate will not trigger the next one
    if self.isFloating_ then
        return true 
    end

    -- a sink port is only set when a linked port is set to SOURCE
    -- and is only release to PASSIVE when it is deactivated by GameBox 
    if self.port_[port].status == TunnelBase.SINK then
        return true
    end

    printInfo("[DEBUG] [TunnelBase] [setPortStatus] is not floating")
    local newStatus = self.status_
    local changed = false
    for _, p in pairs(self.link_) do
        
        -- find whether the port is linked
        if p == port then 
            changed = true
            if self.port_[p].status ~= status then
                printInfo("[DEBUG] [TunnelBase] [setPortStatus] port=%d matched", p)
                self.port_[p].status = status

                -- DEBUG
                if status == TunnelBase.SOURCE then
                    self.port_[p].label:setString("+")
                elseif status == TunnelBase.PASSIVE then
                    self.port_[p].label:setString("")
                else
                    self.port_[p].label:setString("-")
                end

                -- set other port's status that linked
                for _, other in pairs(self.link_) do
                    if other ~= port then
                        if status == TunnelBase.SOURCE then
                            printInfo("[DEBUG] [TunnelBase] [setPortStatus] port=%d sta=SNK", other)
                            self.port_[other].status = TunnelBase.SINK
                            self.port_[other].label:setString("-")
                            newStatus = TunnelBase.ACTIVATED
                        elseif status == TunnelBase.PASSIVE then
                            printInfo("[DEBUG] [TunnelBase] [setPortStatus] port=%d sta=PSV", other)

                            -- we just don't need set the linked port PASSIVE, because all ports will 
                            -- be set to PASSIVE when onDeactivated_ @see [GameBox] [SlateSprite.onDeactivated]
                            --self.port_[other].status = TunnelBase.PASSIVE
                            --self.port_[other].label:setString("")
                            newStatus = TunnelBase.DEACTIVATED
                        end
                    end
                end
            end
            break
        end
    end

    if changed then
        if newStatus == TunnelBase.ACTIVATED then
            self:onActivated_()
        elseif newStatus == TunnelBase.DEACTIVATED then
            self:onDeactivated_()
        end
    end
    self.status_ = newStatus

    return changed 
end

function TunnelBase:getPortStatus(port)
    return self.port_[port].status
end

function TunnelBase:setOnActivatedDelegate(delegate)
    self.onActivated_ = delegate
    return self
end

function TunnelBase:setOnDeactivatedDelegate(delegate)
    self.onDeactivated_ = delegate
    return self
end

function TunnelBase:isActive()
   return self.status_ == TunnelBase.ACTIVATED
end

function TunnelBase:getType()
    return self.type_
end

function TunnelBase:getInactiveType()
    return self.typeInactive_
end

function TunnelBase:getSinkPorts()
    local ret = {}
    for edge, port in pairs(self.port_) do
        if port.status == TunnelBase.SINK then
            ret[edge] = port
        end
    end
    return ret
end

function TunnelBase:getAllPorts()
    return self.port_
end

return TunnelBase

