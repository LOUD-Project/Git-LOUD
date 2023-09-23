local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TerranWeaponFile = import('/lua/terranweapons.lua')

local TANTorpedoAngler = TerranWeaponFile.TANTorpedoAngler
local TDFZephyrCannonWeapon = TerranWeaponFile.TDFZephyrCannonWeapon
local TIFCommanderDeathWeapon = TerranWeaponFile.TIFCommanderDeathWeapon
local TIFCruiseMissileLauncher = TerranWeaponFile.TIFCruiseMissileLauncher
local TDFOverchargeWeapon = TerranWeaponFile.TDFOverchargeWeapon

local Weapons2 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua')

local EXFlameCannonWeapon = Weapons2.UEFACUFlamerWeapon
local UEFACUAntiMatterWeapon = Weapons2.UEFACUAntiMatterWeapon
local UEFACUHeavyPlasmaGatlingCannonWeapon = Weapons2.UEFACUHeavyPlasmaGatlingCannonWeapon
local PDLaserGrid = Weapons2.PDLaserGrid2


local EXCEMPArrayBeam01 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam01


local Buff = import('/lua/sim/Buff.lua')
local Shield = import('/lua/shield.lua').Shield

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local EffectUtils = import('/lua/effectutilities.lua')
local Effects = import('/lua/effecttemplates.lua')

local LOUDINSERT = table.insert

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local WaitTicks = coroutine.yield

local wep, wpTarget


