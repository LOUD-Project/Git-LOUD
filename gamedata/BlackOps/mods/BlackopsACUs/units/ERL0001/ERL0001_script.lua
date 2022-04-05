local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CWeapons = import('/lua/cybranweapons.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local CCannonMolecularWeapon = CWeapons.CCannonMolecularWeapon
local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local CDFHeavyMicrowaveLaserGeneratorCom = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local CDFOverchargeWeapon = CWeapons.CDFOverchargeWeapon
local CANTorpedoLauncherWeapon = CWeapons.CANTorpedoLauncherWeapon
local Entity = import('/lua/sim/Entity.lua').Entity
local EXCEMPArrayBeam01 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam01
local EXCEMPArrayBeam02 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam02
local EXCEMPArrayBeam03 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam03
local RocketPack = import('/lua/cybranweapons.lua').CDFRocketIridiumWeapon02

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

ERL0001 = Class(CWalkingLandUnit) {

    DeathThreadDestructionWaitTime = 2,

    Weapons = {

        DeathWeapon = Class(CIFCommanderDeathWeapon) {},

        RightRipper = Class(CCannonMolecularWeapon) {

        	OnCreate = function(self)
                CCannonMolecularWeapon.OnCreate(self)
                #Disable buff
                self:DisableBuff('STUN')
            end,
        },

        EXRocketPack01 = Class(RocketPack) {},
        EXRocketPack02 = Class(RocketPack) {},

        EXTorpedoLauncher01 = Class(CANTorpedoLauncherWeapon) {},
        EXTorpedoLauncher02 = Class(CANTorpedoLauncherWeapon) {},
        EXTorpedoLauncher03 = Class(CANTorpedoLauncherWeapon) {},

        EXEMPArray01 = Class(EXCEMPArrayBeam01) {

            OnWeaponFired = function(self)
                EXCEMPArrayBeam01.OnWeaponFired(self)
				local wep = self.unit:GetWeaponByLabel('EXEMPArray02')
				local wep2 = self.unit:GetWeaponByLabel('EXEMPArray03')
				local wep3 = self.unit:GetWeaponByLabel('EXEMPArray04')
				local wep5 = self.unit:GetWeaponByLabel('EXEMPShot01')
				local wep6 = self.unit:GetWeaponByLabel('EXEMPShot02')
				local wep7 = self.unit:GetWeaponByLabel('EXEMPShot03')
				self.targetaquired = self:GetCurrentTargetPos()
				if self.targetaquired then
					if self.unit.EMPArrayEffects01 then
						for k, v in self.unit.EMPArrayEffects01 do
							v:Destroy()
						end
						self.unit.EMPArrayEffects01 = {}
					end
					table.insert( self.unit.EMPArrayEffects01, AttachBeamEntityToEntity(self.unit, 'EMP_Array_Beam_01', self.unit, 'EMP_Array_Muzzle_01', self.unit:GetArmy(), '/mods/BlackOpsACUs/effects/emitters/excemparraybeam02_emit.bp') )
					table.insert( self.unit.EMPArrayEffects01, AttachBeamEntityToEntity(self.unit, 'EMP_Array_Beam_02', self.unit, 'EMP_Array_Muzzle_02', self.unit:GetArmy(), '/mods/BlackOpsACUs/effects/emitters/excemparraybeam02_emit.bp') )
					table.insert( self.unit.EMPArrayEffects01, AttachBeamEntityToEntity(self.unit, 'EMP_Array_Beam_03', self.unit, 'EMP_Array_Muzzle_03', self.unit:GetArmy(), '/mods/BlackOpsACUs/effects/emitters/excemparraybeam02_emit.bp') )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Beam_01', self.unit:GetArmy(), '/effects/emitters/microwave_laser_flash_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Beam_01', self.unit:GetArmy(), '/effects/emitters/microwave_laser_muzzle_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Beam_02', self.unit:GetArmy(), '/effects/emitters/microwave_laser_flash_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Beam_02', self.unit:GetArmy(), '/effects/emitters/microwave_laser_muzzle_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Beam_03', self.unit:GetArmy(), '/effects/emitters/microwave_laser_flash_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Beam_03', self.unit:GetArmy(), '/effects/emitters/microwave_laser_muzzle_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_01', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_01', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_02_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_01', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_03_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_01', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_04_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_01', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_05_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_01', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_06_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_02', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_02', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_02_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_02', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_03_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_02', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_04_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_02', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_05_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_02', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_06_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_03', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_01_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_03', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_02_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_03', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_03_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_03', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_04_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_03', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_05_emit.bp' ):ScaleEmitter(0.05) )
					table.insert( self.unit.EMPArrayEffects01, CreateAttachedEmitter( self.unit, 'EMP_Array_Muzzle_03', self.unit:GetArmy(), '/effects/emitters/microwave_laser_end_06_emit.bp' ):ScaleEmitter(0.05) )
					self.unit:SetWeaponEnabledByLabel('EXEMPArray02', true)
					self.unit:SetWeaponEnabledByLabel('EXEMPArray03', true)
					self.unit:SetWeaponEnabledByLabel('EXEMPArray04', true)
					wep:SetTargetGround(self.targetaquired)
					wep2:SetTargetGround(self.targetaquired)
					wep3:SetTargetGround(self.targetaquired)
					wep:OnFire()
					wep2:OnFire()
					wep3:OnFire()
					if self.unit.wcEMP01 then
						self.unit:SetWeaponEnabledByLabel('EXEMPShot01', true)
						wep5:SetTargetGround(self.targetaquired)
						wep5:OnFire()
					elseif self.unit.wcEMP02 then
						self.unit:SetWeaponEnabledByLabel('EXEMPShot02', true)
						wep6:SetTargetGround(self.targetaquired)
						wep6:OnFire()
					elseif self.unit.wcEMP03 then
						self.unit:SetWeaponEnabledByLabel('EXEMPShot03', true)
						wep7:SetTargetGround(self.targetaquired)
						wep7:OnFire()
					end
					self:ForkThread(self.ArrayEffectsCleanup)
				end
			end,
			ArrayEffectsCleanup = function(self)
				WaitTicks(20)
				if self.unit.EMPArrayEffects01 then
					for k, v in self.unit.EMPArrayEffects01 do
						v:Destroy()
					end
					self.unit.EMPArrayEffects01 = {}
				end
			end,
		},
        EXEMPArray02 = Class(EXCEMPArrayBeam02) {
            OnWeaponFired = function(self)
                EXCEMPArrayBeam02.OnWeaponFired(self)
					self:SetWeaponEnabled(false)
            end,
		},
        EXEMPArray03 = Class(EXCEMPArrayBeam02) {
            OnWeaponFired = function(self)
                EXCEMPArrayBeam02.OnWeaponFired(self)
					self:SetWeaponEnabled(false)
            end,
		},
        EXEMPArray04 = Class(EXCEMPArrayBeam02) {
            OnWeaponFired = function(self)
                EXCEMPArrayBeam02.OnWeaponFired(self)
					self:SetWeaponEnabled(false)
            end,
		},
        EXEMPShot01 = Class(CCannonMolecularWeapon) {
            OnWeaponFired = function(self)
                EXCEMPArrayBeam02.OnWeaponFired(self)
					self:SetWeaponEnabled(false)
            end,
		},
        EXEMPShot02 = Class(CCannonMolecularWeapon) {
            OnWeaponFired = function(self)
                EXCEMPArrayBeam02.OnWeaponFired(self)
					self:SetWeaponEnabled(false)
            end,
		},
        EXEMPShot03 = Class(CCannonMolecularWeapon) {
            OnWeaponFired = function(self)
                EXCEMPArrayBeam02.OnWeaponFired(self)
					self:SetWeaponEnabled(false)
            end,
		},

        EXMLG01 = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},
        EXMLG02 = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},
        EXMLG03 = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},

        EXAA01 = Class(EXCEMPArrayBeam02) {},
        EXAA02 = Class(EXCEMPArrayBeam02) {},
        EXAA03 = Class(EXCEMPArrayBeam02) {},
        EXAA04 = Class(EXCEMPArrayBeam02) {},

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
                self.unit:SetWeaponEnabledByLabel('RightRipper', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
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
                self.unit:SetWeaponEnabledByLabel('RightRipper', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
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

    # ********
    # Creation
    # ********
    OnCreate = function(self)
    
        CWalkingLandUnit.OnCreate(self)
        
        self:SetCapturable(false)
        
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
        
        self:HideBone('Mobility_LLeg_B01', true)
        self:HideBone('Mobility_LLeg_B02', true)
        self:HideBone('Mobility_RLeg_B01', true)
        self:HideBone('Mobility_RLeg_B02', true)
        self:HideBone('Back_AA_B01', true)
        self:HideBone('Back_AA_B02R', true)
        self:HideBone('Back_AA_B02L', true)
        self:HideBone('Engineering', true)
        self:HideBone('Combat_Engineering', true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('EMP_Array', true)
        self:HideBone('EMP_Array_Cable', true)
        self:HideBone('Back_MobilityPack', true)
        self:HideBone('Back_CounterIntelPack', true)
        self:HideBone('Torpedo_Launcher', true)
        self:HideBone('Combat_B03_Head', true)
        self:HideBone('Combat_B01_LArm', true)
        self:HideBone('Combat_B01_RArm', true)
        self:HideBone('Combat_B02_LLeg', true)
        self:HideBone('Combat_B02_RLeg', true)
        self:HideBone('Back_CombatPack', true)
        self:HideBone('Chest_Open', true)

        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER4COMMANDER) )
    end,


    OnPrepareArmToBuild = function(self)
        --CWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self.wcBuildMode = true
		self:ForkThread(self.WeaponConfigCheck)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightRipper'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
    
        CWalkingLandUnit.OnStopCapture(self, target)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
    
        CWalkingLandUnit.OnFailedCapture(self, target)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
    
        CWalkingLandUnit.OnStopReclaim(self, target)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('CloakField')
        self:DisableUnitIntel('Sonar')
		self.EMPArrayEffects01 = {}
		self.EMPArrayEffects02 = {}
		self.EMPArrayEffects03 = {}
		self.wcBuildMode = false
		self.wcOCMode = false
		self.wcRocket01 = false
		self.wcRocket02 = false
		self.wcTorp01 = false
		self.wcTorp02 = false
		self.wcTorp03 = false
		self.wcEMP01 = false
		self.wcEMP02 = false
		self.wcEMP03 = false
		self.wcMasor01 = false
		self.wcMasor02 = false
		self.wcMasor03 = false
		self.wcAA01 = false
		self.wcAA02 = false
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
		self.regenammount = 0
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        CWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )

       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt,  __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
       
    end,

    OnStopBuild = function(self, unitBeingBuilt)
    
        CWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        
        if self.Dead then return end

        -- reattach the permanent projectile
        for _, v in self.BuildProjectile do 
        
            TrashDestroy ( v.BuildEffectsBag )
        
            v:AttachTo( self, v.Name )
            
            -- and scale down the emitters
            v.Emitter:ScaleEmitter(0.05)
            v.Sparker:ScaleEmitter(0.05)
        end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
    end,

    OnFailedToBuild = function(self)
    
        CWalkingLandUnit.OnFailedToBuild(self)
        
        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
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
        self:SetMesh('/mods/BlackOpsACUs/units/erl0001/ERL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
        self:HideBone('Mobility_LLeg_B01', true)
        self:HideBone('Mobility_LLeg_B02', true)
        self:HideBone('Mobility_RLeg_B01', true)
        self:HideBone('Mobility_RLeg_B02', true)
        self:HideBone('Back_AA_B01', true)
        self:HideBone('Back_AA_B02R', true)
        self:HideBone('Back_AA_B02L', true)
        self:HideBone('Engineering', true)
        self:HideBone('Combat_Engineering', true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('EMP_Array', true)
        self:HideBone('EMP_Array_Cable', true)
        self:HideBone('Back_MobilityPack', true)
        self:HideBone('Back_CounterIntelPack', true)
        self:HideBone('Torpedo_Launcher', true)
        self:HideBone('Combat_B03_Head', true)
        self:HideBone('Combat_B01_LArm', true)
        self:HideBone('Combat_B01_RArm', true)
        self:HideBone('Combat_B02_LLeg', true)
        self:HideBone('Combat_B02_RLeg', true)
        self:HideBone('Back_CombatPack', true)
        self:HideBone('Chest_Open', true)
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

    DefaultGunBuffThread = function(self)

		if not self.DefaultGunBuffApplied then

			local RipperRate = self:GetBlueprint().Weapon[1].RateOfFire
            --local wepRipper = self:GetWeaponByLabel('RightRipper')
			self:GetWeaponByLabel('RightRipper'):ChangeRateOfFire(RipperRate * 2)

            self:GetWeaponByLabel('OverCharge'):ChangeMaxRadius(30)
			self:ShowBone('Right_Upgrade', true)
			self.DefaultGunBuffApplied = true
		end
    end,

    WeaponRangeReset = function(self)
		if not self.wcRocket01 then
			local wepFlamer01 = self:GetWeaponByLabel('EXRocketPack01')
			wepFlamer01:ChangeMaxRadius(1)
		end
		if not self.wcRocket02 then
			local wepFlamer02 = self:GetWeaponByLabel('EXRocketPack02')
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
		if not self.wcEMP01 and not self.wcEMP02 and not self.wcEMP03 then
				local wepAntiMatter01 = self:GetWeaponByLabel('EXEMPArray01')
				wepAntiMatter01:ChangeMaxRadius(1)
				local wepAntiMatter02 = self:GetWeaponByLabel('EXEMPArray02')
				wepAntiMatter02:ChangeMaxRadius(1)
				local wepAntiMatter03 = self:GetWeaponByLabel('EXEMPArray03')
				wepAntiMatter03:ChangeMaxRadius(1)
				local wepAntiMatter04 = self:GetWeaponByLabel('EXEMPArray04')
				wepAntiMatter04:ChangeMaxRadius(1)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot01')
				wepAntiMatter06:ChangeMaxRadius(1)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot02')
				wepAntiMatter06:ChangeMaxRadius(1)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot03')
				wepAntiMatter06:ChangeMaxRadius(1)
		end
		if not self.wcMasor01 then
			local wepGattling01 = self:GetWeaponByLabel('EXMLG01')
			wepGattling01:ChangeMaxRadius(1)
		end
		if not self.wcMasor02 then
			local wepGattling02 = self:GetWeaponByLabel('EXMLG02')
			wepGattling02:ChangeMaxRadius(1)
		end
		if not self.wcMasor03 then
			local wepGattling03 = self:GetWeaponByLabel('EXMLG03')
			wepGattling03:ChangeMaxRadius(1)
		end
		if not self.wcAA01 then
			local wepLance01 = self:GetWeaponByLabel('EXAA01')
			wepLance01:ChangeMaxRadius(1)
			local wepLance02 = self:GetWeaponByLabel('EXAA02')
			wepLance02:ChangeMaxRadius(1)
		end
		if not self.wcAA02 then
			local wepLance03 = self:GetWeaponByLabel('EXAA03')
			wepLance03:ChangeMaxRadius(1)
			local wepLance04 = self:GetWeaponByLabel('EXAA04')
			wepLance04:ChangeMaxRadius(1)
		end
    end,

    WeaponConfigCheck = function(self)
		if self.wcBuildMode then
			self:SetWeaponEnabledByLabel('RightRipper', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetWeaponEnabledByLabel('EXRocketPack01', false)
			self:SetWeaponEnabledByLabel('EXRocketPack02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXEMPArray01', false)
			self:SetWeaponEnabledByLabel('EXEMPArray02', false)
			self:SetWeaponEnabledByLabel('EXEMPArray03', false)
			self:SetWeaponEnabledByLabel('EXEMPArray04', false)
			self:SetWeaponEnabledByLabel('EXEMPShot01', false)
			self:SetWeaponEnabledByLabel('EXEMPShot02', false)
			self:SetWeaponEnabledByLabel('EXEMPShot03', false)
			self:SetWeaponEnabledByLabel('EXMLG01', false)
			self:SetWeaponEnabledByLabel('EXMLG02', false)
			self:SetWeaponEnabledByLabel('EXMLG03', false)
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)
			self:SetWeaponEnabledByLabel('EXAA03', false)
			self:SetWeaponEnabledByLabel('EXAA04', false)
		end
		if self.wcOCMode then
			self:SetWeaponEnabledByLabel('RightRipper', false)
			self:SetWeaponEnabledByLabel('EXRocketPack01', false)
			self:SetWeaponEnabledByLabel('EXRocketPack02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXEMPArray01', false)
			self:SetWeaponEnabledByLabel('EXEMPArray02', false)
			self:SetWeaponEnabledByLabel('EXEMPArray03', false)
			self:SetWeaponEnabledByLabel('EXEMPArray04', false)
			self:SetWeaponEnabledByLabel('EXEMPShot01', false)
			self:SetWeaponEnabledByLabel('EXEMPShot02', false)
			self:SetWeaponEnabledByLabel('EXEMPShot03', false)
			self:SetWeaponEnabledByLabel('EXMLG01', false)
			self:SetWeaponEnabledByLabel('EXMLG02', false)
			self:SetWeaponEnabledByLabel('EXMLG03', false)
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)
			self:SetWeaponEnabledByLabel('EXAA03', false)
			self:SetWeaponEnabledByLabel('EXAA04', false)
		end
		if not self.wcBuildMode and not self.wcOCMode then
			self:SetWeaponEnabledByLabel('RightRipper', true)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetWeaponEnabledByLabel('EXEMPArray02', false)
			self:SetWeaponEnabledByLabel('EXEMPArray03', false)
			self:SetWeaponEnabledByLabel('EXEMPArray04', false)
			self:SetWeaponEnabledByLabel('EXEMPShot01', false)
			self:SetWeaponEnabledByLabel('EXEMPShot02', false)
			self:SetWeaponEnabledByLabel('EXEMPShot03', false)
			if self.wcRocket01 then
				self:SetWeaponEnabledByLabel('EXRocketPack01', true)
				local wepFlamer01 = self:GetWeaponByLabel('EXRocketPack01')
				wepFlamer01:ChangeMaxRadius(22)
			else
				self:SetWeaponEnabledByLabel('EXRocketPack01', false)
			end
			if self.wcRocket02 then
				self:SetWeaponEnabledByLabel('EXRocketPack02', true)
				local wepFlamer02 = self:GetWeaponByLabel('EXRocketPack02')
				wepFlamer02:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXRocketPack02', false)
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
			if self.wcEMP01 then
				self:SetWeaponEnabledByLabel('EXEMPArray01', true)
				local wepAntiMatter01 = self:GetWeaponByLabel('EXEMPArray01')
				wepAntiMatter01:ChangeMaxRadius(35)
				local wepAntiMatter02 = self:GetWeaponByLabel('EXEMPArray02')
				wepAntiMatter02:ChangeMaxRadius(35)
				local wepAntiMatter03 = self:GetWeaponByLabel('EXEMPArray03')
				wepAntiMatter03:ChangeMaxRadius(35)
				local wepAntiMatter04 = self:GetWeaponByLabel('EXEMPArray04')
				wepAntiMatter04:ChangeMaxRadius(35)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot01')
				wepAntiMatter06:ChangeMaxRadius(35)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot02')
				wepAntiMatter06:ChangeMaxRadius(35)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot03')
				wepAntiMatter06:ChangeMaxRadius(35)
			elseif self.wcEMP02 then
				self:SetWeaponEnabledByLabel('EXEMPArray01', true)
				local wepAntiMatter01 = self:GetWeaponByLabel('EXEMPArray01')
				wepAntiMatter01:ChangeMaxRadius(40)
				local wepAntiMatter02 = self:GetWeaponByLabel('EXEMPArray02')
				wepAntiMatter02:ChangeMaxRadius(40)
				local wepAntiMatter03 = self:GetWeaponByLabel('EXEMPArray03')
				wepAntiMatter03:ChangeMaxRadius(40)
				local wepAntiMatter04 = self:GetWeaponByLabel('EXEMPArray04')
				wepAntiMatter04:ChangeMaxRadius(40)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot01')
				wepAntiMatter06:ChangeMaxRadius(40)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot02')
				wepAntiMatter06:ChangeMaxRadius(40)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot03')
				wepAntiMatter06:ChangeMaxRadius(40)
			elseif self.wcEMP03 then
				self:SetWeaponEnabledByLabel('EXEMPArray01', true)
				local wepAntiMatter01 = self:GetWeaponByLabel('EXEMPArray01')
				wepAntiMatter01:ChangeMaxRadius(45)
				local wepAntiMatter02 = self:GetWeaponByLabel('EXEMPArray02')
				wepAntiMatter02:ChangeMaxRadius(45)
				local wepAntiMatter03 = self:GetWeaponByLabel('EXEMPArray03')
				wepAntiMatter03:ChangeMaxRadius(45)
				local wepAntiMatter04 = self:GetWeaponByLabel('EXEMPArray04')
				wepAntiMatter04:ChangeMaxRadius(45)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot01')
				wepAntiMatter06:ChangeMaxRadius(45)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot02')
				wepAntiMatter06:ChangeMaxRadius(45)
				local wepAntiMatter06 = self:GetWeaponByLabel('EXEMPShot03')
				wepAntiMatter06:ChangeMaxRadius(45)
			elseif not self.wcEMP01 and not self.wcEMP01 and not self.wcEMP01 then
				self:SetWeaponEnabledByLabel('EXEMPArray01', false)
			end
			if self.wcMasor01 then
				self:SetWeaponEnabledByLabel('EXMLG01', true)
				local wepGattling01 = self:GetWeaponByLabel('EXMLG01')
				wepGattling01:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXMLG01', false)
			end
			if self.wcMasor02 then
				self:SetWeaponEnabledByLabel('EXMLG02', true)
				local wepGattling02 = self:GetWeaponByLabel('EXMLG02')
				wepGattling02:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXMLG02', false)
			end
			if self.wcMasor03 then
				self:SetWeaponEnabledByLabel('EXMLG03', true)
				local wepGattling03 = self:GetWeaponByLabel('EXMLG03')
				wepGattling03:ChangeMaxRadius(30)
			else
				self:SetWeaponEnabledByLabel('EXMLG03', false)
			end
			if self.wcAA01 then
				self:SetWeaponEnabledByLabel('EXAA01', true)
				local wepLance01 = self:GetWeaponByLabel('EXAA01')
				wepLance01:ChangeMaxRadius(35)
				self:SetWeaponEnabledByLabel('EXAA02', true)
				local wepLance02 = self:GetWeaponByLabel('EXAA02')
				wepLance02:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXAA01', false)
				self:SetWeaponEnabledByLabel('EXAA02', false)
			end
			if self.wcAA02 then
				self:SetWeaponEnabledByLabel('EXAA03', true)
				local wepLance03 = self:GetWeaponByLabel('EXAA03')
				wepLance03:ChangeMaxRadius(35)
				self:SetWeaponEnabledByLabel('EXAA04', true)
				local wepLance04 = self:GetWeaponByLabel('EXAA04')
				wepLance04:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXAA03', false)
				self:SetWeaponEnabledByLabel('EXAA04', false)
			end
		end
    end,

    OnTransportDetach = function(self, attachBone, unit)
        CWalkingLandUnit.OnTransportDetach(self, attachBone, unit)
		self:StopSiloBuild()
        self:ForkThread(self.WeaponConfigCheck)
    end,

    OnScriptBitClear = function(self, bit)
    
        if bit == 8 then -- cloak toggle
        
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
    
        if bit == 8 then
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

        CWalkingLandUnit.CreateEnhancement(self, enh)

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
            self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

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
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

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
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false

        elseif enh =='EXCombatEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T2_Combat_Eng')

			self.wcRocket01 = true
			self.wcRocket02 = false

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
            self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcRocket01 = false
			self.wcRocket02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false

        elseif enh =='EXAssaultEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T3_Combat_Eng')

			self.wcRocket01 = false
			self.wcRocket02 = true

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
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcRocket01 = false
			self.wcRocket02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false

        elseif enh =='EXApocalypticEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T4_Combat_Eng')

			self.wcRocket01 = false
			self.wcRocket02 = true

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = true

        elseif enh =='EXApocalypticEngineeringRemove' then

            if Buff.HasBuff( self, 'ACU_T4_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcRocket01 = false
			self.wcRocket02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false

		elseif enh =='EXRipperBooster' then
            local wepRipper = self:GetWeaponByLabel('RightRipper')
			wepRipper:AddDamageMod(50)
            wepRipper:ChangeMaxRadius(self:GetBlueprint().Weapon[1].MaxRadius + 5)
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
			wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius + 5)
			self:ShowBone('Right_Upgrade', true)

        elseif enh =='EXRipperBoosterRemove' then
            local wepRipper = self:GetWeaponByLabel('RightRipper')
			wepRipper:AddDamageMod(-50)
            wepRipper:ChangeMaxRadius(self:GetBlueprint().Weapon[1].MaxRadius)
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
			wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
			self:HideBone('Right_Upgrade', true)

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

        elseif enh =='EXEMPArray' then
			self.wcEMP01 = true
			self.wcEMP02 = false
			self.wcEMP03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXEMPArrayRemove' then
			self.wcEMP01 = false
			self.wcEMP02 = false
			self.wcEMP03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedCapacitors' then
			self.wcEMP01 = false
			self.wcEMP02 = true
			self.wcEMP03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedCapacitorsRemove' then
			self.wcEMP01 = false
			self.wcEMP02 = false
			self.wcEMP03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXPowerBooster' then
            self.wcEMP01 = false
			self.wcEMP02 = false
			self.wcEMP03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXPowerBoosterRemove' then
            self:SetWeaponEnabledByLabel('EXEMPArray01', false)
			self.wcEMP01 = false
			self.wcEMP02 = false
			self.wcEMP03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXMasor' then
			self.wcMasor01 = true
			self.wcMasor02 = false
			self.wcMasor03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXMasorRemove' then
			self.wcMasor01 = false
			self.wcMasor02 = false
			self.wcMasor03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedCoolingSystem' then
			self.wcMasor01 = false
			self.wcMasor02 = true
			self.wcMasor03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedCoolingSystemRemove' then
			self.wcMasor01 = false
			self.wcMasor02 = false
			self.wcMasor03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXAdvancedEmitterArray' then
			self.wcMasor01 = false
			self.wcMasor02 = false
			self.wcMasor03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXAdvancedEmitterArrayRemove' then
			self.wcMasor01 = false
			self.wcMasor02 = false
			self.wcMasor03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXArmorPlating' then
            if not Buffs['EXCybranHealthBoost22'] then
                BuffBlueprint {
                    Name = 'EXCybranHealthBoost22',
                    DisplayName = 'EXCybranHealthBoost22',
                    BuffType = 'EXCybranHealthBoost22',
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
            Buff.ApplyBuff(self, 'EXCybranHealthBoost22')
			self.wcAA01 = true
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBDefTier1 = true
			self.RBDefTier2 = false
			self.RBDefTier3 = false

		elseif enh == 'EXArmorPlatingRemove' then
            if Buff.HasBuff( self, 'EXCybranHealthBoost22' ) then
                Buff.RemoveBuff( self, 'EXCybranHealthBoost22' )
            end
			self.wcAA01 = false
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false

        elseif enh == 'EXStructuralIntegrity' then
            if not Buffs['EXCybranHealthBoost23'] then
                BuffBlueprint {
                    Name = 'EXCybranHealthBoost23',
                    DisplayName = 'EXCybranHealthBoost23',
                    BuffType = 'EXCybranHealthBoost23',
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
            Buff.ApplyBuff(self, 'EXCybranHealthBoost23')
			self.wcAA01 = true
			self.wcAA02 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBDefTier1 = true
			self.RBDefTier2 = true
			self.RBDefTier3 = false

        elseif enh == 'EXStructuralIntegrityRemove' then
            if Buff.HasBuff( self, 'EXCybranHealthBoost22' ) then
                Buff.RemoveBuff( self, 'EXCybranHealthBoost22' )
            end
            if Buff.HasBuff( self, 'EXCybranHealthBoost23' ) then
                Buff.RemoveBuff( self, 'EXCybranHealthBoost23' )
            end
			self.wcAA01 = false
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false

        elseif enh == 'EXCompositeMaterials' then
            if not Buffs['EXCybranHealthBoost24'] then
                BuffBlueprint {
                    Name = 'EXCybranHealthBoost24',
                    DisplayName = 'EXCybranHealthBoost24',
                    BuffType = 'EXCybranHealthBoost24',
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
            Buff.ApplyBuff(self, 'EXCybranHealthBoost24')
			self.RBDefTier1 = true
			self.RBDefTier2 = true
			self.RBDefTier3 = true

        elseif enh == 'EXCompositeMaterialsRemove' then
            if Buff.HasBuff( self, 'EXCybranHealthBoost22' ) then
                Buff.RemoveBuff( self, 'EXCybranHealthBoost22' )
            end
            if Buff.HasBuff( self, 'EXCybranHealthBoost23' ) then
                Buff.RemoveBuff( self, 'EXCybranHealthBoost23' )
            end
            if Buff.HasBuff( self, 'EXCybranHealthBoost24' ) then
                Buff.RemoveBuff( self, 'EXCybranHealthBoost24' )
            end
			self.wcAA01 = false
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false

        elseif enh == 'EXElectronicsEnhancment' then
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 50)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 50)

			self.RBIntTier1 = true
			self.RBIntTier2 = false
			self.RBIntTier3 = false

        elseif enh == 'EXElectronicsEnhancmentRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)

			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false

        elseif enh == 'EXElectronicCountermeasures' then
            self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false
            self.StealthEnh = true
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')

			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = false

        elseif enh == 'EXElectronicCountermeasuresRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')
            self.StealthEnh = false
            self.CloakEnh = false
            self.StealthFieldEffects = false
            self.CloakingEffects = false
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)

			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false

        elseif enh == 'EXCloakingSubsystems' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            self.StealthEnh = false
			self.CloakEnh = true
            self:EnableUnitIntel('Cloak')

			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = true

        elseif enh == 'EXCloakingSubsystemsRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Cloak')
            self.CloakEnh = false
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)

			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false

        elseif enh =='EXMobilitySubsystems' then
			self:SetSpeedMult(1.41176)

			self.RBComTier1 = true
			self.RBComTier2 = false
			self.RBComTier3 = false

        elseif enh =='EXMobilitySubsystemsRemove' then
			self:SetSpeedMult(1)

			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false

        elseif enh =='EXDefensiveSubsystems' then
			self:AddCommandCap('RULEUCC_Teleport')

			self.wcAA01 = true
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = false

        elseif enh == 'EXDefensiveSubsystemsRemove' then
			self:SetSpeedMult(1)

			self:RemoveCommandCap('RULEUCC_Teleport')
			self.wcAA01 = false
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false

        elseif enh =='EXNanoKickerSubsystems' then

            if not Buffs['EXCybranRegenBoost100'] then
                BuffBlueprint {
                    Name = 'EXCybranRegenBoost100',
                    BuffType = 'ACUREGENRATE',
					ParsedEntityCategory = categories.COMMAND,
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = 100,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'EXCybranRegenBoost100')

			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = true

        elseif enh == 'EXNanoKickerSubsystemsRemove' then

			Buff.RemoveBuff( self, 'EXCybranRegenBoost100' )

			self:SetSpeedMult(1)

			self:RemoveCommandCap('RULEUCC_Teleport')
			self.wcAA01 = false
			self.wcAA02 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
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
				    'Right_Turret',
				    'Left_Turret',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
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
    
        CWalkingLandUnit.OnIntelEnabled(self)
        
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

    OnKilled = function(self, instigator, type, overkillRatio)
    
        local bp
        
        for k, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                bp = v
            end
        end

        if bp != nil then
			self:AddBuff(bp)
        end

        CWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
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

TypeClass = ERL0001
