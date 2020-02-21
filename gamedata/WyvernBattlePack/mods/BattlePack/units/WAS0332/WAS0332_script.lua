local AeonWeapons = import('/lua/aeonweapons.lua')

local ASeaUnit = import('/lua/aeonunits.lua').ASeaUnit

local AAAZealotMissileWeapon = AeonWeapons.AAAZealotMissileWeapon
local ADFCannonQuantumWeapon = AeonWeapons.ADFCannonQuantumWeapon

WAS0332 = Class(ASeaUnit) {
    Weapons = {
        MainGun = Class(ADFCannonQuantumWeapon) {},

        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},
    },

    BackWakeEffect = {},
}

TypeClass = WAS0332