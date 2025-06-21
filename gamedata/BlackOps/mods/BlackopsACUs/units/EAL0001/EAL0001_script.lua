local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local RemoteViewing = import('/lua/RemoteViewing.lua').RemoteViewing

AWalkingLandUnit = RemoteViewing( AWalkingLandUnit )

local AeonBuffField = import('/lua/aeonweapons.lua').AeonBuffField
local Buff = import('/lua/sim/Buff.lua')

local AWeapons = import('/lua/aeonweapons.lua')

local AIFCommanderDeathWeapon       = AWeapons.AIFCommanderDeathWeapon
local ADFDisruptorCannonWeapon      = AWeapons.ADFDisruptorCannonWeapon
local ADFChronoDampener             = AWeapons.ADFChronoDampener
local AANChronoTorpedoWeapon        = AWeapons.AANChronoTorpedoWeapon
local AIFArtilleryMiasmaShellWeapon = AWeapons.AIFArtilleryMiasmaShellWeapon
local PhasonLaser                   = AWeapons.ADFPhasonLaser
local ADFOverchargeWeapon           = AWeapons.ADFOverchargeWeapon
local Targeting                     = AWeapons.AeonTargetPainter

AWeapons = nil

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

local CreateAeonCommanderBuildingEffects = EffectUtil.CreateAeonCommanderBuildingEffects

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

--local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local Weapon = import('/lua/sim/Weapon.lua').Weapon

local wep, wpTarget


