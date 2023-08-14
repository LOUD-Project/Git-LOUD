---  /lua/sim/DefaultWeapons.lua
---  Default definitions of weapons

local Weapon = import('/lua/sim/Weapon.lua').Weapon

local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local CalculateBallisticAcceleration = import('/lua/sim/CalcBallisticAcceleration.lua').CalculateBallisticAcceleration 

local LOUDABS = math.abs
local LOUDGETN = table.getn
local LOUDMAX = math.max
local LOUDINSERT = table.insert

local CreateAnimator = CreateAnimator
local LOUDATTACHEMITTER = CreateAttachedEmitter

local LOUDSTATE = ChangeState
local ForkThread = ForkThread
local KillThread = KillThread
local WaitSeconds = WaitSeconds
local WaitTicks = coroutine.yield
local DamageArea = DamageArea

local BeenDestroyed = moho.entity_methods.BeenDestroyed

local ChangeDetonateAboveHeight = moho.projectile_methods.ChangeDetonateAboveHeight
local CreateEconomyEvent = CreateEconomyEvent
local CreateProjectile = moho.weapon_methods.CreateProjectile

local GetAIBrain = moho.entity_methods.GetAIBrain
local GetBlueprint = moho.weapon_methods.GetBlueprint
local GetCurrentTargetPos = moho.weapon_methods.GetCurrentTargetPos
local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome
local GetEconomyStored = moho.aibrain_methods.GetEconomyStored

local HideBone = moho.unit_methods.HideBone

local PlayAnim = moho.AnimationManipulator.PlayAnim
local PlaySound = moho.weapon_methods.PlaySound

local RemoveEconomyEvent = RemoveEconomyEvent

local ScaleEmitter = moho.IEffect.ScaleEmitter
local SetBusy = moho.unit_methods.SetBusy
local SetFiringRandomness = moho.weapon_methods.SetFiringRandomness
local SetPrecedence = moho.manipulator_methods.SetPrecedence

local TrashAdd = TrashBag.Add

local WeaponHasTarget = moho.weapon_methods.WeaponHasTarget


