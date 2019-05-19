
local Puzzle = import("..models.Puzzle")
local SlateSprite = import(".SlateSprite")
local SourceSprite = import(".SourceSprite")
local SinkSprite = import(".SinkSprite")

local TunnelBase = import("..models.TunnelBase")

local GameBox = class("GameBox", cc.load("mvc").ViewBase)


GameBox.DEFAULT_HOLE_MARK = 0

function GameBox:getWidth()
    return self.puzzle_.getWidth()
end

function GameBox:getHeight()
    return self.puzzle_.getHeight()
end

function GameBox:onLevelClear(fn)
    self.onLevelClear_ = fn
    return self
end

function GameBox:onSlateMoved(fn)
    self.onSlateMoved_ = fn
    return self
end

function GameBox:isAllTunnelsActive()
    for _, row in pairs(self.slateContainer_) do
        for _, slate in pairs(row) do
            if not slate:isAllTunnelsActive() then
                return false
            end
        end
    end
    return true 
end

function GameBox:isLevelCleared()
    -- then the tunnel sink must be activated, too
    return self.tsnk_.status == TunnelBase.ACTIVATED
end

function GameBox:getTotalMoveSteps()
    return self.puzzle_.getTotalSteps()
end

function GameBox:getMoveDirectionOf(slate)
    local dir = self.puzzle_.NOOP
    local puzzleNumber = slate:getNumber()
    local hole = self.puzzle_.getHolePosition()
    local slateTabPos = self.puzzle_.getPositionOf(puzzleNumber)

    if hole.r - slateTabPos.r == 1 and hole.c == slateTabPos.c then
        dir = self.puzzle_.UP
    elseif hole.r - slateTabPos.r == -1 and hole.c == slateTabPos.c then
        dir = self.puzzle_.DOWN
    elseif hole.c - slateTabPos.c == 1 and hole.r == slateTabPos.r then
        dir = self.puzzle_.LEFT
    elseif hole.c - slateTabPos.c == -1 and hole.r == slateTabPos.r then
        dir = self.puzzle_.RIGHT
    end
    return dir
end

function GameBox:prepareToMove(target)
    local acceptMoving = true

    -- determine the movable direction
    local dir = self:getMoveDirectionOf(target)
    self.movingOperation_ = dir
    
    -- set slate's floating z-order
    if dir == self.puzzle_.UP or dir == self.puzzle_.LEFT then
        target:setLocalZOrder(target:getLocalZOrder() * 2 - 1)
    elseif dir == self.puzzle_.DOWN or dir == self.puzzle_.RIGHT then
        target:setLocalZOrder(target:getLocalZOrder() / 2 + 1)
    else
        acceptMoving = false
    end

    -- deactivated the tunnel on slate
    if acceptMoving then
        target:disconnect() 
    end

    return acceptMoving
end

function GameBox:genSlateMotion(target, posibleMovingDirection)
    printInfo("[GameBox] [genSlateMotion]")
    local moveToHole = true 

    -- find the hole position before moving
    local hole = self.puzzle_.getHolePosition()
    local holePosition = cc.p(hole.c * SlateSprite.FACE_WIDTH,
                              hole.r * -SlateSprite.FACE_HEIGHT)
    local moveToPos
    if self.dragged_ then
        local targetPosition = { x = target:getPositionX(), y = target:getPositionY() }
        local distanceToHole = cc.pGetDistance(targetPosition, holePosition)
        printInfo("[GameBox] [genSlateMotion] distanceToHole=%d", distanceToHole)
        if distanceToHole > SlateSprite.FACE_WIDTH / 2 then
            if posibleMovingDirection == self.puzzle_.LEFT then
                moveToPos = cc.p((hole.c - 1) * SlateSprite.FACE_WIDTH,
                                  hole.r      * -SlateSprite.FACE_HEIGHT)
            elseif posibleMovingDirection == self.puzzle_.RIGHT then
                moveToPos = cc.p((hole.c + 1) * SlateSprite.FACE_WIDTH,
                                  hole.r      * -SlateSprite.FACE_HEIGHT)
            elseif posibleMovingDirection == self.puzzle_.UP then
                moveToPos = cc.p((hole.c    ) * SlateSprite.FACE_WIDTH,
                                 (hole.r - 1) * -SlateSprite.FACE_HEIGHT)
            elseif posibleMovingDirection == self.puzzle_.DOWN then
                moveToPos = cc.p((hole.c    ) * SlateSprite.FACE_WIDTH,
                                 (hole.r + 1) * -SlateSprite.FACE_HEIGHT)
            else
                print("[ERROR] [GameBox] [genSlateMotion] should not get here")
                assert(false, "check self.movingOperation_")
            end
            moveToHole = false
        else
            moveToPos = cc.p(hole.c * SlateSprite.FACE_WIDTH,
                             hole.r * -SlateSprite.FACE_HEIGHT)
        end
    else
        printInfo("[GameBox] [genSlateMotion] no dragged")
        moveToPos = cc.p(hole.c * SlateSprite.FACE_WIDTH,
                         hole.r * -SlateSprite.FACE_HEIGHT)
    end
    local moveTo = cc.MoveTo:create(0.12, moveToPos)
    return moveToHole, moveTo
