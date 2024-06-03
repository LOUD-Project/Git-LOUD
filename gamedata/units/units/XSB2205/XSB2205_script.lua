local Torpedo = import('/lua/seraphimweapons.lua').SANAnaitTorpedo

XSB2205 = Class(import('/lua/seraphimunits.lua').SStructureUnit) {

    Weapons = {
        TorpedoTurret = Class(Torpedo) {},
        AntiTorpedo = Class(import('/lua/seraphimweapons.lua').SDFAjelluAntiTorpedoDefense) {},
    },
	
}

TypeClass = XSB2205