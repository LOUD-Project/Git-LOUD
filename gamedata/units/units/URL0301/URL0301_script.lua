local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CWeapons = import('/lua/cybranweapons.lua')

local CleanupEffectBag = import('/lua/EffectUtilities.lua').CleanupEffectBag
local CreateCybranBuildBeams = import('/lua/EffectUtilities.lua').CreateCybranBuildBeams

local GetHeadingPitch=moho.BuilderArmManipulator.GetHeadingPitch

local ScaleEmitter = moho.IEffect.ScaleEmitter
local SetPrecedence = moho.manipulator_methods.SetPrecedence

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local Buff = import('/lua/sim/Buff.lua')

local CAAMissileNaniteWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CDFLaserDisintegratorWeapon = CWeapons.CDFLaserDisintegratorWeapon02
local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon

CWeapons = nil

URL0301 = Class(CWalkingLandUnit) {
    LeftFoot = 'Left_Foot02',
    RightFoot = 'Right_Foot02',

    Weapons = {
        DeathWeapon = Class(CIFCommanderDeathWeapon) {},

        RightDisintegrator = Class(CDFLaserDisintegratorWeapon) {

            OnCreate = function(self)
                CDFLaserDisintegratorWeapon.OnCreate(self)

                -- Disable buff 
                self:DisableBuff('STUN')
            end,
        },

        NMissile = Class(CAAMissileNaniteWeapon) {},
    },


    OnCreate = function(self)
    
        CWalkingLandUnit.OnCreate(self)
        
        self:SetCapturable(false)
        
        self:HideBone('AA_Gun', true)
        self:HideBone('Power_Pack', true)
        self:HideBone('Rez_Protocol', true)
        self:HideBone('Torpedo', true)
        self:HideBone('Turbine', true)
        
        self:SetWeaponEnabledByLabel('NMissile', false)
        
        if __blueprints[self.BlueprintID].General.BuildBones then
            self:SetupBuildBones()
        end
        self.IntelButtonSet = true
    end,

    OnPrepareArmToBuild = function(self)

        self:BuildManipulatorSetEnabled(true)
        SetPrecedence( self.BuildArmManipulator, 20)
        
        self:SetWeaponEnabledByLabel('RightDisintegrator', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightDisintegrator'):GetHeadingPitch() )

    end,
    
    OnStopCapture = function(self, target)
    
        CWalkingLandUnit.OnStopCapture(self, target)
        
        self:BuildManipulatorSetEnabled(false)
        SetPrecedence( self.BuildArmManipulator, 0)
        
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )

    end,

    OnFailedCapture = function(self, target)
    
        CWalkingLandUnit.OnFailedCapture(self, target)
        
        self:BuildManipulatorSetEnabled(false)
        SetPrecedence( self.BuildArmManipulator, 0)
        
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        
    end,
    
    OnStopReclaim = function(self, target)
    
        CWalkingLandUnit.OnStopReclaim(self, target)
        
        self:BuildManipulatorSetEnabled(false)
        SetPrecedence( self.BuildArmManipulator, 0)
        
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        
    end,

    # ********
    # Engineering effects
    # ********
    OnStartBuild = function(self, unitBeingBuilt, order)    
    
        CWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true   
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
    
        CWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        
        if self.Dead then return end

        if self.BuildProjectile then
        
            -- reattach the permanent projectile
            -- and rescale the emitters
            for _, v in self.BuildProjectile do 
        
                TrashDestroy ( v.BuildEffectsBag )
        
                if v.Detached then
                    v:AttachTo( self, v.Name )
                end
            
                v.Detached = false
            
                -- and scale down the emitters
                ScaleEmitter( v.Emitter, 0.05)
                ScaleEmitter( v.Sparker, 0.05)
            end
        end
        
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
        
        self:BuildManipulatorSetEnabled(false)
        SetPrecedence( self.BuildArmManipulator, 0)   
        
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        
    end,    
    
    OnFailedToBuild = function(self)
    
        CWalkingLandUnit.OnFailedToBuild(self)
        
        self:BuildManipulatorSetEnabled(false)
        
        if not self.Dead then
        
            SetPrecedence( self.BuildArmManipulator,0 )
        
            self:SetWeaponEnabledByLabel('RightDisintegrator', true)
            self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
            
        end

    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )

       CreateCybranBuildBeams( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
    
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        
        self:BuildManipulatorSetEnabled(false)
        
        self:SetMaintenanceConsumptionInactive()
        
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        
        self.LeftArmUpgrade = 'EngineeringArm'
        self.RightArmUpgrade = 'Disintegrator'
    end,

    SetupIntel = function(self, layer)
    
        CWalkingLandUnit.SetupIntel(self)
        
        if layer == 'Seabed' or layer == 'Sub' then
            self:EnableIntel('WaterVision')
        else
            self:EnableIntel('Vision')
        end

        self:EnableIntel('Radar')
        self:EnableIntel('Sonar')
    end,



    OnScriptBitSet = function(self, bit)
        if bit == 8 then # cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')          
        end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 8 then # cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        end
    end,

    # ************
    # Enhancements
    # ************
    CreateEnhancement = function(self, enh)
        
        local bp = __blueprints[self.BlueprintID].Enhancements[enh]
        
        if not bp then return end

        if enh == 'SelfRepairSystem' then
        
            -- added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            CWalkingLandUnit.CreateEnhancement(self, enh)
            
            local bpRegenRate = __blueprints[self.BlueprintID].Enhancements.SelfRepairSystem.NewRegenRate or 0
            
            if not Buffs['CybranSCURegenerateBonus'] then
               BuffBlueprint {
                    Name = 'CybranSCURegenerateBonus',
                    DisplayName = 'CybranSCURegenerateBonus',
                    BuffType = 'SCUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bpRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            
            if Buff.HasBuff( self, 'CybranSCURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCURegenerateBonus' )
            end  
            
            Buff.ApplyBuff(self, 'CybranSCURegenerateBonus')
            
        elseif enh == 'SelfRepairSystemRemove' then
        
            -- added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            CWalkingLandUnit.CreateEnhancement(self, enh)
            
            if Buff.HasBuff( self, 'CybranSCURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCURegenerateBonus' )
            end
			
        elseif enh == 'CloakingGenerator' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            self.StealthEnh = false
			self.CloakEnh = true 
            
            self:EnableUnitIntel('Cloak')
            
            if not Buffs['CybranSCUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranSCUCloakBonus',
                    DisplayName = 'CybranSCUCloakBonus',
                    BuffType = 'SCUCLOAKBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            
            if Buff.HasBuff( self, 'CybranSCUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCUCloakBonus' )
            end
            
            Buff.ApplyBuff(self, 'CybranSCUCloakBonus')                		
            
        elseif enh == 'CloakingGeneratorRemove' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            self:DisableUnitIntel('Cloak')
            
            self.StealthEnh = false
            self.CloakEnh = false 
            
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            
            if Buff.HasBuff( self, 'CybranSCUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCUCloakBonus' )
            end 
            
        elseif enh == 'StealthGenerator' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            self:AddToggleCap('RULEUTC_CloakToggle')
            
            if self.IntelEffectsBag then
                CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            
            self.CloakEnh = false        
            self.StealthEnh = true
            
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')          
            
        elseif enh == 'StealthGeneratorRemove' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')
            
            self.StealthEnh = false
            self.CloakEnh = false 
            
        elseif enh == 'NaniteMissileSystem' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            self:ShowBone('AA_Gun', true)
            self:SetWeaponEnabledByLabel('NMissile', true)
            
        elseif enh == 'NaniteMissileSystemRemove' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            self:HideBone('AA_Gun', true)
            self:SetWeaponEnabledByLabel('NMissile', false)

        elseif enh =='ResourceAllocation' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            local bpEcon = self:GetBlueprint().Economy
            
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            
        elseif enh == 'ResourceAllocationRemove' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            local bpEcon = self:GetBlueprint().Economy
            
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            
        elseif enh =='Switchback' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            if not Buffs['CybranSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'CybranSCUBuildRate',
                    DisplayName = 'CybranSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            
            Buff.ApplyBuff(self, 'CybranSCUBuildRate')
            
        elseif enh == 'SwitchbackRemove' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            if Buff.HasBuff( self, 'CybranSCUBuildRate' ) then
                Buff.RemoveBuff( self, 'CybranSCUBuildRate' )
            end
            
        elseif enh == 'FocusConvertor' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            local wep = self:GetWeaponByLabel('RightDisintegrator')
            wep:AddDamageMod(self:GetBlueprint().Enhancements.FocusConvertor.NewDamageMod or 0)
            
        elseif enh == 'FocusConvertorRemove' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            local wep = self:GetWeaponByLabel('RightDisintegrator')
            wep:AddDamageMod(0)
            
        elseif enh == 'EMPCharge' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            local wep = self:GetWeaponByLabel('RightDisintegrator')
            wep:ReEnableBuff('STUN')        
            
        elseif enh == 'EMPChargeRemove' then
        
			CWalkingLandUnit.CreateEnhancement(self, enh)
            
            local wep = self:GetWeaponByLabel('RightDisintegrator')
            wep:DisableBuff('STUN')        
        end
        
    end,

    # *****
    # Death
    # *****
    OnKilled = function(self, instigator, type, overkillRatio)
        local bp
        for k, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                bp = v
            end
        end 
        #if we could find a blueprint with v.Add.OnDeath, then add the buff 
        if bp != nil then 
            #Apply Buff
			self:AddBuff(bp)
        end
        #otherwise, we should finish killing the unit
        CWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Head',
				    'Right_Elbow',
				    'Left_Elbow',
				    'Right_Arm01',
				    'Left_Shoulder',
				    'Torso',
				    'URL0301',
				    'Left_Thigh',
				    'Left_Knee',
				    'Left_Leg',
				    'Right_Thigh',
				    'Right_Knee',
				    'Right_Leg',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Head',
				    'Right_Elbow',
				    'Left_Elbow',
				    'Right_Arm01',
				    'Left_Shoulder',
				    'Torso',
				    'URL0301',
				    'Left_Thigh',
				    'Left_Knee',
				    'Left_Leg',
				    'Right_Thigh',
				    'Right_Knee',
				    'Right_Leg',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
    },
    
    OnIntelEnabled = function(self)
    
        CWalkingLandUnit.OnIntelEnabled(self)
        
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then 
        
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['CloakingGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            
            if not self.IntelEffectsBag then
			    self.IntelEffectsBag = {}
			    self.CreateTerrainTypeEffects( self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
			end            
            
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
        
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['StealthGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()  
            
            if not self.IntelEffectsBag then 
	            self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		    end
            
        end		
    end,

    OnIntelDisabled = function(self)
    
        CWalkingLandUnit.OnIntelDisabled(self)
        
        if self.IntelEffectsBag then
            CleanupEffectBag(self,'IntelEffectsBag')
            self.IntelEffectsBag = nil
        end
        
        if self.CloakEnh and not self:IsIntelEnabled('Cloak') then
            self:SetMaintenanceConsumptionInactive()
            
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') and not self:IsIntelEnabled('SonarStealth') then
            self:SetMaintenanceConsumptionInactive()
        end          
    end,
    
    OnPaused = function(self)
    
        CWalkingLandUnit.OnPaused(self)
        
        if self.BuildingUnit then
            CWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end
        
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            CWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        CWalkingLandUnit.OnUnpaused(self)
    end,        
}

TypeClass = URL0301
