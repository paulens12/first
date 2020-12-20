local mc = require("multicraft")
local robot = require("robot")
print("loaded lib")
while true do
    while mc.craftEnderPearl() do end
    print("missing items, sleeping for 10 seconds")
    for i=1,16 do
        robot.select(i)
        robot.drop()
    end
    os.sleep(10)
end