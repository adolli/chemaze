
local TunnelBase = import(".TunnelBase")

local TunnelLR = class("TunnelLR", TunnelBase)

function TunnelLR:ctor()
    TunnelLR.super.ctor(self)
    self.link_ = {
        TunnelBase.PL,
        TunnelBase.PR
    }
    self.type_ = TunnelBase.TUNNEL_LR
    self.typeInactive_ = TunnelBase.TUNNEL_LR .. "-gray"
end


return TunnelLR

