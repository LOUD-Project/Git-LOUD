#****************************************************************************
#**
#**  Author(s):  Exavier Macbeth
#**
#**  Summary  :  BlackOps: Adv Command Unit - Aeon ACU
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit

local AWeapons = import('/lua/aeonweapons.lua')
local ADFDisruptorCannonWeapon = AWeapons.ADFDisruptorCannonWeapon
local AIFCommanderDeathWeapon = AWeapons.AIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Weapon = import('/lua/sim/Weapon.lua').Weapon
local ADFOverchargeWeapon = AWeapons.ADFOverchargeWeapon
local ADFChronoDampener = AWeapons.ADFChronoDampener
local Buff = import('/lua/sim/Buff.lua')
local CSoothSayerAmbient = import('/lua/EffectTemplates.lua').CSoothSayerAmbient
local AIFArtilleryMiasmaShellWeapon = import('/lua/aeonweapons.lua').AIFArtilleryMiasmaShellWeapon
local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon
local ADFPhasonLaser = import('/lua/aeonweapons.lua').ADFPhasonLaser
local AeonACUPhasonLaser = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').AeonACUPhasonLaser 
local AIFQuasarAntiTorpedoWeapon = AWeapons.AIFQuasarAntiTorpedoWeapon
local EXCEMPArrayBeam01 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam01 
local AAMWillOWisp = import('/lua/aeonweapons.lua').AAMWillOWisp
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker


local EXQuantumMaelstromWeapon = Class(Weapon) {

    OnFire = function(self)
        local blueprint = self:GetBlueprint()
        DamageArea(self.unit, self.unit:GetPosition(), blueprint.DamageRadius,
                   blueprint.Damage, blueprint.DamageType, blueprint.DamageFriendly)
    end,
}

local OldEAL0001 = EAL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

EAL0001 = Hunker.AddHunker(OldEAL0001)

