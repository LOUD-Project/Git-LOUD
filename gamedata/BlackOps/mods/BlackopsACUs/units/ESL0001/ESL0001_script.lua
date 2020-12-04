local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SeraphimBuffField = import('/lua/seraphimweapons.lua').SeraphimBuffField
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

ESL0001 = Class( SWalkingLandUnit ) {

    DeathThreadDestructionWaitTime = 2,
	
	BuffFields = {
	
		RegenField1 = Class(SeraphimBuffField){
		
			OnCreate = function(self)
				SeraphimBuffField.OnCreate(self)
			end,
		},
		
		RegenField2 = Class(SeraphimBuffField){
		
			OnCreate = function(self)
				SeraphimBuffField.OnCreate(self)
			end,
		},

	},
	
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
        --SWalkingLandUnit.OnPrepareArmToBuild(self)
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
				wepLance01:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXAA01', false)
			end
			if self.wcAA02 then
				self:SetWeaponEnabledByLabel('EXAA02', true)
				local wepLance02 = self:GetWeaponByLabel('EXAA02')
				wepLance02:ChangeMaxRadius(35)
			else
				self:SetWeaponEnabledByLabel('EXAA02', false)
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

    CreateEnhancement = function(self, enh)
	
        SWalkingLandUnit.CreateEnhancement(self, enh)
		
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
            self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )

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
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )

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
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )

			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false

        elseif enh =='EXCombatEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Combat_Eng')
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = true
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
			self:GetBuffFieldByName('SeraphimACURegenBuffField'):Enable()
			
        elseif enh =='EXCombatEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T2_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
			self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()
			
        elseif enh =='EXAssaultEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Combat_Eng')
			
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
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
        elseif enh =='EXApocalypticEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Combat_Eng')
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = true
			
			self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()
			self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Enable()
			
        elseif enh =='EXApocalypticEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER4COMMANDER) )
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
			self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Disable()
			
		elseif enh =='EXChronotonBooster' then
            local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
			wepChronotron:AddDamageMod(50)
			wepChronotron:ChangeMaxRadius(self:GetBlueprint().Weapon[1].MaxRadius + 5)
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius + 5)
			self:ShowBone('Basic_Gun_Up', true)
			
        elseif enh =='EXChronotonBoosterRemove' then
			local wepChronotron = self:GetWeaponByLabel('ChronotronCannon')
			wepChronotron:AddDamageMod(-50)
			wepChronotron:ChangeMaxRadius(self:GetBlueprint().Weapon[1].MaxRadius)
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
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
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXTorpedoClusterLauncherRemove' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXCannonBigBall' then
			self.wcBigBall01 = true
			self.wcBigBall02 = false
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXCannonBigBallRemove' then
			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedContainmentBottle' then
			self.wcBigBall01 = false
			self.wcBigBall02 = true
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXImprovedContainmentBottleRemove' then
			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXPowerBooster' then
            self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXPowerBoosterRemove' then
            self:SetWeaponEnabledByLabel('EXBigBallCannon', false)
			self.wcBigBall01 = false
			self.wcBigBall02 = false
			self.wcBigBall03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXCannonRapid' then
			self.wcRapid01 = true
			self.wcRapid02 = false
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXCannonRapidRemove' then
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXImprovedCoolingSystem' then
            self.wcRapid01 = false
			self.wcRapid02 = true
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXImprovedCoolingSystemRemove' then
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXEnergyShellHardener' then
            self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXEnergyShellHardenerRemove' then
			self.wcRapid01 = false
			self.wcRapid02 = false
			self.wcRapid03 = false
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

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

			self.RBDefTier1 = true
			self.RBDefTier2 = false
			self.RBDefTier3 = false

		elseif enh == 'EXL1LambdaRemove' then
			self.WeaponCheckAA01 = false
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)

			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false

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

			self.RBDefTier1 = true
			self.RBDefTier2 = true
			self.RBDefTier3 = false

        elseif enh == 'EXL2LambdaRemove' then
			self.WeaponCheckAA01 = false
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)

			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false

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

			self.RBDefTier1 = true
			self.RBDefTier2 = true
			self.RBDefTier3 = true

        elseif enh == 'EXL3LambdaRemove' then
			self.WeaponCheckAA01 = false
			self:SetWeaponEnabledByLabel('EXAA01', false)
			self:SetWeaponEnabledByLabel('EXAA02', false)

			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.RBDefTier1 = false
			self.RBDefTier2 = false
			self.RBDefTier3 = false

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

			self.RBIntTier1 = true
			self.RBIntTier2 = false
			self.RBIntTier3 = false

        elseif enh == 'EXElectronicsEnhancmentRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)

			if table.getn({self.lambdaEmitterTable}) > 0 then
				for k, v in self.lambdaEmitterTable do 
					IssueClearCommands({self.lambdaEmitterTable[k]}) 
					IssueKillSelf({self.lambdaEmitterTable[k]})
				end
			end
			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false

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

			self.wcAA01 = true
			self.wcAA02 = true
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = false

        elseif enh == 'EXElectronicCountermeasuresRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
			
            local bpIntel = self:GetBlueprint().Intel
			
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)

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

        elseif enh == 'EXCloakingSubsystems' then
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
			
            self.StealthEnh = false
			self.CloakEnh = true 
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('Cloak')

			self.RBIntTier1 = true
			self.RBIntTier2 = true
			self.RBIntTier3 = true

        elseif enh == 'EXCloakingSubsystemsRemove' then
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')
            self.CloakEnh = false 
			
            self:RemoveCommandCap('RULEUCC_Teleport')
			
            local bpIntel = self:GetBlueprint().Intel
			
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)

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

        elseif enh =='EXBasicDefence' then
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
			
			self.RBComTier1 = true
			self.RBComTier2 = false
			self.RBComTier3 = false

        elseif enh =='EXBasicDefenceRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost19' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost19' )
            end

			local wepOC = self:GetWeaponByLabel('OverCharge')
            local bpDisruptOCRadius = self:GetBlueprint().Weapon[2].MaxRadius
            wepOC:ChangeMaxRadius(bpDisruptOCRadius or 22)
			
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false

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

			wepOC:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
			
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = true

        elseif enh == 'EXOverchargeOverdriveRemove' then
            if Buff.HasBuff( self, 'EXSeraHealthBoost19' ) then
                Buff.RemoveBuff( self, 'EXSeraHealthBoost19' )
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

			wepOC:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
			
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
				    'Body',
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
				    'Body',
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
    },
	
    OnIntelEnabled = function(self)
		
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then 
			
			if self.IntelEffectsBag then
				EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
				self.IntelEffectsBag = nil
			end
		
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
		
        SWalkingLandUnit.OnIntelEnabled(self)
    end,

    OnIntelDisabled = function(self)
		
        if self.IntelEffectsBag then
            EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
            self.IntelEffectsBag = nil
        end
		
        if self.CloakEnh and not self:IsIntelEnabled('Cloak') then

            self:SetMaintenanceConsumptionInactive()
			
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') and not self:IsIntelEnabled('SonarStealth') then
		
            self:SetMaintenanceConsumptionInactive()
        end
	
        SWalkingLandUnit.OnIntelDisabled(self)		
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
	
		if self.CloakEnh then

			if self.EXMoving then
				self:DisableUnitIntel('Cloak')
				self:DisableUnitIntel('RadarStealth')
				self:DisableUnitIntel('SonarStealth')
			else
				self:EnableUnitIntel('RadarStealth')
				self:EnableUnitIntel('SonarStealth')
				self:EnableUnitIntel('Cloak')
			end
		end
		

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

TypeClass = ESL0001