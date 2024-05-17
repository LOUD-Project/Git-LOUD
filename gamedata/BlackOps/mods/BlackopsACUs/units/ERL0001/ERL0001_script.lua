local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Buff = import('/lua/sim/Buff.lua')
local BuffField = import('/lua/cybranweapons.lua').CybranBuffField


local Entity = import('/lua/sim/Entity.lua').Entity

local CWeapons = import('/lua/cybranweapons.lua')

local CCannonMolecularWeapon                = CWeapons.CCannonMolecularWeapon
local CIFCommanderDeathWeapon               = CWeapons.CIFCommanderDeathWeapon
local MicrowaveLaser                        = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local CDFOverchargeWeapon                   = CWeapons.CDFOverchargeWeapon
local CANNaniteTorpedo                      = CWeapons.CANNaniteTorpedoWeapon
local RocketPack                            = CWeapons.CDFRocketIridiumWeapon02
local Targeting                             = CWeapons.CybranTargetPainter

CWeapons = nil

local EXCEMPArrayBeam01 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam01
local EXCEMPArrayBeam02 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam02
local EXCEMPArrayBeam03 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam03

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local wep, wpTarget

ERL0001 = Class(CWalkingLandUnit) {
	
    DeathThreadDestructionWaitTime = 2,

	BuffFields = {
		OpticalInterferenceField = Class(BuffField){},
	},

    Weapons = {

        DeathWeapon = Class(CIFCommanderDeathWeapon) {},
		
        TargetPainter = Class(Targeting) { FxMuzzleFlash = false },

        RightRipper = Class(CCannonMolecularWeapon) {

        	OnCreate = function(self)
                CCannonMolecularWeapon.OnCreate(self)

                self:DisableBuff('STUN')
            end,
        },

        EXRocketPack01 = Class(RocketPack) {},
        EXRocketPack02 = Class(RocketPack) {},

        EXTorpedoLauncher01 = Class(CANNaniteTorpedo) {},
        EXTorpedoLauncher02 = Class(CANNaniteTorpedo) {},
        EXTorpedoLauncher03 = Class(CANNaniteTorpedo) {},

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

        EXMLG01 = Class(MicrowaveLaser) {},
        EXMLG02 = Class(MicrowaveLaser) {},
        EXMLG03 = Class(MicrowaveLaser) {},

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

                --self.unit:SetWeaponEnabledByLabel('RightRipper', false)

                self.unit:BuildManipulatorSetEnabled(false)
                
                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end

                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                
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

                if self.unit.BuildArmManipulator then    
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end

                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)

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
        self:SetupBuildBones()

        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER4COMMANDER) )
    end,
  
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt,  __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    OnPrepareArmToBuild = function(self)

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(true)

        self.BuildArmManipulator:SetPrecedence(20)
        self.wcBuildMode = true

		self:ForkThread(self.WeaponConfigCheck)

        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightRipper'):GetHeadingPitch() )
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
                v.Detached = false
            end
            
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

        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('CloakField')
        
        self:HideBone('Engineering', true)
        self:HideBone('Combat_Engineering', true)

        self:HideBone('Mobility_LLeg_B01', true)
        self:HideBone('Mobility_LLeg_B02', true)
        self:HideBone('Mobility_RLeg_B01', true)
        self:HideBone('Mobility_RLeg_B02', true)

        self:HideBone('Back_AA_B01', true)
        self:HideBone('Back_AA_B02R', true)
        self:HideBone('Back_AA_B02L', true)

        self:HideBone('Right_Upgrade', true)
        self:HideBone('EMP_Array', true)
        self:HideBone('EMP_Array_Cable', true)

        self:HideBone('Back_CombatPack', true)
        self:HideBone('Back_MobilityPack', true)
        self:HideBone('Back_CounterIntelPack', true)

        self:HideBone('Torpedo_Launcher', true)

        self:HideBone('Combat_B03_Head', true)
        self:HideBone('Combat_B01_LArm', true)
        self:HideBone('Combat_B01_RArm', true)
        self:HideBone('Combat_B02_LLeg', true)
        self:HideBone('Combat_B02_RLeg', true)

        self:HideBone('Chest_Open', true)

		self.EMPArrayEffects01 = {}

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
		
		self.IntelPackage = false
        self.IntelPackageOn = false
        self.CloakPackage = false
        self.CloakOn = false
        self.Deviator = false

		wpTarget = self:GetWeaponByLabel('TargetPainter')

		wpTarget:ChangeMaxRadius(100)

		self:ForkThread(self.WeaponConfigCheck)
		self:ForkThread(self.WeaponRangeReset)

        self:ForkThread(self.GiveInitialResources)
		
        self.EnergyConsumption = { Total = 0, Back = 0, Command = 0, LCH = 0, RCH = 0 }
        
        self:RemoveToggleCap('RULEUTC_CloakToggle')
        self:RemoveToggleCap('RULEUTC_IntelToggle')
        self:RemoveToggleCap('RULEUTC_SpecialToggle')
        self:RemoveToggleCap('RULEUTC_StealthToggle')
        
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy

        local antiMissile = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }

        TrashAdd( self.Trash, antiMissile)
    end,

    OnTransportDetach = function(self, attachBone, unit)

        CWalkingLandUnit.OnTransportDetach(self, attachBone, unit)

		self:StopSiloBuild()
        self:ForkThread(self.WeaponConfigCheck)
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

        self:HideBone('Back_CombatPack', true)
        self:HideBone('Back_MobilityPack', true)
        self:HideBone('Back_CounterIntelPack', true)

        self:HideBone('Torpedo_Launcher', true)

        self:HideBone('Combat_B03_Head', true)
        self:HideBone('Combat_B01_LArm', true)
        self:HideBone('Combat_B01_RArm', true)
        self:HideBone('Combat_B02_LLeg', true)
        self:HideBone('Combat_B02_RLeg', true)

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

    WeaponRangeReset = function(self)

		wpTarget:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[2].MaxRadius)

		if not self.wcRocket01 then
			wep = self:GetWeaponByLabel('EXRocketPack01')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcRocket02 then
			wep = self:GetWeaponByLabel('EXRocketPack02')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcTorp01 then
			wep = self:GetWeaponByLabel('EXTorpedoLauncher01')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcTorp02 then
			wep = self:GetWeaponByLabel('EXTorpedoLauncher02')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcTorp03 then
			wep = self:GetWeaponByLabel('EXTorpedoLauncher03')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcEMP01 and not self.wcEMP02 and not self.wcEMP03 then

			wep = self:GetWeaponByLabel('EXEMPArray01')
			wep:ChangeMaxRadius(1)

			wep = self:GetWeaponByLabel('EXEMPArray02')
			wep:ChangeMaxRadius(1)

			wep = self:GetWeaponByLabel('EXEMPArray03')
			wep:ChangeMaxRadius(1)

			wep = self:GetWeaponByLabel('EXEMPArray04')
			wep:ChangeMaxRadius(1)

			wep = self:GetWeaponByLabel('EXEMPShot01')
			wep:ChangeMaxRadius(1)

			wep = self:GetWeaponByLabel('EXEMPShot02')
			wep:ChangeMaxRadius(1)

			wep = self:GetWeaponByLabel('EXEMPShot03')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcMasor01 then
			wep = self:GetWeaponByLabel('EXMLG01')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcMasor02 then
			wep = self:GetWeaponByLabel('EXMLG02')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcMasor03 then
			wep = self:GetWeaponByLabel('EXMLG03')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcAA01 then
			wep = self:GetWeaponByLabel('EXAA01')
			wep:ChangeMaxRadius(1)
			wep = self:GetWeaponByLabel('EXAA02')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcAA02 then
			wep = self:GetWeaponByLabel('EXAA03')
			wep:ChangeMaxRadius(1)
			wep = self:GetWeaponByLabel('EXAA04')
			wep:ChangeMaxRadius(1)
		end
    end,

    WeaponConfigCheck = function(self)

		if self.wcBuildMode then
		
			self:SetWeaponEnabledByLabel('TargetPainter', false)
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
		end

		if self.wcOCMode then
		
			self:SetWeaponEnabledByLabel('TargetPainter', false)
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
		end

		if not self.wcBuildMode and not self.wcOCMode then
		
			self:SetWeaponEnabledByLabel('TargetPainter', true)
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

				wep = self:GetWeaponByLabel('EXRocketPack01')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[5].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXRocketPack01', false)
			end

			if self.wcRocket02 then

				self:SetWeaponEnabledByLabel('EXRocketPack02', true)

				wep = self:GetWeaponByLabel('EXRocketPack02')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[6].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXRocketPack02', false)
			end

			if self.wcTorp01 then

				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', true)

				wep = self:GetWeaponByLabel('EXTorpedoLauncher01')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[7].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			end

			if self.wcTorp02 then

				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', true)

				wep = self:GetWeaponByLabel('EXTorpedoLauncher02')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[8].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			end

			if self.wcTorp03 then

				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', true)

				wep = self:GetWeaponByLabel('EXTorpedoLauncher03')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[9].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			end

			if self.wcEMP01 then

				self:SetWeaponEnabledByLabel('EXEMPArray01', true)
   
                local radius = __blueprints[self.BlueprintID].Weapon[14].MaxRadius

				wep = self:GetWeaponByLabel('EXEMPArray01')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray02')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray03')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray04')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot01')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot02')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot03')
                wep:ChangeMaxRadius(radius)

				wpTarget:ChangeMaxRadius(radius)

			elseif self.wcEMP02 then

				self:SetWeaponEnabledByLabel('EXEMPArray01', true)
   
                local radius = __blueprints[self.BlueprintID].Weapon[15].MaxRadius

				wep = self:GetWeaponByLabel('EXEMPArray01')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray02')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray03')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray04')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot01')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot02')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot03')
                wep:ChangeMaxRadius(radius)

				wpTarget:ChangeMaxRadius(radius)

			elseif self.wcEMP03 then

				self:SetWeaponEnabledByLabel('EXEMPArray01', true)
   
                local radius = __blueprints[self.BlueprintID].Weapon[16].MaxRadius

				wep = self:GetWeaponByLabel('EXEMPArray01')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray02')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray03')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPArray04')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot01')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot02')
                wep:ChangeMaxRadius(radius)
				wep = self:GetWeaponByLabel('EXEMPShot03')
                wep:ChangeMaxRadius(radius)

				wpTarget:ChangeMaxRadius(radius)

			elseif not self.wcEMP01 and not self.wcEMP01 and not self.wcEMP01 then
				self:SetWeaponEnabledByLabel('EXEMPArray01', false)
			end

			if self.wcMasor01 then

				self:SetWeaponEnabledByLabel('EXMLG01', true)

				wep = self:GetWeaponByLabel('EXMLG01')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[17].MaxRadius)

				wpTarget:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[17].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXMLG01', false)
			end

			if self.wcMasor02 then

				self:SetWeaponEnabledByLabel('EXMLG02', true)

				wep = self:GetWeaponByLabel('EXMLG02')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[18].MaxRadius)

				wpTarget:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[18].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXMLG02', false)
			end

			if self.wcMasor03 then

				self:SetWeaponEnabledByLabel('EXMLG03', true)

				wep = self:GetWeaponByLabel('EXMLG03')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[19].MaxRadius)

				wpTarget:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[19].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXMLG03', false)
			end


			if self.wcAA01 then

				self:SetWeaponEnabledByLabel('EXAA01', true)
				
                wep = self:GetWeaponByLabel('EXAA01')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[20].MaxRadius)

				self:SetWeaponEnabledByLabel('EXAA02', true)

				wep = self:GetWeaponByLabel('EXAA02')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[21].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXAA01', false)
				self:SetWeaponEnabledByLabel('EXAA02', false)
			end

			if self.wcAA02 then

				self:SetWeaponEnabledByLabel('EXAA03', true)

				wep = self:GetWeaponByLabel('EXAA03')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[22].MaxRadius)

				self:SetWeaponEnabledByLabel('EXAA04', true)

				wep = self:GetWeaponByLabel('EXAA04')
				wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[23].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXAA03', false)
				self:SetWeaponEnabledByLabel('EXAA04', false)
			end
		end
    end,

    OnScriptBitClear = function(self, bit)

        if bit == 3 and self.IntelPackage and not self.IntelPackageOn then    -- Radar

            -- add command slot consumption when radar turned on
            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] + self.EnergyConsumption['Command']

            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('Sonar')
            self:EnableUnitIntel('Omni')
            
            self.IntelPackageOn = true

        elseif bit == 5 and self.StealthPackage then

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] + self.EnergyConsumption['Back']
            
            self:SetIntelRadius( 'RadarStealth', 32 )
            self:SetIntelRadius( 'RadarStealthField', 32 )
            self:SetIntelRadius( 'SonarStealth', 32 )
            self:SetIntelRadius( 'SonarStealthField', 32 )

            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealthField')

            self.StealthOn = true
            
            if self.CloakPackage then

                self:ForkThread( function(self)

                    WaitTicks(1)
                    self:AddToggleCap('RULEUTC_CloakToggle')            -- add the toggle
                    self:SetScriptBit('RULEUTC_CloakToggle', false )    -- turn on cloak
                    end
                )
            end

            if self.DeviatorPackage then
            
                self:ForkThread( function(self)
            
                    --LOG("*AI DEBUG Turning on Deviator via Stealth")

                    WaitTicks(3)
                    self:AddToggleCap('RULEUTC_SpecialToggle')
                    self:SetScriptBit('RULEUTC_SpecialToggle', false )
                    end
                )
            end
            
        elseif bit == 7 then

            self:GetBuffFieldByName('CybranACUOpticalDisruptionBuffField'):Enable()
            
        elseif bit == 8 and not self.CloakOn then    -- cloak toggle

            self:EnableUnitIntel('Cloak')

            self.CloakOn = true

        end
        
        --LOG("*AI DEBUG Consumption Table after bit "..bit.." clear is "..repr(self.EnergyConsumption) )

        self:SetEnergyMaintenanceConsumptionOverride( self.EnergyConsumption['Total'] )
        
        if self.EnergyConsumption['Total'] > 0 then
            self:SetMaintenanceConsumptionActive()
        else
            self:SetMaintenanceConsumptionInactive()
        end

    end,

    OnScriptBitSet = function(self, bit)

        if bit == 3 and self.IntelPackage and self.IntelPackageOn then

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption['Command']

            self:DisableUnitIntel('Radar')
            self:DisableUnitIntel('Sonar')
            self:DisableUnitIntel('Omni')
            
            self.IntelPackageOn = false

        elseif bit == 5 and self.StealthPackage then

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption['Back']
            
            self:SetIntelRadius( 'RadarStealth', 1 )
            self:SetIntelRadius( 'RadarStealthField', 1 )
            self:SetIntelRadius( 'SonarStealth', 1 )
            self:SetIntelRadius( 'SonarStealthField', 1 )

            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealthField')
            
            self.StealthOn = false
            
            if self.CloakPackage then

                self:ForkThread( function(self)

                    WaitTicks(1)            
                    self:SetScriptBit('RULEUTC_CloakToggle', true )     -- turn off cloak
                    self:RemoveToggleCap('RULEUTC_CloakToggle')         -- remove the toggle
                    end
                )
            end

            if self.DeviatorPackage then

                self:ForkThread( function(self)
            
                    LOG("*AI DEBUG Turning OFF Deviator via Stealth")

                    WaitTicks(3)
                    self:SetScriptBit('RULEUTC_SpecialToggle', true )
                    self:AddToggleCap('RULEUTC_SpecialToggle')
                    end
                )
            end

        elseif bit == 7 then
        
            self:GetBuffFieldByName('CybranACUOpticalDisruptionBuffField'):Disable()
            
        elseif bit == 8 then

            self:DisableUnitIntel('Cloak')
            self.CloakOn = false

        end
        
        --LOG("*AI DEBUG Consumption Table when bit "..bit.." set is "..repr(self.EnergyConsumption) )

        self:SetEnergyMaintenanceConsumptionOverride( self.EnergyConsumption['Total'] )
        
        if self.EnergyConsumption['Total'] > 0 then
            self:SetMaintenanceConsumptionActive()
        else
            self:SetMaintenanceConsumptionInactive()
        end

    end,
 
    CreateEnhancement = function(self, enh)

        CWalkingLandUnit.CreateEnhancement(self, enh)

        local bp = self:GetBlueprint().Enhancements[enh]

        if enh =='EXImprovedEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T2_Imp_Eng')

        elseif enh =='EXImprovedEngineeringRemove' then

            if Buff.HasBuff( self, 'ACU_T2_Imp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Imp_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

        elseif enh =='EXAdvancedEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T3_Adv_Eng')

        elseif enh =='EXAdvancedEngineeringRemove' then

            if Buff.HasBuff( self, 'ACU_T3_Adv_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Adv_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

        elseif enh =='EXExperimentalEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T4_Exp_Eng')

			self.wcRocket01 = true
			self.wcRocket02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

		elseif enh =='EXExperimentalEngineeringRemove' then

            if Buff.HasBuff( self, 'ACU_T4_Exp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Exp_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcRocket01 = false
			self.wcRocket02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXCombatEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T2_Combat_Eng')

			self.wcRocket01 = false
			self.wcRocket02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

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

        elseif enh =='EXAssaultEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T3_Combat_Eng')

			self.wcRocket01 = true
			self.wcRocket02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

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

        elseif enh =='EXApocalypticEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))

            Buff.ApplyBuff(self, 'ACU_T4_Combat_Eng')

			self.wcRocket01 = false
			self.wcRocket02 = true

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

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

		elseif enh =='EXRipperBooster' then

			wpTarget:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[2].MaxRadius + 5)

            wep = self:GetWeaponByLabel('RightRipper')
			wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[2].MaxRadius + 5)
            -- increase the damage 50%
			wep:AddDamageMod( __blueprints[self.BlueprintID].Weapon[2].Damage * .5 )
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            wepOvercharge:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[3].MaxRadius + 5)

			self:ShowBone('Right_Upgrade', true)

        elseif enh =='EXRipperBoosterRemove' then

			wpTarget:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[2].MaxRadius)

            wep = self:GetWeaponByLabel('RightRipper')
			wep:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[2].MaxRadius)            
            -- remove damage boost
			wep:AddDamageMod( -0.5 * __blueprints[self.BlueprintID].Weapon[2].Damage )

            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            wepOvercharge:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[3].MaxRadius)

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

			self.wcAA01 = true
			self.wcAA02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedCapacitorsRemove' then
			self.wcEMP01 = false
			self.wcEMP02 = false
			self.wcEMP03 = false

			self.wcAA01 = false
			self.wcAA02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXPowerBooster' then
            self.wcEMP01 = false
			self.wcEMP02 = false
			self.wcEMP03 = true

			self.wcAA01 = true
			self.wcAA02 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXPowerBoosterRemove' then
			self.wcEMP01 = false
			self.wcEMP02 = false
			self.wcEMP03 = false

			self.wcAA01 = false
			self.wcAA02 = false

            self:SetWeaponEnabledByLabel('EXEMPArray01', false)
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

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

			self.wcAA01 = true
			self.wcAA02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedCoolingSystemRemove' then
			self.wcMasor01 = false
			self.wcMasor02 = false
			self.wcMasor03 = false

			self.wcAA01 = false
			self.wcAA02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXAdvancedEmitterArray' then
			self.wcMasor01 = false
			self.wcMasor02 = false
			self.wcMasor03 = true

			self.wcAA01 = true
			self.wcAA02 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXAdvancedEmitterArrayRemove' then
			self.wcMasor01 = false
			self.wcMasor02 = false
			self.wcMasor03 = false

			self.wcAA01 = false
			self.wcAA02 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh == 'EXIntelEnhancementT2' then

			self.IntelPackage = true
            self.IntelPackageOn = true  -- the existing intel will already be On

            self:AddToggleCap('RULEUTC_IntelToggle')    -- add the toggle

            self:SetScriptBit('RULEUTC_IntelToggle', true )   -- turn off the basic intel
            
            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
			
            Buff.ApplyBuff(self, 'ACU_T2_Intel_Package')    -- add the buff 
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn intel back on

        elseif enh == 'EXIntelEnhancementT2Remove' then

            if self.IntelPackageOn then
                self:SetScriptBit('RULEUTC_IntelToggle', true )   -- turn off the intel
            end
		
            if Buff.HasBuff( self, 'ACU_T2_Intel_Package' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Intel_Package' )
            end
            
            self.EnergyConsumption[bp.Slot] = 0
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn on intel
            
            self:RemoveToggleCap('RULEUTC_IntelToggle')

			self.IntelPackage = false
			
        elseif enh == 'EXIntelEnhancementT3' then

            self:SetScriptBit('RULEUTC_IntelToggle', true )   -- turn off existing intel

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
			
            Buff.ApplyBuff(self, 'ACU_T3_Intel_Package')    -- add the buff 
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn intel back on

        elseif enh == 'EXIntelEnhancementT3Remove' then

            if self.IntelPackageOn then
                self:SetScriptBit('RULEUTC_IntelToggle', true )   -- turn off existing intel
            end
		
            if Buff.HasBuff( self, 'ACU_T3_Intel_Package' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Intel_Package' )
            end
            
            self.EnergyConsumption[bp.Slot] = 0
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn on intel
            
            self:RemoveToggleCap('RULEUTC_IntelToggle')

			self.IntelPackage = false

        elseif enh == 'EXPerimeterOptics' then

            self:SetScriptBit('RULEUTC_IntelToggle', true )   -- turn off existing intel

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
			
            Buff.ApplyBuff(self, 'PerimeterOpticsPackage')    -- add the buff 
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn intel back on

        elseif enh == 'EXPerimeterOpticsRemove' then

            if self.IntelPackageOn then
                self:SetScriptBit('RULEUTC_IntelToggle', true )   -- turn off existing intel
            end
		
            if Buff.HasBuff( self, 'PerimeterOpticsPackage' ) then
                Buff.RemoveBuff( self, 'PerimeterOpticsPackage' )
            end
            
            self.EnergyConsumption[bp.Slot] = 0
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn on intel
            
            self:RemoveToggleCap('RULEUTC_IntelToggle')

			self.IntelPackage = false
        


        elseif enh == 'EXPersonalTeleporter' then

            self:AddCommandCap('RULEUCC_Teleport')
			
        elseif enh == 'EXPersonalTeleporterRemove' then

            self:RemoveCommandCap('RULEUCC_Teleport')



        elseif enh =='EXAgilityPackage' then

            Buff.ApplyBuff(self, 'AgilityBuff')

        elseif enh =='EXAgilityPackageRemove' then

			Buff.RemoveBuff(self, 'AgilityBuff')


        elseif enh == 'EXArmorPlating' then

            Buff.ApplyBuff(self, 'ArmorPackage7')
            
            Buff.ApplyBuff(self,'MobilityPenalty')

		elseif enh == 'EXArmorPlatingRemove' then

            Buff.RemoveBuff( self, 'ArmorPackage7' )
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

        elseif enh =='EXRegenPackage' then

            Buff.ApplyBuff(self, 'RegenPackage10')

        elseif enh == 'EXRegenPackageRemove' then

            Buff.RemoveBuff( self, 'ArmorPackage7' )
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			Buff.RemoveBuff( self, 'RegenPackage10' )



        elseif enh == 'EXStealthField' then

            self.StealthPackage = true

            self:AddToggleCap('RULEUTC_StealthToggle')

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

            self:SetScriptBit('RULEUTC_StealthToggle', false )   -- turn it back on

        elseif enh == 'EXStealthFieldRemove' then

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth Field

            self.EnergyConsumption[bp.Slot] = 0

            self.StealthPackage = false
            
            self:RemoveToggleCap('RULEUTC_StealthToggle')
            

        elseif enh == 'EXCloakingSubsystems' then
			
			self.CloakPackage = true
            self.CloakOn = false

            self:AddToggleCap('RULEUTC_CloakToggle')

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth
            self:SetScriptBit('RULEUTC_CloakToggle', true )     -- turn off cloak

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

            -- this will turn on the cloak now that it's installed
            self:SetScriptBit('RULEUTC_StealthToggle', false )  -- turn on Stealth


        elseif enh == 'EXCloakingSubsystemsRemove' then
            
            if self.CloakOn then
                self:SetScriptBit('RULEUTC_CloakToggle', true ) -- turn off cloak
            end

            self:RemoveToggleCap('RULEUTC_CloakToggle')

            self.CloakPackage = false

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth Field

            self.StealthPackage = false

            self.EnergyConsumption[bp.Slot] = 0
            
            self:RemoveToggleCap('RULEUTC_StealthToggle')


        elseif enh == 'EXDeviatorField' then

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth
            
            self:AddToggleCap('RULEUTC_SpecialToggle')

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
			
			self.DeviatorPackage = true

            -- this will turn on the cloak & Deviator now that it's installed
            self:SetScriptBit('RULEUTC_StealthToggle', false )  -- turn on Stealth

        elseif enh == 'EXDeviatorFieldRemove' then

            self:SetScriptBit('RULEUTC_SpecialToggle', true )  -- turn off Deviator
            
            self:RemoveToggleCap('RULEUTC_SpecialToggle')

            self.DeviatorPackage = false
            
            if self.CloakOn then
                self:SetScriptBit('RULEUTC_CloakToggle', true ) -- turn off cloak
            end

            self:RemoveToggleCap('RULEUTC_CloakToggle')

            self.CloakPackage = false

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth Field

            self.StealthPackage = false

            self.EnergyConsumption[bp.Slot] = 0
            
            self:RemoveToggleCap('RULEUTC_StealthToggle')

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
				    'Left_Leg_B02',
				    'Right_Leg_B02',
			    },
			    Scale = 1.2,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Torso',
			    },
			    Scale = 0.7,
			    Type = 'Jammer01',
		    },
        },
    },

    OnIntelEnabled = function(self,intel)
    
        CWalkingLandUnit.OnIntelEnabled(self,intel)
        
        if self.CloakPackage and intel == 'Cloak' then
            
            if not self.CloakEffectsBag then
			    self.CloakEffectsBag = {}
            end

		    self.CreateTerrainTypeEffects(self, self.IntelEffects.Cloak,'FXIdle',self:GetCurrentLayer(),nil,self.CloakEffectsBag )
        end

        if self.StealthPackage and intel == 'RadarStealthField' then
            
            if not self.StealthEffectsBag then
	            self.StealthEffectsBag = {}
            end

	        self.CreateTerrainTypeEffects(self, self.IntelEffects.Field,'FXIdle',self:GetCurrentLayer(),nil,self.StealthEffectsBag )
        end
    end,

    OnIntelDisabled = function(self,intel)

        CWalkingLandUnit.OnIntelDisabled(self,intel)
        
        if intel == 'Cloak' then
        
            if self.CloakEffectsBag then
                EffectUtil.CleanupEffectBag(self,'CloakEffectsBag')
                self.CloakEffectsBag = nil
            end
        end
        
        if intel == 'RadarStealthField' then

            if self.StealthEffectsBag then
                EffectUtil.CleanupEffectBag(self,'StealthEffectsBag')
                self.StealthEffectsBag = nil
            end        
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
