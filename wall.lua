local mc = require("multicraft")
local robot = require("robot")
print("loaded lib")
while true do
    while mc.craftCompactWall(5) do end
    print("failed to craft, sleeping for 10 seconds")
    for i=1,16 do
        robot.select(i)
        robot.drop()
    end
    os.sleep(10)
end