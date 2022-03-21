local AeonWeapons = import('/lua/aeonweapons.lua')

local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AAAZealotMissileWeapon = AeonWeapons.AAAZealotMissileWeapon
local ADFCannonQuantumWeapon = AeonWeapons.ADFCannonQuantumWeapon
local AAMWillOWisp = AeonWeapons.AAMWillOWisp

UAS0202 = Class(ASeaUnit) {
    Weapons = {
        FrontTurret = Class(ADFCannonQuantumWeapon) {},
        AntiAirMissiles01 = Class(AAAZealotMissileWeapon) {},
        AntiAirMissiles02 = Class(AAAZealotMissileWeapon) {},
        AntiMissile = Class(AAMWillOWisp) {},
    },

    BackWakeEffect = {},
}

TypeClass = UAS0202