local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TIFCruiseMissileUnpackingLauncher = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UEL0111 = Class(TLandUnit) {
    Weapons = {
        MissileWeapon = Class(TIFCruiseMissileUnpackingLauncher){ FxMuzzleFlash = {'/effects/emitters/terran_mobile_missile_launch_01_emit.bp'} },
    },
}

TypeClass = UEL0111