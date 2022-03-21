local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CDFProtonCannonWeapon = import('/lua/cybranweapons.lua').CDFProtonCannonWeapon
       
SRB2311 = Class(CStructureUnit) {
    Weapons = {
        FrontCannon01 = Class(CDFProtonCannonWeapon) {},
    },
}
TypeClass = SRB2311
