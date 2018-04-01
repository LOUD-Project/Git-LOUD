

local SIFHuAntiNuke = import('/lua/seraphimprojectiles.lua').SIFKhuAntiNukeTendril
SIFHuAntiNuke02 = Class(SIFHuAntiNuke) {

    OnCreate = function(self)
        SIFHuAntiNuke.OnCreate(self)
    end,
}
TypeClass = SIFHuAntiNuke02

