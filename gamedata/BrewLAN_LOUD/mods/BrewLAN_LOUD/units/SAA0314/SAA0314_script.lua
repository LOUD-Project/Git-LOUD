local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local MissileFlare = import('/lua/defaultunits.lua').BaseDirectionalAntiMissileFlare

local AeonWeapons = import('/lua/aeonweapons.lua')

local AIFBombQuarkWeapon    = AeonWeapons.AIFBombQuarkWeapon
local ACruiseMissileWeapon  = AeonWeapons.ACruiseMissileWeapon
local ClusterTorpedo        = AeonWeapons.AANChronoTorpedoWeapon

AeonWeapons = nil


SAA0314 = Class(AAirUnit, MissileFlare) {

    Weapons = {

        Bomb = Class(AIFBombQuarkWeapon) {

            -- hooking the bomb firing in the hope of someday diverting
            -- the bomber immediately upon firing rather than breaking off
            -- only after having overflown the target
            OnWeaponFired = function(self)
            
                AIFBombQuarkWeapon.OnWeaponFired(self)

            end,
        
        },

        CruiseMissile = Class(ACruiseMissileWeapon) {},

        ClusterTorpedo = Class(ClusterTorpedo) { FxMuzzleFlash = false },
    },

    OnStopBeingBuilt = function(self,builder,layer)

        AAirUnit.OnStopBeingBuilt(self,builder,layer)

        self:SetScriptBit('RULEUTC_StealthToggle', true)
        self:CreateMissileDetector()
    end,

    FlareBones = {'Diamond'},
}

TypeClass = SAA0314
