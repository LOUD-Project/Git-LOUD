local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TerranWeaponFile = import('/lua/terranweapons.lua')

local TDFHeavyPlasmaCannonWeapon = TerranWeaponFile.TDFHeavyPlasmaCannonWeapon
--local TSAMLauncher = TerranWeaponFile.TSAMLauncher

UEL0303 = Class(TWalkingLandUnit) {

    Weapons = {
        HeavyPlasma01 = Class(TDFHeavyPlasmaCannonWeapon) {
            DisabledFiringBones = {
                'Torso', 'ArmR_B02', 'Barrel_R', 'ArmR_B03', 'ArmR_B04',
                'ArmL_B02', 'Barrel_L', 'ArmL_B03', 'ArmL_B04',
            },
        },
        --AntiAirMissiles = Class(TSAMLauncher) {},
    },

    OnShieldIsUp = function (self)
        self:SetCanTakeDamage(false)
    end,

    OnShieldIsDown = function (self)
        self:SetCanTakeDamage(true) 
    end,    
}

TypeClass = UEL0303