#****************************************************************************
#**
#**  Author(s):  Exavier Macbeth
#**
#**  Summary  :  BlackOps: Adv Command Unit - Serephim ACU
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local Buff = import('/lua/sim/Buff.lua')

local SWeapons = import('/lua/seraphimweapons.lua')
local SDFChronotronCannonWeapon = SWeapons.SDFChronotronCannonWeapon
local SDFChronotronOverChargeCannonWeapon = SWeapons.SDFChronotronCannonOverChargeWeapon
local SIFCommanderDeathWeapon = SWeapons.SIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local SIFLaanseTacticalMissileLauncher = SWeapons.SIFLaanseTacticalMissileLauncher
local AIUtils = import('/lua/ai/aiutilities.lua')
local SDFAireauWeapon = SWeapons.SDFAireauWeapon
local SDFSinnuntheWeapon = SWeapons.SDFSinnuntheWeapon
local SANUallCavitationTorpedo = SWeapons.SANUallCavitationTorpedo
local SeraACURapidWeapon = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').SeraACURapidWeapon 
local SeraACUBigBallWeapon = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').SeraACUBigBallWeapon 
local SAAOlarisCannonWeapon = SWeapons.SAAOlarisCannonWeapon

# Setup as RemoteViewing child unit rather than SWalkingLandUnit
local RemoteViewing = import('/lua/RemoteViewing.lua').RemoteViewing
SWalkingLandUnit = RemoteViewing( SWalkingLandUnit ) 

local OldESL0001 = ESL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

ESL0001 = Hunker.AddHunker(OldESL0001)

