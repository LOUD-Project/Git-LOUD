local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local ADFLaserLightWeapon       = import('/lua/aeonweapons.lua').ADFLaserLightWeapon
local AAAZealotMissileWeapon    = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon 

UAL0108 = Class(AWalkingLandUnit) { 

    Weapons = { 
        MainGun     = Class(ADFLaserLightWeapon) {}, 
        Rocketpack  = Class(AAAZealotMissileWeapon) {},
    }, 
    
    CreateEnhancement = function(self, enh)
	
        AWalkingLandUnit.CreateEnhancement(self, enh)
		
        local bp = self:GetBlueprint().Enhancements[enh]
		
        if enh == 'PersonalShield' then
		
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
			
        elseif enh == 'PersonalShieldRemove' then
		
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			
        end
		
    end,       
} 
TypeClass = UAL0108