--[[

EAL0001 = Class(AWalkingLandUnit) {

    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
        EXTargetPainter = Class(EXCEMPArrayBeam01) {
            OnWeaponFired = function(self)
				EXCEMPArrayBeam01.OnWeaponFired(self)
				self.mypos = self.unit:GetPosition()
				self.targetpos = self:GetCurrentTargetPos()
				if self.targetpos then
				self.targetdistance = VDist3(self.mypos,self.targetpos)
				if self.unit.wcArtillery01 then
					if (self.targetdistance >= 25) then
						self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery01', true)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
					else
						self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
					end
				elseif self.unit.wcArtillery02 then
					if (self.targetdistance >= 25) then
						self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery02', true)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
					else
						self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
					end
				elseif self.unit.wcArtillery03 then
					if (self.targetdistance >= 25) then
						self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery03', true)
					else
						self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
						self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
					end
				elseif self.unit.wcBeam01 then
					self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam01', true)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
				elseif self.unit.wcBeam02 then
					self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam02', true)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
				elseif self.unit.wcBeam03 then
					self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam03', true)
				elseif not self.unit.wcArtillery01 and not self.unit.wcArtillery02 and not self.unit.wcArtillery03 and not self.unit.wcBeam01 and not self.unit.wcBeam02 and not self.unit.wcBeam03 then
					self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)
					self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
					self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
					self.unit:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
					self.unit:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
				end
				end
            end,	
		},
        RightDisruptor = Class(ADFDisruptorCannonWeapon) {},
        EXChronoDampener01 = Class(ADFChronoDampener) {},
        EXChronoDampener02 = Class(ADFChronoDampener) {},
        EXTorpedoLauncher01 = Class(AANChronoTorpedoWeapon) {},
        EXTorpedoLauncher02 = Class(AANChronoTorpedoWeapon) {},
        EXTorpedoLauncher03 = Class(AANChronoTorpedoWeapon) {},
        EXMiasmaArtillery01 = Class(AIFArtilleryMiasmaShellWeapon) {},
        EXMiasmaArtillery02 = Class(AIFArtilleryMiasmaShellWeapon) {},
        EXMiasmaArtillery03 = Class(AIFArtilleryMiasmaShellWeapon) {},
        EXPhasonBeam01 = Class(AeonACUPhasonLaser) {},
        EXPhasonBeam02 = Class(AeonACUPhasonLaser) {},
        EXPhasonBeam03 = Class(AeonACUPhasonLaser) {},
        EXQuantumMaelstrom01 = Class(EXQuantumMaelstromWeapon) {},
        EXQuantumMaelstrom02 = Class(EXQuantumMaelstromWeapon) {},
        EXQuantumMaelstrom03 = Class(EXQuantumMaelstromWeapon) {},
        EXAntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
        EXAntiMissile = Class(AAMWillOWisp) {},
        OverCharge = Class(ADFOverchargeWeapon) {

            OnCreate = function(self)
                ADFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                ADFOverchargeWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                ADFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    ADFOverchargeWeapon.OnFire(self)
                end
            end,
            IdleState = State(ADFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ADFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(ADFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ADFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },              
        },
    },


    OnCreate = function(self)
        AWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetupBuildBones()
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
            self.RemoteViewingData = {}
            self.RemoteViewingData.RemoteViewingFunctions = {}
            self.RemoteViewingData.DisableCounter = 0
            self.RemoteViewingData.IntelButton = true
    end,

    OnPrepareArmToBuild = function(self)
        AWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self.wcBuildMode = true
		self:ForkThread(self.WeaponConfigCheck)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        AWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        AWalkingLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        AWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('CloakField')
		self:HideBone('Engineering', true)
		self:HideBone('Combat_Engineering', true)
		self:HideBone('Left_Turret_Plates', true)
		self:HideBone('Basic_GunUp_Range', true)
		self:HideBone('Basic_GunUp_RoF', true)
		self:HideBone('Torpedo_Launcher', true)
		self:HideBone('Laser_Cannon', true)
		self:HideBone('IntelPack_Torso', true)
		self:HideBone('IntelPack_Head', true)
		self:HideBone('IntelPack_LShoulder', true)
		self:HideBone('IntelPack_RShoulder', true)
		self:HideBone('DamagePack_LArm', true)
		self:HideBone('DamagePack_RArm', true)
		self:HideBone('DamagePack_Torso', true)
		self:HideBone('DamagePack_RLeg_B01', true)
		self:HideBone('DamagePack_RLeg_B02', true)
		self:HideBone('DamagePack_LLeg_B01', true)
		self:HideBone('DamagePack_LLeg_B02', true)
		self:HideBone('ShieldPack_Normal', true)
		self:HideBone('Shoulder_Arty_L', true)
		self:HideBone('ShieldPack_Arty_LArm', true)
		self:HideBone('Shoulder_Arty_R', true)
		self:HideBone('ShieldPack_Arty_RArm', true)
		self:HideBone('Artillery_Torso', true)
		self:HideBone('ShieldPack_Artillery', true)
		self:HideBone('Artillery_Barrel_Left', true)
		self:HideBone('Artillery_Barrel_Right', true)
		self:HideBone('Artillery_Pitch', true)
		self:SetWeaponEnabledByLabel('EXAntiMissile', false)
		self.ccShield = false
		self.ccArtillery = false
		self.wcBuildMode = false
		self.wcOCMode = false
		self.wcChrono01 = false
		self.wcChrono02 = false
		self.wcTorp01 = false
		self.wcTorp02 = false
		self.wcTorp03 = false
		self.wcArtillery01 = false
		self.wcArtillery02 = false
		self.wcArtillery03 = false
		self.wcBeam01 = false
		self.wcBeam02 = false
		self.wcBeam03 = false
		self.wcMaelstrom01 = false
		self.wcMaelstrom02 = false
		self.wcMaelstrom03 = false
		local wepPainter = self:GetWeaponByLabel('EXTargetPainter')
		wepPainter:ChangeMaxRadius(22)
		self:ForkThread(self.WeaponConfigCheck)
		self:ForkThread(self.WeaponRangeReset)
		self.MaelstromEffects01 = {}
        self:ForkThread(self.GiveInitialResources)
        self.ShieldEffectsBag = {}
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
		self.ScryActive = false
		self.regenammount = 0
		self:ForkThread(self.EXRegenBuffThread)
		self:ForkThread(self.EXRegenHeartbeat)
		self.DefaultGunBuffApplied = false
		self.DefaultGunBuffApplied02 = false
        self.Sync.Abilities = self:GetBlueprint().Abilities
        self.Sync.Abilities.EXScryTarget.Active = false
    end,

        OnKilled = function(self, instigator, type, overkillRatio)
            AWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
            if self.RemoteViewingData.Satellite then
                self.RemoteViewingData.Satellite:DisableIntel('Vision')
                self.RemoteViewingData.Satellite:Destroy()
            end
        end,

        DisableRemoteViewingButtons = function(self)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.EXScryTarget.Active = false
            self:AddToggleCap('RULEUTC_IntelToggle')
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        end,
        
        EnableRemoteViewingButtons = function(self)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.EXScryTarget.Active = true
            self:AddToggleCap('RULEUTC_IntelToggle')
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        end,

        EXRemoteCheck = function(self)
            if self.RBIntTier2 and self.ScryActive then
				self:DisableRemoteViewingButtons()
				WaitSeconds(10)
				if self.RBIntTier2 then
					self:EnableRemoteViewingButtons()
				end
			end
        end,

        OnTargetLocation = function(self, location)
            # Initial energy drain here - we drain resources instantly when an eye is relocated (including initial move)
            local aiBrain = self:GetAIBrain()
            local bp = self:GetBlueprint()
            local have = aiBrain:GetEconomyStored('ENERGY')
            local need = bp.Economy.InitialRemoteViewingEnergyDrain
            if not ( have > need ) then
                return
            end
			local selfpos = self:GetPosition()
			local destRange = VDist2(location[1], location[3], selfpos[1], selfpos[3])
			if destRange <= 300 then
				aiBrain:TakeResource( 'ENERGY', bp.Economy.InitialRemoteViewingEnergyDrain )

				self.RemoteViewingData.VisibleLocation = location
				self:CreateVisibleEntity()
				self.ScryActive = true
				self:ForkThread(self.EXRemoteCheck)
			end
        end,

        CreateVisibleEntity = function(self)
            # Only give a visible area if we have a location and intel button enabled
            if not self.RemoteViewingData.VisibleLocation then
                return
            end
            
            if self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton then
                local bp = self:GetBlueprint()
                # Create new visible area
                if not self.RemoteViewingData.Satellite then
                    local spec = {
                        X = self.RemoteViewingData.VisibleLocation[1],
                        Z = self.RemoteViewingData.VisibleLocation[3],
                        Radius = bp.Intel.RemoteViewingRadius,
                        LifeTime = -1,
                        Omni = false,
                        Radar = false,
                        Vision = true,
                        Army = self:GetAIBrain():GetArmyIndex(),
                    }
                    self.RemoteViewingData.Satellite = VizMarker(spec)
                    self.Trash:Add(self.RemoteViewingData.Satellite)
                else
                    # Move and reactivate old visible area
                    if not self.RemoteViewingData.Satellite:BeenDestroyed() then
                        Warp( self.RemoteViewingData.Satellite, self.RemoteViewingData.VisibleLocation )
                        self.RemoteViewingData.Satellite:EnableIntel('Vision')
                    end
                end
				self:ForkThread(self.DisableVisibleEntity)
            end
        end,

        DisableVisibleEntity = function(self)
            # visible entity already off
			WaitSeconds(5)
            if self.RemoteViewingData.DisableCounter > 1 then return end
            # disable vis entity and monitor resources
            if not self:IsDead() and self.RemoteViewingData.Satellite then
                self.RemoteViewingData.Satellite:DisableIntel('Vision')
            end
        end,

    OnFailedToBuild = function(self)
        AWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        AWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true     
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        AWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
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
        self:SetMesh('/mods/BlackopsACUs/units/eal0001/EAL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
		self:HideBone('Engineering', true)
		self:HideBone('Combat_Engineering', true)
		self:HideBone('Left_Turret_Plates', true)
		self:HideBone('Basic_GunUp_Range', true)
		self:HideBone('Basic_GunUp_RoF', true)
		self:HideBone('Torpedo_Launcher', true)
		self:HideBone('Laser_Cannon', true)
		self:HideBone('IntelPack_Torso', true)
		self:HideBone('IntelPack_Head', true)
		self:HideBone('IntelPack_LShoulder', true)
		self:HideBone('IntelPack_RShoulder', true)
		self:HideBone('DamagePack_LArm', true)
		self:HideBone('DamagePack_RArm', true)
		self:HideBone('DamagePack_Torso', true)
		self:HideBone('DamagePack_RLeg_B01', true)
		self:HideBone('DamagePack_RLeg_B02', true)
		self:HideBone('DamagePack_LLeg_B01', true)
		self:HideBone('DamagePack_LLeg_B02', true)
		self:HideBone('ShieldPack_Normal', true)
		self:HideBone('Shoulder_Arty_L', true)
		self:HideBone('ShieldPack_Arty_LArm', true)
		self:HideBone('Shoulder_Arty_R', true)
		self:HideBone('ShieldPack_Arty_RArm', true)
		self:HideBone('Artillery_Torso', true)
		self:HideBone('ShieldPack_Artillery', true)
		self:HideBone('Artillery_Barrel_Left', true)
		self:HideBone('Artillery_Barrel_Right', true)
		self:HideBone('Artillery_Pitch', true)
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
			self.regenammount = self.regenammount + EXBP.Enhancements.EXShieldBattery.NewRegenRate
		end
		if self.RBDefTier2 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXActiveShielding.NewRegenRate
		end
		if self.RBDefTier3 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXImprovedShieldBattery.NewRegenRate
		end
		if self.RBComTier1 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXMaelstromQuantum.NewRegenRate
		end
		if self.RBComTier2 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXFieldExpander.NewRegenRate
		end
		if self.RBComTier3 then
			self.regenammount = self.regenammount + EXBP.Enhancements.EXQuantumInstability.NewRegenRate
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
		--LOG('xxxxxxxxxxxx Aeon Applied Regen', self.regenammount)
    end,

	EXRegenHeartbeat = function(self)
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

    DefaultGunBuffThread = function(self)
		if not self.DefaultGunBuffApplied then
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:AddDamageMod(100)
			self.DefaultGunBuffApplied = true
		end
		if not self.wcBeam01 or not self.wcBeam02 or not self.wcBeam03 then
			self:ShowBone('Basic_GunUp_Range', true)
		else
			self:HideBone('Basic_GunUp_Range', true)
		end
    end,

    DefaultGunBuffThread02 = function(self)
		if not self.DefaultGunBuffApplied02 then
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            wepOvercharge:ChangeMaxRadius(30)
			self.DefaultGunBuffApplied02 = true
		end
		if not self.wcBeam01 or not self.wcBeam02 or not self.wcBeam03 then
			self:ShowBone('Basic_GunUp_RoF', true)
		else
			self:HideBone('Basic_GunUp_RoF', true)
		end
    end,

    WeaponRangeReset = function(self)
		if not self.wcChrono01 then
			local wepFlamer01 = self:GetWeaponByLabel('EXChronoDampener01')
			wepFlamer01:ChangeMaxRadius(1)
		end
		if not self.wcChrono02 then
			local wepFlamer02 = self:GetWeaponByLabel('EXChronoDampener02')
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
		if not self.wcArtillery01 then
			local wepAntiMatter01 = self:GetWeaponByLabel('EXMiasmaArtillery01')
			wepAntiMatter01:ChangeMaxRadius(1)
		end
		if not self.wcArtillery02 then
			local wepAntiMatter02 = self:GetWeaponByLabel('EXMiasmaArtillery02')
			wepAntiMatter02:ChangeMaxRadius(1)
		end
		if not self.wcArtillery03 then
			local wepAntiMatter03 = self:GetWeaponByLabel('EXMiasmaArtillery03')
			wepAntiMatter03:ChangeMaxRadius(1)
		end
		if not self.wcBeam01 then
			local wepGattling01 = self:GetWeaponByLabel('EXPhasonBeam01')
			wepGattling01:ChangeMaxRadius(1)
		end
		if not self.wcBeam02 then
			local wepGattling02 = self:GetWeaponByLabel('EXPhasonBeam02')
			wepGattling02:ChangeMaxRadius(1)
		end
		if not self.wcBeam03 then
			local wepGattling03 = self:GetWeaponByLabel('EXPhasonBeam03')
			wepGattling03:ChangeMaxRadius(1)
		end
		if not self.wcMaelstrom01 then
			local wepClusterMiss01 = self:GetWeaponByLabel('EXQuantumMaelstrom01')
			wepClusterMiss01:ChangeMaxRadius(1)
		end
		if not self.wcMaelstrom02 then
			local wepClusterMiss02 = self:GetWeaponByLabel('EXQuantumMaelstrom02')
			wepClusterMiss02:ChangeMaxRadius(1)
		end
		if not self.wcMaelstrom03 then
			local wepClusterMiss03 = self:GetWeaponByLabel('EXQuantumMaelstrom03')
			wepClusterMiss03:ChangeMaxRadius(1)
		end
    end,
	
    WeaponConfigCheck = function(self)
		if self.wcBuildMode then
			self:SetWeaponEnabledByLabel('EXTargetPainter', false)
			self:SetWeaponEnabledByLabel('RightDisruptor', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetWeaponEnabledByLabel('EXChronoDampener01', false)
			self:SetWeaponEnabledByLabel('EXChronoDampener02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
			self:SetWeaponEnabledByLabel('EXQuantumMaelstrom01', false)
			self:SetWeaponEnabledByLabel('EXQuantumMaelstrom02', false)
			self:SetWeaponEnabledByLabel('EXQuantumMaelstrom03', false)
		end
		if self.wcOCMode then
			self:SetWeaponEnabledByLabel('EXTargetPainter', false)
			self:SetWeaponEnabledByLabel('RightDisruptor', false)
			self:SetWeaponEnabledByLabel('EXChronoDampener01', false)
			self:SetWeaponEnabledByLabel('EXChronoDampener02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
		end
		if not self.wcBuildMode and not self.wcOCMode then
			self:SetWeaponEnabledByLabel('EXTargetPainter', true)
			self:SetWeaponEnabledByLabel('RightDisruptor', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			if self.wcChrono01 then
				self:SetWeaponEnabledByLabel('EXChronoDampener01', true)
				local wepFlamer01 = self:GetWeaponByLabel('EXChronoDampener01')
				wepFlamer01:ChangeMaxRadius(22)
			else
				self:SetWeaponEnabledByLabel('EXChronoDampener01', false)
			end
			if self.wcChrono02 then
				self:SetWeaponEnabledByLabel('EXChronoDampener02', true)
				local wepFlamer02 = self:GetWeaponByLabel('EXChronoDampener02')
				wepFlamer02:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXChronoDampener02', false)
			end
			if self.wcTorp01 then
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', true)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', true)
				local wepTorpedo01 = self:GetWeaponByLabel('EXTorpedoLauncher01')
				wepTorpedo01:ChangeMaxRadius(60)
			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', false)
			end
			if self.wcTorp02 then
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', true)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', true)
				local wepTorpedo02 = self:GetWeaponByLabel('EXTorpedoLauncher02')
				wepTorpedo02:ChangeMaxRadius(60)
			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', false)
			end
			if self.wcTorp03 then
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', true)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', true)
				local wepTorpedo03 = self:GetWeaponByLabel('EXTorpedoLauncher03')
				wepTorpedo03:ChangeMaxRadius(60)
			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', false)
			end
			if self.wcArtillery01 then
				local wepAntiMatter01 = self:GetWeaponByLabel('EXMiasmaArtillery01')
				wepAntiMatter01:ChangeMaxRadius(100)
			else
				
			end
			if self.wcArtillery02 then
				local wepAntiMatter02 = self:GetWeaponByLabel('EXMiasmaArtillery02')
				wepAntiMatter02:ChangeMaxRadius(100)
			else
				
			end
			if self.wcArtillery03 then
				local wepAntiMatter03 = self:GetWeaponByLabel('EXMiasmaArtillery03')
				wepAntiMatter03:ChangeMaxRadius(100)
			else
				
			end
			if self.wcBeam01 then
				local wepGattling01 = self:GetWeaponByLabel('EXPhasonBeam01')
				wepGattling01:ChangeMaxRadius(35)
			else

			end
			if self.wcBeam02 then

				local wepGattling02 = self:GetWeaponByLabel('EXPhasonBeam02')
				wepGattling02:ChangeMaxRadius(40)
			else

			end
			if self.wcBeam03 then

				local wepGattling03 = self:GetWeaponByLabel('EXPhasonBeam03')
				wepGattling03:ChangeMaxRadius(40)
			else

			end
			if self.wcMaelstrom01 then
				self:SetWeaponEnabledByLabel('EXQuantumMaelstrom01', true)
				local wepClusterMiss01 = self:GetWeaponByLabel('EXQuantumMaelstrom01')
				wepClusterMiss01:ChangeMaxRadius(90)
			else
				self:SetWeaponEnabledByLabel('EXQuantumMaelstrom01', false)
			end
			if self.wcMaelstrom02 then
				self:SetWeaponEnabledByLabel('EXQuantumMaelstrom02', true)
				local wepClusterMiss02 = self:GetWeaponByLabel('EXQuantumMaelstrom02')
				wepClusterMiss02:ChangeMaxRadius(90)
			else
				self:SetWeaponEnabledByLabel('EXQuantumMaelstrom02', false)
			end
			if self.wcMaelstrom03 then
				self:SetWeaponEnabledByLabel('EXQuantumMaelstrom03', true)
				local wepClusterMiss03 = self:GetWeaponByLabel('EXQuantumMaelstrom03')
				wepClusterMiss03:ChangeMaxRadius(90)
			else
				self:SetWeaponEnabledByLabel('EXQuantumMaelstrom03', false)
			end
		end
    end,
	
    ArtyShieldCheck = function(self)
		if self.ccArtillery and not self.ccShield then
			self:HideBone('ShieldPack_Normal', true)
			self:HideBone('Shoulder_Normal_L', true)
			self:HideBone('Shoulder_Normal_R', true)
			self:ShowBone('Shoulder_Arty_L', true)
			self:ShowBone('Shoulder_Arty_R', true)
			self:ShowBone('Artillery_Torso', true)
			self:ShowBone('Artillery_Barrel_Left', true)
			self:ShowBone('Artillery_Barrel_Right', true)
			self:HideBone('ShieldPack_Arty_LArm', true)
			self:HideBone('ShieldPack_Arty_RArm', true)
			self:HideBone('ShieldPack_Artillery', true)
			self:ShowBone('Artillery_Pitch', true)
		elseif self.ccShield and not self.ccArtillery then
			self:ShowBone('ShieldPack_Normal', true)
			self:ShowBone('Shoulder_Normal_L', true)
			self:ShowBone('Shoulder_Normal_R', true)
			self:HideBone('Shoulder_Arty_L', true)
			self:HideBone('Shoulder_Arty_R', true)
			self:HideBone('Artillery_Torso', true)
			self:HideBone('Artillery_Barrel_Left', true)
			self:HideBone('Artillery_Barrel_Right', true)
			self:HideBone('ShieldPack_Arty_LArm', true)
			self:HideBone('ShieldPack_Arty_RArm', true)
			self:HideBone('ShieldPack_Artillery', true)
			self:HideBone('Artillery_Pitch', true)
		elseif self.ccArtillery and self.ccShield then
			self:HideBone('ShieldPack_Normal', true)
			self:HideBone('Shoulder_Normal_L', true)
			self:HideBone('Shoulder_Normal_R', true)
			self:ShowBone('Shoulder_Arty_L', true)
			self:ShowBone('Shoulder_Arty_R', true)
			self:ShowBone('Artillery_Torso', true)
			self:ShowBone('Artillery_Barrel_Left', true)
			self:ShowBone('Artillery_Barrel_Right', true)
			self:ShowBone('ShieldPack_Arty_LArm', true)
			self:ShowBone('ShieldPack_Arty_RArm', true)
			self:ShowBone('ShieldPack_Artillery', true)
			self:ShowBone('Artillery_Pitch', true)
		elseif not self.ccArtillery and not self.ccShield then
			self:HideBone('ShieldPack_Normal', true)
			self:ShowBone('Shoulder_Normal_L', true)
			self:ShowBone('Shoulder_Normal_R', true)
			self:HideBone('Shoulder_Arty_L', true)
			self:HideBone('Shoulder_Arty_R', true)
			self:HideBone('Artillery_Torso', true)
			self:HideBone('Artillery_Barrel_Left', true)
			self:HideBone('Artillery_Barrel_Right', true)
			self:HideBone('ShieldPack_Arty_LArm', true)
			self:HideBone('ShieldPack_Arty_RArm', true)
			self:HideBone('ShieldPack_Artillery', true)
			self:HideBone('Artillery_Pitch', true)
		end
    end,

    OnTransportDetach = function(self, attachBone, unit)
        AWalkingLandUnit.OnTransportDetach(self, attachBone, unit)
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
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
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
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')
        end
    end,

    CreateEnhancement = function(self, enh)
        AWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if enh =='EXImprovedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AEONACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'AEONACUT2BuildRate',
                    DisplayName = 'AEONACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'AEONACUT2BuildRate')
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['EXAeonHealthBoost1'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost1',
                    DisplayName = 'EXAeonHealthBoost1',
                    BuffType = 'EXAeonHealthBoost1',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost1')
			self.RBImpEngineering = true
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXImprovedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if Buff.HasBuff( self, 'AEONACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'AEONACUT2BuildRate' )
            end
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'EXAeonHealthBoost1' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost1' )
            end
			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AEONACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'AEONACUT3BuildRate',
                    DisplayName = 'AEONCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'AEONACUT3BuildRate')
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['EXAeonHealthBoost2'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost2',
                    DisplayName = 'EXAeonHealthBoost2',
                    BuffType = 'EXAeonHealthBoost2',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost2')
			self.RBImpEngineering = true
			self.RBAdvEngineering = true
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAdvancedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'AEONACUT3BuildRate' ) then
                Buff.RemoveBuff( self, 'AEONACUT3BuildRate' )
            end
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'EXAeonHealthBoost1' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost1' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost2' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost2' )
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
            if not Buffs['AEONACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'AEONACUT4BuildRate',
                    DisplayName = 'AEONCUT4BuildRate',
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
            Buff.ApplyBuff(self, 'AEONACUT4BuildRate')
            if not Buffs['EXAeonHealthBoost3'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost3',
                    DisplayName = 'EXAeonHealthBoost3',
                    BuffType = 'EXAeonHealthBoost3',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost3')
			self.RBImpEngineering = true
			self.RBAdvEngineering = true
			self.RBExpEngineering = true
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh =='EXExperimentalEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'AEONACUT4BuildRate' ) then
                Buff.RemoveBuff( self, 'AEONACUT4BuildRate' )
            end
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
			local bpEcon = self:GetBlueprint().Economy
			self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'EXAeonHealthBoost1' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost1' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost2' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost2' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost3' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost3' )
            end
			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXCombatEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AEONACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'AEONACUT2BuildRate',
                    DisplayName = 'AEONACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'AEONACUT2BuildRate')
            if not Buffs['EXAeonHealthBoost4'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost4',
                    DisplayName = 'EXAeonHealthBoost4',
                    BuffType = 'EXAeonHealthBoost4',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost4')
			self.wcChrono01 = true
			self.wcChrono02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComEngineering = true
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXCombatEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if Buff.HasBuff( self, 'AEONACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'AEONACUT2BuildRate' )
            end
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
            if Buff.HasBuff( self, 'EXAeonHealthBoost4' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost4' )
            end
			self.wcChrono01 = false
			self.wcChrono02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAssaultEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AEONACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'AEONACUT3BuildRate',
                    DisplayName = 'AEONCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'AEONACUT3BuildRate')
            if not Buffs['EXAeonHealthBoost5'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost5',
                    DisplayName = 'EXAeonHealthBoost5',
                    BuffType = 'EXAeonHealthBoost5',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost5')  
			self.wcChrono01 = false
			self.wcChrono02 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAssaultEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'AEONACUT3BuildRate' ) then
                Buff.RemoveBuff( self, 'AEONACUT3BuildRate' )
            end
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )     
            if Buff.HasBuff( self, 'EXAeonHealthBoost4' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost4' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost5' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost5' )
            end
			self.wcChrono01 = false
			self.wcChrono02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXApocolypticEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AEONACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'AEONACUT4BuildRate',
                    DisplayName = 'AEONCUT4BuildRate',
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
            Buff.ApplyBuff(self, 'AEONACUT4BuildRate')
            if not Buffs['EXAeonHealthBoost6'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost6',
                    DisplayName = 'EXAeonHealthBoost6',
                    BuffType = 'EXAeonHealthBoost6',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost6')
			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = true
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXApocolypticEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'AEONACUT4BuildRate' ) then
                Buff.RemoveBuff( self, 'AEONACUT4BuildRate' )
            end
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
            if Buff.HasBuff( self, 'EXAeonHealthBoost4' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost4' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost5' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost5' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost6' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost6' )
            end
			self.wcChrono01 = false
			self.wcChrono02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh =='EXDisruptorrBooster' then
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread)
        elseif enh =='EXDisruptorrBoosterRemove' then
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh =='EXDisruptorrEnhancer' then
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:ChangeMaxRadius(35)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(35)
			self.DisruptorRange = true
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread02)
        elseif enh =='EXDisruptorrEnhancerRemove' then
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.DisruptorRange = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXTorpedoLauncher' then
            if not Buffs['EXAeonHealthBoost7'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost7',
                    DisplayName = 'EXAeonHealthBoost7',
                    BuffType = 'EXAeonHealthBoost7',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost7')
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:ChangeMaxRadius(35)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(35)
			self.wcTorp01 = true
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXTorpedoLauncherRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost7' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost7' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh =='EXTorpedoRapidLoader' then
            if not Buffs['EXAeonHealthBoost8'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost8',
                    DisplayName = 'EXAeonHealthBoost8',
                    BuffType = 'EXAeonHealthBoost8',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost8')
			local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:AddDamageMod(100)
			self.wcTorp01 = false
			self.wcTorp02 = true
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread)
			self:ForkThread(self.DefaultGunBuffThread02)
        elseif enh =='EXTorpedoRapidLoaderRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost7' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost7' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost8' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost8' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
            wepDisruptor:AddDamageMod(-100)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh =='EXTorpedoClusterLauncher' then
            if not Buffs['EXAeonHealthBoost9'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost9',
                    DisplayName = 'EXAeonHealthBoost9',
                    BuffType = 'EXAeonHealthBoost9',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost9')
			local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:AddDamageMod(200)
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXTorpedoClusterLauncherRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost7' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost7' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost8' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost8' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost9' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost9' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
            wepDisruptor:AddDamageMod(-300)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXArtilleryMiasma' then
            if not Buffs['EXAeonHealthBoost10'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost10',
                    DisplayName = 'EXAeonHealthBoost10',
                    BuffType = 'EXAeonHealthBoost10',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost10')
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:ChangeMaxRadius(35)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(100)
			self.wcArtillery01 = true
			self.wcArtillery02 = false
			self.wcArtillery03 = false
			self.ccArtillery = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXArtilleryMiasmaRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost10' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost10' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false
			self.ccArtillery = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXAdvancedShells' then
            if not Buffs['EXAeonHealthBoost11'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost11',
                    DisplayName = 'EXAeonHealthBoost11',
                    BuffType = 'EXAeonHealthBoost11',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost11')
			self.wcArtillery01 = false
			self.wcArtillery02 = true
			self.wcArtillery03 = false
			self.ccArtillery = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread)
			self:ForkThread(self.DefaultGunBuffThread02)
        elseif enh =='EXAdvancedShellsRemove' then    
			self:RemoveToggleCap('RULEUTC_WeaponToggle')
            if Buff.HasBuff( self, 'EXAeonHealthBoost10' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost10' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost11' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost11' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false
			self.ccArtillery = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXImprovedReloader' then
            if not Buffs['EXAeonHealthBoost12'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost12',
                    DisplayName = 'EXAeonHealthBoost12',
                    BuffType = 'EXAeonHealthBoost12',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost12')
			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = true
			self.ccArtillery = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXImprovedReloaderRemove' then    
			self:RemoveToggleCap('RULEUTC_WeaponToggle')
            if Buff.HasBuff( self, 'EXAeonHealthBoost10' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost10' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost11' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost11' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost12' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost12' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false
			self.ccArtillery = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXBeamPhason' then
            if not Buffs['EXAeonHealthBoost13'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost13',
                    DisplayName = 'EXAeonHealthBoost13',
                    BuffType = 'EXAeonHealthBoost13',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost13')
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:ChangeMaxRadius(35)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(35)
			self.wcBeam01 = true
			self.wcBeam02 = false
			self.wcBeam03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXBeamPhasonRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost13' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost13' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXImprovedCoolingSystem' then
            if not Buffs['EXAeonHealthBoost14'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost14',
                    DisplayName = 'EXAeonHealthBoost14',
                    BuffType = 'EXAeonHealthBoost14',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost14')
			local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:ChangeMaxRadius(40)
            self.wcBeam01 = false
			self.wcBeam02 = true
			self.wcBeam03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)    
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DefaultGunBuffThread)
			self:ForkThread(self.DefaultGunBuffThread02)
        elseif enh =='EXImprovedCoolingSystemRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost13' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost13' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost14' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost14' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXPowerBooster' then
            if not Buffs['EXAeonHealthBoost15'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost15',
                    DisplayName = 'EXAeonHealthBoost15',
                    BuffType = 'EXAeonHealthBoost15',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost15')
			local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            wepDisruptor:ChangeMaxRadius(40)
            self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXPowerBoosterRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost13' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost13' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost14' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost14' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost15' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost15' )
            end
            local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            local bpDisruptZephyrRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepDisruptor:ChangeMaxRadius(bpDisruptZephyrRadius or 22)
			local wepTargetPainter = self:GetWeaponByLabel('EXTargetPainter')
			wepTargetPainter:ChangeMaxRadius(22)
			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXShieldBattery' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreatePersonalShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
			self.ccShield = true
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
		elseif enh == 'EXShieldBatteryRemove' then
            self:DestroyShield()
            RemoveUnitEnhancement(self, 'EXShieldBatteryRemove')
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			self.ccShield = false
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXActiveShielding' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
				self:CreatePersonalShield(bp)
            end)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
			self.ccShield = true
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXActiveShieldingRemove' then
            self:DestroyShield()
            RemoveUnitEnhancement(self, 'EXActiveShieldingRemove')
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			self.ccShield = false
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXImprovedShieldBattery' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
				self:CreatePersonalShield(bp)
            end)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
			self:SetWeaponEnabledByLabel('EXAntiMissile', true)
			self.ccShield = true
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXImprovedShieldBatteryRemove' then
            self:DestroyShield()
            RemoveUnitEnhancement(self, 'EXImprovedShieldBatteryRemove')
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
			self.ccShield = false
			self:ForkThread(self.ArtyShieldCheck)
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXElectronicsEnhancment' then
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 50)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 50)
            if not Buffs['EXAeonHealthBoost16'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost16',
                    DisplayName = 'EXAeonHealthBoost16',
                    BuffType = 'EXAeonHealthBoost16',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost16')
			self:SetWeaponEnabledByLabel('EXAntiMissile', true)
			self.RBIntTier1 = true
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXElectronicsEnhancmentRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
            if Buff.HasBuff( self, 'EXAeonHealthBoost16' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost16' )
            end
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXElectronicCountermeasures' then
            if not Buffs['EXAeonHealthBoost17'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost17',
                    DisplayName = 'EXAeonHealthBoost17',
                    BuffType = 'EXAeonHealthBoost17',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost17')
			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.EnableRemoteViewingButtons)
        elseif enh == 'EXElectronicCountermeasuresRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
            if Buff.HasBuff( self, 'EXAeonHealthBoost16' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost16' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost17' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost17' )
            end
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DisableRemoteViewingButtons)
        elseif enh == 'EXCloakingSubsystems' then
            self:AddCommandCap('RULEUCC_Teleport')
            if not Buffs['EXAeonHealthBoost18'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost18',
                    DisplayName = 'EXAeonHealthBoost18',
                    BuffType = 'EXAeonHealthBoost18',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost18')
			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = true
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXCloakingSubsystemsRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
            if Buff.HasBuff( self, 'EXAeonHealthBoost16' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost16' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost17' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost17' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost18' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost18' )
            end
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
			self:ForkThread(self.EXRegenBuffThread)
			self:ForkThread(self.DisableRemoteViewingButtons)
        elseif enh =='EXMaelstromQuantum' then
				if self.MaelstromEffects01 then
					for k, v in self.MaelstromEffects01 do
						v:Destroy()
					end
					self.MaelstromEffects01 = {}
				end
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'Torso', self:GetArmy(), '/mods/BlackopsACUs/effects/emitters/exmaelstrom_aura_01_emit.bp' ):ScaleEmitter(1):OffsetEmitter(0, -2, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'Torso', self:GetArmy(), '/mods/BlackopsACUs/effects/emitters/exmaelstrom_aura_02_emit.bp' ):ScaleEmitter(1):OffsetEmitter(0, -2.75, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LArm', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_02_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.05, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LArm', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_03_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.05, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LArm', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_04_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.05, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RArm', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_02_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.05, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RArm', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_03_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.05, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RArm', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_04_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.05, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RLeg_B01', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_02_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.1, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RLeg_B01', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_03_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.1, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RLeg_B01', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_04_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.1, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RLeg_B02', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_02_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.15, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RLeg_B02', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_03_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.15, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_RLeg_B02', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_04_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.15, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LLeg_B01', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_02_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.1, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LLeg_B01', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_03_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.1, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LLeg_B01', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_04_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.1, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LLeg_B02', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_02_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.15, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LLeg_B02', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_03_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.15, 0) )
				table.insert( self.MaelstromEffects01, CreateAttachedEmitter( self, 'DamagePack_LLeg_B02', self:GetArmy(), '/effects/emitters/seraphim_being_built_ambient_04_emit.bp' ):ScaleEmitter(0.35):OffsetEmitter(0, -0.15, 0) )
            if not Buffs['EXAeonHealthBoost19'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost19',
                    DisplayName = 'EXAeonHealthBoost19',
                    BuffType = 'EXAeonHealthBoost19',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost19')
			self.wcMaelstrom01 = true
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = true
			self.RBComTier2 = false
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXMaelstromQuantumRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost19' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost19' )
            end
			self.wcMaelstrom01 = false
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
				if self.MaelstromEffects01 then
					for k, v in self.MaelstromEffects01 do
						v:Destroy()
					end
					self.MaelstromEffects01 = {}
				end
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXFieldExpander' then
            if not Buffs['EXAeonHealthBoost20'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost20',
                    DisplayName = 'EXAeonHealthBoost20',
                    BuffType = 'EXAeonHealthBoost20',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost20')
			self:SetWeaponEnabledByLabel('EXAntiMissile', true)
            self.wcMaelstrom01 = false
			self.wcMaelstrom02 = true
			self.wcMaelstrom03 = false
			self:SetWeaponEnabledByLabel('EXAntiMissile', true)
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)    
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh =='EXQuantumInstability' then
            if not Buffs['EXAeonHealthBoost21'] then
                BuffBlueprint {
                    Name = 'EXAeonHealthBoost21',
                    DisplayName = 'EXAeonHealthBoost21',
                    BuffType = 'EXAeonHealthBoost21',
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
            Buff.ApplyBuff(self, 'EXAeonHealthBoost21')
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
            self.wcMaelstrom01 = false
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)      
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = true
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXFieldExpanderRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost19' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost19' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost20' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost20' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost21' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost21' )
            end
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
            self.wcMaelstrom01 = false
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = false
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
				if self.MaelstromEffects01 then
					for k, v in self.MaelstromEffects01 do
						v:Destroy()
					end
					self.MaelstromEffects01 = {}
				end
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
			self:ForkThread(self.EXRegenBuffThread)
        elseif enh == 'EXQuantumInstabilityRemove' then
            if Buff.HasBuff( self, 'EXAeonHealthBoost19' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost19' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost20' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost20' )
            end
            if Buff.HasBuff( self, 'EXAeonHealthBoost21' ) then
                Buff.RemoveBuff( self, 'EXAeonHealthBoost21' )
            end
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
            self.wcMaelstrom01 = false
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = false
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
				if self.MaelstromEffects01 then
					for k, v in self.MaelstromEffects01 do
						v:Destroy()
					end
					self.MaelstromEffects01 = {}
				end
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
				    'Head',
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
				    'Head',
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
        AWalkingLandUnit.OnIntelEnabled(self)
            --if not self.RemoteViewingData.IntelButton then
            --    self.RemoteViewingData.IntelButton = true
            --    self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter - 1
            --    self:CreateVisibleEntity()
            --end
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
        AWalkingLandUnit.OnIntelDisabled(self)
            --if self.RemoteViewingData.IntelButton then
            --    self.RemoteViewingData.IntelButton = false
            --    self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter + 1
            --    self:DisableVisibleEntity()
            --end
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
--]]
TypeClass = EAL0001