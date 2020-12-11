local Shield = import('/lua/shield.lua').Shield

--local EffectUtil = import('/lua/EffectUtilities.lua')
local CleanupEffectBag = import('/lua/EffectUtilities.lua').CleanupEffectBag
local CreateDefaultBuildBeams = import('/lua/EffectUtilities.lua').CreateDefaultBuildBeams
local CreateUEFCommanderBuildSliceBeams = import('/lua/EffectUtilities.lua').CreateUEFCommanderBuildSliceBeams

local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local TWeapons = import('/lua/terranweapons.lua')
local TDFHeavyPlasmaCannonWeapon = TWeapons.TDFHeavyPlasmaCannonWeapon
local TIFCommanderDeathWeapon = TWeapons.TIFCommanderDeathWeapon

UEL0301 = Class(TWalkingLandUnit) {
    
    IntelEffects = {
		{
			Bones = {
				'Jetpack',
			},
			Scale = 0.5,
			Type = 'Jammer01',
		},
    },    

    Weapons = {
        RightHeavyPlasmaCannon = Class(TDFHeavyPlasmaCannonWeapon) {
        },

        DeathWeapon = Class(TIFCommanderDeathWeapon) {
        },
    },

    OnCreate = function(self)
        TWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Jetpack', true)
        self:HideBone('SAM', true)
        self:SetupBuildBones()
        
    end,
    
    OnStopBeingBuilt = function(self, builder, layer)
        TWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
        self:DisableUnitIntel('Jammer')
    end,

    OnPrepareArmToBuild = function(self)
        --TWalkingLandUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightHeavyPlasmaCannon', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightHeavyPlasmaCannon'):GetHeadingPitch() )
    end,
    
    OnStopCapture = function(self, target)
        TWalkingLandUnit.OnStopCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightHeavyPlasmaCannon', true)
        self:GetWeaponManipulatorByLabel('RightHeavyPlasmaCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        TWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightHeavyPlasmaCannon', true)
        self:GetWeaponManipulatorByLabel('RightHeavyPlasmaCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStopReclaim = function(self, target)
        TWalkingLandUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightHeavyPlasmaCannon', true)
        self:GetWeaponManipulatorByLabel('RightHeavyPlasmaCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)    
        TWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        TWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false      
        self:SetWeaponEnabledByLabel('RightHeavyPlasmaCannon', true)    
        self:GetWeaponManipulatorByLabel('RightHeavyPlasmaCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,     
    
    OnFailedToBuild = function(self)
        TWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightHeavyPlasmaCannon', true)
        self:GetWeaponManipulatorByLabel('RightHeavyPlasmaCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        # If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
            CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        else
            CreateUEFCommanderBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )   
        end           
    end,     

    NotifyOfPodDeath = function(self, pod)
        RemoveUnitEnhancement(self, 'Pod')
        self.Pod = nil
        self:RequestRefreshUI()
    end,

    CreateEnhancement = function(self, enh)
        TWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        #Drone
        if enh == 'Pod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('UEA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'Pod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.Pod = pod
        elseif enh == 'PodRemove' then
            if self.Pod and not self.Pod:BeenDestroyed() then
                self.Pod:Kill()
            end
        #Shield
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
        elseif enh == 'ShieldRemove' then
            RemoveUnitEnhancement(self, 'Shield')
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh == 'ShieldGeneratorField' then
            self:DestroyShield()    
            ForkThread(function()
                WaitTicks(1)   
                self:CreateShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'ShieldGeneratorFieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        #ResourceAllocation              
        elseif enh =='ResourceAllocation' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        #SensorRangeEnhancer
        elseif enh == 'SensorRangeEnhancer' then
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
        elseif enh == 'SensorRangeEnhancerRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
        #RadarJammer
        elseif enh == 'RadarJammer' then
            self:SetIntelRadius('Jammer', bp.NewJammerRadius or 26)
            self.RadarJammerEnh = true 
			self:EnableUnitIntel('Jammer')
            self:AddToggleCap('RULEUTC_JammingToggle')              
        elseif enh == 'RadarJammerRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Jammer', 0)
            self:DisableUnitIntel('Jammer')
            self.RadarJammerEnh = false
            self:RemoveToggleCap('RULEUTC_JammingToggle')
        #AdvancedCoolingUpgrade
        elseif enh =='AdvancedCoolingUpgrade' then
            local wep = self:GetWeaponByLabel('RightHeavyPlasmaCannon')
            wep:ChangeRateOfFire(bp.NewRateOfFire)
        elseif enh =='AdvancedCoolingUpgradeRemove' then
            local wep = self:GetWeaponByLabel('RightHeavyPlasmaCannon')
            wep:ChangeRateOfFire(self:GetBlueprint().Weapon[1].RateOfFire or 1)
        #High Explosive Ordnance
        elseif enh =='HighExplosiveOrdnance' then
            local wep = self:GetWeaponByLabel('RightHeavyPlasmaCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius)
        elseif enh =='HighExplosiveOrdnanceRemove' then
            local wep = self:GetWeaponByLabel('RightHeavyPlasmaCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius)
        end
    end,

    OnIntelEnabled = function(self)
        TWalkingLandUnit.OnIntelEnabled(self)
        if self.RadarJammerEnh and self:IsIntelEnabled('Jammer') then 
            if self.IntelEffects then
		        self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
	        end
	        self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['RadarJammer'].MaintenanceConsumptionPerSecondEnergy or 0)        
            self:SetMaintenanceConsumptionActive()
        end    
    end,

    OnIntelDisabled = function(self)
        TWalkingLandUnit.OnIntelDisabled(self)
        if self.RadarJammerEnh and not self:IsIntelEnabled('Jammer') then
            self:SetMaintenanceConsumptionInactive()
            if self.IntelEffectsBag then
                CleanupEffectBag(self,'IntelEffectsBag')
            end
        end       
    end,     
    
    OnPaused = function(self)
        TWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        TWalkingLandUnit.OnUnpaused(self)
    end,     

}

TypeClass = UEL0301