EEL0001 = Class(TWalkingLandUnit) {

    DeathThreadDestructionWaitTime = 2,

    ShieldEffects2 = {'/mods/BlackopsACUs/effects/emitters/ex_uef_shieldgen_01_emit.bp'},

    FlamerEffects = {'/mods/BlackopsACUs/effects/emitters/ex_flamer_torch_01.bp'},

    Weapons = {
	
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
		
        EXTargetPainter = Class(EXCEMPArrayBeam01) {},
		
        RightZephyr = Class(TDFZephyrCannonWeapon) {},
		
        EXFlameCannon01 = Class(EXFlameCannonWeapon) {
        
            OnCreate = function(self)
        
                EXFlameCannonWeapon.OnCreate(self)
                
                ChangeState(self, self.DeadState)
            end,
        },
        
        EXFlameCannon02 = Class(EXFlameCannonWeapon) {
        
            OnCreate = function(self)
        
                EXFlameCannonWeapon.OnCreate(self)
                
                ChangeState(self, self.DeadState)
            end,
        },
		
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
                    TrashAdd( self.unit.Trash, self.unit.SpinManip )
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
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Exhaust', self.unit.Army, Effects.WeaponSteam01 )
                UEFACUHeavyPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,    
		},
		
        EXGattlingEnergyCannon02 = Class(UEFACUHeavyPlasmaGatlingCannonWeapon) {

            OnCreate = function(self)
            
                UEFACUHeavyPlasmaGatlingCannonWeapon.OnCreate(self)
   
                if not self.unit.SpinManip then 
                    self.unit.SpinManip = CreateRotator(self.unit, 'Gatling_Cannon_Barrel', 'z', nil, 270, 300, 60)
                    TrashAdd( self.unit.Trash, self.unit.SpinManip )
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
                    TrashAdd( self.unit.Trash, self.unit.SpinManip )
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
        
            OnCreate = function(self)
        
                PDLaserGrid.OnCreate(self)
                
                ChangeState(self, self.DeadState)
            end,
        }, 

        EXEnergyLance02 = Class(PDLaserGrid) {

            PlayOnlyOneSoundCue = true,
        
            OnCreate = function(self)
        
                PDLaserGrid.OnCreate(self)
                
                ChangeState(self, self.DeadState)
            end,
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

        self:SetupBuildBones()
        
        -- Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER4COMMANDER) )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
    
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        
        if self.Dead then return end
        
        self.Animator = CreateAnimator(self)
        self.Animator:SetPrecedence(0)
        
        if self.IdleAnim then
            self.Animator:PlayAnim( __blueprints[self.BlueprintID].Display.AnimationIdle, true)
            for k, v in self.DisabledBones do
                self.Animator:SetBoneEnabled(v, false)
            end
        end
        
        self:BuildManipulatorSetEnabled(false)

        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('CloakField')

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
        
        self.Rotator1 = CreateRotator(self, 'Back_ShieldPack_Spinner01', 'z', nil, 5, 15)
        self.Rotator2 = CreateRotator(self, 'Back_ShieldPack_Spinner02', 'z', nil, 10, 15)
        self.RadarDish1 = CreateRotator(self, 'Back_IntelPack_Dish', 'y', nil, 1, 4, 2)
        
        TrashAdd( self.Trash, self.Rotator1 )
        TrashAdd( self.Trash, self.Rotator2 )
        TrashAdd( self.Trash, self.RadarDish1 )
        
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

		self.wcCMissiles01 = false
		self.wcCMissiles02 = false
		self.wcCMissiles03 = false

		self.wcTMissiles01 = false
		self.wcNMissiles01 = false
		
		self.IntelPackage = false
        self.IntelPackageOn = false
		
		self.Shield = false
        self.ShieldOn = false

		wpTarget = self:GetWeaponByLabel('EXTargetPainter')

		wpTarget:ChangeMaxRadius(100)

		self:ForkThread(self.WeaponConfigCheck)
		self:ForkThread(self.WeaponRangeReset)

        self:ForkThread(self.GiveInitialResources)

		self.SpysatEnabled = false
		
        self.EnergyConsumption = { Total = 0, Back = 0, Command = 0, LCH = 0, RCH = 0 }
        
        self:RemoveToggleCap('RULEUTC_IntelToggle')
        self:RemoveToggleCap('RULEUTC_ShieldToggle')
        self:RemoveToggleCap('RULEUTC_SpecialToggle')
        
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy

        local antiMissile = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }

        TrashAdd( self.Trash, antiMissile)
    end,

    OnPrepareArmToBuild = function(self)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)

        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('EXTargetPainter'):GetHeadingPitch() )

        self.wcBuildMode = true

		self:ForkThread(self.WeaponConfigCheck)
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )

        EffectUtil.CreateUEFCommanderBuildSliceBeams( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )        

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
		
        if self.IdleAnim then
            self.Animator:PlayAnim(self.IdleAnim, true)
        end
		
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
		
        self.wcBuildMode = false
		
		self:ForkThread(self.WeaponConfigCheck)
		
        self:GetWeaponManipulatorByLabel('EXTargetPainter'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
		
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    OnFailedToBuild = function(self)
    
        TWalkingLandUnit.OnFailedToBuild(self)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)

        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)

        self:GetWeaponManipulatorByLabel('EXTargetPainter'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
    
        TWalkingLandUnit.OnStopCapture(self, target)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)

        self:GetWeaponManipulatorByLabel('EXTargetPainter'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )

        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
    end,

    OnFailedCapture = function(self, target)
    
        TWalkingLandUnit.OnFailedCapture(self, target)
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)

        self:GetWeaponManipulatorByLabel('EXTargetPainter'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )

        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
    end,

    OnStopReclaim = function(self, target)
    
        TWalkingLandUnit.OnStopReclaim(self, target)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)

        self:GetWeaponManipulatorByLabel('EXTargetPainter'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )

        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
    end,

    GiveInitialResources = function(self)
        WaitTicks(5)
        self:GetAIBrain():GiveResource('Energy', __blueprints[self.BlueprintID].Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', __blueprints[self.BlueprintID].Economy.StorageMass)
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
        
        WaitTicks(22)
        
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
        
        local army = self.Army
        
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end

        WaitTicks(61)
        
        self:SetMesh(__blueprints[self.BlueprintID].Display.MeshBlueprint, true)
    end,

    EXSatSpawn = function(self)

        while self.SpysatEnabled and self.IntelPackageOn and not self.Dead do
	
			local location = self:GetPosition('Back_IntelPack')
			
			self.Satellite = CreateUnitHPR('EEA0002', self:GetArmy(), location[1], location[2], location[3], 0,0,0 )

			self.Satellite:AttachTo(self, 'Back_IntelPack')
			
			TrashAdd( self.Trash, self.Satellite )
			
			self.Satellite.Parent = self
			self.Satellite:SetParent(self, 'SpySat')
			
			self:PlayUnitSound('LaunchSat')
			
			self.Satellite:DetachFrom()
			self.Satellite:Open()
            
			-- for respawns --
			while not self.Satellite.Dead and self.IntelPackageOn do
				WaitTicks(100)
			end
	
        end
    end,

    WeaponRangeReset = function(self)

		wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)

		if not self.wcFlamer01 then
			wep = self:GetWeaponByLabel('EXFlameCannon01')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcFlamer02 then
			wep = self:GetWeaponByLabel('EXFlameCannon02')
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
		if not self.wcAMC01 then
			wep = self:GetWeaponByLabel('EXAntiMatterCannon01')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcAMC02 then
			wep = self:GetWeaponByLabel('EXAntiMatterCannon02')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcAMC03 then
			wep = self:GetWeaponByLabel('EXAntiMatterCannon03')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcGatling01 then
			wep = self:GetWeaponByLabel('EXGattlingEnergyCannon01')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcGatling02 then
			wep = self:GetWeaponByLabel('EXGattlingEnergyCannon02')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcGatling03 then
			wep = self:GetWeaponByLabel('EXGattlingEnergyCannon03')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcLance01 then
			wep = self:GetWeaponByLabel('EXEnergyLance01')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcLance02 then
			wep = self:GetWeaponByLabel('EXEnergyLance02')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcCMissiles01 then
			wep = self:GetWeaponByLabel('EXClusterMissles01')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcCMissiles02 then
			wep = self:GetWeaponByLabel('EXClusterMissles02')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcCMissiles03 then
			wep = self:GetWeaponByLabel('EXClusterMissles03')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcTMissiles01 then
			wep = self:GetWeaponByLabel('TacMissile')
			wep:ChangeMaxRadius(1)
		end
		if not self.wcNMissiles01 then
			wep = self:GetWeaponByLabel('TacNukeMissile')
			wep:ChangeMaxRadius(1)
		end
    end,

    WeaponConfigCheck = function(self)

		if self.wcBuildMode then

			self:SetWeaponEnabledByLabel('EXTargetPainter', false)

			--self:SetWeaponEnabledByLabel('RightZephyr', false)
			--self:SetWeaponEnabledByLabel('OverCharge', false)

			--self:SetWeaponEnabledByLabel('EXFlameCannon01', false)
			--self:SetWeaponEnabledByLabel('EXFlameCannon02', false)

			--self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			--self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			--self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)

			--self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', false)
			--self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', false)
			--self:SetWeaponEnabledByLabel('EXAntiMatterCannon03', false)

			--self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', false)
			--self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', false)
			--self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon03', false)

			--self:SetWeaponEnabledByLabel('EXClusterMissles01', false)
			--self:SetWeaponEnabledByLabel('EXClusterMissles02', false)
			--self:SetWeaponEnabledByLabel('EXClusterMissles03', false)

			--self:SetWeaponEnabledByLabel('TacMissile', false)
			--self:SetWeaponEnabledByLabel('TacNukeMissile', false)
		end

		if self.wcOCMode then

			self:SetWeaponEnabledByLabel('EXTargetPainter', false)

			--self:SetWeaponEnabledByLabel('RightZephyr', false)

			--self:SetWeaponEnabledByLabel('EXFlameCannon01', false)
			--self:SetWeaponEnabledByLabel('EXFlameCannon02', false)

			--self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			--self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			--self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)

			--self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', false)
			--self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', false)
			--self:SetWeaponEnabledByLabel('EXAntiMatterCannon03', false)

			--self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', false)
			--self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', false)
			--self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon03', false)

		end

		if not self.wcBuildMode and not self.wcOCMode then
		
			self:SetWeaponEnabledByLabel('EXTargetPainter', true)        
			--self:SetWeaponEnabledByLabel('RightZephyr', true)
			--self:SetWeaponEnabledByLabel('OverCharge', false)
			
			if self.wcFlamer01 or self.wcFlamer02 then

                if self.wcFlamer01 then

                    self:SetWeaponEnabledByLabel('EXFlameCannon01', true)
                    self:SetWeaponEnabledByLabel('EXFlameCannon02', false)

                    wep = self:GetWeaponByLabel('EXFlameCannon01')
                    wep:ChangeMaxRadius(self:GetBlueprint().Weapon[5].MaxRadius)
                    
                else
                    self:SetWeaponEnabledByLabel('EXFlameCannon01', false)
                    self:SetWeaponEnabledByLabel('EXFlameCannon02', true)

                    wep = self:GetWeaponByLabel('EXFlameCannon02')
                    wep:ChangeMaxRadius(self:GetBlueprint().Weapon[6].MaxRadius)

                end
                
                self:ShowBone('Flamer',true)

                self.FlamerEffectsBag[1] = CreateAttachedEmitter( self, 'Flamer_Torch', self:GetArmy(), self.FlamerEffects[1] ):ScaleEmitter(0.0625)
			else
                
                self:ShowBone('Flamer',false)

                for k, v in self.FlamerEffectsBag do
                    v:Destroy()
                end
			end
			
			if self.wcTorp01 then

				wep = self:GetWeaponByLabel('EXTorpedoLauncher01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[7].MaxRadius)
			end
			
			if self.wcTorp02 then

				wep = self:GetWeaponByLabel('EXTorpedoLauncher02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[8].MaxRadius)
			end
			
			if self.wcTorp03 then

				wep = self:GetWeaponByLabel('EXTorpedoLauncher03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[9].MaxRadius)
			end
			
			if self.wcAMC01 then

				wep = self:GetWeaponByLabel('EXAntiMatterCannon01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[10].MaxRadius)
			end
            
			if self.wcAMC02 then

                wep = self:GetWeaponByLabel('EXAntiMatterCannon02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[11].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[11].MaxRadius)
			end

			if self.wcAMC03 then
                
				wep = self:GetWeaponByLabel('EXAntiMatterCannon03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[12].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[12].MaxRadius)
			end

			if self.wcGatling01 then

				wep = self:GetWeaponByLabel('EXGattlingEnergyCannon01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[13].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[13].MaxRadius)
			end

			if self.wcGatling02 then

				wep = self:GetWeaponByLabel('EXGattlingEnergyCannon02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[14].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[14].MaxRadius)
			end

			if self.wcGatling03 then

				wep = self:GetWeaponByLabel('EXGattlingEnergyCannon03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[15].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[15].MaxRadius)
			end
			
			if self.wcCMissiles01 then

				wep = self:GetWeaponByLabel('EXClusterMissles01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[20].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[20].MaxRadius)
			end

			if self.wcCMissiles02 then

				wep = self:GetWeaponByLabel('EXClusterMissles02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[21].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[21].MaxRadius)
			end

			if self.wcCMissiles03 then

				wep = self:GetWeaponByLabel('EXClusterMissles03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[22].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[22].MaxRadius)
			end

			if self.wcLance01 then

				self:SetWeaponEnabledByLabel('EXEnergyLance01', true)
                self:ShowBone('Right_Lance_Turret', true)

				wep = self:GetWeaponByLabel('EXEnergyLance01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[18].MaxRadius)
			else
				self:SetWeaponEnabledByLabel('EXEnergyLance01', false)
                self:HideBone('Right_Lance_Turret', true)
			end

			if self.wcLance02 then

				self:SetWeaponEnabledByLabel('EXEnergyLance02', true)
                self:ShowBone('Left_Lance_Turret', true)

				wep = self:GetWeaponByLabel('EXEnergyLance02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[19].MaxRadius)
			else
				self:SetWeaponEnabledByLabel('EXEnergyLance02', false)
                self:HideBone('Left_Lance_Turret', true)
			end

		end
    end,

    OnTransportDetach = function(self, attachBone, unit)

        TWalkingLandUnit.OnTransportDetach(self, attachBone, unit)

		self:StopSiloBuild()
        self:ForkThread(self.WeaponConfigCheck)
    end,

    OnScriptBitClear = function(self, bit)
    
        if bit == 0 and self.Shield and self.ShieldOn then    -- shield toggle
        
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)
            
			if self.ShieldEffectsBag2 then
            
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = false
			end
            
			self:DisableShield()

            -- remove back slot consumption when shield turned off
            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption['Back']

            self.ShieldOn = false

        elseif bit == 3 and self.IntelPackage and not self.IntelPackageOn then    -- Radar & Rhianne Intel

            -- add command slot consumption when radar turned on
            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] + self.EnergyConsumption['Command']

            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('Sonar')
            self:EnableUnitIntel('Omni')

			self.RadarDish1:SetTargetSpeed(32)            

            self.IntelPackageOn = true
            
            if self.SpysatEnabled then
                self:ForkThread(self.EXSatSpawn)
            end
        end

        self:SetEnergyMaintenanceConsumptionOverride( self.EnergyConsumption['Total'] )
        
        if self.EnergyConsumption['Total'] > 0 then
            self:SetMaintenanceConsumptionActive()
        else
            self:SetMaintenanceConsumptionInactive()
        end

    end,

    OnScriptBitSet = function(self, bit)
    
        if bit == 0 and self.Shield and not self.ShieldOn then
        
			self.Rotator1:SetTargetSpeed(45)
			self.Rotator2:SetTargetSpeed(-80)
            
			if self.ShieldEffectsBag2 then
            
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end

			end
            
            self.ShieldEffectsBag2 = {}
            
			for k, v in self.ShieldEffects2 do
				LOUDINSERT( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter01', self:GetArmy(), v ) )
				LOUDINSERT( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter02', self:GetArmy(), v ) )
				LOUDINSERT( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter03', self:GetArmy(), v ) )
				LOUDINSERT( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter04', self:GetArmy(), v ) )
				LOUDINSERT( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter05', self:GetArmy(), v ) )
				LOUDINSERT( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter06', self:GetArmy(), v ) )
				LOUDINSERT( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter07', self:GetArmy(), v ) )
				LOUDINSERT( self.ShieldEffectsBag2, CreateAttachedEmitter( self, 'Back_ShieldPack_Emitter08', self:GetArmy(), v ) )
			end
            
			self:EnableShield()
            
            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] + self.EnergyConsumption['Back']

            self.ShieldOn = true

        elseif bit == 3 and self.IntelPackage and self.IntelPackageOn then

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption['Command']

            self:DisableUnitIntel('Radar')
            self:DisableUnitIntel('Sonar')
            self:DisableUnitIntel('Omni')

			self.RadarDish1:SetTargetSpeed(0)            

            self.IntelPackageOn = false
            
            if self.SpysatEnabled and self.Satellite then
                self.Satellite:Kill()
                self.Satellite = nil
            end
        end

        self:SetEnergyMaintenanceConsumptionOverride( self.EnergyConsumption['Total'] )
        
        if self.EnergyConsumption['Total'] > 0 then
            self:SetMaintenanceConsumptionActive()
        else
            self:SetMaintenanceConsumptionInactive()
        end

    end,

    CreateEnhancement = function(self, enh)
	
        TWalkingLandUnit.CreateEnhancement(self, enh)
		
        local bp = __blueprints[self.BlueprintID].Enhancements[enh]

        if enh =='EXImprovedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Imp_Eng')

            self.wcLance01 = true
            self.wcLance02 = false
			
        elseif enh =='EXImprovedEngineeringRemove' then
			
            if Buff.HasBuff( self, 'ACU_T2_Imp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Imp_Eng' )
            end

            self.wcLance01 = false
            self.wcLance02 = false
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )
			
        elseif enh =='EXAdvancedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Adv_Eng')

            self.wcLance01 = false
            self.wcLance02 = true

        elseif enh =='EXAdvancedEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Adv_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Adv_Eng' )
            end

            self.wcLance01 = false
            self.wcLance02 = false

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )
			
        elseif enh =='EXExperimentalEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Exp_Eng')			

            self.wcLance01 = true
            self.wcLance02 = true

		elseif enh =='EXExperimentalEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Exp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Exp_Eng' )
            end		

            self.wcLance01 = false
            self.wcLance02 = false

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

        elseif enh =='EXCombatEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Combat_Eng')

			self.wcFlamer01 = true
			self.wcFlamer02 = false
			
        elseif enh =='EXCombatEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T2_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcFlamer01 = false
			self.wcFlamer02 = false
			
        elseif enh =='EXAssaultEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Combat_Eng')

			self.wcFlamer01 = false
			self.wcFlamer02 = true
			
        elseif enh =='EXAssaultEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Combat_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcFlamer01 = false
			self.wcFlamer02 = false
			
        elseif enh =='EXApocalypticEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Combat_Eng')
			
			self.wcFlamer01 = false
			self.wcFlamer02 = true
			
        elseif enh =='EXApocalypticEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcFlamer01 = false
			self.wcFlamer02 = false

		elseif enh =='EXZephyrBooster' then

            local wepZephyr = self:GetWeaponByLabel('RightZephyr')
            
            -- increase the damage 50%
			wepZephyr:AddDamageMod( self:GetBlueprint().Weapon[2].Damage * .5 )

			wepZephyr:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[2].MaxRadius + 5)
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)

			local wepOvercharge = self:GetWeaponByLabel('OverCharge')

            wepOvercharge:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[3].MaxRadius + 5)

			self:ShowBone('Zephyr_Amplifier', true)
			
        elseif enh =='EXZephyrBoosterRemove' then

            local wepZephyr = self:GetWeaponByLabel('RightZephyr')

            -- remove damage boost
			wepZephyr:AddDamageMod( -0.5 * self:GetBlueprint().Weapon[2].Damage )

			wepZephyr:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[2].MaxRadius)            

            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)

			local wepOvercharge = self:GetWeaponByLabel('OverCharge')

            wepOvercharge:ChangeMaxRadius(__blueprints[self.BlueprintID].Weapon[3].MaxRadius)

			self:HideBone('Zephyr_Amplifier', true)
			
        elseif enh =='EXTorpedoLauncher' then

			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', true)

			self.wcTorp01 = true
			self.wcTorp02 = false
			self.wcTorp03 = false

        elseif enh =='EXTorpedoLauncherRemove' then

			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)

			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false

        elseif enh =='EXTorpedoRapidLoader' then

			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', true)

			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)

			self.wcTorp01 = false
			self.wcTorp02 = true
			self.wcTorp03 = false
			
        elseif enh =='EXTorpedoRapidLoaderRemove' then

			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)

			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false

		elseif enh =='EXTorpedoClusterLauncher' then

			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', true)

			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)

			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

        elseif enh =='EXTorpedoClusterLauncherRemove' then

			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)

			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

        elseif enh =='EXClusterMisslePack' then

			self:SetWeaponEnabledByLabel('EXClusterMissles01', true)

			self.wcCMissiles01 = true
			self.wcCMissiles02 = false
			self.wcCMissiles03 = false

        elseif enh =='EXClusterMisslePackRemove' then

			self:SetWeaponEnabledByLabel('EXClusterMissles01', false)

			self.wcCMissiles01 = false
			self.wcCMissiles02 = false
			self.wcCMissiles03 = false

        elseif enh =='EXClusterMisslesPack' then

			self:SetWeaponEnabledByLabel('EXClusterMissles02', true)

			self:SetWeaponEnabledByLabel('EXClusterMissles01', false)

			self.wcCMissiles01 = false
			self.wcCMissiles02 = true
			self.wcCMissiles03 = false

        elseif enh =='EXClusterMisslesPackRemove' then

			self:SetWeaponEnabledByLabel('EXClusterMissles02', false)

			self.wcCMissiles01 = false
			self.wcCMissiles02 = false
			self.wcCMissiles03 = false

        elseif enh =='EXClusterMissleSalvoPack' then

			self:SetWeaponEnabledByLabel('EXClusterMissles03', true)

			self:SetWeaponEnabledByLabel('EXClusterMissles02', false)

			self.wcCMissiles01 = false
			self.wcCMissiles02 = false
			self.wcCMissiles03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

        elseif enh =='EXClusterMissleSalvoPackRemove' then

			self:SetWeaponEnabledByLabel('EXClusterMissles03', false)

			self.wcCMissiles01 = false
			self.wcCMissiles02 = false
			self.wcCMissiles03 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

        elseif enh =='EXAntiMatterCannon' then

			self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', true)

   			self:SetWeaponEnabledByLabel('RightZephyr', false)
  
			self.wcAMC01 = true
			self.wcAMC02 = false
			self.wcAMC03 = false

        elseif enh =='EXAntiMatterCannonRemove' then

			self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', false)

   			self:SetWeaponEnabledByLabel('RightZephyr', true)

			self.wcAMC01 = false
			self.wcAMC02 = false
			self.wcAMC03 = false

        elseif enh =='EXImprovedContainmentBottle' then

			self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', true)

			self:SetWeaponEnabledByLabel('EXAntiMatterCannon01', false)

   			self:SetWeaponEnabledByLabel('RightZephyr', true)

			self.wcAMC01 = false
			self.wcAMC02 = true
			self.wcAMC03 = false
			
        elseif enh =='EXImprovedContainmentBottleRemove' then    

			self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', false)

			self.wcAMC01 = false
			self.wcAMC02 = false
			self.wcAMC03 = false

        elseif enh =='EXPowerBooster' then

			self:SetWeaponEnabledByLabel('EXAntiMatterCannon03', true)

			self:SetWeaponEnabledByLabel('EXAntiMatterCannon02', false)

            self.wcAMC01 = false
			self.wcAMC02 = false
			self.wcAMC03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

        elseif enh =='EXPowerBoosterRemove' then    

			self:SetWeaponEnabledByLabel('EXAntiMatterCannon03', false)

			self.wcAMC01 = false
			self.wcAMC02 = false
			self.wcAMC03 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

        elseif enh =='EXGattlingEnergyCannon' then

			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', true)

			self.wcGatling01 = true
			self.wcGatling02 = false
			self.wcGatling03 = false

        elseif enh =='EXGattlingEnergyCannonRemove' then

			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', false)

			self.wcGatling01 = false
			self.wcGatling02 = false
			self.wcGatling03 = false

        elseif enh =='EXImprovedCoolingSystem' then

			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', true)

			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon01', false)

            self.wcGatling01 = false
			self.wcGatling02 = true
			self.wcGatling03 = false

			self.wcFlamer01 = true
			self.wcFlamer02 = false
			
        elseif enh =='EXImprovedCoolingSystemRemove' then

			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', false)

			self.wcGatling01 = false
			self.wcGatling02 = false
			self.wcGatling03 = false

			self.wcFlamer01 = false
			self.wcFlamer02 = false

        elseif enh =='EXEnergyShellHardener' then

			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon03', true)

			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon02', false)

            self.wcGatling01 = false
			self.wcGatling02 = false
			self.wcGatling03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self.wcFlamer01 = false
			self.wcFlamer02 = true

        elseif enh =='EXEnergyShellHardenerRemove' then

			self:SetWeaponEnabledByLabel('EXGattlingEnergyCannon03', false)

			self.wcGatling01 = false
			self.wcGatling02 = false
			self.wcGatling03 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			self.wcFlamer01 = false
			self.wcFlamer02 = false

        elseif enh == 'EXShieldBubble' then

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
            
            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
            
			self.Shield = true
            self.ShieldOn = false

            self:AddToggleCap('RULEUTC_ShieldToggle')

            self:CreateShield(bp)

			self.Rotator1:SetTargetSpeed(45)
			self.Rotator2:SetTargetSpeed(-90)

		elseif enh == 'EXShieldBubbleRemove' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = false
			end
            
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = 0
            
			self.Shield = false
            
            self:RemoveToggleCap('RULEUTC_ShieldToggle')

            RemoveUnitEnhancement(self, 'EXShieldBubbleRemove')

        elseif enh == 'EXActiveSkinShield' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
            
			self.Shield = true

            self:CreatePersonalShield(bp)

        elseif enh == 'EXActiveSkinShieldRemove' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end
            
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = false
			end
            
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = 0
            
			self.Shield = false
            
            RemoveUnitEnhancement(self, 'EXActiveSkinShieldRemove')
            
            self:RemoveToggleCap('RULEUTC_ShieldToggle')

        elseif enh == 'EXAdvancedSkinShield' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           
            
            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

			self.Shield = true

            self:CreatePersonalShield(bp)

        elseif enh == 'EXAdvancedSkinShieldRemove' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end
            
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = false
			end
            
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = 0
            
			self.Shield = false
            
            RemoveUnitEnhancement(self, 'EXAdvancedSkinShieldRemove')
            
            self:RemoveToggleCap('RULEUTC_ShieldToggle')

        elseif enh == 'EXTyphoonBubble' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           
            
            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

			self.Shield = true

            self:CreateShield(bp)

        elseif enh == 'EXTyphoonBubbleRemove' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end
            
			if self.ShieldEffectsBag2 then
				for k, v in self.ShieldEffectsBag2 do
					v:Destroy()
				end
				self.ShieldEffectsBag2 = false
			end
            
			self.Rotator1:SetTargetSpeed(0)
			self.Rotator2:SetTargetSpeed(0)

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = 0
            
			self.Shield = false
            
            self:RemoveToggleCap('RULEUTC_ShieldToggle')

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

            self.IntelPackageOn = false
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn on the basic intel
            
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

            self.IntelPackageOn = false
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn on intel
            
            self:RemoveToggleCap('RULEUTC_IntelToggle')

			self.IntelPackage = false

        elseif enh == 'EXSatelliteSystem' then

            self:SetScriptBit('RULEUTC_IntelToggle', true )   -- turn off existing intel

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
		
			self.SpysatEnabled = true
			self.Satellite = false

            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end

            self.StealthEnh = true      -- this should allow a visual effect
            
            self:SetScriptBit('RULEUTC_IntelToggle', false )   -- turn intel back on

        elseif enh == 'EXSatelliteSystemRemove' then
			
			self.StealthEnh = false

            if self.IntelPackageOn then
                self:SetScriptBit('RULEUTC_IntelToggle', true )   -- turn off existing intel
            end

			self.SpysatEnabled = false
			
			if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
				self.Satellite:Kill()
			end
			
			self.Satellite = nil
			
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end


        elseif enh == 'EXPersonalTeleporter' then

            self:AddCommandCap('RULEUCC_Teleport')
			
        elseif enh == 'EXPersonalTeleporterRemove' then

            self:RemoveCommandCap('RULEUCC_Teleport')


        elseif enh =='EXTacticalMisslePack' then

            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self:SetWeaponEnabledByLabel('TacMissile', true)

			wep = self:GetWeaponByLabel('TacMissile')
			wep:ChangeMaxRadius(self:GetBlueprint().Weapon[16].MaxRadius)

			self.wcTMissiles01 = true
			self.wcNMissiles01 = false

        elseif enh == 'EXTacticalMisslePackRemove' then

            self:RemoveCommandCap('RULEUCC_Nuke')
            self:RemoveCommandCap('RULEUCC_SiloBuildNuke')

            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

            local amt = self:GetTacticalSiloAmmoCount()

            self:RemoveTacticalSiloAmmo(amt or 0)

            local amt = self:GetNukeSiloAmmoCount()

            self:RemoveNukeSiloAmmo(amt or 0)
            self:StopSiloBuild()

			wep = self:GetWeaponByLabel('TacMissile')
			wep:ChangeMaxRadius( 1 )

			self:SetWeaponEnabledByLabel('TacMissile', false)
			
			self.wcTMissiles01 = false
			self.wcNMissiles01 = false

        elseif enh =='EXTacticalNukeSubstitution' then

            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')

            self:AddCommandCap('RULEUCC_Nuke')
            self:AddCommandCap('RULEUCC_SiloBuildNuke')
            
            Buff.ApplyBuff(self,'MobilityPenalty')

            local amt = self:GetTacticalSiloAmmoCount()

            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()

			self:SetWeaponEnabledByLabel('TacNukeMissile', true)

			wep = self:GetWeaponByLabel('TacNukeMissile')
			wep:ChangeMaxRadius(self:GetBlueprint().Weapon[17].MaxRadius)

			self.wcTMissiles01 = false
			self.wcNMissiles01 = true

        elseif enh == 'EXTacticalNukeSubstitutionRemove' then

            self:RemoveCommandCap('RULEUCC_Nuke')
            self:RemoveCommandCap('RULEUCC_SiloBuildNuke')

            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

            local amt = self:GetTacticalSiloAmmoCount()

            self:RemoveTacticalSiloAmmo(amt or 0)

            local amt = self:GetNukeSiloAmmoCount()

            self:RemoveNukeSiloAmmo(amt or 0)
            self:StopSiloBuild()

			wep = self:GetWeaponByLabel('TacNukeMissile')
			wep:ChangeMaxRadius( 1 )

			self:SetWeaponEnabledByLabel('TacNukeMissile', false)

			self.wcTMissiles01 = false
			self.wcNMissiles01 = false

        end

		self:ForkThread(self.WeaponRangeReset)
		self:ForkThread(self.WeaponConfigCheck)
        
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
	
    OnIntelEnabled = function(self,intel)
    
        TWalkingLandUnit.OnIntelEnabled(self,intel)
 
        -- visual effect when satellite is installed --
        if self.StealthEnh then

            if not self.IntelEffectsBag then 
	            self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		    end                  
        end		
    end,

    OnIntelDisabled = function(self,intel)
    
        TWalkingLandUnit.OnIntelDisabled(self,intel)
        
        if self.IntelEffectsBag then
            EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
            self.IntelEffectsBag = nil
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

TypeClass = EEL0001