EAL0001 = Class(AWalkingLandUnit) {

    DeathThreadDestructionWaitTime = 2,
	
	BuffFields = {
		DamageField1 = Class(AeonBuffField){ OnCreate = function(self) AeonBuffField.OnCreate(self) end, },
		DamageField2 = Class(AeonBuffField){ OnCreate = function(self) AeonBuffField.OnCreate(self) end, },
		DamageField3 = Class(AeonBuffField){ OnCreate = function(self) AeonBuffField.OnCreate(self) end, },
	},

    Weapons = {
	
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
		
        TargetPainter = Class(Targeting) {},
		
        RightDisruptor = Class(ADFDisruptorCannonWeapon) {},
		
        OverCharge = Class(ADFOverchargeWeapon) {

            OnCreate = function(self)

                ADFOverchargeWeapon.OnCreate(self)

                self:SetWeaponEnabled(false)

                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
            end,

            OnEnableWeapon = function(self)

                if self:BeenDestroyed() then return end

                ADFOverchargeWeapon.OnEnableWeapon(self)

                self:SetWeaponEnabled(true)

                --self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)

                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)

                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end

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

                --self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)

                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)

                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end
                
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
		
        EXChronoDampener01 = Class(ADFChronoDampener) {},
        EXChronoDampener02 = Class(ADFChronoDampener) {},
		
        EXTorpedoLauncher01 = Class(AANChronoTorpedoWeapon) {},
        EXTorpedoLauncher02 = Class(AANChronoTorpedoWeapon) {},
        EXTorpedoLauncher03 = Class(AANChronoTorpedoWeapon) {},
		
        EXMiasmaArtillery01 = Class(AIFArtilleryMiasmaShellWeapon) {},
        EXMiasmaArtillery02 = Class(AIFArtilleryMiasmaShellWeapon) {},
        EXMiasmaArtillery03 = Class(AIFArtilleryMiasmaShellWeapon) {},
		
        EXPhasonBeam01 = Class(PhasonLaser) {},
        EXPhasonBeam02 = Class(PhasonLaser) {},
        EXPhasonBeam03 = Class(PhasonLaser) {},
    },

    OnCreate = function(self)
	
        AWalkingLandUnit.OnCreate(self)
		
        self:SetCapturable(false)
        self:SetupBuildBones()
		
        -- Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,  

    OnPrepareArmToBuild = function(self)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(true)

        self.BuildArmManipulator:SetPrecedence(20)
        self.wcBuildMode = true

		self:ForkThread(self.WeaponConfigCheck)

        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
    end,

    OnFailedToBuild = function(self)
    
        AWalkingLandUnit.OnFailedToBuild(self)
        
        if self.Dead then return end
        
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
        
        for _, emit in self.BuildEmitters do
            emit:ScaleEmitter( 0.01 )
        end
    
        if self.BuildProjectile then
        
            if self.BuildProjectile.Detached then
            
                self.BuildProjectile:AttachTo( self, self.BuildPoint )
            end
            
            self.BuildProjectile.Detached = false
        end
        
        AWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false

		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )

        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    OnStopCapture = function(self, target)
    
        AWalkingLandUnit.OnStopCapture(self, target)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false

		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
    
        AWalkingLandUnit.OnFailedCapture(self, target)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false

		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
    
        AWalkingLandUnit.OnStopReclaim(self, target)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false

		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
	
        AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

		self:DisableUnitIntel('CloakField')
        self:DisableUnitIntel('Cloak')		
		
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

		self.wcBuildMode = false
		self.wcOCMode = false

		self.wcChrono01 = false
		self.wcChrono02 = false

		self.wcTorp01 = false
		self.wcTorp02 = false
		self.wcTorp03 = false
        
		self.ccArtillery = false

		self.wcArtillery01 = false
		self.wcArtillery02 = false
		self.wcArtillery03 = false

		self.wcBeam01 = false
		self.wcBeam02 = false
		self.wcBeam03 = false
		
		self.IntelPackage = false
        self.IntelPackageOn = false

        self.MaelstromFieldName = false
        self.MaelstromFieldOn = false
        self.MaelstromFieldRadius = 1
		
		self.Shield = false
        self.ShieldOn = false

		wpTarget = self:GetWeaponByLabel('TargetPainter')

		wpTarget:ChangeMaxRadius(100)
		
		self:ForkThread(self.WeaponConfigCheck)
		self:ForkThread(self.WeaponRangeReset)
		
        self:ForkThread(self.GiveInitialResources)
		
		self.RBImpEngineering = false
		self.RBAdvEngineering = false
		self.RBExpEngineering = false
		
		self.RBComEngineering = false
		self.RBAssEngineering = false
		self.RBApoEngineering = false
		
        self.EnergyConsumption = { Total = 0, Back = 0, Command = 0, LCH = 0, RCH = 0 }

        -- turn off the Rhianne functions
        if self.RechargeThread then
            KillThread (self.RechargeThread)
        end
        
        self.Sync.Abilities = self.RemoteViewingData.Abilities            
        self.Sync.Abilities.TargetLocation.Active = false
        
        self:RemoveToggleCap('RULEUTC_IntelToggle')
        self:RemoveToggleCap('RULEUTC_ShieldToggle')
        self:RemoveToggleCap('RULEUTC_SpecialToggle')
        
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy

        local antiMissile = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }

        TrashAdd( self.Trash, antiMissile)
        
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

    WeaponRangeReset = function(self)
        
		wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
        
		if not self.wcChrono01 then
			wep = self:GetWeaponByLabel('EXChronoDampener01')
			wep:ChangeMaxRadius(1)
		end
        
		if not self.wcChrono02 then
			wep = self:GetWeaponByLabel('EXChronoDampener02')
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

		if not self.wcArtillery01 then
			wep = self:GetWeaponByLabel('EXMiasmaArtillery01')
			wep:ChangeMaxRadius(1)
		end
        
		if not self.wcArtillery02 then
			wep = self:GetWeaponByLabel('EXMiasmaArtillery02')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcArtillery03 then
			wep = self:GetWeaponByLabel('EXMiasmaArtillery03')
			wep:ChangeMaxRadius(1)
		end
        
		if not self.wcBeam01 then
			wep = self:GetWeaponByLabel('EXPhasonBeam01')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcBeam02 then
			wep = self:GetWeaponByLabel('EXPhasonBeam02')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcBeam03 then
			wep = self:GetWeaponByLabel('EXPhasonBeam03')
			wep:ChangeMaxRadius(1)
		end
    end,
	
    WeaponConfigCheck = function(self)
    
        if self.Dead then return end

        -- this flag is set when building anything --
        -- disables weapons --
		if self.wcBuildMode then
		
			self:SetWeaponEnabledByLabel('TargetPainter', false)
			self:SetWeaponEnabledByLabel('RightDisruptor', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)

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
		
		if self.wcOCMode then
		
			self:SetWeaponEnabledByLabel('TargetPainter', false)
			self:SetWeaponEnabledByLabel('RightDisruptor', false)

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
		
			self:SetWeaponEnabledByLabel('TargetPainter', true)
			self:SetWeaponEnabledByLabel('RightDisruptor', true)
			self:SetWeaponEnabledByLabel('OverCharge', false)			

			self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)

			self:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam03', false)

			
			if self.wcChrono01 then
			
				self:SetWeaponEnabledByLabel('EXChronoDampener01', true)
				
				wep = self:GetWeaponByLabel('EXChronoDampener01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[5].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXChronoDampener01', false)
			end
			
			if self.wcChrono02 then
			
				self:SetWeaponEnabledByLabel('EXChronoDampener02', true)
				
				wep = self:GetWeaponByLabel('EXChronoDampener02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[6].MaxRadius)
			else
				self:SetWeaponEnabledByLabel('EXChronoDampener02', false)
			end
			
			if self.wcTorp01 then
			
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', true)
				
				wep = self:GetWeaponByLabel('EXTorpedoLauncher01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[7].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			end
			
			if self.wcTorp02 then
			
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', true)
				
				wep = self:GetWeaponByLabel('EXTorpedoLauncher02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[8].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			end
			
			if self.wcTorp03 then
			
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', true)
				
				wep = self:GetWeaponByLabel('EXTorpedoLauncher03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[9].MaxRadius)
			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			end
			
			if self.wcArtillery01 then
			
				self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', true)
				
				wep = self:GetWeaponByLabel('EXMiasmaArtillery01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[10].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[10].MaxRadius)
			end
			
			if self.wcArtillery02 then
			
				self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', true)
				
				wep = self:GetWeaponByLabel('EXMiasmaArtillery02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[11].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[11].MaxRadius)
			end
			
			if self.wcArtillery03 then
			
				self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', true)
				
				wep = self:GetWeaponByLabel('EXMiasmaArtillery03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[12].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[12].MaxRadius)
			end
			
			if self.wcBeam01 then
			
				self:SetWeaponEnabledByLabel('EXPhasonBeam01', true)
			
				wep = self:GetWeaponByLabel('EXPhasonBeam01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[13].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[13].MaxRadius)
			end
			
			if self.wcBeam02 then
			
				self:SetWeaponEnabledByLabel('EXPhasonBeam02', true)
                
				wep = self:GetWeaponByLabel('EXPhasonBeam02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[14].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[14].MaxRadius)
			end
			
			if self.wcBeam03 then
			
				self:SetWeaponEnabledByLabel('EXPhasonBeam03', true)
                
				wep = self:GetWeaponByLabel('EXPhasonBeam03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[15].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[15].MaxRadius)
			end
			
			if self.MaelstromFieldName then
                self:EnableUnitIntel('RadarStealthField')
                self:SetIntelRadius( 'RadarStealth', self.MaelstromFieldRadius )
			else
                self:SetIntelRadius('RadarStealth', self.MaelstromFieldRadius )
                self:DisableUnitIntel('RadarStealthField')
			end
		end
    end,
	
    ArtyShieldCheck = function(self)
	
		if self.ccArtillery and not self.Shield then
		
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
			
		elseif self.Shield and not self.ccArtillery then
		
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
			
		elseif self.ccArtillery and self.Shield then
		
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
			
		elseif not self.ccArtillery and not self.Shield then
		
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

        if bit == 0 and self.Shield and self.ShieldOn then

			self:DisableShield()

            -- remove back slot consumption when shield turned off
            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption['Back']

            self.ShieldOn = false

        elseif bit == 3 and self.IntelPackage and not self.IntelPackageOn then

            -- add command slot consumption when radar turned on
            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] + self.EnergyConsumption['Command']

            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('Sonar')
            self:EnableUnitIntel('Omni')
         
            self.IntelPackageOn = true
            
        elseif bit == 7 then    -- Maelstrom Field

            if self.MaelstromFieldName and self.MaelstromFieldOn then
            
                self:SetIntelRadius( 'RadarStealth', 1 )
                self:SetIntelRadius( 'RadarStealthField', 1 )
                self:SetIntelRadius( 'SonarStealth', 1 )
                self:SetIntelRadius( 'SonarStealthField', 1 )

                self:DisableUnitIntel('RadarStealthField')
                self:DisableUnitIntel('SonarStealthField')

                self:GetBuffFieldByName( self.MaelstromFieldName ):Disable()

                -- remove back slot consumption when Maelstrom turned off
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption['Back']

                self.MaelstromFieldOn = false
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

			self:EnableShield()
            
            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] + self.EnergyConsumption['Back']

            self.ShieldOn = true

        elseif bit == 3 and self.IntelPackage and self.IntelPackageOn then

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption['Command']

            self:DisableUnitIntel('Radar')
            self:DisableUnitIntel('Sonar')
            self:DisableUnitIntel('Omni')
          
            self.IntelPackageOn = false

        elseif bit == 7 then

            if self.MaelstromFieldName and not self.MaelstromFieldOn then
            
                self:SetIntelRadius( 'RadarStealth', self.MaelstromFieldRadius )
                self:SetIntelRadius( 'RadarStealthField', self.MaelstromFieldRadius )
                self:SetIntelRadius( 'SonarStealth', self.MaelstromFieldRadius )
                self:SetIntelRadius( 'SonarStealthField', self.MaelstromFieldRadius )

                self:EnableUnitIntel('RadarStealthField')
                self:EnableUnitIntel('SonarStealthField')

                self:GetBuffFieldByName( self.MaelstromFieldName ):Enable()

                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] + self.EnergyConsumption['Back']

                self.MaelstromFieldOn = true
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
	
        AWalkingLandUnit.CreateEnhancement(self, enh)

        -- this gives us the data from the enhancement
        local bp = self:GetBlueprint().Enhancements[enh]
		
        if enh =='EXImprovedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Imp_Eng')
			
        elseif enh =='EXImprovedEngineeringRemove' then
			
            if Buff.HasBuff( self, 'ACU_T2_Imp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Imp_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
			
        elseif enh =='EXAdvancedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Adv_Eng')
			
        elseif enh =='EXAdvancedEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Adv_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Adv_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
			
        elseif enh =='EXExperimentalEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Exp_Eng')			
			
		elseif enh =='EXExperimentalEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Exp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Exp_Eng' )
            end		

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			
        elseif enh =='EXCombatEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Combat_Eng')

			self.wcChrono01 = true
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXCombatEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T2_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXAssaultEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Combat_Eng')

			self.wcChrono01 = false
			self.wcChrono02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXAssaultEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Combat_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXApocalypticEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Combat_Eng')
			
			self.wcChrono01 = false
			self.wcChrono02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXApocalypticEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
		elseif enh =='EXDisruptorrBooster' then
        
			wep = self:GetWeaponByLabel('RightDisruptor')
            
            -- increase the damage 50%
			wep:AddDamageMod( self:GetBlueprint().Weapon[2].Damage * .5 )
            
            -- increase radius by 5
			wep:ChangeMaxRadius( self:GetBlueprint().Weapon[2].MaxRadius + 5)
            
            Buff.ApplyBuff(self,'MobilityPenalty')
            
			wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius + 5)
            
			wep = self:GetWeaponByLabel('OverCharge')
            
			wep:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius + 5)
            
			self:ShowBone('Basic_GunUp_Range', true)
			
        elseif enh =='EXDisruptorrBoosterRemove' then
        
			wep = self:GetWeaponByLabel('RightDisruptor')
            
            -- remove previously added damage increase
			wep:AddDamageMod( -0.5 * self:GetBlueprint().Weapon[2].Damage )
            
            -- revert range to original value
			wep:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end
            
			wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
            
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            
			wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius)
            
			self:HideBone('Basic_GunUp_Range', true)

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
			
        elseif enh =='EXArtilleryMiasma' then

			self.wcArtillery01 = true
			self.wcArtillery02 = false
			self.wcArtillery03 = false
            
			self.ccArtillery = true
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)

        elseif enh =='EXArtilleryMiasmaRemove' then

			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false
            
			self.ccArtillery = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)

        elseif enh =='EXAdvancedShells' then

			self.wcArtillery01 = false
			self.wcArtillery02 = true
			self.wcArtillery03 = false
            
			self.ccArtillery = true
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh =='EXAdvancedShellsRemove' then

			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false
            
			self.ccArtillery = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh =='EXImprovedReloader' then

			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = true

			self.ccArtillery = true
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh =='EXImprovedReloaderRemove' then    

			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false

			self.ccArtillery = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh =='EXBeamPhason' then

			self.wcBeam01 = true
			self.wcBeam02 = false
			self.wcBeam03 = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXBeamPhasonRemove' then

			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXImprovedCoolingSystem' then

            self.wcBeam01 = false
			self.wcBeam02 = true
			self.wcBeam03 = false

			self.wcChrono01 = true
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)    
			
        elseif enh =='EXImprovedCoolingSystemRemove' then

			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXPowerBooster' then

            self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self.wcChrono01 = false
			self.wcChrono02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXPowerBoosterRemove' then

			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			self.wcChrono01 = false
			self.wcChrono02 = false
			
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

        elseif enh == 'EXIntelRhianneDevice' then

            self.Sync.Abilities = self.RemoteViewingData.Abilities
            self.Sync.Abilities.TargetLocation.Active = true

            self.RechargeThread = self:ForkThread( self.RechargeEmitter )

        elseif enh == 'EXIntelRhianneDeviceRemove' then

            self.Sync.Abilities = self.RemoteViewingData.Abilities
            self.Sync.Abilities.TargetLocation.Active = false
           
            if self.RemoteViewingData then
            
                if self.RemoteViewingData.Satellite then
                    self.RemoteViewingData.Satellite:Destroy()
                end
   
                if self.CooldownThread then
                    KillThread(self.CooldownThread)
                    self.CooldownThread = nil
                end
   
                if self.ViewtimeThread then
                    KillThread(self.ViewtimeThread)
                    self.ViewtimeThread = nil
                end
   
                if self.ViewingRadiusThread then
                    KillThread(self.ViewingRadiusThread)
                    self.ViewRadiusThread = nil
                end

            end
     
            if self.RechargeThread then
                KillThread(self.RechargeThread)
            end

        elseif enh == 'EXPersonalTeleporter' then

            self:AddCommandCap('RULEUCC_Teleport')
			
        elseif enh == 'EXPersonalTeleporterRemove' then

            self:RemoveCommandCap('RULEUCC_Teleport')

			
        elseif enh =='EXMaelstromQuantum' then

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

            self.MaelstromFieldName = 'AeonMaelstromBuffField'
            self.MaelstromFieldOn = false
            self.MaelstromFieldRadius = 24

            self:AddToggleCap('RULEUTC_SpecialToggle')
            
            self:SetScriptBit('RULEUTC_SpecialToggle', true )   -- turn on the field

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.wcChrono01 = false
			self.wcChrono02 = false

        elseif enh =='EXMaelstromQuantumRemove' then

            if self.MaelstromFieldOn then
                self:SetScriptBit('RULEUTC_SpecialToggle', false )   -- turn off existing field
            end

            self.EnergyConsumption[bp.Slot] = 0

            self.MaelstromFieldName = false
            self.MaelstromFieldOn = false
            self.MaelstromFieldRadius = 1
        
            self:RemoveToggleCap('RULEUTC_SpecialToggle')

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.wcChrono01 = false
			self.wcChrono02 = false

        elseif enh =='EXMaelstromFieldExpander' then

            if self.MaelstromFieldOn then
                self:SetScriptBit('RULEUTC_SpecialToggle', false )   -- turn off existing field
            end
            
            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

            self.MaelstromFieldName = 'AeonMaelstromBuffField2'
            self.MaelstromFieldRadius = 32
            
            self:SetScriptBit('RULEUTC_SpecialToggle', true )   -- turn on the field

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)    

			self.wcChrono01 = true
			self.wcChrono02 = false

        elseif enh == 'EXMaelstromFieldExpanderRemove' then

            if self.MaelstromFieldOn then
                self:SetScriptBit('RULEUTC_SpecialToggle', false )   -- turn off existing field
            end

            self.EnergyConsumption[bp.Slot] = 0

            self.MaelstromFieldName = false
            self.MaelstromFieldOn = false
            self.MaelstromFieldRadius = 1
        
            self:RemoveToggleCap('RULEUTC_SpecialToggle')

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.wcChrono01 = false
			self.wcChrono02 = false

        elseif enh =='EXMaelstromQuantumInstability' then

            Buff.ApplyBuff(self,'MobilityPenalty')

            if self.MaelstromFieldOn then
                self:SetScriptBit('RULEUTC_SpecialToggle', false )   -- turn off existing field
            end
            
            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

            self.MaelstromFieldName = 'AeonMaelstromBuffField3'
            self.MaelstromFieldRadius = 40
            
            self:SetScriptBit('RULEUTC_SpecialToggle', true )   -- turn on the field
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)      

			self.wcChrono01 = false
			self.wcChrono02 = true

        elseif enh == 'EXMaelstromQuantumInstabilityRemove' then

            if self.MaelstromFieldOn then
                self:SetScriptBit('RULEUTC_SpecialToggle', false )   -- turn off existing field
            end

            self.EnergyConsumption[bp.Slot] = 0

            self.MaelstromFieldName = false
            self.MaelstromFieldOn = false
            self.MaelstromFieldRadius = 1
        
            self:RemoveToggleCap('RULEUTC_SpecialToggle')
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.wcChrono01 = false
			self.wcChrono02 = true
			
        elseif enh == 'EXShieldBubble' then

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
            
            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
            
			self.Shield = true
            self.ShieldOn = false

            self:AddToggleCap('RULEUTC_ShieldToggle')
			
            self:CreateShield(bp)  -- this will also turn on the shield

			self:ForkThread(self.ArtyShieldCheck)
			
		elseif enh == 'EXShieldBubbleRemove' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = 0
            
			self.Shield = false
            
            self:RemoveToggleCap('RULEUTC_ShieldToggle')

            RemoveUnitEnhancement(self, 'EXShieldBubbleRemove')
            
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh == 'EXActiveSkinShield' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy
            
			self.Shield = true
            
            self:CreatePersonalShield(bp)  -- this will also turn on the shield
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh == 'EXActiveSkinShieldRemove' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = 0
            
			self.Shield = false
            
            RemoveUnitEnhancement(self, 'EXActiveSkinShieldRemove')

            self:RemoveToggleCap('RULEUTC_ShieldToggle')
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh == 'EXAdvancedSkinShield' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           
            
            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

			self.Shield = true
            
            self:CreatePersonalShield(bp)  -- this will also turn on the shield
            
            Buff.ApplyBuff(self,'MobilityPenalty')
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh == 'EXAdvancedSkinShieldRemove' then

            if self.ShieldOn then
                self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption[bp.Slot]
                self.ShieldOn = false
            end

            self:DisableShield()    -- disable existing shield
            self:DestroyShield()    -- remove existing shield           

            self.EnergyConsumption[bp.Slot] = 0
           
			self.Shield = false
            
            RemoveUnitEnhancement(self, 'EXAdvancedSkinShieldRemove')
            
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end
			
			self:ForkThread(self.ArtyShieldCheck)
        end

    end,

    OnIntelEnabled = function(self,intel)
    
        AWalkingLandUnit.OnIntelEnabled(self,intel)

        if self.MaelstromFieldRadius > 1 and intel == 'RadarStealthField' then
            
            if not self.StealthEffectsBag then
	            self.StealthEffectsBag = {}
            end

	        self.CreateTerrainTypeEffects(self, self.IntelEffects.Field,'FXIdle',self:GetCurrentLayer(),nil,self.StealthEffectsBag )
        end
    end,

    OnIntelDisabled = function(self,intel)

        AWalkingLandUnit.OnIntelDisabled(self,intel)
        
        if intel == 'RadarStealthField' then

            if self.StealthEffectsBag then
                EffectUtil.CleanupEffectBag(self,'StealthEffectsBag')
                self.StealthEffectsBag = nil
            end        
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
			    Scale = 0.8,
			    Type = 'Jammer01',
		    },
        },
    },

}

TypeClass = EAL0001