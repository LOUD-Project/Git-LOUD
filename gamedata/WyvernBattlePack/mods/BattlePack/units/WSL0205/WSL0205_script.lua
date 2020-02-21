local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SDFOhCannon = import('/lua/seraphimweapons.lua').SDFOhCannon

WSL0205 = Class(SWalkingLandUnit) {
    Weapons = {
        MainGun = Class(SDFOhCannon) {},
    },
}
TypeClass = WSL0205