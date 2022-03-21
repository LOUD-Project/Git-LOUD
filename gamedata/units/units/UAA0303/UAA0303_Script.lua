local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AAAAutocannonQuantumWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UAA0303 = Class(AAirUnit) {
    Weapons = {
        AutoCannon1 = Class(AAAAutocannonQuantumWeapon) {},
    },
}

TypeClass = UAA0303