local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TWeapons = import('/lua/terranweapons.lua')

local TAAGinsuRapidPulseWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local TIFCruiseMissileLauncher = TWeapons.TIFCruiseMissileLauncher

TWeapons = nil

SEA0212 = Class(TAirUnit) {
    Weapons = {
        AutoCannon = Class(TAAGinsuRapidPulseWeapon) {},
        Missile = Class(TIFCruiseMissileLauncher) {},
    },
}

TypeClass = SEA0212