DefaultProjectileWeapon = Class(Weapon) {		

    FxRackChargeMuzzleFlash = {},
    FxRackChargeMuzzleFlashScale = 1,
    FxChargeMuzzleFlash = {},
    FxChargeMuzzleFlashScale = 1,
	
    FxMuzzleFlash = {
		'/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
    },
	
    FxMuzzleFlashScale = 1,    

    OnCreate = function(self)
	
        Weapon.OnCreate(self)

        self.WeaponCanFire = true
        self.CurrentRackSalvoNumber = 1
        
        local bp = self.bp
		
        if bp.RackRecoilDistance and bp.RackRecoilDistance != 0 then
		
			if bp.MuzzleSalvoDelay != 0 then
				local strg = '*ERROR: You can not have a RackRecoilDistance with a MuzzleSalvoDelay not equal to 0, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit.BlueprintID
				error(strg, 2)
				return false
			end
		
            self.RecoilManipulators = {}
			
            local dist = bp.RackRecoilDistance or 1
			
            if bp.RackBones[1].TelescopeRecoilDistance then
			
                local tpDist = bp.RackBones[1].TelescopeRecoilDistance or 0

                if LOUDABS(tpDist) > LOUDABS(dist) then
				
                    dist = tpDist
                end
            end
			
            self.RackRecoilReturnSpeed = bp.RackRecoilReturnSpeed or LOUDABS( dist / (( 1 / bp.RateOfFire ) - (bp.MuzzleChargeDelay or 0))) * 1.25
        end
		
        local NumMuzzles = 0
		
        for _, rv in bp.RackBones do
            NumMuzzles = NumMuzzles + LOUDGETN(rv.MuzzleBones or 0)
        end
		
        NumMuzzles = NumMuzzles / LOUDGETN(bp.RackBones)

--[[		
		if bp.MuzzleSalvoDelay != nil then
		
			local totalMuzzleFiringTime = ((NumMuzzles - 1) * bp.MuzzleSalvoDelay)
		
			if totalMuzzleFiringTime > (1 / bp.RateOfFire) and not bp.EnergyDrainPerSecond then
			
				local strg = '*ERROR: The total time to fire ('..totalMuzzleFiringTime..') '..NumMuzzles..' muzzles is longer than the RateOfFire '..bp.RateOfFire..' allows, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit.BlueprintID
				error(strg, 2)
				return false
				
			end

		else
			--LOG("*AI DEBUG value is "..repr(bp.MuzzleSalvoDelay).." for "..repr(bp).." on unit "..self.BlueprintID)
		end
--]]
		
        if bp.EnergyChargeForFirstShot == false then
            self.FirstShot = true
        end
		
        if bp.RenderFireClock then
            self.unit:SetWorkProgress(1)
        end
		
        if bp.FixBombTrajectory then
            self.CBFP_CalcBallAcc = { Do = true, ProjectilesPerOnFire = (bp.ProjectilesPerOnFire or 1), }
        end
		
        LOUDSTATE(self, self.IdleState)
	end,
	
    CheckBallisticAcceleration = function(self, proj)
	
        local acc = CalculateBallisticAcceleration( self, proj, self.CBFP_CalcBallAcc.ProjectilesPerOnFire )

        proj:SetBallisticAcceleration( -acc) #-- change projectile trajectory so it hits the target, cure for engine bug

    end,

	-- modded this so only retrieve bp if old or new is 'stopped'
    OnMotionHorzEventChange = function(self, new, old)
		
		if old == 'Stopped' then

			if self.bp.WeaponUnpackLocksMotion == true then
				self:PackAndMove()
			end
		
            if self.bp.FiringRandomnessWhileMoving then
                SetFiringRandomness( self, bp.FiringRandomnessWhileMoving )
            end
			
        elseif new == 'Stopped' then

			if self.bp.FiringRandomnessWhileMoving then
				SetFiringRandomness( self, bp.FiringRandomness or 0 )
			end
        end
    end,

    CreateProjectileAtMuzzle = function(self, muzzle)

        local proj = self:CreateProjectileForWeapon(muzzle)
        local bp = self.bp
		
        if not proj or BeenDestroyed( proj )then
            return proj
        end
		
        if bp.DetonatesAtTargetHeight == true then
		
            local pos = GetCurrentTargetPos(self)
			
            if pos then
            
                local theight = GetSurfaceHeight(pos[1], pos[3])
                local hght = pos[2] - theight
                
                ChangeDetonateAboveHeight( proj, hght )
            end
        end
		
        if bp.Flare then
            proj:AddFlare(bp.Flare)
        end
		
        if self.unit.CacheLayer == 'Water' and bp.Audio.FireUnderWater then
        
            PlaySound( self, bp.Audio.FireUnderWater )
            
        elseif bp.Audio.Fire then
        
            PlaySound( self, bp.Audio.Fire)
        end
		
		if self.CBFP_CalcBallAcc then
			self:CheckBallisticAcceleration(proj)
		end
		
		if bp.CountedProjectile then
			self:CheckCountedMissileLaunch()
		end

        return proj
    end,
	
	-- passed in the bp data to avoid the call
    CheckCountedMissileLaunch = function(self)

        if self.bp.NukeWeapon then
            self.unit:OnCountedMissileLaunch('nuke')
        else
            self.unit:OnCountedMissileLaunch('tactical')
        end
    end,

	-- passed in the bp data to save the call
    StartEconomyDrain = function(self)

        if self.FirstShot then return end
		
        local bp = self.bp
		
        if not self.EconDrain and bp.EnergyRequired and bp.EnergyDrainPerSecond then
		
			local function ChargeProgress( self, progress)
				moho.unit_methods.SetWorkProgress( self, progress )
			end
		
            local nrgReq = self:GetWeaponEnergyRequired(bp)
            local nrgDrain = self:GetWeaponEnergyDrain(bp)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG StartEconomyDrain "..repr(self.bp.Label).." -- "..nrgReq)
            end
            
            if nrgReq > 0 and nrgDrain > 0 then
			
                local time = nrgReq / nrgDrain
				
                if time < 0.1 then
                    time = 0.1
                end

                self.EconDrain = CreateEconomyEvent( self.unit, nrgReq, 0, time, ChargeProgress )
                self.FirstShot = true
            end
        end
    end,

    -- adjacency affects the energy cost required, not the drain. So, drain will be about the same
    -- but the time it takes to drain will not be.
    GetWeaponEnergyRequired = function(self, bp)
	
        local weapNRG = (self.bp.EnergyRequired or 0) * (self.AdjEnergyMod or 1)

        return LOUDMAX( 0, weapNRG )
    end,

    GetWeaponEnergyDrain = function(self, bp)

        return self.bp.EnergyDrainPerSecond or 0
    end,

    -- Effect functions: Not only visual effects but also plays animations, recoil, etc.

    -- Played when a muzzle is fired.  Mostly used for muzzle flashes
    PlayFxMuzzleSequence = function(self, muzzle)
	
        local unit = self.unit
        local army = unit.Army

        local emit
		
        for _, v in self.FxMuzzleFlash do
            emit = LOUDATTACHEMITTER( unit, muzzle, army, v)
            
            if self.FxMuzzleFlashScale != 1 then
                ScaleEmitter( emit, self.FxMuzzleFlashScale )
            end
        end
    end,

    -- Played during the beginning of the MuzzleChargeDelay time when a muzzle in a rack is fired.
    PlayFxMuzzleChargeSequence = function(self, muzzle)
	
        local unit = self.unit
        local army = unit.Army

        local emit
        
        for _, v in self.FxChargeMuzzleFlash do
        
            emit = LOUDATTACHEMITTER( unit, muzzle, army, v)
            
            if self.FxChargeMuzzleFlashScale != 1 then
                ScaleEmitter( emit, self.FxChargeMuzzleFlashScale )
            end
        end
    end,    

    -- Played when a rack salvo charges.  Do not put a wait in here or you'll
    -- make the time value in the bp off.  Spawn another thread to do waits.
    PlayFxRackSalvoChargeSequence = function(self, blueprint)
	
        local bp = self.bp
        local unit = self.unit
        local army = unit.Army
        
        local emit
		
        for _, v in self.FxRackChargeMuzzleFlash do
		
            for _, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
			
                emit = LOUDATTACHEMITTER( unit, ev, army, v)
                
                if self.FxRackChargeMuzzleFlashScale != 1 then
                    ScaleEmitter( emit, self.FxRackChargeMuzzleFlashScale)
                end
            end
        end
		
        if bp.Audio.ChargeStart then
		
            PlaySound( self, bp.Audio.ChargeStart)
        end
		
        if bp.AnimationCharge and not self.Animator then
        
            self.rackchargetime = GetGameTimeSeconds()
		
            self.Animator = CreateAnimator(unit)
            
            PlayAnim( self.Animator, bp.AnimationCharge ):SetRate( bp.AnimationChargeRate or 1 )
            
            WaitFor(self.Animator)
            
            self.rackchargetime = GetGameTimeSeconds() - self.rackchargetime
        end
        
    end,

    -- Played when a rack salvo reloads.  Do not put a wait in here or you'll
    -- make the time value in the bp off.  Spawn another thread to do waits.
    PlayFxRackSalvoReloadSequence = function(self, blueprint)
    
        self.reloadtime = GetGameTimeSeconds()

        self.Animator = CreateAnimator(self.unit)
        
		PlayAnim( self.Animator, self.bp.AnimationReload):SetRate( self.bp.AnimationReloadRate or 1)
        
        WaitFor(self.Animator)
        
        self.reloadtime = GetGameTimeSeconds() - self.reloadtime
		
    end,

    -- Played when a rack reloads. Mostly used for Recoil.
    PlayFxRackReloadSequence = function(self, blueprint)
	
        local bp = self.bp
		
        if bp.CameraShakeRadius and bp.CameraShakeMax and bp.CameraShakeMin and bp.CameraShakeDuration and
		   bp.CameraShakeRadius > 0 and bp.CameraShakeMax > 0 and bp.CameraShakeMin >= 0 and bp.CameraShakeDuration > 0 then
			
            self.unit:ShakeCamera(bp.CameraShakeRadius, bp.CameraShakeMax, bp.CameraShakeMin, bp.CameraShakeDuration)
        end
		
        if bp.ShipRock == true then
		
            local ix,iy,iz = self.unit:GetBoneDirection(bp.RackBones[self.CurrentRackSalvoNumber].RackBone)
			
            self.unit:RecoilImpulse(-ix,-iy,-iz)
        end
		
        if bp.RackRecoilDistance and bp.RackRecoilDistance != 0 then
            self:PlayRackRecoil({bp.RackBones[self.CurrentRackSalvoNumber]}, bp)
        end
    end,

    -- Played when a weapon unpacks. 
    PlayFxWeaponUnpackSequence = function(self)
	
        local bp = self.bp
        
        local unitBP = __blueprints[self.unit.BlueprintID].Audio
        
        self.repacktime = 0

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon Unpack Sequence "..repr(self.bp.Label) )
        end

        if unitBP.Activate then
            PlaySound( self, unitBP.Activate)
        end

        if unitBP.Open then
            PlaySound( self, unitBP.Open)
        end
        
        if bp.Audio.Unpack then
            PlaySound( self, bp.Audio.Unpack)
        end
        
        if bp.WeaponUnpackAnimation and not self.UnpackAnimator then
        
            self.repacktime = GetGameTimeSeconds()
        
            self.UnpackAnimator = CreateAnimator(self.unit)
            
            PlayAnim( self.UnpackAnimator, bp.WeaponUnpackAnimation ):SetRate(0)
            
            SetPrecedence( self.UnpackAnimator, bp.WeaponUnpackAnimatorPrecedence or 0)
            
            TrashAdd( self.unit.Trash, self.UnpackAnimator )
        end
        
        if self.UnpackAnimator then

            self.UnpackAnimator:SetRate(bp.WeaponUnpackAnimationRate)
            
            WaitFor(self.UnpackAnimator)
            
            self.repacktime = GetGameTimeSeconds() - self.repacktime

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Unpack Sequence ends "..repr(self.bp.Label).." after "..repr(self.repacktime).." seconds" )
            end

        end

    end,

    -- Played when a weapon packs up.  It has no target and is done with all of its rack salvos
    PlayFxWeaponPackSequence = function(self, blueprint)
	
        local bp = self.bp
        
        local unitBP = __blueprints[self.unit.BlueprintID].Audio
        
        self.repacktime = 0

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon Pack Sequence "..repr(self.bp.Label) )
        end
		
        if unitBP.Close then
            PlaySound( self, unitBP.Close)
        end
        
        if bp.WeaponUnpackAnimation and self.UnpackAnimator then
        
            self.UnpackAnimator:SetRate(-bp.WeaponUnpackAnimationRate)
        end
        
        if self.UnpackAnimator then
        
            self.repacktime = GetGameTimeSeconds()

            WaitFor(self.UnpackAnimator)
            
            self.repacktime = GetGameTimeSeconds() - self.repacktime

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Pack Sequence ends "..repr(self.bp.Label).." after "..repr(self.repacktime).." seconds" )
            end

        end

    end,

    PlayRackRecoil = function(self, rackList, blueprint)
    
        local CreateSlider = CreateSlider
        local LOUDINSERT = LOUDINSERT
        local SetPrecedence = SetPrecedence
        local TrashAdd = TrashAdd
        
        local SetGoal = moho.SlideManipulator.SetGoal
        local SetSpeed = moho.SlideManipulator.SetSpeed
        
        local unit = self.unit
        local RackRecoilDistance = self.bp.RackRecoilDistance
        
        local tmpSldr
        
        for _, v in rackList do
		
            tmpSldr = CreateSlider( unit, v.RackBone)
			
            LOUDINSERT( self.RecoilManipulators, tmpSldr)
			
            SetPrecedence( tmpSldr, 11 )
            SetGoal( tmpSldr, 0, 0, RackRecoilDistance )
            SetSpeed( tmpSldr, -1 )
			
            TrashAdd( unit.Trash, tmpSldr )
			
            if v.TelescopeBone then
            
                tmpSldr = CreateSlider( unit, v.TelescopeBone)
                
                LOUDINSERT( self.RecoilManipulators, tmpSldr)
                
                SetPrecedence( tmpSldr, 11 )
                SetGoal( tmpSldr, 0, 0, v.TelescopeRecoilDistance or RackRecoilDistance)
                SetSpeed( tmpSldr, -1)
                
                TrashAdd( unit.Trash, tmpSldr )
            end
        end
        
        self:ForkThread( self.PlayRackRecoilReturn, rackList)
    end,

    PlayRackRecoilReturn = function(self, rackList)
	
        WaitTicks(1)
        
        local SetGoal = moho.SlideManipulator.SetGoal
        local SetSpeed = moho.SlideManipulator.SetSpeed
		
        for _, v in rackList do
        
            for _, mv in self.RecoilManipulators do
                SetGoal( mv, 0, 0, 0)
                SetSpeed( mv, self.RackRecoilReturnSpeed)
            end
        end
    end,

    WaitForAndDestroyManips = function(self)
	
        local manips = self.RecoilManipulators
		
        if manips then
            for _, v in manips do
                WaitFor(v)
            end
            self:DestroyRecoilManips()
        end
		
        if self.Animator then
            WaitFor(self.Animator)
            self.Animator:Destroy()
            self.Animator = nil
        end
    end,

    DestroyRecoilManips = function(self)
	
        local manips = self.RecoilManipulators
		
        if manips then
            for _, v in manips do
                v:Destroy()
            end
            self.RecoilManipulators = {}
        end
    end,

    -- General State-less event handling
    OnLostTarget = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon OnLostTarget for "..repr(self.bp.Label))
        end

        Weapon.OnLostTarget(self)
		
        local bp = self.bp
		
        if bp.WeaponUnpacks == true then
            LOUDSTATE(self, self.WeaponPackingState)
        else
            LOUDSTATE(self, self.IdleState)
        end
    end,

    OnDestroy = function(self)
        LOUDSTATE(self, self.DeadState)
        Weapon.OnDestroy(self)
    end,

    OnEnterState = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon Entering new state "..repr(self.bp.Label))
        end
    
        if self.WeaponWantEnabled and not self.WeaponIsEnabled then
		
            self.WeaponIsEnabled = true
            self:SetWeaponEnabled(true)

            --if ScenarioInfo.WeaponStateDialog then
              --  LOG("*AI DEBUG DefaultWeapon WeaponEnabled "..repr(self.bp.Label))
            --end
			
        elseif not self.WeaponWantEnabled and self.WeaponIsEnabled then
			
            if self.bp.CountedProjectile != true then
                self.WeaponIsEnabled = false
                self:SetWeaponEnabled(false)

                --if ScenarioInfo.WeaponStateDialog then
                  --  LOG("*AI DEBUG DefaultWeapon WeaponDisabled "..repr(self.bp.Label))
                --end

            end
        end
		
        if self.WeaponAimWantEnabled and not self.WeaponAimIsEnabled then
		
            self.WeaponAimIsEnabled = true
            self:AimManipulatorSetEnabled(true)

            --if ScenarioInfo.WeaponStateDialog then
              --  LOG("*AI DEBUG DefaultWeapon Aim Enabled "..repr(self.bp.Label))
            --end
			
        elseif not self.WeaponAimWantEnabled and self.WeaponAimIsEnabled then
		
            self.WeaponAimIsEnabled = false
            self:AimManipulatorSetEnabled(false)

            --if ScenarioInfo.WeaponStateDialog then
              --  LOG("*AI DEBUG DefaultWeapon Aim Disabled "..repr(self.bp.Label))
            --end
            
        end
    end,

    PackAndMove = function(self)
	
        LOUDSTATE(self, self.WeaponPackingState)
		
    end,

    CanWeaponFire = function(self)
	
        if self.WeaponCanFire then
		
            return self.WeaponCanFire
        else
		
            return true
        end
		
    end,

    OnWeaponFired = function(self)
     
        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon OnWeaponFired "..repr(self.bp.Label).." at "..repr(GetGameTimeSeconds()) )
        end
        
		Weapon.OnWeaponFired(self)
    end,

    OnDisableWeapon = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon OnDisableWeapon "..repr(self.bp.Label) )
        end
        
        if self.EconDrain then 
            RemoveEconomyEvent( self, self.EconDrain)
        end

        Weapon.OnDisableWeapon(self)
    end, 
    
    OnEnableWeapon = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon OnEnableWeapon "..repr(self.bp.Label) )
        end

    end,


    -- WEAPON STATES:

    -- A Weapon is idle state when it has no target
	-- also note that a weapon is created BEFORE the actual unit is completed - so you'll see
	-- any first shot charging take place before the unit is finished - that's ok.
    IdleState = State {
	
		WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
        
            local unit = self.unit

            if unit.Dead then return end
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon IdleState "..repr(self.bp.Label).." - SetBusy to false" )
            end
            
            SetBusy( unit, false )
            
            self:WaitForAndDestroyManips()
            
            local bp = self.bp
			
            for _, v in bp.RackBones do
			
                if v.HideMuzzle == true then
				
                    for _, mv in v.MuzzleBones do
                        unit:ShowBone( mv, true )
                    end
                end
            end

			if bp.EnergyRequired and bp.EnergyDrainPerSecond then
                self:ForkThread( self.StartEconomyDrain )
			end
            
			-- NOTE: This is setup so that it only works if there is more than 1 rack
            -- intended to force the reload rack process after a firing sequence
            if LOUDGETN(bp.RackBones) > 1 and self.CurrentRackSalvoNumber > 1 then
 
                LOUDSTATE(self, self.RackSalvoReloadState)
--[[ 
                self.reloadtime = 0
                
                if bp.AnimationReload and not self.Animator then
                
                    self:PlayFxRackSalvoReloadSequence(bp)
                end

                WaitSeconds( bp.RackReloadTimeout - self.reloadtime )
                
                self.CurrentRackSalvoNumber = 1
--]]
            end
			
        end,

        OnGotTarget = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon IdleState OnGotTarget "..repr(self.bp.Label) )
            end
            
            local bp = self.bp
	
            if (bp.WeaponUnpackLocksMotion != true or (bp.WeaponUnpackLocksMotion == true and not self.unit:IsUnitState('Moving'))) then
			
                if bp.CountedProjectile == true and not self:CanWeaponFire() then
				
                    return
					
                end
				
                if bp.WeaponUnpacks == true then
				
                    LOUDSTATE(self, self.WeaponUnpackingState)
					
                else
				
                    if bp.RackSalvoChargeTime and bp.RackSalvoChargeTime > 0 then
					
                        LOUDSTATE(self, self.RackSalvoChargeState)
						
                    else
					
                        LOUDSTATE(self, self.RackSalvoFireReadyState)
						
                    end
					
                end
				
            end
			
        end,

        OnFire = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon IdleState OnFire "..repr(self.bp.Label) )
            end
            
            local bp = self.bp
			
            if bp.WeaponUnpacks == true then
			
                LOUDSTATE(self, self.WeaponUnpackingState)
				
            else
			
                if bp.RackSalvoChargeTime and bp.RackSalvoChargeTime > 0 then
				
                    LOUDSTATE(self, self.RackSalvoChargeState)
					
                elseif bp.SkipReadyState and bp.SkipReadyState == true then
				
                    LOUDSTATE(self, self.RackSalvoFiringState)
					
                else
				
                    LOUDSTATE(self, self.RackSalvoFireReadyState)
					
                end
				
            end
			
        end,
    },
	
    WeaponUnpackingState = State {

        WeaponWantEnabled = false,
        WeaponAimWantEnabled = false,

        Main = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Unpacking State "..repr(self.bp.Label).." - SetBusy to true" )
            end
            
            local unit = self.unit
            
            SetBusy( unit, true )

            local bp = self.bp
            
            if bp.WeaponUnpackLocksMotion then
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon Unpacking State "..repr(self.bp.Label).." - Set Immobile" )
                end
 			
                unit:SetImmobile(true)
				
            end
            
            self:PlayFxWeaponUnpackSequence(bp)
            
			if self.bp.WeaponRepackTimeout then
            
                if ScenarioInfo.WeaponStateDialog then

                    LOG("*AI DEBUG DefaultWeapon Unpacking State "..repr(self.bp.Label).." waiting "..repr(self.bp.WeaponRepackTimeout - self.repacktime).." seconds" )

                end

				WaitSeconds( self.bp.WeaponRepackTimeout - self.repacktime )
			end

            local rackSalvoChargeTime = bp.RackSalvoChargeTime
            
            if rackSalvoChargeTime and rackSalvoChargeTime > 0 then
			
                LOUDSTATE(self, self.RackSalvoChargeState)
				
            else
			
                LOUDSTATE(self, self.RackSalvoFireReadyState)
				
            end
        end,

        OnFire = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Unpacking State OnFire "..repr(self.bp.Label) )
            end
        end,
    },
	
    RackSalvoChargeState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Charge State "..repr(self.bp.Label).." - SetBusy to true" )
			end
            
            local unit = self.unit
            
            SetBusy( unit, true )
			
            local bp = self.bp
            
            self.rackchargetime = 0
			
            self:PlayFxRackSalvoChargeSequence(bp)
			
            if bp.NotExclusive then
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Charge for "..repr(self.bp.Label).." - SetBusy to false" )
                end

                SetBusy( unit, false )
            end
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Charge for "..repr(self.bp.Label).." waiting "..repr(bp.RackSalvoChargeTime - self.rackchargetime).." seconds" )
            end
            
            WaitSeconds( bp.RackSalvoChargeTime - self.rackchargetime)
            
            if bp.NotExclusive then
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Charge for "..repr(self.bp.Label).." - SetBusy to true" )
                end
                
                SetBusy( unit, true )
            end
            
            if bp.RackSalvoFiresAfterCharge == true then
			
                LOUDSTATE(self, self.RackSalvoFiringState)
				
            else
			
                LOUDSTATE(self, self.RackSalvoFireReadyState)
				
            end
			
        end,

        OnFire = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Charge OnFire "..repr(self.bp.Label) )
            end
            
        end,
    },

    RackSalvoFireReadyState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Fire Ready State "..repr(self.bp.Label) )
            end
            
            local unit = self.unit
            
            if (self.bp.CountedProjectile == true and self.bp.WeaponUnpacks == true) then
			
                SetBusy( unit, true )
            else
			
                SetBusy( unit, false)
            end
			
            self.WeaponCanFire = false
			
            if self.EconDrain then

                WaitFor(self.EconDrain)
				
                RemoveEconomyEvent( unit, self.EconDrain )
				
                self.EconDrain = nil
            end
			
            self.WeaponCanFire = true

            --We change the state on counted projectiles because we won't get another OnFire call.
            --The second part is a hack for units with reload animations.  They have the same problem
            --they need a RackSalvoReloadTime that's 1/RateOfFire set to avoid firing twice on the first shot
            if self.bp.CountedProjectile == true or self.bp.AnimationReload then
			
                LOUDSTATE(self, self.RackSalvoFiringState)
            end
        end,

		-- while debugging the WeaponUnpackLocksMotion I discovered that if you have the value NeedsUnpack = true in the AI section
		-- then the weapon will Never do an OnFire() event unless the unit is set to IMMOBILE
        OnFire = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Fire Ready OnFire "..repr(self.bp.Label) )
			end
            
            if self.WeaponCanFire then
                LOUDSTATE(self, self.RackSalvoFiringState)
            end
			
        end,
    },

    RackSalvoFiringState = State {
	
        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State for "..repr(self.bp.Label).." - rack "..repr(self.CurrentRackSalvoNumber) )
			end
            
            local bp = self.bp
            local unit = self.unit
            
            local NotExclusive = bp.NotExclusive
			
            -- ok -- with multiple weaponed units - this is the command that halts other weapons from firing
            -- when Exclusive, all other weapons will 'pause' until this function completes
            SetBusy( unit, (not NotExclusive or false) )
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State for "..repr(self.bp.Label).." - SetBusy is "..repr(not NotExclusive or false) )
            end
            
			if self.RecoilManipulators then
				self:DestroyRecoilManips()
			end
			
            local numRackFiring = self.CurrentRackSalvoNumber
		
			local RacksToBeFired = LOUDGETN(bp.RackBones)
			
            if bp.RackFireTogether == true then
                numRackFiring = RacksToBeFired
            end	
			
            -- this used to be placed AFTER the firing events 
            if bp.RenderFireClock and bp.RateOfFire > 0 then
			
	            if not unit.Dead then
				
                    local rof = 1 / bp.RateOfFire                

                    self:ForkThread(self.RenderClockThread, rof)                
                end
            end

            self:OnWeaponFired()
            
            local rackInfo, MuzzlesToBeFired, numMuzzlesFiring, muzzleIndex, muzzle
            
            local HideBone = HideBone
            local LOUDGETN = LOUDGETN
            local PlaySound = PlaySound
            local SetBusy = SetBusy
           	local ShowBone = moho.unit_methods.ShowBone
            local WaitSeconds = WaitSeconds

            -- Most of the time this will only run once per rack, the only time it doesn't is when racks fire together.
            while self.CurrentRackSalvoNumber <= numRackFiring and not self.HaltFireOrdered do
			
                rackInfo = bp.RackBones[self.CurrentRackSalvoNumber]

				MuzzlesToBeFired = LOUDGETN(bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones)
                numMuzzlesFiring = bp.MuzzleSalvoSize or 1

                -- this is a highly questionable statement since it always overrides the MuzzleSalvoSize
                -- IF the number of muzzles is different and the MuzzleSalvoDelay is zero
                if bp.MuzzleSalvoDelay == 0 then
                    numMuzzlesFiring = MuzzlesToBeFired
                end

                muzzleIndex = 1

				-- fire all the muzzles --
                for i = 1, numMuzzlesFiring do

                    if self.HaltFireOrdered then
                        continue
                    end
					
                    muzzle = rackInfo.MuzzleBones[muzzleIndex]
					
                    if rackInfo.HideMuzzle == true then
                        ShowBone( unit, muzzle, true)
                    end
					
					-- muzzle charge delay -- 
                    if bp.MuzzleChargeDelay and bp.MuzzleChargeDelay > 0 then
					
                        if bp.Audio.MuzzleChargeStart then
                            PlaySound( self, bp.Audio.MuzzleChargeStart)
                        end
						
                        self:PlayFxMuzzleChargeSequence(muzzle)
						
                        if NotExclusive then

                            if ScenarioInfo.WeaponStateDialog then
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing (MuzzleChargeDelay) for "..repr(self.bp.Label).." - SetBusy to false" )
                            end

                            SetBusy( unit, false )
                        end
            
                        if ScenarioInfo.WeaponStateDialog then
                            LOG("*AI DEBUG DefaultWeapon Muzzle Charge Delay waiting "..repr(bp.MuzzleChargeDelay).." seconds" )
                        end
						
                        WaitSeconds(bp.MuzzleChargeDelay)

                    end
					
                    self:PlayFxMuzzleSequence(muzzle)                    
					
                    if rackInfo.HideMuzzle == true then
                        HideBone( unit, muzzle, true)
                    end
					
                    if self.HaltFireOrdered then
                        continue
                    end
                
                    self.FirstShot = false
                    
                    self:StartEconomyDrain() -- the recharge begins as soon as the weapon starts firing
					
					-- create the projectile --
                    self:CreateProjectileAtMuzzle(muzzle)

                    if bp.CountedProjectile == true then
					
                        if bp.NukeWeapon == true then
						
                            unit:NukeCreatedAtUnit()
                            unit:RemoveNukeSiloAmmo(1)
                        else
                            unit:RemoveTacticalSiloAmmo(1)
                        end
                    end
					
                    muzzleIndex = muzzleIndex + 1

					-- reset the muzzle index if fired all muzzles
                    if muzzleIndex > MuzzlesToBeFired then
                        muzzleIndex = 1
                    end
					
					-- muzzle salvo delay -- 
                    if bp.MuzzleSalvoDelay > 0 then
					
                        if NotExclusive then

                            if ScenarioInfo.WeaponStateDialog then
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing (MuzzleSalvoDelay) for "..repr(self.bp.Label).." - SetBusy to false" )
                            end

                            SetBusy( unit, false )
                        end
            
                        if ScenarioInfo.WeaponStateDialog then
                            LOG("*AI DEBUG DefaultWeapon Muzzle Salvo Delay waiting "..repr(bp.MuzzleSalvoDelay).." seconds" )
                        end
						
                        WaitSeconds(bp.MuzzleSalvoDelay)
						
                        if NotExclusive then

                            if ScenarioInfo.WeaponStateDialog then
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing (MuzzleSalvoDelay) for "..repr(self.bp.Label).." - SetBusy to true" )
                            end
                        
                            SetBusy( unit, true )
                        end
                    end
                end
                
                if bp.CameraShakeRadius or bp.ShipRock or bp.RackRecoilDistance != 0 then
                    self:PlayFxRackReloadSequence(bp)
                end
	     
                if self.EconDrain then
                    WaitFor(self.EconDrain)
                end
			
				-- advance the rack number --
                if self.CurrentRackSalvoNumber <= RacksToBeFired then
                    self.CurrentRackSalvoNumber = self.CurrentRackSalvoNumber + 1
                end
            end

			if bp.Buffs then
				self:DoOnFireBuffs(bp.Buffs)
			end

            self.HaltFireOrdered = false

			-- if all the racks have fired --
            if self.CurrentRackSalvoNumber > RacksToBeFired then
			
				-- reset the rack count - this is usually done
                -- in the IdleState --
                self.CurrentRackSalvoNumber = 1

                -- this takes precedence - delay for reloading the rack
                if bp.RackSalvoReloadTime > 0 or bp.AnimationReload then
				
                    LOUDSTATE(self, self.RackSalvoReloadState)
                    
                -- otherwise if there is a pre-firing chargeup delay
                elseif bp.RackSalvoChargeTime > 0 then
				
                    LOUDSTATE(self, self.IdleState)
				
                -- otherwise counted projectiles either pack up or go back to idle state
                elseif bp.CountedProjectile == true then
				
					if bp.WeaponUnpacks == true then
					
						LOUDSTATE(self, self.WeaponPackingState)
						
					else
					
						LOUDSTATE(self, self.IdleState)
						
					end
					
                -- anything else is just ready to fire again --
                else
				
                    LOUDSTATE(self, self.RackSalvoFireReadyState)
					
                end
				
            elseif bp.CountedProjectile == true then

				if not bp.WeaponUnpacks then
					LOUDSTATE(self, self.IdleState)
				else
					LOUDSTATE(self, self.WeaponPackingState)
				end
				
            else
			
                LOUDSTATE(self, self.RackSalvoFireReadyState)
				
            end
        end,
		
		OnFire = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State OnFire "..repr(self.bp.Label) )		
            end

		end,

        OnLostTarget = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State OnLostTarget "..repr(self.bp.Label) )		
            end

            Weapon.OnLostTarget(self)
			
            if self.bp.WeaponUnpacks == true then
			
                LOUDSTATE(self, self.WeaponPackingState)
            end
        end,

        -- Set a bool so we won't fire if the target reticle is moved
        OnHaltFire = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State OnHaltFire "..repr(self.bp.Label) )
			end
            
            self.HaltFireOrdered = true
        end,
		
        RenderClockThread = function(self, rof)
		
            local clockTime = rof
            local unit = self.unit
			local WaitTicks = WaitTicks
			
            while clockTime > 0.0 and not self:BeenDestroyed() and not unit.Dead do
                
                clockTime = clockTime - 0.1
                
                unit:SetWorkProgress( 1 - clockTime / rof )
                
                WaitTicks(1)
            end
        end,
    },

    RackSalvoReloadState = State {

        WeaponWantEnabled = false,
        WeaponAimWantEnabled = true,

        Main = function(self)

            local WeaponStateDialog = ScenarioInfo.WeaponStateDialog

            if WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(self.bp.Label).." - SetBusy to true" )		
            end
			
            local bp = self.bp
            local NotExclusive = bp.NotExclusive
            local unit = self.unit
            
            SetBusy( unit, true)
			
            if NotExclusive then

                if WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(self.bp.Label).." - SetBusy to false" )
                end

                SetBusy( unit, false )
            end
            
            self.reloadtime = 0
            
            if bp.AnimationReload and not self.Animator then

                if WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(self.bp.Label).." plays reload animation" )		
                end
            
                self:PlayFxRackSalvoReloadSequence(bp)

                if WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Reload animation "..repr(self.bp.Label).." takes "..repr(self.reloadtime).." seconds" )		
                end
                
            end
            
            if bp.RackSalvoReloadTime then
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State waits for "..repr(bp.RackSalvoReloadTime - self.reloadtime).." seconds" )
                end
            
                WaitSeconds( bp.RackSalvoReloadTime - self.reloadtime )
            end
			
            self:WaitForAndDestroyManips()
            
            if NotExclusive then
            
                if WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State for "..repr(self.bp.Label).." - SetBusy to true" )
                end

                SetBusy( unit, true )
            end

            if WeaponHasTarget( self ) and bp.RackSalvoChargeTime > 0 and self:CanWeaponFire() then
			
                LOUDSTATE(self, self.RackSalvoChargeState)
				
            elseif WeaponHasTarget( self ) and self:CanWeaponFire() then
			
				if not bp.ManualFire then
			
					LOUDSTATE(self, self.RackSalvoFireReadyState)
					
				else
				
					if bp.WeaponUnpacks == true then
						
						LOUDSTATE(self, self.WeaponPackingState)

					else
					
						LOUDSTATE(self, self.IdleState)
						
					end
				
				end
				
            elseif not WeaponHasTarget( self ) and bp.WeaponUnpacks == true and bp.WeaponUnpackLocksMotion != true then
			
                LOUDSTATE(self, self.WeaponPackingState)
				
            else
			
                LOUDSTATE(self, self.IdleState)
				
            end
			
        end,

        OnFire = function(self)

            if WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State OnFire "..repr(self.bp.Label) )
            end

        end,
    },

    WeaponPackingState = State {
	
        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon WeaponPacking State "..repr(self.bp.Label) )
			end
            
            SetBusy( self.unit, true )

			-- reset the rack count - this is usually done
            -- in the IdleState --
            self.CurrentRackSalvoNumber = 1

            self:AimManipulatorSetEnabled(false)
			
            self:PlayFxWeaponPackSequence(self.bp)

			if self.bp.WeaponRepackTimeout then
            
                if ScenarioInfo.WeaponStateDialog then

                    LOG("*AI DEBUG DefaultWeapon WeaponPacking State Timeout "..repr(self.bp.Label).." is "..repr(self.bp.WeaponRepackTimeout - self.repacktime) )

                end

				WaitSeconds( self.bp.WeaponRepackTimeout - self.repacktime )
			end
			
         
            if self.bp.WeaponUnpackLocksMotion then
                self.unit:SetImmobile(false)
            end
			
            LOUDSTATE(self, self.IdleState)
			
        end,

        OnGotTarget = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon WeaponPacking State OnGotTarget "..repr(self.bp.Label) )		
            end
            
            if not self.bp.ForceSingleFire then
			
                LOUDSTATE(self, self.WeaponUnpackingState)
				
            end
			
        end,

        -- Override so that it doesn't play the firing sound when
        -- we're not actually creating the projectile yet
        OnFire = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon WeaponPacking State OnFire")
            end
            
            if self.bp.CountedProjectile == true and not self.bp.ForceSingleFire then
			
                LOUDSTATE(self, self.WeaponUnpackingState)
				
            end
			
        end,

    },

    DeadState = State {

        OnEnterState = function(self)
        end,

        Main = function(self)
        end,
    },
	
}

