local CAirUnit = import('/lua/defaultunits.lua').AirUnit
local CIFBombNeutronWeapon = import('/lua/cybranweapons.lua').CIFBombNeutronWeapon

URA0103 = Class(CAirUnit) {
    Weapons = {
        Bomb = Class(CIFBombNeutronWeapon) {},
    },

    ExhaustBones = {'Exhaust_L','Exhaust_R',},
    ContrailBones = {'Contrail_L','Contrail_R',},
}

TypeClass = URA0103