
local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

XEL0308 = Class(TLandUnit) {
    Weapons = {
	
        MissileRack01 = Class(TSAMLauncher) {},

        MainGun = Class(TDFGaussCannonWeapon) {}
    },
}
TypeClass = XEL0308