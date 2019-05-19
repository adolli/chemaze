
local function isNan(v)
    return v ~= v
end

math.cbrt = function(x)
    local ret = 0
    if x < 0 then
        ret = -((-x)^(1/3))
    else
        ret = x^(1/3)
    end
    return ret
end



local function newPuzzle(m,n,initialPuzzle)
    if (m*n)~=#initialPuzzle then return end

    local self={puzzle=initialPuzzle,sizeM=m,sizeN=n}

    local getNumbers=function ()
        local puzzleCopy={}
        for i,v in ipairs(self.puzzle) do
            puzzleCopy[i]=v
        end
        return puzzleCopy
    end

    local getM=function ()
        local localM=self.sizeM;
        return localM
    end

    local getN=function ()
        local localN=self.sizeN;
        return localN
    end

    local moveNumber=function (position,direction)
        if self.puzzle[position] and self.puzzle[position]>0 then
            local x=math.floor((position-1 )%m)
            local y=math.floor((position-1 )/m)

            local moveSteps={{0,-1},{1,0},{0,1},{-1,0}}
            local newX=x+moveSteps[direction][1]
            local newY=y+moveSteps[direction][2]

            if newX>= 0 and newX<m and newY>=0 and newY<n then
                local newPos=newY*m+newX+1
                if self.puzzle[newPos]==0 then
                    self.puzzle[newPos],self.puzzle[position] = self.puzzle[position],self.puzzle[newPos]
                end
            end
        end
    end


    return{
        getM=getM,
        getN=getN,
        getNumbers=getNumbers,
        moveNumber=moveNumber
    }
end


local tableClone2D = function(dst, src)
    for i = 1, #src do
        dst[i] = {}
        for j = 1, #src[i] do
            dst[i][j] = src[i][j]
        end
    end
end

local function printMaze(maze)
    io.write("------------------")
    print()
    for i = 1, #maze do
        for j = 1, #maze[i] do
            io.write(string.format("%d ", maze[i][j]))
        end
        print()
    end
end

math.fuck_mod = function(n, d)
    if n <= 0 then
        return -((-n) % d)
    else
        return n % d
    end
end

cc = cc or {}
cc.exports = cc.exports or {}