--[[

ESL0001 = Class( SWalkingLandUnit ) {
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
        ChronotronCannon = Class(SDFChronotronCannonWeapon) {},
        EXTorpedoLauncher01 = Class(SANUallCavitationTorpedo) {},
        EXTorpedoLauncher02 = Class(SANUallCavitationTorpedo) {},
        EXTorpedoLauncher03 = Class(SANUallCavitationTorpedo) {},
        EXBigBallCannon01 = Class(SeraACUBigBallWeapon) {
            PlayFxMuzzleChargeSequence = function(self, muzzle)
                #CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
                if not self.ClawTopRotator then 
                    self.ClawTopRotator = CreateRotator(self.unit, 'Pincer_Upper', 'x')
                    self.ClawBottomRotator = CreateRotator(self.unit, 'Pincer_Lower', 'x')
                    
                    self.unit.Trash:Add(self.ClawTopRotator)
                    self.unit.Trash:Add(self.ClawBottomRotator)
                end
                
                self.ClawTopRotator:SetGoal(-15):SetSpeed(10)
                self.ClawBottomRotator:SetGoal(15):SetSpeed(10)
                
                SDFSinnuntheWeapon.PlayFxMuzzleChargeSequence(self, muzzle)
                
                self:ForkThread(function()
                    WaitSeconds(self.unit:GetBlueprint().Weapon[7].MuzzleChargeDelay)
                    
                    self.ClawTopRotator:SetGoal(0):SetSpeed(50)
                    self.ClawBottomRotator:SetGoal(0):SetSpeed(50)
                end)
            end,
		},
        EXBigBallCannon02 = Class(SeraACUBigBallWeapon) {
            PlayFxMuzzleChargeSequence = function(self, muzzle)
                #CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
                if not self.ClawTopRotator then 
                    self.ClawTopRotator = CreateRotator(self.unit, 'Pincer_Upper', 'x')
                    self.ClawBottomRotator = CreateRotator(self.unit, 'Pincer_Lower', 'x')
                    
                    self.unit.Trash:Add(self.ClawTopRotator)
                    self.unit.Trash:Add(self.ClawBottomRotator)
                end
                
                self.ClawTopRotator:SetGoal(-15):SetSpeed(10)
                self.ClawBottomRotator:SetGoal(15):SetSpeed(10)
                
                SDFSinnuntheWeapon.PlayFxMuzzleChargeSequence(self, muzzle)
                
                self:ForkThread(function()
                    WaitSeconds(self.unit:GetBlueprint().Weapon[8].MuzzleChargeDelay)
                    
                    self.ClawTopRotator:SetGoal(0):SetSpeed(50)
                    self.ClawBottomRotator:SetGoal(0):SetSpeed(50)
                end)
            end,
		},
        EXBigBallCannon03 = Class(SeraACUBigBallWeapon) {
            PlayFxMuzzleChargeSequence = function(self, muzzle)
                #CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
                if not self.ClawTopRotator then 
                    self.ClawTopRotator = CreateRotator(self.unit, 'Pincer_Upper', 'x')
                    self.ClawBottomRotator = CreateRotator(self.unit, 'Pincer_Lower', 'x')
                    
                    self.unit.Trash:Add(self.ClawTopRotator)
                    self.unit.Trash:Add(self.ClawBottomRotator)
                end
                
                self.ClawTopRotator:SetGoal(-15):SetSpeed(10)
                self.ClawBottomRotator:SetGoal(15):SetSpeed(10)
                
                SDFSinnuntheWeapon.PlayFxMuzzleChargeSequence(self, muzzle)
                
                self:ForkThread(function()
                    WaitSeconds(self.unit:GetBlueprint().Weapon[9].MuzzleChargeDelay)
                    
                    self.ClawTopRotator:SetGoal(0):SetSpeed(50)
                    self.ClawBottomRotator:SetGoal(0):SetSpeed(50)
                end)
            end,
		},
        EXRapidCannon01 = Class(SeraACURapidWeapon) {},
        EXRapidCannon02 = Class(SeraACURapidWeapon) {},
        EXRapidCannon03 = Class(SeraACURapidWeapon) {},
        EXAA01 = Class(SAAOlarisCannonWeapon) {},
        EXAA02 = Class(SAAOlarisCannonWeapon) {},
        Missile = Class(SIFLaanseTacticalMissileLauncher) {
            CurrentRack = 1,
                
            PlayFxMuzzleSequence = function(self, muzzle)
                local bp = self:GetBlueprint()
                self.MissileRotator = CreateRotator(self.unit, bp.RackBones[self.CurrentRack].RackBone, 'x', nil, 0, 0, 0)
                muzzle = bp.RackBones[self.CurrentRack].MuzzleBones[1]
                self.MissileRotator:SetGoal(-10):SetSpeed(10)
                SIFLaanseTacticalMissileLauncher.PlayFxMuzzleSequence(self, muzzle)
                WaitFor(self.MissileRotator)
                WaitTicks(1)
            end,
                
            CreateProjectileAtMuzzle = function(self, muzzle)
                muzzle = self:GetBlueprint().RackBones[self.CurrentRack].MuzzleBones[1]
                if self.CurrentRack >= 2 then
                    self.CurrentRack = 1
                else
                    self.CurrentRack = self.CurrentRack + 1
                end
                SIFLaanseTacticalMissileLauncher.CreateProjectileAtMuzzle(self, muzzle)
            end,
                
            PlayFxRackReloadSequence = function(self)
                WaitTicks(1)
                self.MissileRotator:SetGoal(0):SetSpeed(10)
                WaitFor(self.MissileRotator)
                self.MissileRotator:Destroy()
                self.MissileRotator = nil
            end,
        },
        OverCharge = Class(SDFChronotronOverChargeCannonWeapon) {

            OnCreate = function(self)
                SDFChronotronOverChargeCannonWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                SDFChronotronOverChargeCannonWeapon.OnEnableWeapon(self)
				self.unit.EXOCFire = true
				self:ForkThread(self.EXOCRecloakTimer)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('ChronotronCannon', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
            end,
            
            EXOCRecloakTimer = function(self)
				WaitSeconds(5)
				self.unit.EXOCFire = false
            end,

            OnWeaponFired = function(self)
                SDFChronotronOverChargeCannonWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('ChronotronCannon', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    SDFChronotronOverChargeCannonWeapon.OnFire(self)
                end
            end,
            IdleState = State(SDFChronotronOverChargeCannonWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        SDFChronotronOverChargeCannonWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(SDFChronotronOverChargeCannonWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        SDFChronotronOverChargeCannonWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },  
        },
    },


    OnCreate = function(self)
        SWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetupBuildBones()
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        SWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self.wcBuildMode = true
		self:ForkThread(self.WeaponConfigCheck)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        SWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        SWalkingLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        SWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:DisableRemoteViewingButtons()
        self:ForkThread(self.GiveInitialResources)
        self.ShieldEffectsBag = {}
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('CloakField')
		self:HideBone('Engineering', true)
		self:HideBone('Combat_Engineering', true)
		self:HideBone('Rapid_Cannon', true)
		self:HideBone('Basic_Gun_Up', true)
		self:HideBone('Big_Ball_Cannon', true)
		self:HideBone('Torpedo_Launcher', true)
		self:HideBone('Missile_Launcher', true)
		self:HideBone('IntelPack', true)
		self:HideBone('L_Spinner_B01', true)
		self:HideBone('L_Spinner_B02', true)
		self:HideBone('L_Spinner_B03', true)
		self:HideBone('S_Spinner_B01', true)
		self:HideBone('S_Spinner_B02', true)
		self:HideBone('S_Spinner_B03', true)
		self:HideBone('Left_AA_Mount', true)
		self:HideBone('Right_AA_Mount', true)
		self.lambdaEmitterTable = {}
		if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'S_Spinner_B01', 'y' )
            self.Trash:Add( self.RotatorManipulator1 )
        end
        self.RotatorManipulator1:SetAccel( 30 )
        self.RotatorManipulator1:SetTargetSpeed( 120 )
		if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'L_Spinner_B01', 'y' )
            self.Trash:Add( self.RotatorManipulator2 )
        end
        self.RotatorManipulator2:SetAccel( -15 )
        self.RotatorManipulator2:SetTargetSpeed( -60 )
		self.wcBuildMode = false
		self.wcOCMode = false
		self.wcTorp01 = false
		self.wcTorp02 = false
		self.wcTorp03 = false
		self.wcBigBall01 = false
		self.wcBigBall02 = false
		self.wcBigBall03 = false
		self.wcRapid01 = false
		self.wcRapid02 = false
		self.wcRapid03 = false
		self.wcAA01 = false
		self.wcAA02 = false
		self.wcTMissiles01 = false
		self:ForkThread(self.WeaponRangeReset)
		self:ForkThread(self.WeaponConfigCheck)
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
		self.EXCloakOn = false
		self.EXCloakTele = false
		self.EXMoving = false
		self.EXOCFire = false
		self.regenammount = 0
		self:ForkThread(self.EXRegenBuffThread)
		self:ForkThread(self.EXRegenHeartbeat)
		self.DefaultGunBuffApplied = false
    end,

    OnFailedToBuild = function(self)
        SWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
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
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
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
        self:ShowBone(0, true)
        self:SetUnSelectable(false)
        self:SetBusy(false)
        self:SetBlockCommandQueue(false)
		self:HideBone('Engineering', true)
		self:HideBone('Combat_Engineering', true)
		self:HideBone('Rapid_Cannon', true)
		self:HideBone('Basic_Gun_Up', true)
		self:HideBone('Big_Ball_Cannon', true)
		self:HideBone('Torpedo_Launcher', true)
		self:HideBone('Missile_Launcher', true)
		self:HideBone('IntelPack', true)
		self:HideBone('L_Spinner_B01', true)
		self:HideBone('L_Spinner_B02', true)
		self:HideBone('L_Spinner_B03', true)
		self:HideBone('S_Spinner_B01', true)
		self:HideBone('S_Spinner_B02', true)
		self:HideBone('S_Spinner_B03', true)
		self:HideBone('Left_AA_Mount', true)
		self:HideBone('Right_AA_Mount', true)
        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end

        WaitSeconds(6)
    end,

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    EXRegenBuffThread = function(self)
		--if Buff.HasBuff( self, 'EXRegenBoost' ) then
		--	Buff.RemoveBuff( self, 'EXRegenBoost' )
		--end
		self.regenammount = 0
		local EXBP = self:GetBlueprint()
		if self.RBImpEngineering then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXImprovedEngineering.NewRegenRate
		end
		if self.RBAdvEngineering then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXAdvancedEngineering.NewRegenRate
		end
		if self.RBExpEngineering then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXExperimentalEngineering.NewRegenRate
		end
		if self.RBComEngineering then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXCombatEngineering.NewRegenRate
		end
		if self.RBAssEngineering then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXAssaultEngineering.NewRegenRate
		end
		if self.RBApoEngineering then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXApocolypticEngineering.NewRegenRate
		end
		if self.RBDefTier1 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXL1Lambda.NewRegenRate
		end
		if self.RBDefTier2 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXL2Lambda.NewRegenRate
		end
		if self.RBDefTier3 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXL3Lambda.NewRegenRate
		end
		if self.RBComTier1 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXBasicDefence.NewRegenRate
		end
		if self.RBComTier2 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXTacticalMisslePack.NewRegenRate
		end
		if self.RBComTier3 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXOverchargeOverdrive.NewRegenRate
		end
		if self.RBIntTier1 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXElectronicsEnhancment.NewRegenRate
		end
		if self.RBIntTier2 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXElectronicCountermeasures.NewRegenRate
		end
		if self.RBIntTier3 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXCloakingSubsystems.NewRegenRate
		end		
		--if not Buffs['EXRegenBoost'] then
        --    BuffBlueprint {
        --        Name = 'EXRegenBoost',
        --        DisplayName = 'EXRegenBoost',
        --        BuffType = 'EXRegenBoost',
        --        Stacks = 'REPLACE',
        --        Duration = -1,
        --        Affects = {
        --            Regen = {
        --                Add = self.regenammount,
        --                Mult = 1.0,
        --            },
        --        },
        --    }
        --end
        --Buff.ApplyBuff(self, 'EXRegenBoost')
		--LOG('xxxxxxxxxxxx Sera Applied Regen', self.regenammount)
    end,

	EXRegenHeartbeat = function(self)
		if self.RBIntTier3 then
			if not self.EXCloakingThread then
				self.EXCloakingThread = self:ForkThread(self.EXCloakControl)
			end
		end
		self.regenapply = self.regenammount / 10
		self.HealthDiff = self:GetMaxHealth() - self:GetHealth()
		if self.HealthDiff <= self.regenapply then
			self:SetHealth(self, self:GetHealth() + self.HealthDiff)
			--LOG('xxxxxxxxxxxx Applied HealthDif', self.HealthDiff)
		elseif self.HealthDiff >= self.regenapply then
			self:SetHealth(self, self:GetHealth() + self.regenapply)
			--LOG('xxxxxxxxxxxx Applied Regen', self.regenapply)
		end
		WaitSeconds(0.1)
		--LOG('xxxxxxxxxxxx Heartbeat Delay and Reset')
		self:ForkThread(self.EXRegenHeartbeat)
	end,

	EXCloakControl = function(self)
		if self.EXMoving then
			if self.RBIntTier3 then
				if self:IsIntelEnabled('Cloak') then
				self:DisableUnitIntel('Cloak')
				self:DisableUnitIntel('RadarStealth')
				--self:DisableUnitIntel('SonarStealth')
			end
			end
		elseif self.EXCloakTele then
			if self.RBIntTier3 then
				if self:IsIntelEnabled('Cloak') then
				self:DisableUnitIntel('Cloak')
				self:DisableUnitIntel('RadarStealth')
				--self:DisableUnitIntel('SonarStealth')
			end
			end
		elseif self.EXOCFire then
			if self.RBIntTier3 then
				if self:IsIntelEnabled('Cloak') then
				self:DisableUnitIntel('Cloak')
				self:DisableUnitIntel('RadarStealth')
				--self:DisableUnitIntel('SonarStealth')
			end
			end
		else
			if self.RBIntTier3 then
				if not self:IsIntelEnabled('Cloak') then
				self:EnableUnitIntel('Cloak')
				self:EnableUnitIntel('RadarStealth')
				--self:EnableUnitIntel('SonarStealth')
			end
			end
		end
		WaitSeconds(1)
		self.EXCloakingThread = nil
	end,

    DefaultGunBuffThread = function(self)
		if not self.DefaultGunBuffApplied then
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
			wepChronotron:AddDamageMod(100)
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            wepOvercharge:ChangeMaxRadius(30)
			self:ShowBone('Basic_Gun_Up', true)
			self.DefaultGunBuffApplied = true
		end
    end,

    WeaponRangeReset = function(self)
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
		if not self.wcBigBall01 then
			local wepAntiMatter01 = self:GetWeaponByLabel('EXBigBallCannon01')
			wepAntiMatter01:ChangeMaxRadius(1)
		end
		if not self.wcBigBall02 then
			local wepAntiMatter02 = self:GetWeaponByLabel('EXBigBallCannon02')
			wepAntiMatter02:ChangeMaxRadius(1)
		end
		if not self.wcBigBall03 then
			local wepAntiMatter03 = self:GetWeaponByLabel('EXBigBallCannon03')
			wepAntiMatter03:ChangeMaxRadius(1)
		end
		if not self.wcRapid01 then
			local wepGattling01 = self:GetWeaponByLabel('EXRapidCannon01')
			wepGattling01:ChangeMaxRadius(1)
		end
		if not self.wcRapid02 then
			local wepGattling02 = self:GetWeaponByLabel('EXRapidCannon02')
			wepGattling02:ChangeMaxRadius(1)
		end
		if not self.wcRapid03 then
			local wepGattling03 = self:GetWeaponByLabel('EXRapidCannon03')
			wepGattling03:ChangeMaxRadius(1)
		end
		if not self.wcAA01 then
			local wepLance01 = self:GetWeaponByLabel('EXAA01')
			wepLance01:ChangeMaxRadius(1)
		end
		if not self.wcAA02 then
			local wepLance02 = self:GetWeaponByLabel('EXAA02')
			wepLance02:ChangeMaxRadius(1)
		end
		if not self.wcTMissiles01 then
			local wepTacMiss = self:GetWeaponByLabel('Missile')
			wepTacMiss:ChangeMaxRadius(1)
		end
    end,
	
    WeaponConfigCheck = function(self)
		if self.wcBuildMode then
			self:SetWeaponEnabledByLabel('ChronotronCannon', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXBigBallCannon01', false)
			self:SetWeaponEnabledByLabel('EXBigBallCannon02', false)
			self:SetWeaponEnabledByLabel('EXBigBallCannon03', false)
			self:SetWeaponEnabledByLabel('EXRapidCannon01', false)
			self:SetWeaponEnabledByLabel('EXRapidCannon02', false)
			self:SetWeaponEnabledByLabel('EXRapidCannon03', false)
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)
			self:SetWeaponEnabledByLabel('Missile', false)
		end
		if self.wcOCMode then
			self:SetWeaponEnabledByLabel('ChronotronCannon', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXBigBallCannon01', false)
			self:SetWeaponEnabledByLabel('EXBigBallCannon02', false)
			self:SetWeaponEnabledByLabel('EXBigBallCannon03', false)
			self:SetWeaponEnabledByLabel('EXRapidCannon01', false)
			self:SetWeaponEnabledByLabel('EXRapidCannon02', false)
			self:SetWeaponEnabledByLabel('EXRapidCannon03', false)
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)
		end
		if not self.wcBuildMode and not self.wcOCMode then
			self:SetWeaponEnabledByLabel('ChronotronCannon', true)
			self:SetWeaponEnabledByLabel('OverCharge', false)
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
			if self.wcBigBall01 then
				self:SetWeaponEnabledByLabel('EXBigBallCannon01', true)
				local wepAntiMatter01 = self:GetWeaponByLabel('EXBigBallCannon01')
				wepAntiMatter01:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXBigBallCannon01', false)
			end
			if self.wcBigBall02 then
				self:SetWeaponEnabledByLabel('EXBigBallCannon02', true)
				local wepAntiMatter02 = self:GetWeaponByLabel('EXBigBallCannon02')
				wepAntiMatter02:ChangeMaxRadius(40)
			else
				self:SetWeaponEnabledByLabel('EXBigBallCannon02', false)
			end
			if self.wcBigBall03 then
				self:SetWeaponEnabledByLabel('EXBigBallCannon03', true)
				local wepAntiMatter03 = self:GetWeaponByLabel('EXBigBallCannon03')
				wepAntiMatter03:ChangeMaxRadius(45)
			else
				self:SetWeaponEnabledByLabel('EXBigBallCannon03', false)
			end
			if self.wcRapid01 then
				self:SetWeaponEnabledByLabel('EXRapidCannon01', true)
				local wepGattling01 = self:GetWeaponByLabel('EXRapidCannon01')
				wepGattling01:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXRapidCannon01', false)
			end
			if self.wcRapid02 then
				self:SetWeaponEnabledByLabel('EXRapidCannon02', true)
				local wepGattling02 = self:GetWeaponByLabel('EXRapidCannon02')
				wepGattling02:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXRapidCannon02', false)
			end
			if self.wcRapid03 then
				self:SetWeaponEnabledByLabel('EXRapidCannon03', true)
				local wepGattling03 = self:GetWeaponByLabel('EXRapidCannon03')
				wepGattling03:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXRapidCannon03', false)
			end
			if self.wcAA01 then
				self:SetWeaponEnabledByLabel('EXAA01', true)
				local wepLance01 = self:GetWeaponByLabel('EXAA01')
				wepLance01:ChangeMaxRadius(22)
			else
				self:SetWeaponEnabledByLabel('EXAA01', false)
			end
			if self.wcAA02 then
				self:SetWeaponEnabledByLabel('EXAA02', true)
				local wepLance02 = self:GetWeaponByLabel('EXAA02')
				wepLance02:ChangeMaxRadius(22)
			else
				self:SetWeaponEnabledByLabel('EXAA02', false)
			end
			if self.wcTMissiles01 then
				self:SetWeaponEnabledByLabel('Missile', true)
				local wepTacMiss = self:GetWeaponByLabel('Missile')
				wepTacMiss:ChangeMaxRadius(256)
			else
				self:SetWeaponEnabledByLabel('Missile', false)
			end
		end
    end,

    OnTransportDetach = function(self, attachBone, unit)
        SWalkingLandUnit.OnTransportDetach(self, attachBone, unit)
		self:StopSiloBuild()
        self:ForkThread(self.WeaponConfigCheck)
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 0 then # shield toggle
			self:DisableShield()
			self:StopUnitAmbientSound( 'ActiveLoop' )
        elseif bit == 8 then # cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('Sonar')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')     			
        end
    end,

    OnScriptBitSet = function(self, bit)
        if bit == 0 then # shield toggle
			self:EnableShield()
            self:PlayUnitAmbientSound( 'ActiveLoop' )
		elseif bit == 8 then # cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('Radar')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('Sonar')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')
        end
    end,

    RegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.TECH1, self:GetPosition(), self:GetBlueprint().Enhancements.EXCombatEngineering.Radius)
            local units2 = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.TECH2, self:GetPosition(), self:GetBlueprint().Enhancements.EXCombatEngineering.Radius)
            local units3 = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.TECH3, self:GetPosition(), self:GetBlueprint().Enhancements.EXCombatEngineering.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimACURegenAura')
            end
            for _,unit in units2 do
                Buff.ApplyBuff(unit, 'SeraphimACURegenAura2')
            end
            for _,unit in units3 do
                Buff.ApplyBuff(unit, 'SeraphimACURegenAura3')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,
       
    AdvancedRegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.TECH1, self:GetPosition(), self:GetBlueprint().Enhancements.EXAssaultEngineering.Radius)
            local units2 = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.TECH2, self:GetPosition(), self:GetBlueprint().Enhancements.EXAssaultEngineering.Radius)
            local units3 = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.TECH3, self:GetPosition(), self:GetBlueprint().Enhancements.EXAssaultEngineering.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimAdvancedACURegenAura')
            end
            for _,unit in units2 do
                Buff.ApplyBuff(unit, 'SeraphimAdvancedACURegenAura2')
            end
            for _,unit in units3 do
                Buff.ApplyBuff(unit, 'SeraphimAdvancedACURegenAura3')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,

    CreateEnhancement = function(self, enh)
        SWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh =='EXImprovedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SERAPHIMACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'SERAPHIMACUT2BuildRate',
                    DisplayName = 'SERAPHIMACUT2BuildRate',
                    BuffType = 'ACUBUILDRATE',
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
            Buff.ApplyBuff(self, 'SERAPHIMACUT2BuildRate')
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['EXSeraHealthBoost1'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost1',
                    DisplayName = 'EXSeraHealthBoost1',
                    BuffType = 'EXSeraHealthBoost1',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost1')
			self.RBImpEngineering = true
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXImprovedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if Buff.HasBuff( self, 'SERAPHIMACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'SERAPHIMACUT2BuildRate' )
            end
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'EXSeraHealthBoost1' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost1' )
            end
			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SERAPHIMACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'SERAPHIMACUT3BuildRate',
                    DisplayName = 'SERAPHIMCUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
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
            Buff.ApplyBuff(self, 'SERAPHIMACUT3BuildRate')
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['EXSeraHealthBoost2'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost2',
                    DisplayName = 'EXSeraHealthBoost2',
                    BuffType = 'EXSeraHealthBoost2',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost2')
			self.RBImpEngineering = true
			self.RBAdvEngineering = true
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAdvancedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'SERAPHIMACUT3BuildRate' ) then
                Buff.RemoveBuff( self, 'SERAPHIMACUT3BuildRate' )
            end
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'EXSeraHealthBoost1' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost1' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost2' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost2' )
            end
			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXExperimentalEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
			local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['SERAPHIMACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'SERAPHIMACUT4BuildRate',
                    DisplayName = 'SERAPHIMCUT4BuildRate',
                    BuffType = 'ACUBUILDRATE',
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
            Buff.ApplyBuff(self, 'SERAPHIMACUT4BuildRate')
            if not Buffs['EXSeraHealthBoost3'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost3',
                    DisplayName = 'EXSeraHealthBoost3',
                    BuffType = 'EXSeraHealthBoost3',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost3')
			self.RBImpEngineering = true
			self.RBAdvEngineering = true
			self.RBExpEngineering = true
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh =='EXExperimentalEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'SERAPHIMACUT4BuildRate' ) then
                Buff.RemoveBuff( self, 'SERAPHIMACUT4BuildRate' )
            end
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
			local bpEcon = self:GetBlueprint().Economy
			self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'EXSeraHealthBoost1' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost1' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost2' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost2' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost3' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost3' )
            end
			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXCombatEngineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not Buffs['SeraphimACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimACURegenAura',
                    DisplayName = 'SeraphimACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
                
            end
            if not Buffs['SeraphimACURegenAura2'] then
                BuffBlueprint {
                    Name = 'SeraphimACURegenAura2',
                    DisplayName = 'SeraphimACURegenAura2',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond2 or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
                
            end
            if not Buffs['SeraphimACURegenAura3'] then
                BuffBlueprint {
                    Name = 'SeraphimACURegenAura3',
                    DisplayName = 'SeraphimACURegenAura3',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond3 or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
                
            end
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.RegenThreadHandle = self:ForkThread(self.RegenBuffThread)
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SERAPHIMACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'SERAPHIMACUT2BuildRate',
                    DisplayName = 'SERAPHIMACUT2BuildRate',
                    BuffType = 'ACUBUILDRATE',
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
            Buff.ApplyBuff(self, 'SERAPHIMACUT2BuildRate')
            if not Buffs['EXSeraHealthBoost4'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost4',
                    DisplayName = 'EXSeraHealthBoost4',
                    BuffType = 'EXSeraHealthBoost4',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost4')
			self.RBComEngineering = true
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXCombatEngineeringRemove' then
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.RegenThreadHandle)
            local bp = self:GetBlueprint().Economy.BuildRate
            if Buff.HasBuff( self, 'SERAPHIMACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'SERAPHIMACUT2BuildRate' )
            end
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
            if Buff.HasBuff( self, 'EXSeraHealthBoost4' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost4' )
            end
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAssaultEngineering' then
            if self.RegenThreadHandle then
                if self.ShieldEffectsBag then
                    for k, v in self.ShieldEffectsBag do
                        v:Destroy()
                    end
		            self.ShieldEffectsBag = {}
		        end
                KillThread(self.RegenThreadHandle)
                
            end
            local bp = self:GetBlueprint().Enhancements[enh]
            if not Buffs['SeraphimAdvancedACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimAdvancedACURegenAura',
                    DisplayName = 'SeraphimAdvancedACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
            end
            if not Buffs['SeraphimAdvancedACURegenAura2'] then
                BuffBlueprint {
                    Name = 'SeraphimAdvancedACURegenAura2',
                    DisplayName = 'SeraphimAdvancedACURegenAura2',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond2 or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
            end
            if not Buffs['SeraphimAdvancedACURegenAura3'] then
                BuffBlueprint {
                    Name = 'SeraphimAdvancedACURegenAura3',
                    DisplayName = 'SeraphimAdvancedACURegenAura3',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond3 or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
            end
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.AdvancedRegenThreadHandle = self:ForkThread(self.AdvancedRegenBuffThread)
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SERAPHIMACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'SERAPHIMACUT3BuildRate',
                    DisplayName = 'SERAPHIMCUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
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
            Buff.ApplyBuff(self, 'SERAPHIMACUT3BuildRate')
            if not Buffs['EXSeraHealthBoost5'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost5',
                    DisplayName = 'EXSeraHealthBoost5',
                    BuffType = 'EXSeraHealthBoost5',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost5')  
			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAssaultEngineeringRemove' then
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.AdvancedRegenThreadHandle)
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'SERAPHIMACUT3BuildRate' ) then
                Buff.RemoveBuff( self, 'SERAPHIMACUT3BuildRate' )
            end
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )     
            if Buff.HasBuff( self, 'EXSeraHealthBoost4' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost4' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost5' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost5' )
            end
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXApocolypticEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SERAPHIMACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'SERAPHIMACUT4BuildRate',
                    DisplayName = 'SERAPHIMCUT4BuildRate',
                    BuffType = 'ACUBUILDRATE',
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
            Buff.ApplyBuff(self, 'SERAPHIMACUT4BuildRate')
            if not Buffs['EXSeraHealthBoost6'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost6',
                    DisplayName = 'EXSeraHealthBoost6',
                    BuffType = 'EXSeraHealthBoost6',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost6')
			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = true
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXApocolypticEngineeringRemove' then
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.AdvancedRegenThreadHandle)
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'SERAPHIMACUT4BuildRate' ) then
                Buff.RemoveBuff( self, 'SERAPHIMACUT4BuildRate' )
            end
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
            if Buff.HasBuff( self, 'EXSeraHealthBoost4' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost4' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost5' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost5' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost6' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost6' )
            end
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh =='EXChronotonBooster' then
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:ChangeMaxRadius(30)
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread)
        elseif enh =='EXChronotonBoosterRemove' then
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXTorpedoLauncher' then
            if not Buffs['EXSeraHealthBoost7'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost7',
                    DisplayName = 'EXSeraHealthBoost7',
                    BuffType = 'EXSeraHealthBoost7',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost7')
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:ChangeMaxRadius(30)
			self.wcTorp01 = true
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXTorpedoLauncherRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost7' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost7' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXTorpedoRapidLoader' then
            if not Buffs['EXSeraHealthBoost8'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost8',
                    DisplayName = 'EXSeraHealthBoost8',
                    BuffType = 'EXSeraHealthBoost8',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost8')
			local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:AddDamageMod(100)
			self.wcTorp01 = false
			self.wcTorp02 = true
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread)
        elseif enh =='EXTorpedoRapidLoaderRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost7' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost7' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost8' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost8' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
            wepChronotron:AddDamageMod(-100)
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh =='EXTorpedoClusterLauncher' then
            if not Buffs['EXSeraHealthBoost9'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost9',
                    DisplayName = 'EXSeraHealthBoost9',
                    BuffType = 'EXSeraHealthBoost9',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost9')
			local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:AddDamageMod(200)
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXTorpedoClusterLauncherRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost7' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost7' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost8' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost8' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost9' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost9' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
            wepChronotron:AddDamageMod(-300)
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXCannonBigBall' then
            if not Buffs['EXSeraHealthBoost10'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost10',
                    DisplayName = 'EXSeraHealthBoost10',
                    BuffType = 'EXSeraHealthBoost10',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost10')
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:ChangeMaxRadius(35)
			self.wcBigBall01 = true
			self.wcBigBall02 = false
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXCannonBigBallRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost10' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost10' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXImprovedContainmentBottle' then
            if not Buffs['EXSeraHealthBoost11'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost11',
                    DisplayName = 'EXSeraHealthBoost11',
                    BuffType = 'EXSeraHealthBoost11',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost11')
			local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:ChangeMaxRadius(40)
			self.wcBigBall01 = false
			self.wcBigBall02 = true
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread)
        elseif enh =='EXImprovedContainmentBottleRemove' then    
            if Buff.HasBuff( self, 'EXSeraHealthBoost10' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost10' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost11' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost11' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXPowerBooster' then
            if not Buffs['EXSeraHealthBoost12'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost12',
                    DisplayName = 'EXSeraHealthBoost12',
                    BuffType = 'EXSeraHealthBoost12',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost12')
			local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:ChangeMaxRadius(45)
            self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXPowerBoosterRemove' then    
            self:SetWeaponEnabledByLabel('EXBigBallCannon', false)
            if Buff.HasBuff( self, 'EXSeraHealthBoost10' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost10' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost11' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost11' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost12' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost12' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXCannonRapid' then
            if not Buffs['EXSeraHealthBoost13'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost13',
                    DisplayName = 'EXSeraHealthBoost13',
                    BuffType = 'EXSeraHealthBoost13',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost13')
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:ChangeMaxRadius(30)
			self.wcRapid01 = true
			self.wcRapid02 = false
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXCannonRapidRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost13' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost13' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXImprovedCoolingSystem' then
            if not Buffs['EXSeraHealthBoost14'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost14',
                    DisplayName = 'EXSeraHealthBoost14',
                    BuffType = 'EXSeraHealthBoost14',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost14')
			local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:ChangeMaxRadius(35)
            self.wcRapid01 = false
			self.wcRapid02 = true
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread)
        elseif enh =='EXImprovedCoolingSystemRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost13' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost13' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost14' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost14' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXEnergyShellHardener' then
            if not Buffs['EXSeraHealthBoost15'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost15',
                    DisplayName = 'EXSeraHealthBoost15',
                    BuffType = 'EXSeraHealthBoost15',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost15')
			local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            wepChronotron:ChangeMaxRadius(35)
            self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXEnergyShellHardenerRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost13' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost13' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost14' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost14' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost15' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost15' )
            end
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[1].MaxRadius
            wepChronotron:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXL1Lambda' then
			self.WeaponCheckAA01 = true
			self:SetWeaponEnabledByLabel('EXAA01', true)
			self:SetWeaponEnabledByLabel('EXAA02', true)
            local platOrientSm01 = self:GetOrientation()
            local platOrientLg01 = self:GetOrientation()
			local locationSm01 = self:GetPosition('S_Lambda_B01')
			local locationLg01 = self:GetPosition('L_Lambda_B01')
			local lambdaEmitterSm01 = CreateUnit('esb0002', self:GetArmy(), locationSm01[1], locationSm01[2], locationSm01[3], platOrientSm01[1], platOrientSm01[2], platOrientSm01[3], platOrientSm01[4], 'Land')
			local lambdaEmitterLg01 = CreateUnit('esb0001', self:GetArmy(), locationLg01[1], locationLg01[2], locationLg01[3], platOrientLg01[1], platOrientLg01[2], platOrientLg01[3], platOrientLg01[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm01)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg01)
			lambdaEmitterSm01:AttachTo(self, 'S_Lambda_B01')
			lambdaEmitterLg01:AttachTo(self, 'L_Lambda_B01')
			lambdaEmitterSm01:SetParent(self, 'esl0001')
			lambdaEmitterLg01:SetParent(self, 'esl0001')
            lambdaEmitterSm01:SetCreator(self)
            lambdaEmitterLg01:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm01)
			self.Trash:Add(lambdaEmitterLg01)
			--[[
            local platOrientSm01 = self:GetOrientation()
            local platOrientLg01 = self:GetOrientation()
			local locationSm01 = self:GetPosition('S_Lambda_B01')
			local locationLg01 = self:GetPosition('L_Lambda_B01')
			--local lambdaEmitterSm01 = CreateUnitHPR('esb0005', self:GetArmy(), locationSm01[1], locationSm01[2], locationSm01[3], 0, 0, 0)
			--local lambdaEmitterLg01 = CreateUnitHPR('esb0005', self:GetArmy(), locationLg01[1], locationLg01[2], locationLg01[3], 0, 0, 0)
			local lambdaEmitterSm01 = CreateUnit('esb0005', self:GetArmy(), locationSm01[1], locationSm01[2], locationSm01[3], platOrientSm01[1], platOrientSm01[2], platOrientSm01[3], platOrientSm01[4], 'Air')
			local lambdaEmitterLg01 = CreateUnit('esb0005', self:GetArmy(), locationLg01[1], locationLg01[2], locationLg01[3], platOrientLg01[1], platOrientLg01[2], platOrientLg01[3], platOrientLg01[4], 'Air')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm01)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg01)
			lambdaEmitterSm01:AttachTo(self, 'S_Lambda_B01')
			lambdaEmitterLg01:AttachTo(self, 'L_Lambda_B01')
			lambdaEmitterSm01:SetParent(self, 'esl0001')
			lambdaEmitterLg01:SetParent(self, 'esl0001')
            lambdaEmitterSm01:SetCreator(self)
            lambdaEmitterLg01:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm01)
			self.Trash:Add(lambdaEmitterLg01)
			]]--
            if not Buffs['EXSeraHealthBoost22'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost22',
                    DisplayName = 'EXSeraHealthBoost22',
                    BuffType = 'EXSeraHealthBoost22',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost22')
			self.RBDefTier1 = true
			self.RBDefTier2 = false
			self.RBDefTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh == 'EXL1LambdaRemove' then
			self.WeaponCheckAA01 = false
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)
            if Buff.HasBuff( self, 'EXSeraHealthBoost22' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost22' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXL2Lambda' then
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
            local platOrientSm01 = self:GetOrientation()
            local platOrientLg01 = self:GetOrientation()
			local locationSm01 = self:GetPosition('S_Lambda_B01')
			local locationLg01 = self:GetPosition('L_Lambda_B01')
			local lambdaEmitterSm01 = CreateUnit('esb0002', self:GetArmy(), locationSm01[1], locationSm01[2], locationSm01[3], platOrientSm01[1], platOrientSm01[2], platOrientSm01[3], platOrientSm01[4], 'Land')
			local lambdaEmitterLg01 = CreateUnit('esb0001', self:GetArmy(), locationLg01[1], locationLg01[2], locationLg01[3], platOrientLg01[1], platOrientLg01[2], platOrientLg01[3], platOrientLg01[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm01)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg01)
			lambdaEmitterSm01:AttachTo(self, 'S_Lambda_B01')
			lambdaEmitterLg01:AttachTo(self, 'L_Lambda_B01')
			lambdaEmitterSm01:SetParent(self, 'esl0001')
			lambdaEmitterLg01:SetParent(self, 'esl0001')
            lambdaEmitterSm01:SetCreator(self)
            lambdaEmitterLg01:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm01)
			self.Trash:Add(lambdaEmitterLg01)
             local platOrientSm02 = self:GetOrientation()
            local platOrientLg02 = self:GetOrientation()
			local locationSm02 = self:GetPosition('S_Lambda_B02')
			local locationLg02 = self:GetPosition('L_Lambda_B02')
			local lambdaEmitterSm02 = CreateUnit('esb0003', self:GetArmy(), locationSm02[1], locationSm02[2], locationSm02[3], platOrientSm02[1], platOrientSm02[2], platOrientSm02[3], platOrientSm02[4], 'Land')
			local lambdaEmitterLg02 = CreateUnit('esb0001', self:GetArmy(), locationLg02[1], locationLg02[2], locationLg02[3], platOrientLg02[1], platOrientLg02[2], platOrientLg02[3], platOrientLg02[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm02)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg02)
			lambdaEmitterSm02:AttachTo(self, 'S_Lambda_B02')
			lambdaEmitterLg02:AttachTo(self, 'L_Lambda_B02')
			lambdaEmitterSm02:SetParent(self, 'esl0001')
			lambdaEmitterLg02:SetParent(self, 'esl0001')
            lambdaEmitterSm02:SetCreator(self)
            lambdaEmitterLg02:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm02)
			self.Trash:Add(lambdaEmitterLg02)
            if not Buffs['EXSeraHealthBoost23'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost23',
                    DisplayName = 'EXSeraHealthBoost23',
                    BuffType = 'EXSeraHealthBoost23',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost23')
			self.RBDefTier1 = true
			self.RBDefTier2 = true
			self.RBDefTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXL2LambdaRemove' then
			self.WeaponCheckAA01 = false
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)
            if Buff.HasBuff( self, 'EXSeraHealthBoost22' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost22' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost23' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost23' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXL3Lambda' then
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
            local platOrientSm01 = self:GetOrientation()
            local platOrientLg01 = self:GetOrientation()
			local locationSm01 = self:GetPosition('S_Lambda_B01')
			local locationLg01 = self:GetPosition('L_Lambda_B01')
			local lambdaEmitterSm01 = CreateUnit('esb0002', self:GetArmy(), locationSm01[1], locationSm01[2], locationSm01[3], platOrientSm01[1], platOrientSm01[2], platOrientSm01[3], platOrientSm01[4], 'Land')
			local lambdaEmitterLg01 = CreateUnit('esb0001', self:GetArmy(), locationLg01[1], locationLg01[2], locationLg01[3], platOrientLg01[1], platOrientLg01[2], platOrientLg01[3], platOrientLg01[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm01)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg01)
			lambdaEmitterSm01:AttachTo(self, 'S_Lambda_B01')
			lambdaEmitterLg01:AttachTo(self, 'L_Lambda_B01')
			lambdaEmitterSm01:SetParent(self, 'esl0001')
			lambdaEmitterLg01:SetParent(self, 'esl0001')
            lambdaEmitterSm01:SetCreator(self)
            lambdaEmitterLg01:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm01)
			self.Trash:Add(lambdaEmitterLg01)
             local platOrientSm02 = self:GetOrientation()
            local platOrientLg02 = self:GetOrientation()
			local locationSm02 = self:GetPosition('S_Lambda_B02')
			local locationLg02 = self:GetPosition('L_Lambda_B02')
			local lambdaEmitterSm02 = CreateUnit('esb0003', self:GetArmy(), locationSm02[1], locationSm02[2], locationSm02[3], platOrientSm02[1], platOrientSm02[2], platOrientSm02[3], platOrientSm02[4], 'Land')
			local lambdaEmitterLg02 = CreateUnit('esb0001', self:GetArmy(), locationLg02[1], locationLg02[2], locationLg02[3], platOrientLg02[1], platOrientLg02[2], platOrientLg02[3], platOrientLg02[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm02)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg02)
			lambdaEmitterSm02:AttachTo(self, 'S_Lambda_B02')
			lambdaEmitterLg02:AttachTo(self, 'L_Lambda_B02')
			lambdaEmitterSm02:SetParent(self, 'esl0001')
			lambdaEmitterLg02:SetParent(self, 'esl0001')
            lambdaEmitterSm02:SetCreator(self)
            lambdaEmitterLg02:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm02)
			self.Trash:Add(lambdaEmitterLg02)
            local platOrientSm03 = self:GetOrientation()
            local platOrientLg03 = self:GetOrientation()
			local locationSm03 = self:GetPosition('S_Lambda_B03')
			local locationLg03 = self:GetPosition('L_Lambda_B03')
			local lambdaEmitterSm03 = CreateUnit('esb0004', self:GetArmy(), locationSm03[1], locationSm03[2], locationSm03[3], platOrientSm03[1], platOrientSm03[2], platOrientSm03[3], platOrientSm03[4], 'Land')
			local lambdaEmitterLg03 = CreateUnit('esb0004', self:GetArmy(), locationLg03[1], locationLg03[2], locationLg03[3], platOrientLg03[1], platOrientLg03[2], platOrientLg03[3], platOrientLg03[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm03)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg03)
			lambdaEmitterSm03:AttachTo(self, 'S_Lambda_B03')
			lambdaEmitterLg03:AttachTo(self, 'L_Lambda_B03')
			lambdaEmitterSm03:SetParent(self, 'esl0001')
			lambdaEmitterLg03:SetParent(self, 'esl0001')
            lambdaEmitterSm03:SetCreator(self)
            lambdaEmitterLg03:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm03)
			self.Trash:Add(lambdaEmitterLg03)
            if not Buffs['EXSeraHealthBoost24'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost24',
                    DisplayName = 'EXSeraHealthBoost24',
                    BuffType = 'EXSeraHealthBoost24',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost24')
			self.RBDefTier1 = true
			self.RBDefTier2 = true
			self.RBDefTier3 = true
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXL3LambdaRemove' then
			self.WeaponCheckAA01 = false
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)
            if Buff.HasBuff( self, 'EXSeraHealthBoost22' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost22' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost23' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost23' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost24' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost24' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXElectronicsEnhancment' then
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
            local platOrientSm01 = self:GetOrientation()
            local platOrientLg01 = self:GetOrientation()
			local locationSm01 = self:GetPosition('S_Lambda_B01')
			local locationLg01 = self:GetPosition('L_Lambda_B01')
			local lambdaEmitterSm01 = CreateUnit('esb0002', self:GetArmy(), locationSm01[1], locationSm01[2], locationSm01[3], platOrientSm01[1], platOrientSm01[2], platOrientSm01[3], platOrientSm01[4], 'Land')
			local lambdaEmitterLg01 = CreateUnit('esb0001', self:GetArmy(), locationLg01[1], locationLg01[2], locationLg01[3], platOrientLg01[1], platOrientLg01[2], platOrientLg01[3], platOrientLg01[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm01)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg01)
			lambdaEmitterSm01:AttachTo(self, 'S_Lambda_B01')
			lambdaEmitterLg01:AttachTo(self, 'L_Lambda_B01')
			lambdaEmitterSm01:SetParent(self, 'esl0001')
			lambdaEmitterLg01:SetParent(self, 'esl0001')
            lambdaEmitterSm01:SetCreator(self)
            lambdaEmitterLg01:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm01)
			self.Trash:Add(lambdaEmitterLg01)
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 50)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 50)
            if not Buffs['EXSeraHealthBoost16'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost16',
                    DisplayName = 'EXSeraHealthBoost16',
                    BuffType = 'EXSeraHealthBoost16',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost16')
			self.RBIntTier1 = true
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXElectronicsEnhancmentRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
            if Buff.HasBuff( self, 'EXSeraHealthBoost16' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost16' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXElectronicCountermeasures' then
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
            local platOrientSm01 = self:GetOrientation()
            local platOrientLg01 = self:GetOrientation()
			local locationSm01 = self:GetPosition('S_Lambda_B01')
			local locationLg01 = self:GetPosition('L_Lambda_B01')
			local lambdaEmitterSm01 = CreateUnit('esb0002', self:GetArmy(), locationSm01[1], locationSm01[2], locationSm01[3], platOrientSm01[1], platOrientSm01[2], platOrientSm01[3], platOrientSm01[4], 'Land')
			local lambdaEmitterLg01 = CreateUnit('esb0001', self:GetArmy(), locationLg01[1], locationLg01[2], locationLg01[3], platOrientLg01[1], platOrientLg01[2], platOrientLg01[3], platOrientLg01[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm01)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg01)
			lambdaEmitterSm01:AttachTo(self, 'S_Lambda_B01')
			lambdaEmitterLg01:AttachTo(self, 'L_Lambda_B01')
			lambdaEmitterSm01:SetParent(self, 'esl0001')
			lambdaEmitterLg01:SetParent(self, 'esl0001')
            lambdaEmitterSm01:SetCreator(self)
            lambdaEmitterLg01:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm01)
			self.Trash:Add(lambdaEmitterLg01)
             local platOrientSm02 = self:GetOrientation()
            local platOrientLg02 = self:GetOrientation()
			local locationSm02 = self:GetPosition('S_Lambda_B02')
			local locationLg02 = self:GetPosition('L_Lambda_B02')
			local lambdaEmitterSm02 = CreateUnit('esb0003', self:GetArmy(), locationSm02[1], locationSm02[2], locationSm02[3], platOrientSm02[1], platOrientSm02[2], platOrientSm02[3], platOrientSm02[4], 'Land')
			local lambdaEmitterLg02 = CreateUnit('esb0001', self:GetArmy(), locationLg02[1], locationLg02[2], locationLg02[3], platOrientLg02[1], platOrientLg02[2], platOrientLg02[3], platOrientLg02[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm02)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg02)
			lambdaEmitterSm02:AttachTo(self, 'S_Lambda_B02')
			lambdaEmitterLg02:AttachTo(self, 'L_Lambda_B02')
			lambdaEmitterSm02:SetParent(self, 'esl0001')
			lambdaEmitterLg02:SetParent(self, 'esl0001')
            lambdaEmitterSm02:SetCreator(self)
            lambdaEmitterLg02:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm02)
			self.Trash:Add(lambdaEmitterLg02)
            self:AddCommandCap('RULEUCC_Teleport')
            if not Buffs['EXSeraHealthBoost17'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost17',
                    DisplayName = 'EXSeraHealthBoost17',
                    BuffType = 'EXSeraHealthBoost17',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost17')
			self.wcAA01 = true
			self.wcAA02 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXElectronicCountermeasuresRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
            if Buff.HasBuff( self, 'EXSeraHealthBoost16' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost16' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost17' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost17' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.wcAA01 = false
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXCloakingSubsystems' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            --self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.StealthEnh = false
			self.CloakEnh = true 
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('Cloak')
            if not Buffs['EXSeraHealthBoost18'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost18',
                    DisplayName = 'EXSeraHealthBoost18',
                    BuffType = 'EXSeraHealthBoost18',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost18')
			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = true
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXCloakingSubsystemsRemove' then
            --self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')
            self.CloakEnh = false 
            self:RemoveCommandCap('RULEUCC_Teleport')
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
            if Buff.HasBuff( self, 'EXSeraHealthBoost16' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost16' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost17' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost17' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost18' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost18' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.wcAA01 = false
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXBasicDefence' then
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
            local platOrientSm01 = self:GetOrientation()
            local platOrientLg01 = self:GetOrientation()
			local locationSm01 = self:GetPosition('S_Lambda_B01')
			local locationLg01 = self:GetPosition('L_Lambda_B01')
			local lambdaEmitterSm01 = CreateUnit('esb0002', self:GetArmy(), locationSm01[1], locationSm01[2], locationSm01[3], platOrientSm01[1], platOrientSm01[2], platOrientSm01[3], platOrientSm01[4], 'Land')
			local lambdaEmitterLg01 = CreateUnit('esb0001', self:GetArmy(), locationLg01[1], locationLg01[2], locationLg01[3], platOrientLg01[1], platOrientLg01[2], platOrientLg01[3], platOrientLg01[4], 'Land')
			table.insert (self.lambdaEmitterTable, lambdaEmitterSm01)
			table.insert (self.lambdaEmitterTable, lambdaEmitterLg01)
			lambdaEmitterSm01:AttachTo(self, 'S_Lambda_B01')
			lambdaEmitterLg01:AttachTo(self, 'L_Lambda_B01')
			lambdaEmitterSm01:SetParent(self, 'esl0001')
			lambdaEmitterLg01:SetParent(self, 'esl0001')
            lambdaEmitterSm01:SetCreator(self)
            lambdaEmitterLg01:SetCreator(self)
			self.Trash:Add(lambdaEmitterSm01)
			self.Trash:Add(lambdaEmitterLg01)
            if not Buffs['EXSeraHealthBoost19'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost19',
                    DisplayName = 'EXSeraHealthBoost19',
                    BuffType = 'EXSeraHealthBoost19',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost19')
			local wepOC = self:GetWeaponByLabel('OverCharge')
            wepOC:ChangeMaxRadius(bp.OverchargeRangeMod or 44)
            wepOC:AddDamageMod(bp.OverchargeDamageMod)        
			self.RBComTier1 = true
			self.RBComTier2 = false
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXBasicDefenceRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost19' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost19' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			local wepOC = self:GetWeaponByLabel('OverCharge')
            local bpDisruptOCRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepOC:ChangeMaxRadius(bpDisruptOCRadius or 22)
            wepOC:AddDamageMod(-bp.OverchargeDamageMod)        
			self:StopSiloBuild()
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXTacticalMisslePack' then
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            if not Buffs['EXSeraHealthBoost20'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost20',
                    DisplayName = 'EXSeraHealthBoost20',
                    BuffType = 'EXSeraHealthBoost20',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost20')
			local wepOC = self:GetWeaponByLabel('OverCharge')
            wepOC:AddDamageMod(bp.OverchargeDamageMod2)        
			self.wcTMissiles01 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXTacticalMisslePackRemove' then
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()
            if Buff.HasBuff( self, 'EXSeraHealthBoost19' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost19' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost20' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost20' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost21' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost21' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			local wepOC = self:GetWeaponByLabel('OverCharge')
            local bpDisruptOCRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepOC:ChangeMaxRadius(bpDisruptOCRadius or 22)
            wepOC:AddDamageMod(-bp.OverchargeDamageMod)        
            wepOC:AddDamageMod(-bp.OverchargeDamageMod2)        
			self.wcTMissiles01 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXOverchargeOverdrive' then
            if not Buffs['EXSeraHealthBoost21'] then
                BuffBlueprint {
                    Name = 'EXSeraHealthBoost21',
                    DisplayName = 'EXSeraHealthBoost21',
                    BuffType = 'EXSeraHealthBoost21',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXSeraHealthBoost21')   
			local wepOC = self:GetWeaponByLabel('OverCharge')
            wepOC:ChangeMaxRadius(bp.OverchargeRangeMod or 44)
            wepOC:AddDamageMod(bp.OverchargeDamageMod3)        
			wepOC:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = true
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXOverchargeOverdriveRemove' then
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()
            if Buff.HasBuff( self, 'EXSeraHealthBoost19' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost19' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost20' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost20' )
            end
            if Buff.HasBuff( self, 'EXSeraHealthBoost21' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost21' )
            end
			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			local wepOC = self:GetWeaponByLabel('OverCharge')
            local bpDisruptOCRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepOC:ChangeMaxRadius(bpDisruptOCRadius or 22)
            wepOC:AddDamageMod(-bp.OverchargeDamageMod)        
            wepOC:AddDamageMod(-bp.OverchargeDamageMod2)        
            wepOC:AddDamageMod(-bp.OverchargeDamageMod3)        
			wepOC:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
			self.wcTMissiles01 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
		end
    end,

    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Body',
--				    'Right_Turret',
--				    'Left_Turret',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Torso',
--				    'Chest_Left',
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
				    'Body',
--				    'Right_Turret',
--				    'Left_Turret',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Torso',
--				    'Chest_Left',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
    },
	
    OnIntelEnabled = function(self)
        SWalkingLandUnit.OnIntelEnabled(self)
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then 
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['EXCloakingSubsystems'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
			    self.IntelEffectsBag = {}
			    self.CreateTerrainTypeEffects( self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
			end            
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['EXElectronicCountermeasures'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()  
            if not self.IntelEffectsBag then 
	            self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		    end                  
        end		
    end,

    OnIntelDisabled = function(self)
        SWalkingLandUnit.OnIntelDisabled(self)
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

    OnMotionHorzEventChange = function(self, new, old)
		if self.RBIntTier3 then
			if ((new == 'Stopped' or new == 'Stopping') and (old == 'Cruise' or old == 'TopSpeed')) then
				self.EXMoving = false
			elseif ( old == 'Stopped' or (old == 'Stopping' and (new == 'Cruise' or new == 'TopSpeed'))) then
				self.EXMoving = true
			end
		end
        SWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
    end,

	EXRecloakDelayThread = function(self)
		WaitSeconds(3)
		self.EXCloakTele = false
	end,

	EXOCCloakTiming = function(self)
		WaitSeconds(5)
		self.EXOCFire = false
	end,

    OnFailedTeleport = function(self)
		SWalkingLandUnit.OnFailedTeleport(self)
		self:ForkThread(self.EXRecloakDelayThread)
    end,

    PlayTeleportChargeEffects = function(self)
		self.EXCloakTele = true
		SWalkingLandUnit.PlayTeleportChargeEffects(self)
    end,
	
    PlayTeleportInEffects = function( self )
		SWalkingLandUnit.PlayTeleportInEffects(self)
		self:ForkThread(self.EXRecloakDelayThread)
    end,

}
--]]
TypeClass = ESL0001