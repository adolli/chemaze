
local MenuButton = class("MenuButton", function(fileLogo)
    local normal = cc.Sprite:create("darkBtnBack.png")
    cc.Sprite:create(fileLogo)
        :move(normal:getContentSize().width / 2, normal:getContentSize().height / 2)
        :addTo(normal)
    local selected = cc.Sprite:create("lightedBtnBack.png")
    cc.Sprite:create(fileLogo)
        :move(selected:getContentSize().width / 2, selected:getContentSize().height / 2)
        :addTo(selected)

    local menuItem = cc.MenuItemSprite:create(normal, selected, nil)
    return menuItem
end)


return MenuButton

