
local CLandUnit = import('/lua/defaultunits.lua').MobileUnit
local CAABurstCloudFlakArtilleryWeapon = import('/lua/cybranweapons.lua').CAABurstCloudFlakArtilleryWeapon

URL0205 = Class(CLandUnit) {
    DestructionPartsLowToss = {'Turret',},

    Weapons = {
        AAGun = Class(CAABurstCloudFlakArtilleryWeapon) {},
    },
}

TypeClass = URL0205