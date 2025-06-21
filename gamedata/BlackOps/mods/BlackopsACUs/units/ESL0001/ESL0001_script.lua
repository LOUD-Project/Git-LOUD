local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Buff = import('/lua/sim/Buff.lua')
local BuffField = import('/lua/sim/BuffField.lua').BuffField

local SWeapons = import('/lua/seraphimweapons.lua')

local SDFChronotronCannonWeapon             = SWeapons.SDFChronotronCannonWeapon
local SDFChronotronOverChargeCannonWeapon   = SWeapons.SDFChronotronCannonOverChargeWeapon
local SIFCommanderDeathWeapon               = SWeapons.SIFCommanderDeathWeapon
local SDFSinnuntheWeapon                    = SWeapons.SDFSinnuntheWeapon
local SANAnaitTorpedo                       = SWeapons.SANAnaitTorpedo
local SAAOlarisCannonWeapon                 = SWeapons.SAAOlarisCannonWeapon
local Targeting                             = SWeapons.SeraphimTargetPainter

SWeapons = nil

local SeraACURapidWeapon    = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').SeraACURapidWeapon 
local SeraACUBigBallWeapon  = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').SeraACUBigBallWeapon 

local EffectTemplate    = import('/lua/EffectTemplates.lua')
local EffectUtil        = import('/lua/EffectUtilities.lua')

local MissileRedirect   = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy
local LambdaRedirect    = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldRedirector
local LambdaDestroy     = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldDestroyer

local CreateAttachedEmitter = CreateAttachedEmitter

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local wep, wpTarget

