local AeonWeapons = import('/lua/aeonweapons.lua')

local ASeaUnit = import('/lua/defaultunits.lua').SeaUnit

local AA = AeonWeapons.AAAZealotMissileWeapon
local Cannon = AeonWeapons.ADFCannonQuantumWeapon

AeonWeapons = nil

WAS0332 = Class(ASeaUnit) {
    Weapons = {
        MainGun         = Class(Cannon) {},
        AntiAirMissiles = Class(AA) {},
    },

}

TypeClass = WAS0332