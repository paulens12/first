local robot = require("robot")
local component = require("component")
local sides = require("sides")
local term = require("term")
local inv = component.inventory_controller
local craft = component.crafting.craft
local serialization = require("serialization")

local multicraft = {}

local function takeItemsInternal(itemName, amount, side)
    local remaining = amount
    for i=1,inv.getInventorySize(side) do
        if remaining == 0 then return true end
        -- term.write("check slot " .. i .. "\n")
        local stack = inv.getStackInSlot(side, i)
        if stack ~= nil and stack.name == itemName then
            if stack.size > remaining then
                inv.suckFromSlot(side, i, remaining)
                term.write("taking " .. remaining .. " remaining items from slot " .. i .. "\n")
                return true
            else
                inv.suckFromSlot(side, i, stack.size)
                remaining = remaining - stack.size
                term.write("taking " .. stack.size .. " items from slot " .. i .. "\n")
            end
        end
    end
    term.write("not enough items of type " .. itemName .. "\n")
    return false
end

local function takeItems(itemName, amount, slot, side)
    local beforeSelection = robot.select()
    robot.select(slot)
    -- waitForInventory(side, itemName, amount)
    local ret = takeItemsInternal(itemName, amount, side)
    robot.select(beforeSelection)
    return ret
end

local function walkToGrid()
    robot.turnRight()
    robot.forward()
    robot.forward()
    robot.turnLeft()
    robot.forward()
    robot.forward()
end

local function walkToStart()
    robot.back()
    robot.back()
    robot.turnLeft()
    robot.forward()
    robot.forward()
    robot.turnRight()
end

local function putLayer(size, matrix)
    for i=1,size do
        -- put one line
        for j=2,size do robot.forward() end
        for j=1,size do
            -- put one block
            -- term.write(matrix[i][j] .. "\n")
            if matrix[i][j] ~= 0 then
                robot.select(matrix[i][j])
                robot.place()
            end
            -- move
            if j ~= size then robot.back() end
        end
        -- move to start of next row
        if i ~= size then
            robot.turnRight()
            robot.forward()
            robot.turnLeft()
        end
    end
    robot.turnLeft()
    for i=2,size do robot.forward() end
    robot.turnRight()
end

local function dumpSlot(slot, side)
    robot.select(slot)
    robot.drop()
    
    local localStack = inv.getStackInInternalSlot(slot)
    if localStack ~= nil then
        term.write("not enough space in inventory!")
        return false
    end
    return true
end

local function craftMultiblock(size, matrix, dropIndex, suckIndex, duration)
    walkToGrid()
    for i=1,size do
        putLayer(size, matrix[i])
        robot.up()
    end
    robot.up()
    robot.select(dropIndex)
    robot.drop(1)
    for i=0,size do robot.down() end

    term.write("sleeping for " .. duration .. " seconds\n")
    os.sleep(duration)
    term.write("sleep done\n")

    robot.turnRight()
    for i=1, (size - 1) / 2 do robot.forward() end
    robot.turnLeft()
    for i=1, (size - 1) / 2 do robot.forward() end
    robot.select(suckIndex)
    robot.suck()
    for i=1, (size - 1) / 2 do robot.back() end
    robot.turnLeft()
    for i=1, (size - 1) / 2 do robot.forward() end
    robot.turnRight()

    walkToStart()
end

function multicraft.craftEnderPearl()
    local matrix = {
        {{13, 13, 13}, {13, 13, 13}, {13, 13, 13}},
        {{13, 13, 13}, {13, 15, 13}, {13, 13, 13}},
        {{13, 13, 13}, {13, 13, 13}, {13, 13, 13}}
    }
    term.write("initialized matrix")
    if takeItems("minecraft:obsidian", 26, 13, sides.front) == false then return end
    if takeItems("minecraft:redstone", 10, 14, sides.front) == false then return end
    robot.select(14)
    for i=0,2 do
        for j=1,3 do
            local slot = i * 4 + j
            robot.transferTo(slot, 1)
        end
    end
    robot.select(15)
    craft(1)
    
    craftMultiblock(3, matrix, 14, 4, 12)
    return dumpSlot(4)
end

local function invHasAmount(side, itemName, amount)
    local remaining = amount
    term.write("checking if inventory has enough items\n")
    for i=1, inv.getInventorySize(side) do
        if remaining == 0 then return true end
        local stack = inv.getStackInSlot(side, i)
        if stack ~= nil and stack.name == itemName then
            if stack.size > remaining then
                term.write(stack.size .. "\n")
                return true
            else
                remaining = remaining - stack.size
            end
        end
    end
    return false
end

local function waitForInventory(side, itemName, amount)
    term.write("Waiting for " .. amount .. "x " .. itemName)
    while invHasAmount(side, itemName, amount) == false do os.sleep(1) end
end

return multicraft