ESL0001 = Class( SWalkingLandUnit ) {

    DeathThreadDestructionWaitTime = 2,
	
	BuffFields = {

		RegenField1 = Class(BuffField){},
		RegenField2 = Class(BuffField){},
	},
	
    Weapons = {
	
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
		
        ChronotronCannon = Class(SDFChronotronCannonWeapon) {},
		
        TargetPainter = Class(Targeting) { FxMuzzleFlash = false },
		
        EXTorpedoLauncher01 = Class(SANAnaitTorpedo) { FxMuzzleFlash = false },
        EXTorpedoLauncher02 = Class(SANAnaitTorpedo) { FxMuzzleFlash = false },
        EXTorpedoLauncher03 = Class(SANAnaitTorpedo) { FxMuzzleFlash = false },
		
        EXBigBallCannon01 = Class(SeraACUBigBallWeapon) {
		
            PlayFxMuzzleChargeSequence = function(self, muzzle)

                -- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
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
		
        EXBigBallCannon02 = Class(SeraACUBigBallWeapon) {
		
            PlayFxMuzzleChargeSequence = function(self, muzzle)

                -- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
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
		
        EXBigBallCannon03 = Class(SeraACUBigBallWeapon) {
		
            PlayFxMuzzleChargeSequence = function(self, muzzle)

                -- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
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
                    WaitSeconds(self.unit:GetBlueprint().Weapon[10].MuzzleChargeDelay)
       
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

                --self.unit:SetWeaponEnabledByLabel('ChronotronCannon', false)

                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                
                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end
                
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

                --self.unit:SetWeaponEnabledByLabel('ChronotronCannon', true)

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

        self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    OnPrepareArmToBuild = function(self)

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(true)

        self.BuildArmManipulator:SetPrecedence(20)
        self.wcBuildMode = true

		self:ForkThread(self.WeaponConfigCheck)

        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
    end,

    OnFailedToBuild = function(self)

        SWalkingLandUnit.OnFailedToBuild(self)

        if self.Dead then return end

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

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false

		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )

        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
    end,

    OnStopCapture = function(self, target)

        SWalkingLandUnit.OnStopCapture(self, target)

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false

		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)

        SWalkingLandUnit.OnFailedCapture(self, target)

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false

		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)

        SWalkingLandUnit.OnStopReclaim(self, target)

        if self.Dead then return end

        self:BuildManipulatorSetEnabled(false)

        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false

		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)

        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

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
        
        self.OCOverdrive = false

		self.EXMoving = false
		self.EXOCFire = false

		wpTarget = self:GetWeaponByLabel('TargetPainter')

		wpTarget:ChangeMaxRadius(100)

		self:ForkThread(self.WeaponConfigCheck)
		self:ForkThread(self.WeaponRangeReset)

        self:ForkThread(self.GiveInitialResources)
		
        self.EnergyConsumption = { Total = 0, Back = 0, Command = 0, LCH = 0, RCH = 0 }

        local bpd = __blueprints[self.BlueprintID].Defense
        
    	local bp = bpd.LambdaRedirect01
        local bp2 = bpd.LambdaRedirect02

        local bp4 = bpd.LambdaDestroy01
        local bp5 = bpd.LambdaDestroy02
        
        self.Lambda1 = LambdaRedirect { Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }
        self.Lambda2 = LambdaRedirect { Owner = self, Radius = bp2.Radius, AttachBone = bp2.AttachBone, RedirectRateOfFire = bp2.RedirectRateOfFire }

        self.Lambda4 = LambdaDestroy { Owner = self, Radius = bp4.Radius, AttachBone = bp4.AttachBone, RedirectRateOfFire = bp4.RedirectRateOfFire }
        self.Lambda5 = LambdaDestroy { Owner = self, Radius = bp5.Radius, AttachBone = bp5.AttachBone, RedirectRateOfFire = bp5.RedirectRateOfFire }
		
        TrashAdd( self.Trash, self.Lambda1)
        TrashAdd( self.Trash, self.Lambda2)
        TrashAdd( self.Trash, self.Lambda4)
        TrashAdd( self.Trash, self.Lambda5)

		-- turn on Lambda emitters --
        self:SetScriptBit( 'RULEUTC_SpecialToggle', true)

        self:RemoveToggleCap('RULEUTC_CloakToggle')
        self:RemoveToggleCap('RULEUTC_IntelToggle')

        self:SetScriptBit( 'RULEUTC_SpecialToggle', false)

        self:RemoveToggleCap('RULEUTC_ShieldToggle')

        self:RemoveToggleCap('RULEUTC_SpecialToggle')
        self:RemoveToggleCap('RULEUTC_StealthToggle')

        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy

        local antiMissile = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }

        TrashAdd( self.Trash, antiMissile)

    end,

    OnTransportDetach = function(self, attachBone, unit)

        SWalkingLandUnit.OnTransportDetach(self, attachBone, unit)

        self:ForkThread(self.WeaponConfigCheck)
    end,
    
    WarpInEffectThread = function(self)

        self:PlayUnitSound('CommanderArrival')

        self:CreateProjectile( '/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)

        WaitSeconds(2.1)

        self:ShowBone(0, true)

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
    end,

    WeaponRangeReset = function(self)
        
		wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)

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

		if not self.wcBigBall01 then
			wep = self:GetWeaponByLabel('EXBigBallCannon01')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcBigBall02 then
			wep = self:GetWeaponByLabel('EXBigBallCannon02')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcBigBall03 then
			wep = self:GetWeaponByLabel('EXBigBallCannon03')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcRapid01 then
			wep = self:GetWeaponByLabel('EXRapidCannon01')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcRapid02 then
			wep = self:GetWeaponByLabel('EXRapidCannon02')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcRapid03 then
			wep = self:GetWeaponByLabel('EXRapidCannon03')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcAA01 then
			wep = self:GetWeaponByLabel('EXAA01')
			wep:ChangeMaxRadius(1)
		end

		if not self.wcAA02 then
			wep = self:GetWeaponByLabel('EXAA02')
			wep:ChangeMaxRadius(1)
		end
    end,
	
    WeaponConfigCheck = function(self)
    
        if self.Dead then return end

		if self.wcBuildMode then

			self:SetWeaponEnabledByLabel('TargetPainter', false)
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
		end

		if self.wcOCMode then

			self:SetWeaponEnabledByLabel('TargetPainter', false)
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
		end

		if not self.wcBuildMode and not self.wcOCMode then

			self:SetWeaponEnabledByLabel('TargetPainter', true)
			self:SetWeaponEnabledByLabel('ChronotronCannon', true)
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

			if self.wcTorp01 then

				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', true)

				wep = self:GetWeaponByLabel('EXTorpedoLauncher01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[5].MaxRadius)
			end

			if self.wcTorp02 then

				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', true)

				wep = self:GetWeaponByLabel('EXTorpedoLauncher02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[6].MaxRadius)
			end

			if self.wcTorp03 then

				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', true)

				wep = self:GetWeaponByLabel('EXTorpedoLauncher03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[7].MaxRadius)
			end

			if self.wcBigBall01 then

				self:SetWeaponEnabledByLabel('EXBigBallCannon01', true)

				wep = self:GetWeaponByLabel('EXBigBallCannon01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[8].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[8].MaxRadius)
			end

			if self.wcBigBall02 then

				self:SetWeaponEnabledByLabel('EXBigBallCannon02', true)

				wep = self:GetWeaponByLabel('EXBigBallCannon02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[9].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[9].MaxRadius)
			end

			if self.wcBigBall03 then

				self:SetWeaponEnabledByLabel('EXBigBallCannon03', true)

				wep = self:GetWeaponByLabel('EXBigBallCannon03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[10].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[10].MaxRadius)
			end

			if self.wcRapid01 then

				self:SetWeaponEnabledByLabel('EXRapidCannon01', true)

				wep = self:GetWeaponByLabel('EXRapidCannon01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[11].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[11].MaxRadius)
			end

			if self.wcRapid02 then

				self:SetWeaponEnabledByLabel('EXRapidCannon02', true)

				wep = self:GetWeaponByLabel('EXRapidCannon02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[12].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[12].MaxRadius)
			end

			if self.wcRapid03 then

				self:SetWeaponEnabledByLabel('EXRapidCannon03', true)

				wep = self:GetWeaponByLabel('EXRapidCannon03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[13].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[13].MaxRadius)
			end

			if self.wcAA01 then

                self:ShowBone('Left_AA_Mount', true)
				self:SetWeaponEnabledByLabel('EXAA01', true)

				wep = self:GetWeaponByLabel('EXAA01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[14].MaxRadius)

			else
                self:HideBone('Left_AA_Mount', true)
				self:SetWeaponEnabledByLabel('EXAA01', false)
			end

			if self.wcAA02 then

                self:ShowBone('Right_AA_Mount', true)
				self:SetWeaponEnabledByLabel('EXAA02', true)

				wep = self:GetWeaponByLabel('EXAA02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[15].MaxRadius)

			else
                self:HideBone('Right_AA_Mount', true)
				self:SetWeaponEnabledByLabel('EXAA02', false)
			end
            
            if self.OCOverdrive then
                wep = self:GetWeaponByLabel('OverCharge')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius + 10)
                wep:ChangeProjectileBlueprint('/mods/BlackOpsACUs/projectiles/OmegaOverCharge01/OmegaOverCharge01_proj.bp')
            else
                wep = self:GetWeaponByLabel('OverCharge')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius)
                wep:ChangeProjectileBlueprint('/projectiles/SDFChronatronCannon02/SDFChronatronCannon02_proj.bp')
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
		
        elseif bit == 7 then    -- Lambda Fields

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] - self.EnergyConsumption['Back']

            self.Lambda1:Disable()
            self.Lambda2:Disable()

            self.Lambda4:Disable()
            self.Lambda5:Disable()

            KillThread(self.ConsumptionThread)
            self.ConsumptionThread = nil

        elseif bit == 8 then

            self:EnableUnitIntel('Cloak')
            self.CloakOn = true

        end

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
		
        elseif bit == 7 then 

            self.EnergyConsumption['Total'] = self.EnergyConsumption['Total'] + self.EnergyConsumption['Back']

            if self.LambdaTier1 then
                self.Lambda1:Enable()
                self.Lambda2:Enable()
            end
            
            if self.LambdaTier2 then
                self.Lambda4:Enable()
                self.Lambda5:Enable()
            end
            
            if not self.ConsumptionThread then
                self.ConsumptionThread = self:ForkThread( self.WatchConsumption )
            end

		elseif bit == 8 then # cloak toggle

            self:DisableUnitIntel('Cloak')
            self.CloakOn = false

        end

        self:SetEnergyMaintenanceConsumptionOverride( self.EnergyConsumption['Total'] )
        
        if self.EnergyConsumption['Total'] > 0 then
            self:SetMaintenanceConsumptionActive()
        else
            self:SetMaintenanceConsumptionInactive()
        end

    end,

    -- this thread is launched when the lambda is turned on
    -- and will disable it, and remove the toggle, if the power drops out
    -- and will restore it once the power returns
    WatchConsumption = function(self)

        local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local GetResourceConsumed = moho.unit_methods.GetResourceConsumed
        local WaitTicks = coroutine.yield

        local MaintenanceConsumption = self.EnergyConsumption['Back']
    
        local on = true
        local count = 0

        local aiBrain = self:GetAIBrain()
        local army =  self.Army

        self.Effects = {}    

        while MaintenanceConsumption > 0 do

            WaitTicks(16)
            
            if GetResourceConsumed(self) != 1 and GetEconomyStored(aiBrain,'Energy') < 1 then

                -- turn off Lambda emitters --
                self:SetScriptBit('RULEUTC_SpecialToggle', false)

                self:RemoveToggleCap('RULEUTC_SpecialToggle')

                on = false
            end

            while not on do

                WaitTicks(16)

                if GetEconomyStored(aiBrain,'Energy') > MaintenanceConsumption then

                    self:AddToggleCap('RULEUTC_SpecialToggle')

                    -- turn on Lambda emitters --
                    self:SetScriptBit('RULEUTC_SpecialToggle', true)

                    on = true
                end
            end
            
        end

    end,    

    CreateEnhancement = function(self, enh)
	
        SWalkingLandUnit.CreateEnhancement(self, enh)
		
        local bp = self:GetBlueprint().Enhancements[enh]

        if enh =='EXImprovedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Imp_Eng')
			
			self:GetBuffFieldByName('SeraphimACURegenBuffField'):Enable()
			
        elseif enh =='EXImprovedEngineeringRemove' then
			
            if Buff.HasBuff( self, 'ACU_T2_Imp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Imp_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
			
			self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()
			
        elseif enh =='EXAdvancedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Adv_Eng')
			
			self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()
			self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Enable()
			
        elseif enh =='EXAdvancedEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Adv_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Adv_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
			
			self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Disable()

        elseif enh =='EXExperimentalEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Exp_Eng')			
			
            self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()
			self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Enable()
            
            self.OCOverdrive = true

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
		elseif enh =='EXExperimentalEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Exp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Exp_Eng' )
            end		

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )

			
			self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()
			self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Disable()

            self.OCOverdrive = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXCombatEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Combat_Eng')

			self.wcAA01 = true
			self.wcAA02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Disable()
			
        elseif enh =='EXCombatEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T2_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcAA01 = false
			self.wcAA02 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXAssaultEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Combat_Eng')

			self.wcAA01 = true
			self.wcAA02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXAssaultEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Combat_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcAA01 = false
			self.wcAA02 = false		

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXApocalypticEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Combat_Eng')

			self.wcAA01 = true
			self.wcAA02 = true
            
            self.OCOverdrive = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXApocalypticEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcAA01 = false
			self.wcAA02 = false		
            
            self.OCOverdrive = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
		elseif enh =='EXChronotronBooster' then

            wep = self:GetWeaponByLabel('ChronotronCannon')
            
            -- increase the damage 50%
			wep:AddDamageMod( self:GetBlueprint().Weapon[2].Damage * .5 )
            
            -- increase radius by 5
			wep:ChangeMaxRadius( self:GetBlueprint().Weapon[2].MaxRadius + 5)
            
            Buff.ApplyBuff(self,'MobilityPenalty')
            
			wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius + 5)
            
			wep = self:GetWeaponByLabel('OverCharge')
            
			wep:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius + 5)

			self:ShowBone('Basic_Gun_Up', true)
			
        elseif enh =='EXChronotronBoosterRemove' then

			wep = self:GetWeaponByLabel('ChronotronCannon')
            
            -- remove previously added damage increase
			wep:AddDamageMod( -0.5 * self:GetBlueprint().Weapon[2].Damage )
            
            -- revert range to original value
			wep:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end
            
			wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)

			wep = self:GetWeaponByLabel('OverCharge')

            wep:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius)

			self:HideBone('Basic_Gun_Up', true)

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
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXTorpedoClusterLauncherRemove' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXStormCannon' then
			self.wcBigBall01 = true
			self.wcBigBall02 = false
			self.wcBigBall03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXStormCannonRemove' then
			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXStormCannonII' then
			self.wcBigBall01 = false
			self.wcBigBall02 = true
			self.wcBigBall03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXStormCannonIIRemove' then
			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXStormCannonIII' then
            self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXStormCannonIIIRemove' then

            self:SetWeaponEnabledByLabel('EXBigBallCannon', false)
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXRapidCannon' then
			self.wcRapid01 = true
			self.wcRapid02 = false
			self.wcRapid03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXRapidCannonRemove' then
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXRapidCannonII' then
            self.wcRapid01 = false
			self.wcRapid02 = true
			self.wcRapid03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXRapidCannonIIRemove' then
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXRapidCannonIII' then
            self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXRapidCannonIIIRemove' then
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false
            
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

        elseif enh == 'EXPersonalTeleporter' then

            self:AddCommandCap('RULEUCC_Teleport')
			
        elseif enh == 'EXPersonalTeleporterRemove' then

            self:RemoveCommandCap('RULEUCC_Teleport')

        elseif enh == 'EXL1Lambda' then

			self.LambdaTier1 = true
			self.LambdaTier2 = false

            self:AddToggleCap('RULEUTC_SpecialToggle')

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

            -- turn on Lambda emitters --
            self:SetScriptBit('RULEUTC_SpecialToggle', true)

		elseif enh == 'EXL1LambdaRemove' then

            -- turn off Lambda emitters --
            self:SetScriptBit('RULEUTC_SpecialToggle', false)
            
            self.EnergyConsumption[bp.Slot] = 0

            self:RemoveToggleCap('RULEUTC_SpecialToggle')

			self.LambdaTier1 = false
			self.LambdaTier2 = false

        elseif enh == 'EXL2Lambda' then

            -- turn off existing Lambda emitters --
            self:SetScriptBit('RULEUTC_SpecialToggle', false)

			self.LambdaTier1 = true
			self.LambdaTier2 = true

            self:AddToggleCap('RULEUTC_SpecialToggle')

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

            -- turn on Lambda emitters --
            self:SetScriptBit('RULEUTC_SpecialToggle', true)

        elseif enh == 'EXL2LambdaRemove' then

            -- turn off Lambda emitters --
            self:SetScriptBit('RULEUTC_SpecialToggle', false)
            
            self.EnergyConsumption[bp.Slot] = 0

            self:RemoveToggleCap('RULEUTC_SpecialToggle')

			self.LambdaTier1 = false
			self.LambdaTier2 = false

        elseif enh == 'EXArmorPlating' then

            Buff.ApplyBuff(self, 'ArmorPackage7')
            
            Buff.ApplyBuff(self,'MobilityPenalty')

		elseif enh == 'EXArmorPlatingRemove' then

            Buff.RemoveBuff( self, 'ArmorPackage7' )
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

        elseif enh == 'EXStealthField' then

            self.StealthPackage = true

            self:AddToggleCap('RULEUTC_StealthToggle')

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth

            self.EnergyConsumption[bp.Slot] = bp.ConsumptionPerSecondEnergy

            self:SetScriptBit('RULEUTC_StealthToggle', false )   -- turn it back on

        elseif enh == 'EXStealthFieldRemove' then

            Buff.RemoveBuff( self, 'ArmorPackage7' )
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

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

            Buff.RemoveBuff( self, 'ArmorPackage7' )
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end
            
            if self.CloakOn then
                self:SetScriptBit('RULEUTC_CloakToggle', true ) -- turn off cloak
            end

            self:RemoveToggleCap('RULEUTC_CloakToggle')

            self.CloakPackage = false

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth Field

            self.StealthPackage = false

            self.EnergyConsumption[bp.Slot] = 0
            
            self:RemoveToggleCap('RULEUTC_StealthToggle')

        elseif enh =='EXOverchargeOverdrive' then

			local wepOC = self:GetWeaponByLabel('OverCharge')
            wepOC:ChangeMaxRadius(bp.OverchargeRangeMod or 44)

			wepOC:ChangeProjectileBlueprint('/mods/BlackOpsACUs/projectiles/OmegaOverCharge01/OmegaOverCharge01_proj.bp')

        elseif enh == 'EXOverchargeOverdriveRemove' then

            Buff.RemoveBuff( self, 'ArmorPackage7' )
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end
            
            if self.CloakOn then
                self:SetScriptBit('RULEUTC_CloakToggle', true ) -- turn off cloak
            end

            self:RemoveToggleCap('RULEUTC_CloakToggle')

            self.CloakPackage = false

            self:SetScriptBit('RULEUTC_StealthToggle', true )   -- turn off Stealth Field

            self.StealthPackage = false

            self.EnergyConsumption[bp.Slot] = 0
            
            self:RemoveToggleCap('RULEUTC_StealthToggle')
			
			local wepOC = self:GetWeaponByLabel('OverCharge')
            local bpDisruptOCRadius = self:GetBlueprint().Weapon[3].MaxRadius

            wepOC:ChangeMaxRadius(bpDisruptOCRadius or 22)

			wepOC:ChangeProjectileBlueprint('/projectiles/SDFChronatronCannon02/SDFChronatronCannon02_proj.bp')
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
		end
    end,

    IntelEffects = {
		Cloak = { { Bones = {'Body','Right_Arm_B01','Left_Arm_B01','Left_Leg_B01','Right_Leg_B01'}, Scale = 1.0, Type = 'Cloak01' } },
		Field = { { Bones = {'Body'}, Scale = 0.65, Type = 'Jammer01' } },
    },
	
    OnIntelEnabled = function(self,intel)

        SWalkingLandUnit.OnIntelEnabled(self,intel)		
       
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
	
        SWalkingLandUnit.OnIntelDisabled(self,intel)		
        
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
	
		if self.CloakPackage then
        
			if ((new == 'Stopped' or new == 'Stopping') and (old == 'Cruise' or old == 'TopSpeed')) then

				self.EXMoving = false

			elseif ( old == 'Stopped' or (old == 'Stopping' and (new == 'Cruise' or new == 'TopSpeed'))) then

				self.EXMoving = true

			end

			if self.EXMoving then
            
                if self.CloakOn then
                    self:SetScriptBit('RULEUTC_CloakToggle', true ) -- turn off cloak
                end

			else

                self:SetScriptBit('RULEUTC_CloakToggle', false ) -- turn on cloak

			end
		end
		
        SWalkingLandUnit.OnMotionHorzEventChange(self, new, old)

    end,

	EXRecloakDelayThread = function(self)
		WaitSeconds(3)
		self.EXCloakTele = false
	end,

	EXOCCloakTiming = function(self)
    
        if self.CloakPackage then
            
            if self.CloakOn then
                self:SetScriptBit('RULEUTC_CloakToggle', true ) -- turn off cloak
            end

            self:RemoveToggleCap('RULEUTC_CloakToggle')
        
        end

		WaitSeconds(5)

		self.EXOCFire = false
        
        if self.CloakPackage then

            self:AddToggleCap('RULEUTC_CloakToggle')

            self:SetScriptBit('RULEUTC_CloakToggle', false ) -- turn on cloak
        end

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

TypeClass = ESL0001