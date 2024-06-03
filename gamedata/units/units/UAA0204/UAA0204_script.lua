local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon


UAA0204 = Class(AAirUnit) {

    Weapons = {
        Torpedo = Class(AANChronoTorpedoWeapon) { FxMuzzleFlash = false },
    },
}

TypeClass = UAA0204