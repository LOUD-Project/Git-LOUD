local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AAAAutocannonQuantumWeapon = import('/lua/aeonweapons.lua').AAAAutocannonMissileWeapon

XAA0202 = Class(AAirUnit) {
    Weapons = {
        AutoCannon1 = AAAAutocannonQuantumWeapon,
    },
}

TypeClass = XAA0202