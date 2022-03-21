local CSubUnit =  import('/lua/defaultunits.lua').SubUnit

local WeaponsFile = import('/lua/cybranweapons.lua')

local CANNaniteTorpedoWeapon = WeaponsFile.CANNaniteTorpedoWeapon
local CIFSmartCharge = WeaponsFile.CIFSmartCharge

XRS0204 = Class(CSubUnit) {

    Weapons = {
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
        AntiTorpedo = Class(CIFSmartCharge) {},
    },
	
    OnCreate = function(self)
	
        CSubUnit.OnCreate(self)
		
        self:SetMaintenanceConsumptionActive()
		
    end,
}

TypeClass = XRS0204