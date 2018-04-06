#****************************************************************************
#**
#**  Author(s):  Exavier Macbeth
#**
#**  Summary  :  BlackOps: Adv Command Unit - UEF ACU
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local Shield = import('/lua/shield.lua').Shield

local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local TerranWeaponFile = import('/lua/terranweapons.lua')
local TDFZephyrCannonWeapon = TerranWeaponFile.TDFZephyrCannonWeapon
local TIFCommanderDeathWeapon = TerranWeaponFile.TIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TIFCruiseMissileLauncher = TerranWeaponFile.TIFCruiseMissileLauncher
local TDFOverchargeWeapon = TerranWeaponFile.TDFOverchargeWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local UEFACUHeavyPlasmaGatlingCannonWeapon = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').UEFACUHeavyPlasmaGatlingCannonWeapon
local Weapons2 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua')
local EXFlameCannonWeapon = Weapons2.HawkGaussCannonWeapon
local UEFACUAntiMatterWeapon = Weapons2.UEFACUAntiMatterWeapon
local PDLaserGrid = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').PDLaserGrid2 
local EffectUtils = import('/lua/effectutilities.lua')
local Effects = import('/lua/effecttemplates.lua')
local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

EEL0001 = Class(TWalkingLandUnit) {    
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
        RightZephyr = Class(TDFZephyrCannonWeapon) {},
        EXFlameCannon01 = Class(EXFlameCannonWeapon) {},
        EXFlameCannon02 = Class(EXFlameCannonWeapon) {},
        EXTorpedoLauncher01 = Class(TANTorpedoAngler) {},
        EXTorpedoLauncher02 = Class(TANTorpedoAngler) {},
        EXTorpedoLauncher03 = Class(TANTorpedoAngler) {},
        EXAntiMatterCannon01 = Class(UEFACUAntiMatterWeapon) {},
        EXAntiMatterCannon02 = Class(UEFACUAntiMatterWeapon) {},
        EXAntiMatterCannon03 = Class(UEFACUAntiMatterWeapon) {},
        EXGattlingEnergyCannon01 = Class(UEFACUHeavyPlasmaGatlingCannonWeapon) {
            OnCreate = function(self)
                UEFACUHeavyPlasmaGatlingCannonWeapon.OnCreate(self)
                if not self.unit.SpinManip then 
                    self.unit.SpinManip = CreateRotator(self.unit, 'Gatling_Cannon_Barrel', 'z', nil, 270, 300, 60)
                    self.unit.Trash:Add(self.unit.SpinManip)
                end
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(0)
                end
            end,
            PlayFxRackSalvoChargeSequence = function(self)
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(500)
                end
                UEFACUHeavyPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
            PlayFxRackSalvoReloadSequence = function(self)
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Exhaust', self.unit:GetArmy(), Effects.WeaponSteam01 )
                UEFACUHeavyPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,    
		},
        EXGattlingEnergyCannon02 = Class(UEFACUHeavyPlasmaGatlingCannonWeapon) {
            OnCreate = function(self)
                UEFACUHeavyPlasmaGatlingCannonWeapon.OnCreate(self)
                if not self.unit.SpinManip then 
                    self.unit.SpinManip = CreateRotator(self.unit, 'Gatling_Cannon_Barrel', 'z', nil, 270, 300, 60)
                    self.unit.Trash:Add(self.unit.SpinManip)
                end
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(0)
                end
            end,
            PlayFxRackSalvoChargeSequence = function(self)
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(500)
                end
                UEFACUHeavyPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
            PlayFxRackSalvoReloadSequence = function(self)
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Exhaust', self.unit:GetArmy(), Effects.WeaponSteam01 )
                UEFACUHeavyPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,    
		},
        EXGattlingEnergyCannon03 = Class(UEFACUHeavyPlasmaGatlingCannonWeapon) {
            OnCreate = function(self)
                UEFACUHeavyPlasmaGatlingCannonWeapon.OnCreate(self)
                if not self.unit.SpinManip then 
                    self.unit.SpinManip = CreateRotator(self.unit, 'Gatling_Cannon_Barrel', 'z', nil, 270, 300, 60)
                    self.unit.Trash:Add(self.unit.SpinManip)
                end
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(0)
                end
            end,
            PlayFxRackSalvoChargeSequence = function(self)
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(500)
                end
                UEFACUHeavyPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
            PlayFxRackSalvoReloadSequence = function(self)
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Exhaust', self.unit:GetArmy(), Effects.WeaponSteam01 )
                UEFACUHeavyPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,    
		},
        EXClusterMissles01 = Class(TIFCruiseMissileLauncher) {},
        EXClusterMissles02 = Class(TIFCruiseMissileLauncher) {},
        EXClusterMissles03 = Class(TIFCruiseMissileLauncher) {},
        EXEnergyLance01 = Class(PDLaserGrid) { 
            PlayOnlyOneSoundCue = true, 
        }, 
        EXEnergyLance02 = Class(PDLaserGrid) { 
            PlayOnlyOneSoundCue = true, 
        }, 
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
        TacMissile = Class(TIFCruiseMissileLauncher) {
            CreateProjectileAtMuzzle = function(self)
				muzzle = self:GetBlueprint().RackBones[1].MuzzleBones[1]
				self.slider = CreateSlider(self.unit, 'Back_MissilePack_B02', 0, 0, 0, 0.25, true)
				self.slider:SetGoal(0, 0, 0.22)
				WaitTicks(1)
				WaitFor(self.slider)
				TIFCruiseMissileLauncher.CreateProjectileAtMuzzle(self, muzzle)
				self.slider:SetGoal(0, 0, 0)
				WaitFor(self.slider)
				self.slider:Destroy()
            end,
        },
        TacNukeMissile = Class(TIFCruiseMissileLauncher) {
             CreateProjectileAtMuzzle = function(self)
				muzzle = self:GetBlueprint().RackBones[1].MuzzleBones[1]
				self.slider = CreateSlider(self.unit, 'Back_MissilePack_B02', 0, 0, 0, 0.25, true)
				self.slider:SetGoal(0, 0, 0.22)
				WaitTicks(1)
				WaitFor(self.slider)
				TIFCruiseMissileLauncher.CreateProjectileAtMuzzle(self, muzzle)
				self.slider:SetGoal(0, 0, 0)
				WaitFor(self.slider)
				self.slider:Destroy()
            end,
       },
    },

    OnCreate = function(self)
        TWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Engineering_Suite', true)
        self:HideBone('Flamer', true)
        self:HideBone('HAC', true)
        self:HideBone('Gatling_Cannon', true)
        self:HideBone('Back_MissilePack_B01', true)
        self:HideBone('Back_SalvoLauncher', true)
        self:HideBone('Back_ShieldPack', true)
        self:HideBone('Left_Lance_Turret', true)
        self:HideBone('Right_Lance_Turret', true)
        self:HideBone('Zephyr_Amplifier', true)
        self:HideBone('Back_IntelPack', true)
        self:HideBone('Torpedo_Launcher', true)
        self:SetupBuildBones()
        self.HasLeftPod = false
        self.HasRightPod = false
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER4COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        --TWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self.wcBuildMode = true
		self:ForkThread(self.WeaponConfigCheck)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightZephyr'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        TWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        TWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        TWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    GiveInitialResources = function(self)
        WaitTicks(5)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        if self:BeenDestroyed() then return end
        self.Animator = CreateAnimator(self)
        self.Animator:SetPrecedence(0)
        if self.IdleAnim then
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationIdle, true)
            for k, v in self.DisabledBones do
                self.Animator:SetBoneEnabled(v, false)
            end
        end
        self:BuildManipulatorSetEnabled(false)
        self:DisableUnitIntel('Radar')
        self:DisableUnitIntel('Sonar')
        self:DisableUnitIntel('Spoof')
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('CloakField')
		self:SetMaintenanceConsumptionInactive()
        self.Rotator1 = CreateRotator(self, 'Back_ShieldPack_Spinner01', 'z', nil, 0, 20, 0)
        self.Rotator2 = CreateRotator(self, 'Back_ShieldPack_Spinner02', 'z', nil, 0, 40, 0)
        self.RadarDish1 = CreateRotator(self, 'Back_IntelPack_Dish', 'y', nil, 0, 20, 0)
        self.Trash:Add(self.Rotator1)
        self.Trash:Add(self.Rotator2)
        self.Trash:Add(self.RadarDish1)
		self.ShieldEffectsBag2 = {}
		self.FlamerEffectsBag = {}
		self.wcBuildMode = false
		self.wcOCMode = false
		self.wcFlamer01 = false
		self.wcFlamer02 = false
		self.wcTorp01 = false
		self.wcTorp02 = false
		self.wcTorp03 = false
		self.wcAMC01 = false
		self.wcAMC02 = false
		self.wcAMC03 = false
		self.wcGatling01 = false
		self.wcGatling02 = false
		self.wcGatling03 = false
		self.wcLance01 = false
		self.wcLance02 = false
		self.wcCMissiles01 = false
		self.wcCMissiles02 = false
		self.wcCMissiles03 = false
		self.wcTMissiles01 = false
		self.wcNMissiles01 = false
		self:ForkThread(self.WeaponConfigCheck)
		self:ForkThread(self.WeaponRangeReset)
        self:ForkThread(self.GiveInitialResources)
		self.RBImpEngineering = false
		self.RBAdvEngineering = false
		self.RBExpEngineering = false
		self.RBComEngineering = false
		self.RBAssEngineering = false
		self.RBApoEngineering = false
		self.RBDefTier1 = false
		self.RBDefTier2 = false
		self.RBDefTier3 = false
		self.RBComTier1 = false
		self.RBComTier2 = false
		self.RBComTier3 = false
		self.RBIntTier1 = false
		self.RBIntTier2 = false
		self.RBIntTier3 = false
		self.SpysatEnabled = false
		self.regenammount = 0

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
        self:SetMesh('/mods/BlackOpsACUs/units/eel0001/EEL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
        self:HideBone('Engineering_Suite', true)
        self:HideBone('Flamer', true)
        self:HideBone('HAC', true)
        self:HideBone('Gatling_Cannon', true)
        self:HideBone('Back_MissilePack_B01', true)
        self:HideBone('Back_SalvoLauncher', true)
        self:HideBone('Back_ShieldPack', true)
        self:HideBone('Left_Lance_Turret', true)
        self:HideBone('Right_Lance_Turret', true)
        self:HideBone('Zephyr_Amplifier', true)
        self:HideBone('Back_IntelPack', true)
        self:HideBone('Torpedo_Launcher', true)
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

    OnStartBuild = function(self, unitBeingBuilt, order)
        TWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        if self.Animator then
            self.Animator:SetRate(0)
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,

    OnFailedToBuild = function(self)
        TWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        # If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
            EffectUtil.CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        else
            EffectUtil.CreateUEFCommanderBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )        
        end           
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        TWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        if (self.IdleAnim and not self:IsDead()) then
            self.Animator:PlayAnim(self.IdleAnim, true)
        end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightZephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    NotifyOfPodDeath = function(self, pod)
        if pod == 'LeftPod' then
            if self.HasRightPod then
                TWalkingLandUnit.CreateEnhancement(self, 'RightPodRemove') # cant use CreateEnhancement function
                TWalkingLandUnit.CreateEnhancement(self, 'LeftPod') #makes the correct upgrade icon light up
                if self.LeftPod and not self.LeftPod:IsDead() then
                    self.LeftPod:Kill()
                end
            else
                self:CreateEnhancement('LeftPodRemove')
            end
            self.HasLeftPod = false
        elseif pod == 'RightPod' then   #basically the same as above but we can use the CreateEnhancement function this time
            if self.HasLeftPod then
                TWalkingLandUnit.CreateEnhancement(self, 'RightPodRemove') # cant use CreateEnhancement function
                TWalkingLandUnit.CreateEnhancement(self, 'LeftPod') #makes the correct upgrade icon light up
                if self.LeftPod and not self.LeftPod:IsDead() then
                    self.RightPod:Kill()
                end
            else
                self:CreateEnhancement('LeftPodRemove')
            end
            self.HasRightPod = false

        elseif pod == 'SpySat' and self.SpysatEnabled then 
			self.Satellite = nil
			self:ForkThread(self.EXSatRespawn)
        end
        self:RequestRefreshUI()
    end,

    EXSatSpawn = function(self)
        if not self.Satellite and self.SpysatEnabled then
			local location = self:GetPosition('Torso')
			self.Satellite = CreateUnitHPR('EEA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
			self.Satellite:AttachTo(self, 'Back_IntelPack')
			self.Trash:Add(self.Satellite)
			self.Satellite.Parent = self
			self.Satellite:SetParent(self, 'SpySat')
			self:PlayUnitSound('LaunchSat')
			self.Satellite:DetachFrom()
			self.Satellite:Open()
        end
    end,

    EXSatRespawn = function(self)
        if self.SpysatEnabled then
			WaitSeconds(300)
			if self.SpysatEnabled and not self.Satellite then
				local location = self:GetPosition('Torso')
				self.Satellite = CreateUnitHPR('EEA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
				self.Satellite:AttachTo(self, 'Back_IntelPack')
				self.Trash:Add(self.Satellite)
				self.Satellite.Parent = self
				self.Satellite:SetParent(self, 'SpySat')
				self:PlayUnitSound('LaunchSat')
				self.Satellite:DetachFrom()
				self.Satellite:Open()
			end
		end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 0 then # shield toggle
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = {}
			end
			self:DisableShield()
			self:StopUnitAmbientSound( 'ActiveLoop' )
        elseif bit == 2 then 

        elseif bit == 8 then # cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('Sonar')
			self.RadarDish1:SetTargetSpeed(45)
        end
    end,

    OnScriptBitSet = function(self, bit)
        if bit == 0 then # shield toggle
			self.Rotator1:SetTargetSpeed(90)
			self.Rotator2:SetTargetSpeed(-180)
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = {}
			end
			for k, v in self.ShieldEffects2 do
				table.insert( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter01', self:GetArmy(), v ) )
				table.insert( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter02', self:GetArmy(), v ) )
				table.insert( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter03', self:GetArmy(), v ) )
				table.insert( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter04', self:GetArmy(), v ) )
				table.insert( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter05', self:GetArmy(), v ) )
				table.insert( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter06', self:GetArmy(), v ) )
				table.insert( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter07', self:GetArmy(), v ) )
				table.insert( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter08', self:GetArmy(), v ) )
			end
			self:EnableShield()
            self:PlayUnitAmbientSound( 'ActiveLoop' )
		elseif bit == 2 then

		elseif bit == 8 then # cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Radar')
            self:DisableUnitIntel('Sonar')
			self.RadarDish1:SetTargetSpeed(0)
        end
    end,

    WeaponRangeReset = function(self)
		if not self.wcFlamer01 then
			local wepFlamer01 = self:GetWeaponByLabel('EXFlameCannon01')
			wepFlamer01:ChangeMaxRadius(1)
		end
		if not self.wcFlamer02 then
			local wepFlamer02 = self:GetWeaponByLabel('EXFlameCannon02')
			wepFlamer02:ChangeMaxRadius(1)
		end
		if not self.wcTorp01 then
			local wepTorpedo01 = self:GetWeaponByLabel('EXTorpedoLauncher01')
			wepTorpedo01:ChangeMaxRadius(1)
		end
		if not self.wcTorp02 then
			local wepTorpedo02 = self:GetWeaponByLabel('EXTorpedoLauncher02')
			wepTorpedo02:ChangeMaxRadius(1)
		end
		if not self.wcTorp03 then
			local wepTorpedo03 = self:GetWeaponByLabel('EXTorpedoLauncher03')
			wepTorpedo03:ChangeMaxRadius(1)
		end
		if not self.wcAMC01 then
			local wepAntiMatter01 = self:GetWeaponByLabel('EXAntiMatterCannon01')
			wepAntiMatter01:ChangeMaxRadius(1)
		end
		if not self.wcAMC02 then
			local wepAntiMatter02 = self:GetWeaponByLabel('EXAntiMatterCannon02')
			wepAntiMatter02:ChangeMaxRadius(1)
		end
		if not self.wcAMC03 then
			local wepAntiMatter03 = self:GetWeaponByLabel('EXAntiMatterCannon03')
			wepAntiMatter03:ChangeMaxRadius(1)
		end
		if not self.wcGatling01 then
			local wepGattling01 = self:GetWeaponByLabel('EXGattlingEnergyCannon01')
			wepGattling01:ChangeMaxRadius(1)
		end
		if not self.wcGatling02 then
			local wepGattling02 = self:GetWeaponByLabel('EXGattlingEnergyCannon02')
			wepGattling02:ChangeMaxRadius(1)
		end
		if not self.wcGatling03 then
			local wepGattling03 = self:GetWeaponByLabel('EXGattlingEnergyCannon03')
			wepGattling03:ChangeMaxRadius(1)
		end
		if not self.wcLance01 then
			local wepLance01 = self:GetWeaponByLabel('EXEnergyLance01')
			wepLance01:ChangeMaxRadius(1)
		end
		if not self.wcLance02 then
			local wepLance02 = self:GetWeaponByLabel('EXEnergyLance02')
			wepLance02:ChangeMaxRadius(1)
		end
		if not self.wcCMissiles01 then
			local wepClusterMiss01 = self:GetWeaponByLabel('EXClusterMissles01')
			wepClusterMiss01:ChangeMaxRadius(1)
		end
		if not self.wcCMissiles02 then
			local wepClusterMiss02 = self:GetWeaponByLabel('EXClusterMissles02')
			wepClusterMiss02:ChangeMaxRadius(1)
		end
		if not self.wcCMissiles03 then
			local wepClusterMiss03 = self:GetWeaponByLabel('EXClusterMissles03')
			wepClusterMiss03:ChangeMaxRadius(1)
		end
		if not self.wcTMissiles01 then
			local wepTacMiss = self:GetWeaponByLabel('TacMissile')
			wepTacMiss:ChangeMaxRadius(1)
		end
		if not self.wcNMissiles01 then
			local wepNukeMiss = self:GetWeaponByLabel('TacNukeMissile')
			wepNukeMiss:ChangeMaxRadius(1)
		end
    end,

    WeaponConfigCheck = function(self)
		if self.wcBuildMode then
			self:SetWeaponEnabledByLabel('RightZephyr', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetWeaponEnabledByLabel('EXFlameCannon01', false)
			self:SetWeaponEnabledByLabel('EXFlameCannon02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', false)
			self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', false)
			self:SetWeaponEnabledByLabel('EXAntiMatterCannon03', false)
			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', false)
			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', false)
			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon03', false)
			self:SetWeaponEnabledByLabel('EXEnergyLance01', false)
			self:SetWeaponEnabledByLabel('EXEnergyLance02', false)
			self:SetWeaponEnabledByLabel('EXClusterMissles01', false)
			self:SetWeaponEnabledByLabel('EXClusterMissles02', false)
			self:SetWeaponEnabledByLabel('EXClusterMissles03', false)
			self:SetWeaponEnabledByLabel('TacMissile', false)
			self:SetWeaponEnabledByLabel('TacNukeMissile', false)
		end
		if self.wcOCMode then
			self:SetWeaponEnabledByLabel('RightZephyr', false)
			self:SetWeaponEnabledByLabel('EXFlameCannon01', false)
			self:SetWeaponEnabledByLabel('EXFlameCannon02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', false)
			self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', false)
			self:SetWeaponEnabledByLabel('EXAntiMatterCannon03', false)
			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', false)
			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', false)
			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon03', false)
			self:SetWeaponEnabledByLabel('EXEnergyLance01', false)
			self:SetWeaponEnabledByLabel('EXEnergyLance02', false)
		end
		if not self.wcBuildMode and not self.wcOCMode then
			self:SetWeaponEnabledByLabel('RightZephyr', true)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			if self.wcFlamer01 then
				self:SetWeaponEnabledByLabel('EXFlameCannon01', true)
				local wepFlamer01 = self:GetWeaponByLabel('EXFlameCannon01')
				wepFlamer01:ChangeMaxRadius(22)
			else
				self:SetWeaponEnabledByLabel('EXFlameCannon01', false)
			end
			if self.wcFlamer02 then
				self:SetWeaponEnabledByLabel('EXFlameCannon02', true)
				local wepFlamer02 = self:GetWeaponByLabel('EXFlameCannon02')
				wepFlamer02:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXFlameCannon02', false)
			end
			if self.wcTorp01 then
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', true)
				local wepTorpedo01 = self:GetWeaponByLabel('EXTorpedoLauncher01')
				wepTorpedo01:ChangeMaxRadius(60)
			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			end
			if self.wcTorp02 then
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', true)
				local wepTorpedo02 = self:GetWeaponByLabel('EXTorpedoLauncher02')
				wepTorpedo02:ChangeMaxRadius(60)
			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			end
			if self.wcTorp03 then
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', true)
				local wepTorpedo03 = self:GetWeaponByLabel('EXTorpedoLauncher03')
				wepTorpedo03:ChangeMaxRadius(60)
			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			end
			if self.wcAMC01 then
				self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', true)
				local wepAntiMatter01 = self:GetWeaponByLabel('EXAntiMatterCannon01')
				wepAntiMatter01:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', false)
			end
			if self.wcAMC02 then
				self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', true)
				local wepAntiMatter02 = self:GetWeaponByLabel('EXAntiMatterCannon02')
				wepAntiMatter02:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', false)
			end
			if self.wcAMC03 then
				self:SetWeaponEnabledByLabel('EXAntiMatterCannon03', true)
				local wepAntiMatter03 = self:GetWeaponByLabel('EXAntiMatterCannon03')
				wepAntiMatter03:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXAntiMatterCannon03', false)
			end
			if self.wcGatling01 then
				self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', true)
				local wepGattling01 = self:GetWeaponByLabel('EXGattlingEnergyCannon01')
				wepGattling01:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', false)
			end
			if self.wcGatling02 then
				self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', true)
				local wepGattling02 = self:GetWeaponByLabel('EXGattlingEnergyCannon02')
				wepGattling02:ChangeMaxRadius(40)
			else
				self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', false)
			end
			if self.wcGatling03 then
				self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon03', true)
				local wepGattling03 = self:GetWeaponByLabel('EXGattlingEnergyCannon03')
				wepGattling03:ChangeMaxRadius(45)
			else
				self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon03', false)
			end
			if self.wcLance01 then
				self:SetWeaponEnabledByLabel('EXEnergyLance01', true)
				local wepLance01 = self:GetWeaponByLabel('EXEnergyLance01')
				wepLance01:ChangeMaxRadius(22)
			else
				self:SetWeaponEnabledByLabel('EXEnergyLance01', false)
			end
			if self.wcLance02 then
				self:SetWeaponEnabledByLabel('EXEnergyLance02', true)
				local wepLance02 = self:GetWeaponByLabel('EXEnergyLance02')
				wepLance02:ChangeMaxRadius(22)
			else
				self:SetWeaponEnabledByLabel('EXEnergyLance02', false)
			end
			if self.wcCMissiles01 then
				self:SetWeaponEnabledByLabel('EXClusterMissles01', true)
				local wepClusterMiss01 = self:GetWeaponByLabel('EXClusterMissles01')
				wepClusterMiss01:ChangeMaxRadius(90)
			else
				self:SetWeaponEnabledByLabel('EXClusterMissles01', false)
			end
			if self.wcCMissiles02 then
				self:SetWeaponEnabledByLabel('EXClusterMissles02', true)
				local wepClusterMiss02 = self:GetWeaponByLabel('EXClusterMissles02')
				wepClusterMiss02:ChangeMaxRadius(90)
			else
				self:SetWeaponEnabledByLabel('EXClusterMissles02', false)
			end
			if self.wcCMissiles03 then
				self:SetWeaponEnabledByLabel('EXClusterMissles03', true)
				local wepClusterMiss03 = self:GetWeaponByLabel('EXClusterMissles03')
				wepClusterMiss03:ChangeMaxRadius(90)
			else
				self:SetWeaponEnabledByLabel('EXClusterMissles03', false)
			end
			if self.wcTMissiles01 then
				self:SetWeaponEnabledByLabel('TacMissile', true)
				local wepTacMiss = self:GetWeaponByLabel('TacMissile')
				wepTacMiss:ChangeMaxRadius(256)
			else
				self:SetWeaponEnabledByLabel('TacMissile', false)
			end
			if self.wcNMissiles01 then
				self:SetWeaponEnabledByLabel('TacNukeMissile', true)
				local wepNukeMiss = self:GetWeaponByLabel('TacNukeMissile')
				wepNukeMiss:ChangeMaxRadius(256)
			else
				self:SetWeaponEnabledByLabel('TacNukeMissile', false)
			end
		end
    end,

    OnTransportDetach = function(self, attachBone, unit)
        TWalkingLandUnit.OnTransportDetach(self, attachBone, unit)
		self:StopSiloBuild()
        self:ForkThread(self.WeaponConfigCheck)
    end,

    CreateEnhancement = function(self, enh)
	
        TWalkingLandUnit.CreateEnhancement(self, enh)
		
        local bp = self:GetBlueprint().Enhancements[enh]

        if enh =='EXImprovedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Imp_Eng')
			
			self.RBImpEngineering = true
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			
        elseif enh =='EXImprovedEngineeringRemove' then
			
            if Buff.HasBuff( self, 'ACU_T2_Imp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Imp_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			
        elseif enh =='EXAdvancedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Adv_Eng')

			self.RBImpEngineering = true
			self.RBAdvEngineering = true
			self.RBExpEngineering = false
			
        elseif enh =='EXAdvancedEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Adv_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Adv_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			
        elseif enh =='EXExperimentalEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Exp_Eng')			

			self.RBImpEngineering = true
			self.RBAdvEngineering = true
			self.RBExpEngineering = true
			
		elseif enh =='EXExperimentalEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Exp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Exp_Eng' )
            end		

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false

        elseif enh =='EXCombatEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Combat_Eng')

			self.wcFlamer01 = true
			self.wcFlamer02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = true
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
        elseif enh =='EXCombatEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T2_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcFlamer01 = false
			self.wcFlamer02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
        elseif enh =='EXAssaultEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Combat_Eng')

			self.wcFlamer01 = false
			self.wcFlamer02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = false
			
        elseif enh =='EXAssaultEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Combat_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcFlamer01 = false
			self.wcFlamer02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
        elseif enh =='EXApocolypticEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Combat_Eng')
			
			self.wcFlamer01 = false
			self.wcFlamer02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = true
			
        elseif enh =='EXApocolypticEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcFlamer01 = false
			self.wcFlamer02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false

		elseif enh =='EXZephyrBooster' then
            local wepZephyr = self:GetWeaponByLabel('RightZephyr')
            wepZephyr:AddDamageMod(50)
			wepZephyr:ChangeMaxRadius(self:GetBlueprint().Weapon[1].MaxRadius + 5)
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius + 5)
			self:ShowBone('Zephyr_Amplifier', true)
			
        elseif enh =='EXZephyrBoosterRemove' then
            local wepZephyr = self:GetWeaponByLabel('RightZephyr')
            wepZephyr:AddDamageMod(-50)
			wepZephyr:ChangeMaxRadius(self:GetBlueprint().Weapon[1].MaxRadius)
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
			self:HideBone('Zephyr_Amplifier', true)
			
        elseif enh =='EXTorpedoLauncher' then
			self.wcTorp01 = true
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXTorpedoLauncherRemove' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXTorpedoRapidLoader' then
			self.wcTorp01 = false
			self.wcTorp02 = true
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXTorpedoRapidLoaderRemove' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

		elseif enh =='EXTorpedoClusterLauncher' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXTorpedoClusterLauncherRemove' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXAntiMatterCannon' then
			self.wcAMC01 = true
			self.wcAMC02 = false
			self.wcAMC03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXAntiMatterCannonRemove' then
			self.wcAMC01 = false
			self.wcAMC02 = false
			self.wcAMC03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedContainmentBottle' then
			self.wcAMC01 = false
			self.wcAMC02 = true
			self.wcAMC03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXImprovedContainmentBottleRemove' then    
			self.wcAMC01 = false
			self.wcAMC02 = false
			self.wcAMC03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXPowerBooster' then
            self.wcAMC01 = false
			self.wcAMC02 = false
			self.wcAMC03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)     

        elseif enh =='EXPowerBoosterRemove' then    
			self.wcAMC01 = false
			self.wcAMC02 = false
			self.wcAMC03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXGattlingEnergyCannon' then
			self.wcGatling01 = true
			self.wcGatling02 = false
			self.wcGatling03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXGattlingEnergyCannonRemove' then
			self.wcGatling01 = false
			self.wcGatling02 = false
			self.wcGatling03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedCoolingSystem' then
            self.wcGatling01 = false
			self.wcGatling02 = true
			self.wcGatling03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXImprovedCoolingSystemRemove' then
			self.wcGatling01 = false
			self.wcGatling02 = false
			self.wcGatling03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXEnergyShellHardener' then
            self.wcGatling01 = false
			self.wcGatling02 = false
			self.wcGatling03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXEnergyShellHardenerRemove' then
			self.wcGatling01 = false
			self.wcGatling02 = false
			self.wcGatling03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXShieldBattery' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreatePersonalShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
			self.Rotator1:SetTargetSpeed(90)
			self.Rotator2:SetTargetSpeed(-180)

		elseif enh == 'EXShieldBatteryRemove' then
            self:DestroyShield()
            RemoveUnitEnhancement(self, 'EXShieldBatteryRemove')
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = {}
			end
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)

        elseif enh == 'EXActiveShielding' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
				self:CreatePersonalShield(bp)
            end)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
			self.wcLance01 = true
			self.wcLance02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXActiveShieldingRemove' then
            self:DestroyShield()
            RemoveUnitEnhancement(self, 'EXActiveShieldingRemove')
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = {}
			end
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)
			self.wcLance01 = false
			self.wcLance02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXImprovedShieldBattery' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
				self:CreatePersonalShield(bp)
            end)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()

        elseif enh == 'EXImprovedShieldBatteryRemove' then
            self:DestroyShield()
            RemoveUnitEnhancement(self, 'EXImprovedShieldBatteryRemove')
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = {}
			end
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)
			self.wcLance01 = false
			self.wcLance02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXShieldExpander' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
                self:CreateShield(bp)
            end)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()

        elseif enh == 'EXShieldExpanderRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = {}
			end
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)
			self.wcLance01 = false
			self.wcLance02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXElectronicsEnhancment' then
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 50)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 50)
			self.RadarDish1:SetTargetSpeed(45)

			self.wcLance01 = true
			self.wcLance02 = false
			self.RBIntTier1 = true
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXElectronicsEnhancmentRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
			self.RadarDish1:SetTargetSpeed(0)

			self.wcLance01 = false
			self.wcLance02 = false
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh == 'EXElectronicCountermeasures' then
			self.SpysatEnabled = true
			self:ForkThread(self.EXSatSpawn)
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false        
            self.StealthEnh = true

			self.wcLance01 = true
			self.wcLance02 = true
			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXElectronicCountermeasuresRemove' then
			self.SpysatEnabled = false
			if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
				self.Satellite:Kill()
			end
			self.Satellite = nil
			self.StealthEnh = false
            self.CloakEnh = false 
            self.StealthFieldEffects = false
            self.CloakingEffects = false     
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
			self.RadarDish1:SetTargetSpeed(0)

			self.wcLance01 = false
			self.wcLance02 = false
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXCloakingSubsystems' then
            self:AddCommandCap('RULEUCC_Teleport')

			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXCloakingSubsystemsRemove' then
			self.SpysatEnabled = false
			if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
				self.Satellite:Kill()
			end
			self.Satellite = nil
            self.StealthEnh = false
            self.CloakEnh = false 
            self.StealthFieldEffects = false
            self.CloakingEffects = false     
            self:RemoveCommandCap('RULEUCC_Teleport')
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
			self.RadarDish1:SetTargetSpeed(0)

			self.wcLance01 = false
			self.wcLance02 = false
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXClusterMisslePack' then
			self.wcCMissiles01 = true
			self.wcCMissiles02 = false
			self.wcCMissiles03 = false
			self.wcTMissiles01 = false
			self.wcNMissiles01 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = true
			self.RBComTier2 = false
			self.RBComTier3 = false

        elseif enh =='EXClusterMisslePackRemove' then
			self.wcCMissiles01 = false
			self.wcCMissiles02 = false
			self.wcCMissiles03 = false
			self.wcTMissiles01 = false
			self.wcNMissiles01 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:StopSiloBuild()
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false

        elseif enh =='EXTacticalMisslePack' then
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')

            self.wcCMissiles01 = false
			self.wcCMissiles02 = true
			self.wcCMissiles03 = false
			self.wcTMissiles01 = true
			self.wcNMissiles01 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)     
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = false

        elseif enh =='EXTacticalNukeSubstitution' then
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:AddCommandCap('RULEUCC_Nuke')
            self:AddCommandCap('RULEUCC_SiloBuildNuke')
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()

            self.wcCMissiles01 = false
			self.wcCMissiles02 = false
			self.wcCMissiles03 = true
			self.wcTMissiles01 = false
			self.wcNMissiles01 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)    
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = true

        elseif enh == 'EXTacticalMisslePackRemove' then
            self:RemoveCommandCap('RULEUCC_Nuke')
            self:RemoveCommandCap('RULEUCC_SiloBuildNuke')
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            local amt = self:GetNukeSiloAmmoCount()
            self:RemoveNukeSiloAmmo(amt or 0)
            self:StopSiloBuild()

            self.wcCMissiles01 = false
			self.wcCMissiles02 = false
			self.wcCMissiles03 = false
			self.wcTMissiles01 = false
			self.wcNMissiles01 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false

        elseif enh == 'EXTacticalNukeSubstitutionRemove' then
            self:RemoveCommandCap('RULEUCC_Nuke')
            self:RemoveCommandCap('RULEUCC_SiloBuildNuke')
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            local amt = self:GetNukeSiloAmmoCount()
            self:RemoveNukeSiloAmmo(amt or 0)
            self:StopSiloBuild()

            self.wcCMissiles01 = false
			self.wcCMissiles02 = false
			self.wcCMissiles03 = false
			self.wcTMissiles01 = false
			self.wcNMissiles01 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false

        elseif enh == 'LeftPod' or enh == 'RightPod' then
            TWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here so this happens only once for each enhancement
            -- making sure we have up to date information (dont delete! needed for bug fix below)
            if not self.LeftPod or self.LeftPod:IsDead() then
                self.HasLeftPod = false
            end
            if not self.RightPod or self.RightPod:IsDead() then
                self.HasRightPod = false
            end
            -- fix for a bug that occurs when pod 1 is destroyed while upgrading to get pod 2
            if enh == 'RightPod' and (not self.HasLeftPod or not self.HasRightPod) then
                TWalkingLandUnit.CreateEnhancement(self, 'RightPodRemove')
                TWalkingLandUnit.CreateEnhancement(self, 'LeftPod')
            end
            -- add new pod to left or right
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
            -- highlight correct icons: right if we have 2 pods, left if we have 1 pod (no other possibilities)
            if self.HasLeftPod and self.HasRightPod then
                TWalkingLandUnit.CreateEnhancement(self, 'RightPod')
            else
                TWalkingLandUnit.CreateEnhancement(self, 'LeftPod')
            end
        -- for removing the pod upgrades
        elseif enh == 'RightPodRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here so this happens only once for each enhancement
            if self.RightPod and not self.RightPod:IsDead() then
                self.RightPod:Kill()
                self.HasRightPod = false
            end
            if self.LeftPod and not self.LeftPod:IsDead() then
                self.LeftPod:Kill()
                self.HasLeftPod = false
            end
        elseif enh == 'LeftPodRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here so this happens only once for each enhancement
            if self.LeftPod and not self.LeftPod:IsDead() then
                self.LeftPod:Kill()
                self.HasLeftPod = false
            end
		end
    end,

    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Head',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Torso',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Head',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Torso',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
		Jammer = {
		    {
			    Bones = {
				    'Torso',
			    },
				Scale = 0.5,
				Type = 'Jammer01',
		    },	
        },	
    },
	
    OnIntelEnabled = function(self)
        TWalkingLandUnit.OnIntelEnabled(self)
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then 
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['EXCloakingSubsystems'].MaintenanceConsumptionPerSecondEnergy or 1)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
			    self.IntelEffectsBag = {}
			    self.CreateTerrainTypeEffects( self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
			end            
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['EXElectronicCountermeasures'].MaintenanceConsumptionPerSecondEnergy or 1)
            self:SetMaintenanceConsumptionActive()  
            if not self.IntelEffectsBag then 
	            self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
				--self.CreateTerrainTypeEffects( self, self.IntelEffects.Jammer, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		    end                  
        end		
    end,

    OnIntelDisabled = function(self)
        TWalkingLandUnit.OnIntelDisabled(self)
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

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
            self.Satellite:Kill()
			self.Satellite = nil
        end
        TWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    OnDestroy = function(self)
        if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
            self.Satellite:Destroy()
			self.Satellite = nil
        end
        TWalkingLandUnit.OnDestroy(self)
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

    ShieldEffects2 = {
        '/mods/BlackopsACUs/effects/emitters/ex_uef_shieldgen_01_emit.bp',
    },

    FlamerEffects = {
        '/mods/BlackopsACUs/effects/emitters/ex_flamer_torch_01.bp',
    },

}

TypeClass = EEL0001