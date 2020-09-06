local unitName = "BSS0401"

local file = io.open ("BSS0401_unit.bp", "r+")

io.input(file)

local curLine = io.read()
while not string.find(curLine,"MaxSpeed") do
    curLine = io.read()
end
--print(curLine)

unitSpeed = string.match(curLine, "[0-9.]+")
--print(unitSpeed)



io.close(file)



--Blueprints = require("Blueprints")

--dofile("Blueprints.lua")

--Blueprints.loadBlueprints()

AI = {
    AttackAngle = 60,
    GuardReturnRadius = 60,
    InitialAutoMode = true,
    TargetBones = {
        'XSS0401',
        'Left_AA_Turret01',
        'Front_Turret01',
        'TMD_Turret',
    },
}

print(AI.AttackAngle)
--bob = dofile("BSS0401_unit.bp")

--print(bob.BuildIconSortPriority)