end

function GameBox:printSlateContainer_debug()
    print("=======")
    for r = 1, self:getHeight() do
        for c = 1, self:getWidth() do
            if self.slateContainer_[r][c] then
                io.write(string.format("[%d] ", self.slateContainer_[r][c]:getNumber()))
            else
                io.write("[ ] ")
            end
        end
        print()
    end
end

function GameBox:slateContainerUpdateSlatePosition(dir)
    for r = 1, self:getHeight() do 
        for c = 1, self:getWidth() do
            if self.slateContainer_[r][c] == nil then
                if dir == self.puzzle_.UP then
                    if r == 1 then return self end
                    self.slateContainer_[r][c] = self.slateContainer_[r - 1][c]
                    self.slateContainer_[r - 1][c] = nil
                elseif dir == self.puzzle_.DOWN then
                    if r == #self.slateContainer_ then return self end
                    self.slateContainer_[r][c] = self.slateContainer_[r + 1][c]
                    self.slateContainer_[r + 1][c] = nil
                elseif dir == self.puzzle_.LEFT then
                    if c == 1 then return self end
                    self.slateContainer_[r][c] = self.slateContainer_[r][c - 1]
                    self.slateContainer_[r][c - 1] = nil
                elseif dir == self.puzzle_.RIGHT then
                    if c == #self.slateContainer_[r] then return self end
                    self.slateContainer_[r][c] = self.slateContainer_[r][c + 1]
                    self.slateContainer_[r][c + 1] = nil
                end
                return self
            end
        end
    end
end

function GameBox:refireTunnelSource()
    printInfo("[DEBUG] [GameBox] [updatePuzzleState] refire")
    local firedSlate = self.slateContainer_[self.tsrc_.r + self.tsrc_.dir.dr + 1][self.tsrc_.c + self.tsrc_.dir.dc + 1]
    if firedSlate then
        self.tunnelSteady_ = false
        local firedTunnels = firedSlate:getTunnels()
        for _, tunnel in pairs(firedTunnels) do
            printInfo("[DEBUG] [GameBox] [refireTunnelSource] tunnel%d", _)
            local statusChanged = tunnel:setPortStatus(TunnelBase.PAIRED_PORT[self.tsrc_.edge], TunnelBase.SOURCE)
            self.tunnelSteady_ = not statusChanged
        end
    else
        printInfo("[DEBUG] [GameBox] [updatePuzzleState] no slate to refire")
    end
end

function GameBox:updatePuzzleState()
    if self.movingOperation_ ~= self.puzzle_.NOOP then
        -- first move the puzzle
        self.puzzle_.move(self.movingOperation_)

        -- then move the slate in slate container
        self:slateContainerUpdateSlatePosition(self.movingOperation_) 

        if self.onSlateMoved_ ~= nil then
            self:onSlateMoved_()
        end
    end

    -- play release slate sound effect
    cc.SimpleAudioEngine:getInstance():playEffect("sound/release.wav")

    -- recover the tunnel's floating status of the slate
    for _, row in pairs(self.slateContainer_) do
        for _, slate in pairs(row) do
            for _, tunnel in pairs(slate:getTunnels()) do
                tunnel.isFloating_ = false
            end
        end
    end

    self:refireTunnelSource()

    return self
end

function GameBox:resetSlateZOrder()
    for r = 1, self:getHeight() do
        for c = 1, self:getWidth() do
            if self.slateContainer_[r][c] then
                self.slateContainer_[r][c]:setLocalZOrder(2^(r + c - 1))
            end
        end
    end
    return self
end

