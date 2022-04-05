local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit
local TerranWeaponFile = import('/lua/terranweapons.lua')

local TDFZephyrCannonWeapon = TerranWeaponFile.TDFZephyrCannonWeapon
local TIFCommanderDeathWeapon = TerranWeaponFile.TIFCommanderDeathWeapon
local TIFCruiseMissileLauncher = TerranWeaponFile.TIFCruiseMissileLauncher
local TDFOverchargeWeapon = TerranWeaponFile.TDFOverchargeWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

local CreateUEFCommanderBuildSliceBeams = EffectUtil.CreateUEFCommanderBuildSliceBeams

local Buff = import('/lua/sim/Buff.lua')
local Shield = import('/lua/shield.lua').Shield

local LOUDINSERT = table.insert

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local WaitTicks = coroutine.yield


UEL0001 = Class(TWalkingLandUnit) { 
   
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
        
        RightZephyr = Class(TDFZephyrCannonWeapon) {},
        
        RightZephyrUpgraded = Class(TDFZephyrCannonWeapon) {},

        OverCharge = Class(TDFOverchargeWeapon) {

            OnCreate = function(self)
                TDFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('RightZephyr', false)
                self.unit:ResetWeaponByLabel('RightZephyr')
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightZephyr'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                TDFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('RightZephyr', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    TDFOverchargeWeapon.OnFire(self)
                end
            end,
            
            IdleState = State(TDFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        TDFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            
            RackSalvoFireReadyState = State(TDFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        TDFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },            
            
        },
        
        TacMissile = Class(TIFCruiseMissileLauncher) {},
        
        TacNukeMissile = Class(TIFCruiseMissileLauncher) {},
    },

    OnCreate = function(self)
    
        TWalkingLandUnit.OnCreate(self)
        
        self:SetCapturable(false)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
        self:HideBone('Back_Upgrade_B01', true)
        self:SetupBuildBones()
        self.HasLeftPod = false
        self.HasRightPod = false
		
        -- Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
    
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        
        if self.Dead then return end
        
        self.Animator = CreateAnimator(self)
        self.Animator:SetPrecedence(0)
        
        if self.IdleAnim then
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationIdle, true)
            for k, v in self.DisabledBones do
                self.Animator:SetBoneEnabled(v, false)
            end
        end
        
        self:BuildManipulatorSetEnabled(false)
        
        self:SetWeaponEnabledByLabel('RightZephyr', true)
        self:SetWeaponEnabledByLabel('RightZephyrUpgraded', false)
        self:SetWeaponEnabledByLabel('TacMissile', false)
        self:SetWeaponEnabledByLabel('TacNukeMissile', false)
        
        self:ForkThread(self.GiveInitialResources)
    end,

    OnPrepareArmToBuild = function(self)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        --self:SetWeaponEnabledByLabel('RightZephyr', false)
        --self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightZephyr'):GetHeadingPitch() )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
	
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
		
        -- If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        --if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
          --  EffectUtil.CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        --else
            CreateUEFCommanderBuildSliceBeams( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )        
        --end           
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
    
        TWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        
        if self.Animator then
            self.Animator:SetRate(0)
        end
        
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,

    OnStopBuild = function(self, unitBeingBuilt)
	
        TWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)

        if self.Dead then return end

        if (self.IdleAnim and not self:IsDead()) then
            self.Animator:PlayAnim(self.IdleAnim, true)
        end
		
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
		
        --self:SetWeaponEnabledByLabel('RightZephyr', true)
        --self:SetWeaponEnabledByLabel('OverCharge', false)
		
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    OnFailedToBuild = function(self)
    
        TWalkingLandUnit.OnFailedToBuild(self)

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        --self:SetWeaponEnabledByLabel('RightZephyr', true)
        --self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
    
        TWalkingLandUnit.OnStopCapture(self, target)

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        --self:SetWeaponEnabledByLabel('RightZephyr', true)
        --self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
    
        TWalkingLandUnit.OnFailedCapture(self, target)
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        --self:SetWeaponEnabledByLabel('RightZephyr', true)
        --self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
    
        TWalkingLandUnit.OnStopReclaim(self, target)

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        --self:SetWeaponEnabledByLabel('RightZephyr', true)
        --self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    GiveInitialResources = function(self)
    
        WaitTicks(5)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
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
        self:SetMesh('/units/uel0001/UEL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
        self:HideBone('Back_Upgrade_B01', true)
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

-- Brute51 Pod Fix part 1/2 ---------------------------------
-- In this fix I'm seperating 'Left pod' from the left should pod (first upgrade) and the 'Right pod' from the 
-- right shoulder pod (second upgrade). This way if a pod is destroyed I dont have to reset the other pod so now it
-- can continue to do what it was doing.
-- When a pod is destroyed this removes either the 2nd upgrade if we had 2 pods, or the first if we had 1 pod.
--
    NotifyOfPodDeath = function(self, pod)

        if self.HasLeftPod and self.HasRightPod then
        
            -- we have 2 pods and one dies

            -- So we need to go back to 1 enhancement icon being lit insted of
            -- both. If I make the left one dark then the right one turns dark aswell.
            -- Bypassing the ACUs createenhancement function because that destroys both pods
            TWalkingLandUnit.CreateEnhancement(self, 'RightPodRemove') # darkens both pod enhancement icons
            TWalkingLandUnit.CreateEnhancement(self, 'LeftPod') # makes the correct enhancement icon light up again

        else
            -- we have 1 pod and it dies

            -- since we have just 1 pod only the left enhancement icon is lit. 
            self:CreateEnhancement('LeftPodRemove')
        end

        self:RequestRefreshUI()

        if pod == 'LeftPod' then
            self.HasLeftPod = false
        else
            self.HasRightPod = false
        end

-- end Pod Fix 1/2 ---------------------------------------
    end,

    CreateEnhancement = function(self, enh)
        
        local bp = __blueprints[self.BlueprintID].Enhancements[enh]
        if not bp then return end

        if enh == 'LeftPod' or enh == 'RightPod' then

            -- making sure we have up to date information
            if not self.LeftPod or self.LeftPod:IsDead() then
                self.HasLeftPod = false
            end
            if not self.RightPod or self.RightPod:IsDead() then
                self.HasRightPod = false
            end

            -- when we're enhancing to the 2nd pod enhancement ( = right pod) but the first pod is destroyed then 
            -- change to 1st pod ( = left pod)
            if enh == 'RightPod' and not self.HasLeftPod and not self.HasRightPod then
                TWalkingLandUnit.CreateEnhancement(self, 'RightPodRemove')  # no pod enhancement icons lit
                enh = 'LeftPod'
            end

            TWalkingLandUnit.CreateEnhancement(self, enh)

            if not self.HasLeftPod then
                local location = self:GetPosition('AttachSpecial02')
                local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
                pod:SetCreator(self)
                pod:SetParent(self, 'LeftPod')
                self.Trash:Add(pod)
                self.LeftPod = pod
                self.HasLeftPod = true
            else
                local location = self:GetPosition('AttachSpecial01')
                local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
                pod:SetCreator(self)
                pod:SetParent(self, 'RightPod')
                self.Trash:Add(pod)
                self.RightPod = pod
                self.HasRightPod = true
            end

        -- for removing the pod upgrades
        elseif enh == 'RightPodRemove' or enh == 'LeftPodRemove' then

            -- this is only run when the ACU has only 1 pod enhancement or when we're dumping an enhancement for
            -- another one. In both cases it's ok if we destroy both living pods.

            TWalkingLandUnit.CreateEnhancement(self, enh)

            if self.RightPod and not self.RightPod:IsDead() then
                self.RightPod:Kill()
                self.HasRightPod = false
            end
            if self.LeftPod and not self.LeftPod:IsDead() then
                self.LeftPod:Kill()
                self.HasLeftPod = false
            end


        elseif enh =='DamageStablization' then
        
            -- added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            TWalkingLandUnit.CreateEnhancement(self, enh)
            
            local bpRegenRate = bp.NewRegenRate or 0
            if not Buffs['UefACURegenerateBonus'] then
               BuffBlueprint {
                    Name = 'UefACURegenerateBonus',
                    DisplayName = 'UefACURegenerateBonus',
                    BuffType = 'ACUREGENERATEBONUS',
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
            if Buff.HasBuff( self, 'UefACURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'UefACURegenerateBonus' )
            end  
            Buff.ApplyBuff(self, 'UefACURegenerateBonus')

        elseif enh =='DamageStablizationRemove' then
            # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            TWalkingLandUnit.CreateEnhancement(self, enh)
            if Buff.HasBuff( self, 'UefACURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'UefACURegenerateBonus' )
            end  
		
        elseif enh == 'Teleporter' then
			TWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Teleport')

        elseif enh == 'TeleporterRemove' then
			TWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Teleport')

        elseif enh == 'Shield' then
			TWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreatePersonalShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()

        elseif enh == 'ShieldRemove' then
			TWalkingLandUnit.CreateEnhancement(self, enh)
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            RemoveUnitEnhancement(self, 'ShieldRemove')
            self:RemoveToggleCap('RULEUTC_ShieldToggle')

        elseif enh == 'ShieldGeneratorField' then
			TWalkingLandUnit.CreateEnhancement(self, enh)
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
                self:CreateShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)

        elseif enh == 'ShieldGeneratorFieldRemove' then
			TWalkingLandUnit.CreateEnhancement(self, enh)
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')

		-- T2 Engineering 
        elseif enh =='AdvancedEngineering' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T2_Engineering')
			
        elseif enh =='AdvancedEngineeringRemove' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )

            if Buff.HasBuff( self, 'ACU_T2_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Engineering' )
            end
		
		-- T3 Engineering 
        elseif enh =='T3Engineering' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T3_Engineering')
			
        elseif enh =='T3EngineeringRemove' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            if Buff.HasBuff( self, 'ACU_T3_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Engineering' )
            end
			
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
		
		-- T4 Engineering 
        elseif enh =='T4Engineering' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T4_Engineering')
			
        elseif enh =='T4EngineeringRemove' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            if Buff.HasBuff( self, 'ACU_T4_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Engineering' )
            end
			
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
	
        --ResourceAllocation              
        elseif enh == 'ResourceAllocation' then
			TWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
			
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
			
        elseif enh == 'ResourceAllocationRemove' then
			TWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)

        elseif enh =='HeavyAntiMatterCannon' then
        
			TWalkingLandUnit.CreateEnhancement(self, enh)

            self:SetWeaponEnabledByLabel('RightZephyrUpgraded', true)
            
            local wep = self:GetWeaponByLabel('RightZephyr')
            wep:ChangeMaxRadius(30)
            
            wep = self:GetWeaponByLabel('RightZephyrUpgraded')
            wep:ChangeMaxRadius(30)
            
            wep = self:GetWeaponByLabel('OverCharge')
            wep:ChangeMaxRadius(30)
            
        elseif enh =='HeavyAntiMatterCannonRemove' then
        
			TWalkingLandUnit.CreateEnhancement(self, enh)
            
            local wep = self:GetWeaponByLabel('RightZephyr')
            wep:ChangeMaxRadius(22)
            
            wep = self:GetWeaponByLabel('RightZephyrUpgraded')
            wep:ChangeMaxRadius(22)
            
            wep = self:GetWeaponByLabel('OverCharge')
            wep:ChangeMaxRadius(22)
            
            self:SetWeaponEnabledByLabel('RightZephyrUpgraded', false)

        elseif enh =='TacticalMissile' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
			
            self:SetWeaponEnabledByLabel('TacMissile', true)
			
        elseif enh =='TacticalNukeMissile' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
			
            self:AddCommandCap('RULEUCC_Nuke')
            self:AddCommandCap('RULEUCC_SiloBuildNuke')
			
            self:SetWeaponEnabledByLabel('TacMissile', false)
            self:SetWeaponEnabledByLabel('TacNukeMissile', true)
			
            local amt = self:GetTacticalSiloAmmoCount()
			
            self:RemoveTacticalSiloAmmo(amt or 0)
			
            self:StopSiloBuild()
			
        elseif enh == 'TacticalMissileRemove' or enh == 'TacticalNukeMissileRemove' then
		
			TWalkingLandUnit.CreateEnhancement(self, enh)
			
            self:RemoveCommandCap('RULEUCC_Nuke')
            self:RemoveCommandCap('RULEUCC_SiloBuildNuke')
			
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
			
            self:SetWeaponEnabledByLabel('TacMissile', false)
            self:SetWeaponEnabledByLabel('TacNukeMissile', false)
			
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
			
            local amt = self:GetNukeSiloAmmoCount()
            self:RemoveNukeSiloAmmo(amt or 0)
			
            self:StopSiloBuild()
        end
    end,
    
    OnPaused = function(self)
        TWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StopBuildingEffects(self, self.UnitBeingBuilt)
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StartBuildingEffects(self, self.UnitBeingBuilt, self.UnitBuildOrder)
        end
        TWalkingLandUnit.OnUnpaused(self)
    end,      

}

TypeClass = UEL0001