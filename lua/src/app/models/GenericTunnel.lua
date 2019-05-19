
local TunnelBase = import(".TunnelBase")

local GenericTunnel = {}

function GenericTunnel.create(s, p)
    printInfo("[DEBUG] [GenericTunnel] [ctor] type="..p.type_)
    
    local tunnelCls = class("GT"..string.format("%d", math.random(100000)), TunnelBase)
    function tunnelCls:ctor()
        tunnelCls.super.ctor(self)
        self.link_ = p.link
        self.type_ = p.type_
        if p.typeInactive_ then
            self.typeInactive_ = p.typeInactive_
        else
            self.typeInactive_ = self.type_ .. "-gray"
        end
    end
    
    return tunnelCls
end    

return GenericTunnel

