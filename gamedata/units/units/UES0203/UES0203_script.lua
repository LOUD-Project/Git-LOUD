local TSubUnit = import('/lua/terranunits.lua').TSubUnit
local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler
local TDFLightPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFLightPlasmaCannonWeapon

UES0203 = Class(TSubUnit) {

    PlayDestructionEffects = true,

    Weapons = {
        Torpedo = Class(TANTorpedoAngler) {},
        PlasmaGun = Class(TDFLightPlasmaCannonWeapon) {}
    },
	
}


TypeClass = UES0203