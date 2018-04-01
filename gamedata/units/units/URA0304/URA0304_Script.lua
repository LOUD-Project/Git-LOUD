local CAirUnit = import('/lua/cybranunits.lua').CAirUnit

local CIFBombNeutronWeapon = import('/lua/cybranweapons.lua').CIFBombNeutronWeapon
local CAAAutocannon = import('/lua/cybranweapons.lua').CAAAutocannon

URA0304 = Class(CAirUnit) {

    Weapons = {
        Bomb = Class(CIFBombNeutronWeapon) {},
        AAGun = Class(CAAAutocannon) {},
    },
	
    ContrailBones = {'Left_Exhaust','Right_Exhaust'},
	
    ExhaustBones = {'Center_Exhaust',},
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_StealthToggle', true)
        self:RequestRefreshUI()
		
    end,
	
}

TypeClass = URA0304
