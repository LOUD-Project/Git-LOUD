local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')

local AAAZealotMissileWeapon    = AeonWeapons.AAAZealotMissileWeapon
local ADFCannonQuantumWeapon    = AeonWeapons.ADFCannonQuantumWeapon
local AAMWillOWisp              = AeonWeapons.AAMWillOWisp

AeonWeapons = nil

UAS0202 = Class(ASeaUnit) {
    Weapons = {
        FrontTurret         = Class(ADFCannonQuantumWeapon) {},
        AntiAirMissiles01   = Class(AAAZealotMissileWeapon) {},
        AntiAirMissiles02   = Class(AAAZealotMissileWeapon) {},
        AntiMissile         = Class(AAMWillOWisp) {},
    },

}

TypeClass = UAS0202