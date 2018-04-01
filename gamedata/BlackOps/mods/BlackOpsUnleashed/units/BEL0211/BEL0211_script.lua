local TLandUnit = import('/lua/terranunits.lua').TLandUnit

local TDFMachineGunWeapon = import('/lua/terranweapons.lua').TDFMachineGunWeapon

BEL0211 = Class(TLandUnit) {
    Weapons = {
        LeftHeavyFlamer = Class(TDFMachineGunWeapon) {},
        RightHeavyFlamer = Class(TDFMachineGunWeapon) {},
    },
    

}

TypeClass = BEL0211