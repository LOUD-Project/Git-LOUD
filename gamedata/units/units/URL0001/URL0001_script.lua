local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit
local CWeapons = import('/lua/cybranweapons.lua')

local CCannonMolecularWeapon = CWeapons.CCannonMolecularWeapon
local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon
local CDFHeavyMicrowaveLaserGeneratorCom = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local CDFOverchargeWeapon = CWeapons.CDFOverchargeWeapon
local CANTorpedoLauncherWeapon = CWeapons.CANTorpedoLauncherWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

local Buff = import('/lua/sim/Buff.lua')

local Entity = import('/lua/sim/Entity.lua').Entity

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

URL0001 = Class(CWalkingLandUnit) {
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(CIFCommanderDeathWeapon) {},
		
        RightRipper = Class(CCannonMolecularWeapon) {},
		
        Torpedo = Class(CANTorpedoLauncherWeapon) {},
		
        MLG = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
            DisabledFiringBones = {'Turret_Muzzle_03'},
            
            SetOnTransport = function(self, transportstate)
                CDFHeavyMicrowaveLaserGeneratorCom.SetOnTransport(self, transportstate)
                self:ForkThread(self.OnTransportWatch)
            end,
            
            OnTransportWatch = function(self)
                while self:GetOnTransport() do
                    self:PlayFxBeamEnd()
                    self:SetWeaponEnabled(false)
                    WaitSeconds(0.3)
                end
            end,          
        },

        OverCharge = Class(CDFOverchargeWeapon) {
            OnCreate = function(self)
                CDFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                CDFOverchargeWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)

                --self.unit:SetWeaponEnabledByLabel('RightRipper', false)

                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                
                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end
                
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightRipper'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                CDFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)

                --self.unit:SetWeaponEnabledByLabel('RightRipper', true)

                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                
                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end
                
                self.unit:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
            end,
            
            PauseOvercharge = function(self)
                if not self.unit:IsOverchargePaused() then
                    self.unit:SetOverchargePaused(true)
                    WaitSeconds(1/self:GetBlueprint().RateOfFire)
                    self.unit:SetOverchargePaused(false)
                end
            end,
            
            OnFire = function(self)
                if not self.unit:IsOverchargePaused() then
                    CDFOverchargeWeapon.OnFire(self)
                end
            end,
            IdleState = State(CDFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        CDFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(CDFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        CDFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },    
        },
    },

    OnCreate = function(self)
    
        CWalkingLandUnit.OnCreate(self)
        
        self:SetCapturable(false)
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
		
        -- Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
    end,


    OnPrepareArmToBuild = function(self)
    
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightRipper', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightRipper'):GetHeadingPitch() )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    OnStopCapture = function(self, target)
    
        CWalkingLandUnit.OnStopCapture(self, target)
        
        if self.Dead then return end        

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
    
        CWalkingLandUnit.OnFailedCapture(self, target)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
    
        CWalkingLandUnit.OnStopReclaim(self, target)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
    
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('MLG', false)
        self:SetWeaponEnabledByLabel('Torpedo', false)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('Sonar')
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        self:ForkThread(self.GiveInitialResources)
    end,

    OnFailedToBuild = function(self)
    
        CWalkingLandUnit.OnFailedToBuild(self)
        
        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)    
    
        CWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
    
        CWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        
        if self.Dead then return end

        -- reattach the permanent projectile
        for _, v in self.BuildProjectile do 
        
            TrashDestroy ( v.BuildEffectsBag )
        
            if v.Detached then
                v:AttachTo( self, v.Name )
            end
            
            v.Detached = false
            
            -- and scale down the emitters
            v.Emitter:ScaleEmitter(0.05)
            v.Sparker:ScaleEmitter(0.05)
        end

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    PlayCommanderWarpInEffect = function(self)
    
        self:HideBone(0, true)
        self:SetUnSelectable(true)
        self:SetBusy(true)        
        self:SetBlockCommandQueue(true)
        self:ForkThread(self.WarpInEffectThread)
    end,

    WarpInEffectThread = function(self)
    
        self:PlayUnitSound('CommanderArrival')
        self:CreateProjectile( '/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
        WaitSeconds(2.1)
        self:SetMesh('/units/url0001/URL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)        
        self:SetBlockCommandQueue(false)

        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end
        
        WaitSeconds(6)
        self:SetMesh(self:GetBlueprint().Display.MeshBlueprint, true)
    end,    

    GiveInitialResources = function(self)
    
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,
    
    OnScriptBitSet = function(self, bit)
    
        if bit == 8 then # cloak toggle

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

            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        end
    end,

    CreateEnhancement = function(self, enh)
	
        CWalkingLandUnit.CreateEnhancement(self, enh)
		
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
			
        elseif enh == 'TeleporterRemove' then
            RemoveUnitEnhancement(self, 'Teleporter')
            RemoveUnitEnhancement(self, 'TeleporterRemove')
            self:RemoveCommandCap('RULEUCC_Teleport')
			
        elseif enh == 'StealthGenerator' then
            self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false        
            self.StealthEnh = true
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')
			
        elseif enh == 'StealthGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')           
            self.StealthEnh = false
            self.CloakEnh = false 
            self.StealthFieldEffects = false
            self.CloakingEffects = false     
			
        elseif enh == 'ResourceAllocation' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'CloakingGenerator' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            self.StealthEnh = false
			self.CloakEnh = true 
            self:EnableUnitIntel('Cloak')
            if not Buffs['CybranACUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranACUCloakBonus',
                    DisplayName = 'CybranACUCloakBonus',
                    BuffType = 'ACUCLOAKBONUS',
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
            if Buff.HasBuff( self, 'CybranACUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranACUCloakBonus' )
            end  
            Buff.ApplyBuff(self, 'CybranACUCloakBonus')                		
        elseif enh == 'CloakingGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Cloak')
            self.CloakEnh = false 
            if Buff.HasBuff( self, 'CybranACUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranACUCloakBonus' )
            end              
			
        --T2 Engineering
        elseif enh =='AdvancedEngineering' then
		
            local bp = self:GetBlueprint().Enhancements[enh]
			
            if not bp then return end
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T2_Engineering')
			
        elseif enh =='AdvancedEngineeringRemove' then
		
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
			
            if Buff.HasBuff( self, 'ACU_T2_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Engineering' )
            end
			
        -- T3 Engineering
        elseif enh =='T3Engineering' then
		
            local bp = self:GetBlueprint().Enhancements[enh]
			
            if not bp then return end
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T3_Engineering')
			
        elseif enh =='T3EngineeringRemove' then
		
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            if Buff.HasBuff( self, 'ACU_T3_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Engineering' )
            end
			
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
			
        -- T4 Engineering
        elseif enh =='T4Engineering' then
		
            local bp = self:GetBlueprint().Enhancements[enh]
			
            if not bp then return end
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T4_Engineering')
			
        elseif enh =='T4EngineeringRemove' then
		
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            if Buff.HasBuff( self, 'ACU_T4_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Engineering' )
            end
			
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )

        elseif enh =='CoolingUpgrade' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            local microwave = self:GetWeaponByLabel('MLG')
            microwave:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
        elseif enh == 'CoolingUpgradeRemove' then
            local wep = self:GetWeaponByLabel('RightRipper')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local microwave = self:GetWeaponByLabel('MLG')
            microwave:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)            
        elseif enh == 'MicrowaveLaserGenerator' then
            self:SetWeaponEnabledByLabel('MLG', true)
        elseif enh == 'MicrowaveLaserGeneratorRemove' then
            self:SetWeaponEnabledByLabel('MLG', false)
        elseif enh == 'NaniteTorpedoTube' then
            self:SetWeaponEnabledByLabel('Torpedo', true)
            self:EnableUnitIntel('Sonar')
        elseif enh == 'NaniteTorpedoTubeRemove' then
            self:SetWeaponEnabledByLabel('Torpedo', false)
			self:DisableUnitIntel('Sonar')
        end             
    end,
    
    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Head',
				    'Right_Turret',
				    'Left_Turret',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Chest_Right',
				    'Chest_Left',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Left_Foot_B01',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
				    'Right_Foot_B01',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Head',
				    'Right_Turret',
				    'Left_Turret',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Chest_Right',
				    'Chest_Left',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Left_Foot_B01',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
				    'Right_Foot_B01',
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
            EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
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
            CWalkingLandUnit.StopBuildingEffects(self, self.UnitBeingBuilt)
        end    
        
    end,
    
    OnUnpaused = function(self)
    
        if self.BuildingUnit then
            CWalkingLandUnit.StartBuildingEffects(self, self.UnitBeingBuilt, self.UnitBuildOrder)
        end
        
        CWalkingLandUnit.OnUnpaused(self)
    end,     
}   
    
TypeClass = URL0001
