
local TunnelBase = import(".TunnelBase")

local TunnelLD = class("TunnelLD", TunnelBase)

function TunnelLD:ctor()
    TunnelLD.super.ctor(self)
    self.link_ = {
        TunnelBase.PL,
        TunnelBase.PD
    }
    self.type_ = TunnelBase.TUNNEL_LD
    self.typeInactive_ = TunnelBase.TUNNEL_LD .. "-gray"
end


return TunnelLD

