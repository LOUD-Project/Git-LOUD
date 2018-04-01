
local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local CAABurstCloudFlakArtilleryWeapon = import('/lua/cybranweapons.lua').CAABurstCloudFlakArtilleryWeapon

URB3304 = Class(CStructureUnit) {
    Weapons = {
        AAGun = Class(CAABurstCloudFlakArtilleryWeapon) {},
    },
}

TypeClass = URB3304