function GameBox:clearOperatingFlag()
    self.isOperating_ = false
    return self
end

function GameBox:clearDraggedFlag()
    self.dragged_ = false
    return self
end

function GameBox:levelClearProc()
    -- if it's already cleared (the method is called before)
    -- it will not be invoked again
    if self.isCleared_ then
        return self
    end

    if self:isLevelCleared() then
        self.isCleared_ = true
        if self.onLevelClear_ then
            self:onLevelClear_()
        end
    end
    return self
end

function GameBox:isConnectedToTerminalSink(slate)
    local sinkConnectedSlate = self.slateContainer_
            [self.tsnk_.r + self.tsnk_.dir.dr + 1]
            [self.tsnk_.c + self.tsnk_.dir.dc + 1]
    if sinkConnectedSlate == slate then
        local sinkConnectedPort = TunnelBase.PAIRED_PORT[self.tsnk_.edge]
        for _, tunnel in pairs(slate:getTunnels()) do
            if tunnel:getPortStatus(sinkConnectedPort) == TunnelBase.SINK then
                return true
            end
        end
    end
    return false
end

function GameBox:getConnectedSlateByTunnelEdge(slate, edge)
    for r = 1, self:getHeight() do
        for c = 1, self:getWidth() do
            if self.slateContainer_[r][c] == slate then
                if edge == TunnelBase.PU then
                    if r == 1 then return nil end
                    return self.slateContainer_[r - 1][c]
                elseif edge == TunnelBase.PD then
                    if r == self:getHeight() then return nil end
                    return self.slateContainer_[r + 1][c]
                elseif edge == TunnelBase.PL then
                    if c == 1 then return nil end
                    return self.slateContainer_[r][c - 1]
                elseif edge == TunnelBase.PR then
                    if c == self:getWidth() then return nil end
                    return self.slateContainer_[r][c + 1]
                end
            end
        end
    end
    return nil 
end

