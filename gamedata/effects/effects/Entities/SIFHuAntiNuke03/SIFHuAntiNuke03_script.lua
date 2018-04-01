

local SIFHuAntiNuke = import('/lua/seraphimprojectiles.lua').SIFKhuAntiNukeSmallTendril
SIFHuAntiNuke03 = Class(SIFHuAntiNuke) {

    OnCreate = function(self)
        SIFHuAntiNuke.OnCreate(self)
    end,
}
TypeClass = SIFHuAntiNuke03

