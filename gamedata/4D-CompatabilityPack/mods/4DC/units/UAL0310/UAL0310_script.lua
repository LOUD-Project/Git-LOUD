local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local EffectUtils = import('/lua/EffectUtilities.lua')
local Effects = import('/lua/effecttemplates.lua')

local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon
local CustomAeonWeapons = import('/mods/4DC/lua/4D_weapons.lua')
local ArrowMissileWeapon = CustomAeonWeapons.ArrowMissileWeapon
local LaserPhalanxWeapon = CustomAeonWeapons.LaserPhalanxWeapon

ual0310 = Class(AWalkingLandUnit) { 

	Weapons = {
	
		HatchMissile = Class(ArrowMissileWeapon) {

            OnWeaponFired = function(self) 
			
                ArrowMissileWeapon.OnWeaponFired(self) 
				
                -- Hides the missile bones after the unit has fired 
                self.unit:HideBone('LargeSAM', false)
				
            end, 

            PlayFxRackSalvoReloadSequence = function(self)
			
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'LargeSAM', self.unit:GetArmy(), Effects.WeaponSteam01 )
                -- Unhides the missile bones so the player can see the missile reload 
                self.unit:ShowBone('LargeSAM', false)  
                ArrowMissileWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,
		},
		
		MissileSideLeft = Class(AAAZealotMissileWeapon) {},
		MissileSideRight = Class(AAAZealotMissileWeapon) {},
		LaserPhalanx = Class(LaserPhalanxWeapon) {},
	},

    CreateEnhancement = function(self, enh)
	
        AWalkingLandUnit.CreateEnhancement(self, enh)
		
        local bp = self:GetBlueprint().Enhancements[enh]      
		
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