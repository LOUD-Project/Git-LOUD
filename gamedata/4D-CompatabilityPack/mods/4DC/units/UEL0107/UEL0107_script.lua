local THoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local MortarWeapon               = import('/lua/terranweapons.lua').TDFFragmentationGrenadeLauncherWeapon
local AANDepthChargeBombWeapon      = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

UEL0107 = Class(THoverLandUnit) {

    Weapons = {
        Mortar = Class(MortarWeapon){},
        DepthCharge = Class(AANDepthChargeBombWeapon){},
    },

}
TypeClass = UEL0107