KamikazeWeapon = Class(Weapon) {

    OnFire = function(self)

        DamageArea(self.unit, self.unit:GetPosition(), self.bp.DamageRadius, self.bp.Damage, self.bp.DamageType or 'Normal', self.bp.DamageFriendly or false)
        
        self.unit:Kill()
    end,
}

BareBonesWeapon = Class(Weapon) {
    Data = {},

    OnFire = function(self)

        local myProjectile = CreateProjectile( self.unit, self.bp.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
        
        if self.Data then
            myProjectile:PassData(self.Data)
        end
    end,
}

DefaultBeamWeapon = Class(DefaultProjectileWeapon) {

    BeamType = CollisionBeam,

    OnCreate = function(self)
		
        DefaultProjectileWeapon.OnCreate(self)	

        self.Beams = {}
        
        local counter = 1
		local beam
        local bp = self.bp

        for rk, rv in bp.RackBones do

            for mk, mv in rv.MuzzleBones do

                -- create the beam -- initially disabled
                beam = self.BeamType{ BeamBone = 0, CollisionCheckInterval = bp.BeamCollisionDelay * 10, OtherBone = mv, Weapon = self }
                -- store reference to the parent weapon
                beam.Weapon = self

                beam:Disable()

                if ScenarioInfo.WeaponDialog then
                    LOG("*AI DEBUG OnCreate Beam for weapon "..repr(beam.Weapon.bp.Label).." on muzzle "..repr(mv).." for unit "..repr(beam.Weapon.unit.BlueprintID))
                end

                -- add beam to the weapons trash table
                TrashAdd( self.Trash, beam)

                -- add a reference to the beam in the weapons Beams table
                self.Beams[counter] = { Beam = beam, Muzzle = mv }
                counter = counter + 1
            end

        end

    end,

    CreateProjectileAtMuzzle = function(self, muzzle)
	
		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG DefaultBeamWeapon CreateProjectileAtMuzzle For "..repr(self.bp.Label).." for "..repr(__blueprints[self.unit.BlueprintID].Description).." using muzzle "..repr(muzzle) )
		end
		
		local PlaySound = moho.weapon_methods.PlaySound
		
        local enabled = false
		
        for _, v in self.Beams do
            if v.Muzzle == muzzle and v.Beam:IsEnabled() then
                enabled = true
            end
        end
		
        if not enabled then
            self:PlayFxBeamStart(muzzle)
        end
        
        if self.unit.CacheLayer == 'Water' and self.bp.Audio.FireUnderWater then
        
            PlaySound( self, self.bp.Audio.FireUnderWater )
            
        elseif self.bp.Audio.Fire then
        
            PlaySound( self, self.bp.Audio.Fire)
            
        end
    end,

    PlayFxBeamStart = function(self, muzzle)

        local beam
		
        for _, v in self.Beams do
            if v.Muzzle == muzzle then
                beam = v.Beam
                break
            end
        end
		
        if beam:IsEnabled() then return end
	
        local bp = self.bp

        beam:Enable()
		
        TrashAdd( self.Trash, beam )
		
        if bp.BeamLifetime > 0 then
            self:ForkThread( self.BeamLifetimeThread, beam, bp.BeamLifetime or 1)
        end
		
        if bp.BeamLifetime == 0 then
            self.HoldFireThread = self:ForkThread(self.WatchForHoldFire, beam)
        end
		
        if bp.Audio.BeamStart then
            PlaySound( self, bp.Audio.BeamStart )
        end
		
        if bp.Audio.BeamLoop and self.Beams[1].Beam then
            self.Beams[1].Beam:SetAmbientSound(bp.Audio.BeamLoop, nil)
        end
		
        self.BeamStarted = true
    end,

    PlayFxWeaponUnpackSequence = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG Default BEAM Weapon Unpack Sequence "..repr(self.bp.Label) )
        end

        if ( self.bp.BeamLifetime > 0 ) or (( self.bp.BeamLifetime <= 0 ) and not self.ContBeamOn) then
        
            DefaultProjectileWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,

    IdleState = State (DefaultProjectileWeapon.IdleState) {
	
        Main = function(self)
        
            DefaultProjectileWeapon.IdleState.Main(self)
            
            self:PlayFxBeamEnd()
            
            self:ForkThread(self.ContinuousBeamFlagThread)
        end,
    },

    WeaponPackingState = State (DefaultProjectileWeapon.WeaponPackingState) {
	
        Main = function(self)

            if (self.bp.BeamLifetime > 0) then
                self:PlayFxBeamEnd()
            else
                self.ContBeamOn = true
            end
            
            DefaultProjectileWeapon.WeaponPackingState.Main(self)
        end,
    },

    PlayFxBeamEnd = function(self, beam)
	
        if not self.unit.Dead then

            if self.bp.Audio.BeamStop and self.BeamStarted then
                PlaySound( self, self.bp.Audio.BeamStop )
            end
			
            if self.bp.Audio.BeamLoop and self.Beams[1].Beam then
                self.Beams[1].Beam:SetAmbientSound(nil, nil)
            end
			
            if beam then
                beam:Disable()
            else
                for _, v in self.Beams do
                    v.Beam:Disable()
                end
            end
			
            self.BeamStarted = false
        end
		
        if self.HoldFireThread then
            KillThread(self.HoldFireThread)
        end
        
    end,

    ContinuousBeamFlagThread = function(self)
    
        WaitTicks(1)
        self.ContBeamOn = nil
    end,

    BeamLifetimeThread = function(self, beam, lifeTime)
    
        WaitTicks(lifeTime * 10)
        
		WaitTicks(1)
        
        self:PlayFxBeamEnd(beam)
    end,
    
    WatchForHoldFire = function(self, beam)
    
		WaitTicks = WaitTicks
        
        while true do
        
            WaitTicks(10)

            if self.unit and self.unit:GetFireState() == 1 then
                self.BeamStarted = false
                self:PlayFxBeamEnd(beam)
            end
        end
    end,
    
    StartEconomyDrain = function(self)

        if not self.EconDrain and self.bp.EnergyRequired and self.bp.EnergyDrainPerSecond then
        
            if not self:EconomySupportsBeam() then
                return
            end
        end
		
        DefaultProjectileWeapon.StartEconomyDrain(self)
    end,
    
    OnHaltFire = function(self)
    
        for _,v in self.Beams do

            if not v.Beam:IsEnabled() then
                continue
            end
            
            self:PlayFxBeamEnd( v.Beam )
        end
    end,
    
    EconomySupportsBeam = function(self)
    
        local aiBrain = GetAIBrain(self.unit)
        
        local energyIncome = GetEconomyIncome( aiBrain, 'ENERGY' ) * 10
        local energyStored = GetEconomyStored( aiBrain, 'ENERGY' )
        
        local nrgReq = self:GetWeaponEnergyRequired()
        local nrgDrain = self:GetWeaponEnergyDrain()

        if energyStored < nrgReq and energyIncome < nrgDrain then
            return false
        end
        
        return true    
    end,
    
    RackSalvoFireReadyState = State (DefaultProjectileWeapon.RackSalvoFireReadyState) {

        Main = function(self)
            if not self:EconomySupportsBeam() then
                self:PlayFxBeamEnd()
                LOUDSTATE(self, self.IdleState)
                return
            end
            DefaultProjectileWeapon.RackSalvoFireReadyState.Main(self)
        end,
    },
}

