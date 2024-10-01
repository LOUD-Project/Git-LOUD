local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SWeapons = import('/lua/seraphimweapons.lua')

local SDFLightChronotronCannonWeapon    = SWeapons.SDFLightChronotronCannonWeapon
local SDFOverChargeWeapon               = SWeapons.SDFChronotronCannonOverChargeWeapon
local SIFLaanseTacticalMissileLauncher  = SWeapons.SIFLaanseTacticalMissileLauncher
local AIFCommanderDeathWeapon           = SWeapons.SIFCommanderDeathWeapon

SWeapons = nil

local Buff = import('/lua/sim/Buff.lua')
local CreateSeraphimUnitEngineerBuildingEffects = import('/lua/EffectUtilities.lua').CreateSeraphimUnitEngineerBuildingEffects

XSL0301 = Class(SWalkingLandUnit) {
    
    Weapons = {

        ChronotronCannon = Class(SDFLightChronotronCannonWeapon) {},

        DeathWeapon = Class(AIFCommanderDeathWeapon) {},

        OverCharge = Class(SDFOverChargeWeapon) {

            OnCreate = function(self)

                SDFOverChargeWeapon.OnCreate(self)

                self:SetWeaponEnabled(false)

                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)

				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)

                if self:BeenDestroyed() then return end

                SDFOverChargeWeapon.OnEnableWeapon(self)

                self:SetWeaponEnabled(true)

                self.unit:AddCommandCap('RULEUCC_Overcharge')

                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                
                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end

                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)

                SDFOverChargeWeapon.OnWeaponFired(self)

                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)    

                if self:BeenDestroyed() then return end

                self:SetWeaponEnabled(false)

                self.unit:RemoveCommandCap('RULEUCC_Overcharge')
                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)

                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end

                self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )                
            end,

            PauseOvercharge = function(self)

                if not self.unit:IsOverchargePaused() then

                    self.unit:SetOverchargePaused(true)

                    self.unit:RemoveCommandCap('RULEUCC_Overcharge')                    

                    if self.EconDrain then
                    
                        WaitFor(self.EconDrain)

                    end

                    self.unit:SetOverchargePaused(false)

                    self.unit:AddCommandCap('RULEUCC_Overcharge')

                end
            end,

        },

        Missile = Class(SIFLaanseTacticalMissileLauncher) {

            OnCreate = function(self)
                SIFLaanseTacticalMissileLauncher.OnCreate(self)

                self:SetWeaponEnabled(false)
            end,
        },
    },
    
    OnPrepareArmToBuild = function(self)

        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('ChronotronCannon', false)

        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)

        SWalkingLandUnit.OnStopCapture(self, target)

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnFailedCapture = function(self, target)

        SWalkingLandUnit.OnFailedCapture(self, target)

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStopReclaim = function(self, target)

        SWalkingLandUnit.OnStopReclaim(self, target)

        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)

        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedToBuild = function(self)

        SWalkingLandUnit.OnFailedToBuild(self)

        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)

        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)

        local bp = self:GetBlueprint()

        if order != 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then
            self:StartBuildingEffects(unitBeingBuilt, order)
        end

        self:DoOnStartBuildCallbacks(unitBeingBuilt)
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')

        if bp.General.UpgradesTo and unitBeingBuilt:GetUnitId() == bp.General.UpgradesTo and order == 'Upgrade' then
            self.Upgrading = true
            self.BuildingUnit = false        
            unitBeingBuilt.DisallowCollisions = true
        end

        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,    

    OnStopBuild = function(self, unitBeingBuilt)

        SWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )

        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    
    OnFailedToBuild = function(self)
        SWalkingLandUnit.OnFailedToBuild(self)

        self:BuildManipulatorSetEnabled(false)
        
        if not self.Dead then
            self.BuildArmManipulator:SetPrecedence(0)
            self:SetWeaponEnabledByLabel('ChronotronCannon', true)
            self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        end
    end,
    
    OnCreate = function(self)
        SWalkingLandUnit.OnCreate(self)

        self:SetCapturable(false)

        self:HideBone('Back_Upgrade', true)
        self:SetupBuildBones()
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,  
    
    CreateEnhancement = function(self, enh)

        SWalkingLandUnit.CreateEnhancement(self, enh)

        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        -- Teleporter
        if enh == 'Teleporter' then

            self:AddCommandCap('RULEUCC_Teleport')

        elseif enh == 'TeleporterRemove' then

            self:RemoveCommandCap('RULEUCC_Teleport')

        -- Missile
        elseif enh == 'Missile' then

            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('Missile', true)

        elseif enh == 'MissileRemove' then

            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('Missile', false)

        -- Shields
        elseif enh == 'Shield' then

            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)

        elseif enh == 'ShieldRemove' then

            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')

        -- Overcharge
        elseif enh == 'Overcharge' then

      	    self:SetWeaponEnabledByLabel('OverCharge', true)

        elseif enh == 'OverchargeRemove' then

      	    self:RemoveCommandCap('RULEUCC_Overcharge')
      	    self:SetWeaponEnabledByLabel('OverCharge', false)

        -- Engineering Throughput Upgrade
        elseif enh =='EngineeringThroughput' then

            if not Buffs['SeraphimSCUBuildRate'] then

                BuffBlueprint {
                    Name = 'SeraphimSCUBuildRate',
                    DisplayName = 'SeraphimSCUBuildRate',
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

            Buff.ApplyBuff(self, 'SeraphimSCUBuildRate')

        elseif enh == 'EngineeringThroughputRemove' then

            if Buff.HasBuff( self, 'SeraphimSCUBuildRate' ) then
                Buff.RemoveBuff( self, 'SeraphimSCUBuildRate' )
            end
        
        --Damage Stabilization
        elseif enh == 'DamageStabilization' then

            if not Buffs['SeraphimSCUDamageStabilization'] then

               BuffBlueprint {
                    Name = 'SeraphimSCUDamageStabilization',
                    DisplayName = 'SeraphimSCUDamageStabilization',
                    BuffType = 'SCUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end

            if Buff.HasBuff( self, 'SeraphimSCUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimSCUDamageStabilization' )
            end  

            Buff.ApplyBuff(self, 'SeraphimSCUDamageStabilization')            

      	elseif enh == 'DamageStabilizationRemove' then

            if Buff.HasBuff( self, 'SeraphimSCUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimSCUDamageStabilization' )
            end  

        --Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then

            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)

        elseif enh == 'EnhancedSensorsRemove' then

            local bpIntel = self:GetBlueprint().Intel

            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 16)
        end

    end,
    
    OnPaused = function(self)

        SWalkingLandUnit.OnPaused(self)

        if self.BuildingUnit then
            SWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)

        if self.BuildingUnit then
            SWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end

        SWalkingLandUnit.OnUnpaused(self)
    end,         
}

TypeClass = XSL0301
