local CSubUnit =  import('/lua/defaultunits.lua').SubUnit

local CybranWeapons = import('/lua/cybranweapons.lua')

local CIFMissileLoaWeapon       = CybranWeapons.CIFMissileLoaWeapon
local CIFMissileStrategicWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CANTorpedoLauncherWeapon  = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

CybranWeapons = nil

URS0304 = Class(CSubUnit) {

    Weapons = {
        NukeMissile = Class(CIFMissileStrategicWeapon){},
        CruiseMissile = Class(CIFMissileLoaWeapon){},
        Torpedo = Class(CANTorpedoLauncherWeapon){},
    },

}

TypeClass = URS0304

