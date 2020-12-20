local robot = require("robot")
local component = require("component")
local sides = require("sides")
local term = require("term")
local inv = component.inventory_controller
local craft = component.crafting.craft

local stack = inv.getStackInInternalSlot(1)
print(stack.name)