
local TunnelBase = import(".TunnelBase")

local TunnelRD = class("TunnelRD", TunnelBase)

function TunnelRD:ctor()
    TunnelRD.super.ctor(self)
    self.link_ = {
        TunnelBase.PR,
        TunnelBase.PD
    }
    self.type_ = TunnelBase.TUNNEL_RD
    self.typeInactive_ = TunnelBase.TUNNEL_RD .. "-gray"
end


return TunnelRD

