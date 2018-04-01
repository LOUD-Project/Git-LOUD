local TConstructionUnit = import('/lua/terranunits.lua').TConstructionUnit
local TDFMachineGunWeapon = import('/lua/terranweapons.lua').TDFMachineGunWeapon

UEL0101 = Class(TConstructionUnit) {
    
    Weapons = {
        MainGun = Class(TDFMachineGunWeapon) {
        },
    },

}


TypeClass = UEL0101