function GameBox:ctor(level)
    GameBox.super.ctor(self)
    printInfo("[GameBox] [ctor] level=%s", level.name)

    self.nameLabel_ = cc.Label:createWithSystemFont(level.name, "Arial", 50)
        :setAnchorPoint(cc.p(0, 0))
        :move(-330, 115)
        :addTo(self, 100)

    self.tsrc_ = level.tsrc
    self.tsnk_ = level.tsnk
    self.tsnk_.status = TunnelBase.DEACTIVATED
    self.puzzle_ = Puzzle(level.origin, level.target, GameBox.DEFAULT_HOLE_MARK)

    self.movingOperation_ = self.puzzle_.NOOP
    self.isOperating_ = false
    self.dragged_ = false
    self.isCleared_ = false
    self.tunnelSteady_ = true
    self.forceToStopAutoReset_ = false
    self.onLevelClear_ = function() end 
    self.onSlateMoved_ = function() end
    self.slateContainer_ = {}
    self.moveRecord_ = {}
    self.moveRecordIndex_ = 0

    self.sourceSprite_ = SourceSprite:create(level.tsrc.edgename)
        :move(level.tsrc.c * SlateSprite.FACE_WIDTH, level.tsrc.r * -SlateSprite.FACE_HEIGHT)
        :addTo(self, 2^(level.tsrc.c + level.tsrc.r + 1))
    self.sinkSprite_ = SinkSprite:create(level.tsnk.edgename)
        :move(level.tsnk.c * SlateSprite.FACE_WIDTH, level.tsnk.r * -SlateSprite.FACE_HEIGHT)
        :addTo(self, 2^(level.tsnk.c + level.tsnk.r + 1))
    
    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:setSwallowTouches(true)
    
    touchListener:registerScriptHandler(function(touch, event)
        printInfo("[GameBox] [onTouchBegan]")
        self.forceToStopAutoReset_ = true
        if self.isOperating_ or self.isCleared_ then
            return false
        end
        
        local target = event:getCurrentTarget()
        printInfo("[GameBox] [onTouchBegan] target=%d z-order=%d", 
            target:getNumber(),
            target:getLocalZOrder())
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local r = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(r, locationInNode) then
            local accept = self:prepareToMove(target)
            if accept then
                cc.SimpleAudioEngine:getInstance():playEffect("sound/pick.wav")
            end
            return accept 
        end
        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    
    touchListener:registerScriptHandler(function(touch, event)
        printInfo("[GameBox] [onTouchMoved]")
        local target = event:getCurrentTarget()
        self.dragged_ = true
        local hole = self.puzzle_.getHolePosition()
        local holePosition = cc.p(hole.c * SlateSprite.FACE_WIDTH,
                                  hole.r * -SlateSprite.FACE_HEIGHT)
        local touchedPosition = self:convertToNodeSpace(touch:getLocation())
        local targetPosition = { x = target:getPositionX(), y = target:getPositionY() }

        -- limit the slate dragging position
        if self.movingOperation_ == self.puzzle_.RIGHT then
            touchedPosition.y = targetPosition.y
            if touchedPosition.x < holePosition.x then
                touchedPosition.x = holePosition.x
            elseif touchedPosition.x > holePosition.x + SlateSprite.FACE_WIDTH then
                touchedPosition.x = holePosition.x + SlateSprite.FACE_WIDTH
            end
        elseif self.movingOperation_ == self.puzzle_.LEFT then
            touchedPosition.y = targetPosition.y
            if touchedPosition.x < holePosition.x - SlateSprite.FACE_WIDTH then
                touchedPosition.x = holePosition.x - SlateSprite.FACE_WIDTH
            elseif touchedPosition.x > holePosition.x then
                touchedPosition.x = holePosition.x 
            end
        elseif self.movingOperation_ == self.puzzle_.UP then
            touchedPosition.x = targetPosition.x
            if touchedPosition.y < holePosition.y then
                touchedPosition.y = holePosition.y
            elseif touchedPosition.y > holePosition.y + SlateSprite.FACE_HEIGHT then
                touchedPosition.y = holePosition.y + SlateSprite.FACE_HEIGHT
            end
        elseif self.movingOperation_ == self.puzzle_.DOWN then
            touchedPosition.x = targetPosition.x
            if touchedPosition.y < holePosition.y - SlateSprite.FACE_HEIGHT then
                touchedPosition.y = holePosition.y - SlateSprite.FACE_HEIGHT
            elseif touchedPosition.y > holePosition.y then
                touchedPosition.y = holePosition.y 
            end
        end
        target:setPosition(touchedPosition)
    end, cc.Handler.EVENT_TOUCH_MOVED)
    
    touchListener:registerScriptHandler(function(touch, event)
        printInfo("[GameBox] [onTouchEnded]")
        local target = event:getCurrentTarget()
        printInfo("[GameBox] [onTouchEnded] targetNumber=%d", target:getNumber()) 

        -- set operating flag to avoid two actions performing at the time
        self.isOperating_ = true

        local moveToHole, moveTo = self:genSlateMotion(target, self.movingOperation_)
        if not moveToHole then
            self.movingOperation_ = self.puzzle_.NOOP
        end
        local updatePuzzle = cc.CallFunc:create(handler(self, self.updatePuzzleState))
        local resetZOrder = cc.CallFunc:create(handler(self, self.resetSlateZOrder))
        local clearOperating = cc.CallFunc:create(handler(self, self.clearOperatingFlag))
        local clearDragging = cc.CallFunc:create(handler(self, self.clearDraggedFlag))
        local levelClear = cc.CallFunc:create(handler(self, self.levelClearProc))

        -- run the anction
        local action = cc.Sequence:create(moveTo, updatePuzzle, resetZOrder, 
            clearOperating, clearDragging, levelClear)
        target:runAction(action)
    end, cc.Handler.EVENT_TOUCH_ENDED)

    for i = 0, self.puzzle_.getHeight() - 1 do
        self.slateContainer_[i + 1] = {}
        for j = 0, self.puzzle_.getWidth() - 1 do
            local puzzleNumber = self.puzzle_.get(i + 1, j + 1) -- index from 1
            if puzzleNumber ~= GameBox.DEFAULT_HOLE_MARK then
                local slate = SlateSprite:create("slate.png", level.tunnelSeq[i + 1][j + 1])
                    :move(j * SlateSprite.FACE_WIDTH, i * -SlateSprite.FACE_HEIGHT)
                    :setNumber(puzzleNumber)
                    :addTo(self, 2^(i + j + 1))
                -- add touch listener for each slate
                self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener:clone(), slate)

                slate:setOnActivatedDelegate(function(_slate, tunnel) 
                    printInfo("[GameBox] [SlateSprite.onActivated] slate=%d", _slate:getNumber())
                    -- trigger the other slates which connected my sink port when i got an activation 
                    for edge, _ in pairs(tunnel:getSinkPorts()) do
                        printInfo("[DEBUG] [GameBox] [SlateSprite.onActivated] slate=%d sinkPort=%d", 
                        _slate:getNumber(), edge)
                        local connnctedSlate = self:getConnectedSlateByTunnelEdge(_slate, edge)
                        if connnctedSlate then
                            for _, connectedTunnel in pairs(connnctedSlate:getTunnels()) do
                                local connectedPort = TunnelBase.PAIRED_PORT[edge]
                                local statusChanged = connectedTunnel:setPortStatus(connectedPort, TunnelBase.SOURCE)
                                self.tunnelSteady_ = not statusChanged
                            end
                        elseif self:isConnectedToTerminalSink(_slate) and self:isAllTunnelsActive() then
                            -- sink will only be activated when all other tunnels are activated
                            -- if it is connected to the tunnel sink of the GameBox
                            self.tsnk_.status = TunnelBase.ACTIVATED
                            self.sinkSprite_:activate()
                            self:levelClearProc()
                        end
                    end
                end)

                slate:setOnDeactivatedDelegate(function(_slate, tunnel) 
                    printInfo("[GameBox] [SlateSprite.onDeactivated] slate=%d", _slate:getNumber())
                    for edge, _ in pairs(tunnel:getSinkPorts()) do
                        printInfo("[DEBUG] [GameBox] [SlateSprite.onDeativated] slate=%d sinkPort=%d", 
                        _slate:getNumber(), edge)
                        local connnctedSlate = self:getConnectedSlateByTunnelEdge(_slate, edge)
                        if connnctedSlate then
                            for _, connectedTunnel in pairs(connnctedSlate:getTunnels()) do
                                local connectedPort = TunnelBase.PAIRED_PORT[edge]
                                local statusChanged = connectedTunnel:setPortStatus(connectedPort, TunnelBase.PASSIVE)
                                self.tunnelSteady_ = not statusChanged
                            end
                        end
                    end
                    for _, p in pairs(tunnel:getAllPorts()) do
                        p.status = TunnelBase.PASSIVE
                        p.label:setString("")
                    end
                    tunnel.status_ = TunnelBase.DEACTIVATED
                end)

                -- store to container
                self.slateContainer_[i + 1][j + 1] = slate
            end
        end
    end

    -- refire
    self:refireTunnelSource()