local IDAStar = function(state_s, state_t, HOLE_MARK)

    -- default parameters
    HOLE_MARK = HOLE_MARK or 0 

    -- constants
    local MOVE_UP = { r = -1, c = 0 }
    local MOVE_DOWN = { r = 1, c = 0 }
    local MOVE_LEFT = { r = 0, c = -1 }
    local MOVE_RIGHT = { r = 0, c = 1 }
    local MOVE_ACTION = { MOVE_UP, MOVE_LEFT, MOVE_DOWN, MOVE_RIGHT }
    local UP, DOWN, LEFT, RIGHT = 0, 2, 1, 3
    local NOOP = -1
    



    -- data member
    local width_ = #state_s[1]
    local height_ = #state_s
    local targetList_ = {}
    local estimateSteps_ = 0
    local totalSteps_ = 0 
    local moveRecord_ = { NOOP, NOOP }

    local state_ = {} 
    tableClone2D(state_, state_s)

    local hole = { r = 0, c = 0 }


    -- private member functions
    local calcManhattonDistance = function()
        for i = 1, #state_ do
            for j = 1, #state_[i] do
                if state_[i][j] ~= HOLE_MARK then
                    local targetCoord = targetList_[state_[i][j]]
                    estimateSteps_ = estimateSteps_ + math.abs(targetCoord.r - i) + math.abs(targetCoord.c - j)
                end
            end
        end
    end

    -- init
    for i = 1, #state_ do
        for j = 1, #state_[i] do
            if state_[i][j] == HOLE_MARK then
                hole.r, hole.c = i, j
            end
            targetList_[state_t[i][j]] = { r = i, c = j }
        end
    end

    -- private static functions
    local getInversions = function(_state)
        local tbl = {}
        for i = 1, #_state do
            for j = 1, #_state[i] do
                table.insert(tbl, _state[i][j])
            end
        end
        local coverPairCount = 0
        for i = 1, #tbl do
            for j = 2, #tbl do
                if tbl[i] > tbl[j] then
                    coverPairCount = coverPairCount + 1;
                end
            end
        end
        return coverPairCount
    end

    -- members
    local solvable = function()
        if #state_ % 2 == 1 then
            return getInversions(state_) % 2 == 0
        else
            if (#state_ - hole.r) % 2 == 1 then
                return getInversions(state_) % 2 == 0
            else
                return getInversions(state_) % 2 == 1
            end
        end
    end

    cc.exports.solveImpl = function(_state, _hole, depth, direction, estimate)
        --print(estimateSteps_, estimate, depth, direction)
        local solved = true
        for i = 1, #_state do
            for j = 1, #_state do
                if _state[i][j] ~= state_t[i][j] then
                    solved = false
                    break
                end
            end
            if not solved then
                break
            end
        end
        if solved then
            return true
        end

        local hole1 = { r = _hole.r, c = _hole.c }
        local state1 = {}
        for dir = 0, 3 do
            --io.write(string.format("dir=%d  direction=%d\n", dir % 2, math.mod(direction, 2)))
            tableClone2D(state1, _state)
            if dir == direction or
                (math.fuck_mod(dir, 2) ~= math.fuck_mod(direction, 2))
            then
                hole1.r = _hole.r + MOVE_ACTION[dir + 1].r
                hole1.c = _hole.c + MOVE_ACTION[dir + 1].c

                if hole1.r >= 1 and hole1.c >= 1 and hole1.r <= #_state and hole1.c <= #_state[hole1.r] then
                    state1[_hole.r][_hole.c] = state1[hole1.r][hole1.c]
                    state1[hole1.r][hole1.c] = HOLE_MARK

                    local estimate1
                    local movedValue = _state[hole1.r][hole1.c]
                    if dir == DOWN  and hole1.r > targetList_[movedValue].r or
                       dir == UP    and hole1.r < targetList_[movedValue].r or
                       dir == RIGHT and hole1.c > targetList_[movedValue].c or
                       dir == LEFT  and hole1.c < targetList_[movedValue].c then
                        estimate1 = estimate - 1
                    else
                        estimate1 = estimate + 1
                    end

                    -- reduce the branch
                    --io.write(string.format("h1=%d  d=%d  hx=%d  dir=%d",
                    --  estimate1, depth, estimateSteps_, dir))
                    --print()
                    if estimate1 + depth + 1 <= estimateSteps_ then
                        moveRecord_[depth + 1] = dir
                        moveRecord_[depth + 2] = -1 -- terminator

                        -- iteration
                        if cc.exports.solveImpl(state1, hole1, depth + 1, dir, estimate1) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    local solve = function()
        local firstIncrease = 10
        local nextIncease = 5
        calcManhattonDistance()
        estimateSteps_ = estimateSteps_ + firstIncrease
        local initSteps = estimateSteps_
        moveRecord_[1] = NOOP
        while not solveImpl(state_, hole, 0, NOOP, initSteps) do
            estimateSteps_ = estimateSteps_ + nextIncease
        end
        return moveRecord_
    end

    local getEstimateSteps = function()
        return estimateSteps_
    end

    local increaseEstimateStepsBy = function(step)
        estimateSteps_ = estimateSteps_ + step
    end

    local move = function(dir)
        if dir == UP then
            if hole.r == 1 then return end
            state_[hole.r][hole.c] = state_[hole.r - 1][hole.c]
            state_[hole.r - 1][hole.c] = HOLE_MARK
            hole.r = hole.r - 1
            totalSteps_ = totalSteps_ + 1
        elseif dir == DOWN then
            if hole.r == height_ then return end
            state_[hole.r][hole.c] = state_[hole.r + 1][hole.c]
            state_[hole.r + 1][hole.c] = HOLE_MARK
            hole.r = hole.r + 1
            totalSteps_ = totalSteps_ + 1
        elseif dir == LEFT then
            if hole.c == 1 then return end
            state_[hole.r][hole.c] = state_[hole.r][hole.c - 1]
            state_[hole.r][hole.c - 1] = HOLE_MARK
            hole.c = hole.c - 1
            totalSteps_ = totalSteps_ + 1
        elseif dir == RIGHT then
            if hole.c == width_ then return end
            state_[hole.r][hole.c] = state_[hole.r][hole.c + 1]
            state_[hole.r][hole.c + 1] = HOLE_MARK
            hole.c = hole.c + 1
            totalSteps_ = totalSteps_ + 1
        end
        
        printMaze(state_);
    end

    local getTotalSteps = function()
        local ret = totalSteps_
        return ret
    end
    local resetTotalSteps = function()
        totalSteps_ = 0
    end

    local get = function(r, c)
        return state_[r][c]
    end
    local getHeight = function()
        local ret = height_
        return ret
    end
    local getWidth = function()
        local ret = width_
        return ret
    end

    local getTagCloseToHole = function(dir)
        local ret = -1
        if dir == UP and hole.r ~= 1 then
            ret = state_[hole.r - 1][hole.c]
        elseif dir == DOWN and hole.r ~= height_ then
            ret = state_[hole.r + 1][hole.c]
        elseif dir == LEFT and hole.c ~= 1 then
            ret = state_[hole.r][hole.c - 1]
        elseif dir == RIGHT and hole.c ~= width_ then
            ret = state_[hole.r][hole.c + 1]
        end
        return ret
    end

    -- NOTICE: position index from 0 to N
    local getPositionOf = function(val)
        for r = 1, height_ do
            for c = 1, width_ do
                if state_[r][c] == val then
                    return { r = r - 1, c = c - 1 }
                end
            end
        end
        return { r = 0, c = 0 }
    end

    -- NOTICE: position index from 0 to N
    local getHolePosition = function()
        local pos = { r = hole.r - 1, c = hole.c - 1 }
        return pos
    end

    local isSolved = function()
        for r = 1, height_ do
            for c = 1, width_ do
                if state_[r][c] ~= state_t[r][c] then
                    return false
                end
            end
        end
        return true
    end

    return {
        solve = solve,
        isSolved = isSolved,
        move = move,

        getTagCloseToHole = getTagCloseToHole,
        getPositionOf = getPositionOf,
        getHolePosition = getHolePosition,
        getTotalSteps = getTotalSteps,
        resetTotalSteps = resetTotalSteps,
        get = get,
        getHeight = getHeight,
        getWidth = getWidth,

        HOLE_MARK = HOLE_MARK,
        UP = UP, DOWN = DOWN, LEFT = LEFT, RIGHT = RIGHT, NOOP = NOOP
    }

end






--自动复原的执行逻辑在将通过调用此函数实现，无需返回；
local function p4_SlidePuzzle(p)
    -- target state
    local state_t = {
        { 1, 2, 3 },
        { 4, 5, 6 },
        { 7, 8, 0 }
    }

    -- initial state
    local state_s = {}

    for i = 1, p.getN() do
        --state_t[i] = {}
        state_s[i] = {}
        for j = 1, p.getM() do
            --state_t[i][j] = (i - 1) * p.getM() + j
            local tmp = p.getNumbers()[(i - 1) * p.getM() + j]
            state_s[i][j] = tmp
        end
    end
    --state_t[p.getN()][p.getM()] = 0

    local solver = IDAStar(state_s, state_t)
    --printMaze(state_s)

    --local firstIncrease = 0 
    --local nextIncease = 1
    --solver.calcManhattonDistance()
    --solver.increaseEstimateStepsBy(firstIncrease)
    --local initSteps = solver.getEstimateSteps()
    --print("estimate steps", solver.getEstimateSteps())
    --while true do
    --    if solver.solveImpl(state_s, solver.hole, 0, -1, initSteps) then
    --        break
    --    end
    --    solver.increaseEstimateStepsBy(nextIncease)
    --end
    local moveRecord = solver.solve()
    --local moveRecord2 = solver2.solve()

    for _, v in pairs(moveRecord) do
        if v == solver.NOOP then
            break
        end
        solver.move(v)
    end
    print("total steps", solver.getTotalSteps())

    solver.move(solver.LEFT)
    solver.move(solver.UP)
    moveRecord = solver.solve()
    for _, v in pairs(moveRecord) do
        if v == solver.NOOP then
            break
        end
        solver.move(v)
    end
    print("total steps", solver.getTotalSteps())
    
    --local alterDirection = { 3, 2, 1, 4 }
    --for i = 1, solver.getEstimateSteps() do
    --    if solver.moveRecord[i] == -1 then
    --        break
    --    end
    --    solver.move(state_s, solver.moveRecord[i])

        -- alternate direction
    --    if solver.moveRecord[i] == solver.UP then
    --        initHole.r = initHole.r - 1
    --    elseif solver.moveRecord[i] == solver.DOWN then
    --        initHole.r = initHole.r + 1
    --    elseif solver.moveRecord[i] == solver.LEFT then
    --        initHole.c = initHole.c - 1
    --    elseif solver.moveRecord[i] == solver.RIGHT then
    --        initHole.c = initHole.c + 1
    --    end
    --    p.moveNumber((initHole.r - 1) * p.getM() + initHole.c, alterDirection[solver.moveRecord[i]+1])

    --    printMaze(state_s)
    --end

end

--样例执行例子，与后台判题逻辑类似，请确保能跑通此基本用例才提交代码
local function testSample(m,n,t)
    local p1=newPuzzle(m,n,t)
    p4_SlidePuzzle(p1)
    local resStr="";
    local finalT=p1.getNumbers()
    for i,v in ipairs(finalT) do
        resStr=resStr .. v
    end
    return resStr

end

--print (testSample(3, 3, {0, 1, 2, 3, 4, 5, 6, 7, 8}))
--print (testSample(3,3,{1,2,3,4,5,6,7,8,0}))
--print (testSample(3,3,{1,2,3,4,5,6,0,7,8})) --提交前注意注释掉所有的输出操作
--print (testSample(3,3,{0,1,2,8,4,5,3,6,7})) --提交前注意注释掉所有的输出操作
--print (testSample(3,3,{8, 7, 6, 5, 4, 3, 2, 1, 0}))
--print (testSample(4,4,{2, 1, 3, 7, 13, 4, 11, 9, 0, 12, 10, 6, 14, 15, 8, 5}))
--print (os.clock())

--newstate = newPuzzle(3, 3, {1,2,3,4,5,6,7,0,8})
--newstate = newPuzzle(3, 3, {8, 7, 6, 5, 4, 3, 2, 1, 0})
--newstate = newPuzzle(4, 4, {2, 1, 3, 7, 13, 4, 11, 9, 0, 12, 10, 6, 14, 15, 8, 5})
--p4_SlidePuzzle(newstate)


local Puzzle = IDAStar
return Puzzle

