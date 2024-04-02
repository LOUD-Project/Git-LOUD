local TSubUnit =  import('/lua/defaultunits.lua').SubUnit

local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler
local TDFLightPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFLightPlasmaCannonWeapon

UES0203 = Class(TSubUnit) {

    Weapons = {
        Torpedo = Class(TANTorpedoAngler) {},
        PlasmaGun = Class(TDFLightPlasmaCannonWeapon) {}
    },
	
}


TypeClass = UES0203