end

function GameBox:onCreate() 
    printInfo("[GameBox] [onCreate]")
end

function GameBox:getSlateByNumber(number)
    for _, row in pairs(self.slateContainer_) do
        for _, slate in pairs(row) do
            if slate and slate:getNumber() == number then
                return slate
            end
        end
    end
    return nil
end

function GameBox:nextMoveOperation()
    self.moveRecordIndex_ = self.moveRecordIndex_ + 1
    local dir = self.moveRecord_[self.moveRecordIndex_]
    if dir == self.puzzle_.NOOP or self.isCleared_ or self.forceToStopAutoReset_ then
        self.isOperating_ = false
        return self
    end

    self.isOperating_ = true
    local number = self.puzzle_.getTagCloseToHole(dir)
    local slate = self:getSlateByNumber(number)
    assert(slate ~= nil, "there must be a slate to the given direction of the hole")

    self:prepareToMove(slate)
    local hole = self.puzzle_.getHolePosition()
    local moveToPos = cc.p(hole.c * SlateSprite.FACE_WIDTH,
                           hole.r * -SlateSprite.FACE_HEIGHT)
    local moveTo = cc.MoveTo:create(0.4, moveToPos)
    local updatePuzzle = cc.CallFunc:create(handler(self, self.updatePuzzleState))
    local resetZOrder = cc.CallFunc:create(handler(self, self.resetSlateZOrder))
    local levelClear = cc.CallFunc:create(handler(self, self.levelClearProc))
    local doNextMove = cc.CallFunc:create(handler(self, self.nextMoveOperation))
    local action = cc.Sequence:create(moveTo, updatePuzzle, resetZOrder, levelClear, doNextMove)
    slate:runAction(action)
end

function GameBox:autoResetSlates()
    if self.isOperating_ then
        return self
    end

    self.forceToStopAutoReset_ = false
    self.moveRecordIndex_ = 0
    self.moveRecord_ = self.puzzle_.solve()
    self:nextMoveOperation()
    return self
end


return GameBox

