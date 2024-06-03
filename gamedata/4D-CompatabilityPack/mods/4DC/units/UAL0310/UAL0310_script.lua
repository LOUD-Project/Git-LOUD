local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

local ArrowMissileWeapon = import('/mods/4DC/lua/4D_weapons.lua').ArrowMissileWeapon
local LaserPhalanxWeapon = import('/mods/4DC/lua/4D_weapons.lua').LaserPhalanxWeapon

local CreateBoneEffects = import('/lua/EffectUtilities.lua').CreateBoneEffects
local WeaponSteam       = import('/lua/effecttemplates.lua').WeaponSteam01

ual0310 = Class(AWalkingLandUnit) { 

	Weapons = {
	
		HatchMissile = Class(ArrowMissileWeapon) {

            OnWeaponFired = function(self) 
			
                ArrowMissileWeapon.OnWeaponFired(self) 
				
                -- Hides the missile bones after the unit has fired 
                self.unit:HideBone('LargeSAM', false)
				
            end, 

            PlayFxRackSalvoReloadSequence = function(self)
            
                local unit = self.unit
			
                self.ExhaustEffects = CreateBoneEffects( unit, 'LargeSAM', unit:GetArmy(), WeaponSteam )

                -- Unhides the missile bones so the player can see the missile reload 
                unit:ShowBone('LargeSAM', false)  
                ArrowMissileWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
		},
		
		MissileSideLeft     = Class(AAAZealotMissileWeapon) {},
		MissileSideRight    = Class(AAAZealotMissileWeapon) {},
		LaserPhalanx        = Class(LaserPhalanxWeapon) {},
	},

    CreateEnhancement = function(self, enh)
	
        AWalkingLandUnit.CreateEnhancement(self, enh)
		
        local bp = __blueprints[self.BlueprintID].Enhancements[enh]      
		
        if enh == 'ShieldDomeAdd' then
		
            self:AddToggleCap('RULEUTC_ShieldToggle')                
            self:CreateShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
			
        elseif enh == 'ShieldDomeRemove' then
		
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			
        end
		
    end,   
   
} 
TypeClass = ual0310