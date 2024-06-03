local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CAABurstCloudFlakArtilleryWeapon = import('/lua/cybranweapons.lua').CAABurstCloudFlakArtilleryWeapon

URB2204 = Class(CStructureUnit) {
    Weapons = {
        AAGun = Class(CAABurstCloudFlakArtilleryWeapon) {},
    },
}

TypeClass = URB2204