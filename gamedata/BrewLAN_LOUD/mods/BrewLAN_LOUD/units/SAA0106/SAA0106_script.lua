local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

SAA0106 = Class(AAirUnit) {

    Weapons = {
        Torpedo = Class(AANChronoTorpedoWeapon) { FxMuzzleFlash = false },
    },
}

TypeClass = SAA0106
