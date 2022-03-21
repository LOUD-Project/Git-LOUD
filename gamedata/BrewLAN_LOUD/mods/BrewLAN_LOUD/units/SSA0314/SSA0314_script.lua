local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local MissileFlare = import('/lua/defaultunits.lua').BaseDirectionalAntiMissileFlare

local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SIFBombZhanaseeWeapon = SeraphimWeapons.SIFBombZhanaseeWeapon
local SLaanseMissileWeapon = SeraphimWeapons.SLaanseMissileWeapon
local SANHeavyCavitationTorpedo = SeraphimWeapons.SANHeavyCavitationTorpedo

SSA0314 = Class(SAirUnit, MissileFlare) {

    Weapons = {
        Bomb = Class(SIFBombZhanaseeWeapon) {},
        Torpedo = Class(SANHeavyCavitationTorpedo) {},
        CruiseMissile = Class(SLaanseMissileWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        SAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetScriptBit('RULEUTC_StealthToggle', true)
        self:CreateMissileDetector()
    end,

    FlareBones = {'Ring_C'},
}

TypeClass = SSA0314
