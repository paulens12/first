local mc = require("multicraft")
while true do
    while mc.craftEnderPearl do end
    for i=1,16 do
        robot.select(i)
        robot.drop()
    end
    os.sleep(10)
end