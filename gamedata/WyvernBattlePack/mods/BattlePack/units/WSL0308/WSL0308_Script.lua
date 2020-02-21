local SLandUnit = import('/lua/seraphimunits.lua').SLandUnit

local WeaponsFile = import('/lua/seraphimweapons.lua')
local SDFThauCannon = WeaponsFile.SDFThauCannon


WSL0308 = Class(SLandUnit) {
    Weapons = {
        MainTurret = Class(SDFThauCannon) {},
    },
}
TypeClass = WSL0308