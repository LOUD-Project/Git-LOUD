local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AWeapons = import('/lua/aeonweapons.lua')
local ADFReactonCannon = AWeapons.ADFReactonCannon
local AIFCommanderDeathWeapon = AWeapons.AIFCommanderDeathWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

UAL0301 = Class(AWalkingLandUnit) {    
    Weapons = {
        RightReactonCannon = Class(ADFReactonCannon) {},
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
    },
    
    OnPrepareArmToBuild = function(self)
        --AWalkingLandUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightReactonCannon', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightReactonCannon'):GetHeadingPitch() )
    end,
        
    OnStopCapture = function(self, target)
        AWalkingLandUnit.OnStopCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightReactonCannon', true)
        self:GetWeaponManipulatorByLabel('RightReactonCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnFailedCapture = function(self, target)
        AWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightReactonCannon', true)
        self:GetWeaponManipulatorByLabel('RightReactonCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStopReclaim = function(self, target)
        AWalkingLandUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightReactonCannon', true)
        self:GetWeaponManipulatorByLabel('RightReactonCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        AWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true     
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        AWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightReactonCannon', true)
        self:GetWeaponManipulatorByLabel('RightReactonCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,
    
    OnFailedToBuild = function(self)
        AWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightReactonCannon', true)
        self:GetWeaponManipulatorByLabel('RightReactonCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnCreate = function(self)
        AWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Turbine', true)
        self:SetupBuildBones()
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,      
    
    CreateEnhancement = function(self, enh)

        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
		
        #SystemIntegrityCompensator
        if enh == 'SystemIntegrityCompensator' then
            # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            AWalkingLandUnit.CreateEnhancement(self, enh)
            local bpRegenRate = bp.NewRegenRate or 0
            if not Buffs['AeonSCURegenerateBonus'] then
               BuffBlueprint {
                    Name = 'AeonSCURegenerateBonus',
                    DisplayName = 'AeonSCURegenerateBonus',
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
            if Buff.HasBuff( self, 'AeonSCURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'AeonSCURegenerateBonus' )
            end  
            Buff.ApplyBuff(self, 'AeonSCURegenerateBonus')
        elseif enh == 'SystemIntegrityCompensatorRemove' then
            # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            AWalkingLandUnit.CreateEnhancement(self, enh)
            if Buff.HasBuff( self, 'AeonSCURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'AeonSCURegenerateBonus' )
            end  
        end

		
        #Teleporter
        if enh == 'Teleporter' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Teleport')
			
        #Shields
        elseif enh == 'Shield' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
        elseif enh == 'ShieldRemove' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			
        elseif enh == 'ShieldHeavy' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            self:ForkThread(self.CreateHeavyShield, bp)
			
        elseif enh == 'ShieldHeavyRemove' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle') 
			
        #ResourceAllocation              
        elseif enh =='ResourceAllocation' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
			
        elseif enh == 'ResourceAllocationRemove' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
			
        #Engineering Focus Module
        elseif enh =='EngineeringFocusingModule' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            if not Buffs['AeonSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'AeonSCUBuildRate',
                    DisplayName = 'AeonSCUBuildRate',
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
            Buff.ApplyBuff(self, 'AeonSCUBuildRate')
			
        elseif enh == 'EngineeringFocusingModuleRemove' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            if Buff.HasBuff( self, 'AeonSCUBuildRate' ) then
                Buff.RemoveBuff( self, 'AeonSCUBuildRate' )
            end

        #Sacrifice
        elseif enh == 'Sacrifice' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Sacrifice')
        elseif enh == 'SacrificeRemove' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Sacrifice')  
			
        #StabilitySupressant
        elseif enh =='StabilitySuppressant' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('RightReactonCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadiusMod or 0)
			
        elseif enh =='StabilitySuppressantRemove' then
			AWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('RightReactonCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadiusMod or 0)
        end
    end,
    
    CreateHeavyShield = function(self, bp)
        WaitTicks(1)
        self:CreatePersonalShield(bp)
        self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)     
        self:SetMaintenanceConsumptionActive()
    end,    
    
    OnPaused = function(self)
        AWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            AWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            AWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        AWalkingLandUnit.OnUnpaused(self)
    end,         
}

TypeClass = UAL0301
