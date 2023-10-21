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
local GetGameTick = GetGameTick
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

    FxRackChargeMuzzleFlash = false,
    FxRackChargeMuzzleFlashScale = 1,
    FxChargeMuzzleFlash = false,
    FxChargeMuzzleFlashScale = 1,
	
    FxMuzzleFlash = {
		'/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
    },
	
    FxMuzzleFlashScale = 1,    

    OnCreate = function(self)
	
        Weapon.OnCreate(self)

        self.WeaponCanFire = true
        self.CurrentRackNumber = 1
        
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

        if bp.EnergyChargeForFirstShot == false then
            self.FirstShot = true
        end
		
        if bp.RenderFireClock then
            self.unit:SetWorkProgress(1)
        end
		
        if bp.FixBombTrajectory then
            self.CBFP_CalcBallAcc = { Do = true, ProjectilesPerOnFire = (bp.ProjectilesPerOnFire or 1), }
        end

        if not bp.EnabledByEnhancement then
            LOUDSTATE(self, self.IdleState)
        else
            LOUDSTATE(self, self.DeadState)
        end
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
            
            if nrgReq > 0 and nrgDrain > 0 then

                local chargetime = (nrgReq / nrgDrain) * 1.0001
                
                if chargetime < 0.2 then
                    chargetime = 0.2
                end
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon Start Economy Drain for "..repr(self.bp.Label).." -- Required "..nrgReq.." -- Rate "..nrgDrain.." -- Time "..repr(chargetime).." at "..GetGameTick() )
                end

                self.EconDrain = CreateEconomyEvent( self.unit, nrgReq, 0, chargetime - 0.100, ChargeProgress )
                self.FirstShot = true   -- technically - this should be called WeaponCharged
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

    -- Played during the beginning of a MuzzleChargeDelay time when a muzzle in a rack is fired.
    PlayFxMuzzleChargeSequence = function(self, muzzle)
        
        if self.FxChargeMuzzleFlash then
	
            local unit = self.unit
            local army = unit.Army
            local emit
        
            for _, v in self.FxChargeMuzzleFlash do
        
                emit = LOUDATTACHEMITTER( unit, muzzle, army, v)
            
                if self.FxChargeMuzzleFlashScale != 1 then
                    ScaleEmitter( emit, self.FxChargeMuzzleFlashScale )
                end
            end
        end
    end,    

    -- Played when a rack charges (prior to firing).  If there is an animiation, the code will record the
    -- time taken to run it
    PlayFxRackSalvoChargeSequence = function(self, blueprint)
	
        local bp = blueprint or self.bp
        local unit = self.unit

        if self.FxRackChargeMuzzleFlash then

            local army = unit.Army
            local emit

            for _, v in self.FxRackChargeMuzzleFlash do
		
                for _, ev in bp.RackBones[self.CurrentRackNumber].MuzzleBones do
			
                    emit = LOUDATTACHEMITTER( unit, ev, army, v)
                
                    if self.FxRackChargeMuzzleFlashScale != 1 then
                        ScaleEmitter( emit, self.FxRackChargeMuzzleFlashScale)
                    end
                end
            end
        end
		
        if bp.Audio.ChargeStart then
            PlaySound( self, bp.Audio.ChargeStart)
        end
		
        if bp.AnimationCharge and not self.Animator then
        
            self.ElapsedRackChargeTime = GetGameTick()
		
            self.Animator = CreateAnimator(unit)
            
            PlayAnim( self.Animator, bp.AnimationCharge ):SetRate( bp.AnimationChargeRate or 1 )
            
            WaitFor(self.Animator)
            
            self.ElapsedRackChargeTime = GetGameTick() - self.ElapsedRackChargeTime
        end
        
    end,

    -- Played when a rack reloads (after firing).  
    PlayFxRackSalvoReloadSequence = function(self, blueprint)
    
        local bp = blueprint or self.bp

        -- play the reload animation and measure how long that takes --        
        if bp.AnimationReload and not self.Animator then

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." reload animation" )		
            end

            local seqtime = GetGameTick()

            self.Animator = CreateAnimator(self.unit)
        
            PlayAnim( self.Animator, bp.AnimationReload):SetRate( bp.AnimationReloadRate or 1)
        
            WaitFor(self.Animator)

            seqtime = GetGameTick() - seqtime

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." reload animation takes "..repr(seqtime).." ticks" )		
            end

            self.ElapsedRackReloadTime = seqtime + self.ElapsedRackReloadTime
        end
		
    end,

    -- Played when a rack reloads. Mostly used for Recoil.
    PlayFxRackReloadSequence = function(self, blueprint)
	
        local bp = self.bp
		
        if bp.CameraShakeRadius and bp.CameraShakeMax and bp.CameraShakeMin and bp.CameraShakeDuration and
		   bp.CameraShakeRadius > 0 and bp.CameraShakeMax > 0 and bp.CameraShakeMin >= 0 and bp.CameraShakeDuration > 0 then
			
            self.unit:ShakeCamera(bp.CameraShakeRadius, bp.CameraShakeMax, bp.CameraShakeMin, bp.CameraShakeDuration)
        end
		
        if bp.ShipRock == true then
		
            local ix,iy,iz = self.unit:GetBoneDirection(bp.RackBones[self.CurrentRackNumber].RackBone)
			
            self.unit:RecoilImpulse(-ix,-iy,-iz)
        end
		
        if bp.RackRecoilDistance and bp.RackRecoilDistance != 0 then
            self:PlayRackRecoil({bp.RackBones[self.CurrentRackNumber]}, bp)
        end
    end,

    -- Played when a weapon unpacks. If there is an animation, it will play it, and record the time taken
    -- to run it
    PlayFxWeaponUnpackSequence = function(self)
	
        local bp = self.bp
        
        local unitBP = __blueprints[self.unit.BlueprintID].Audio

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon Unpack Sequence "..repr(self.bp.Label).." at "..GetGameTick() )
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
        
        self.ElapsedRepackTime = 0
        
        if bp.WeaponUnpackAnimation and not self.UnpackAnimator then
        
            self.UnpackAnimator = CreateAnimator(self.unit)
            
            self.ElapsedRepackTime = GetGameTick()

            PlayAnim( self.UnpackAnimator, bp.WeaponUnpackAnimation ):SetRate(0)

            self.ElapsedRepackTime = GetGameTick() - self.ElapsedRepackTime            

            SetPrecedence( self.UnpackAnimator, bp.WeaponUnpackAnimatorPrecedence or 0)
            
            TrashAdd( self.unit.Trash, self.UnpackAnimator )
        end
        
        if self.UnpackAnimator then

            self.ElapsedRepackTime = GetGameTick() - self.ElapsedRepackTime

            self.UnpackAnimator:SetRate(bp.WeaponUnpackAnimationRate)
            
            WaitFor(self.UnpackAnimator)
            
            self.ElapsedRepackTime = GetGameTick() - self.ElapsedRepackTime

            if ScenarioInfo.WeaponStateDialog then
                if self.EconDrain then
                    LOG("*AI DEBUG DefaultWeapon Unpack Sequence ends "..repr(bp.Label).." at "..GetGameTick() )
                else
                    LOG("*AI DEBUG DefaultWeapon Unpack Sequence ends "..repr(bp.Label).." after "..self.ElapsedRepackTime.." ticks at "..GetGameTick() )
                end
            end
            
            if self.ElapsedRepackTime > 0 and ( not bp.WeaponRepackTimeout or (math.floor(bp.WeaponRepackTimeout*10) - self.ElapsedRepackTime < 0 )) then
                LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout -(".. (bp.WeaponRepackTimeout or 0) ..") during unpack - is either not existant or less than the WeaponUnpackAnimation - "..self.ElapsedRepackTime.." ticks. "..repr(self.unit.BlueprintID))
            end
            
			if bp.WeaponRepackTimeout and ( math.floor(bp.WeaponRepackTimeout*10) - self.ElapsedRepackTime) >= 1 then
            
                if ScenarioInfo.WeaponStateDialog then
                    if self.EconDrain then
                        LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout "..repr(bp.Label) )
                    else
                        LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout"..repr(bp.Label).." waits "..math.floor(bp.WeaponRepackTimeout*10) - self.ElapsedRepackTime.." ticks" )
                    end
                end

                WaitSeconds( bp.WeaponRepackTimeout - (self.ElapsedRepackTime/10) )
			end

        end

    end,

    -- Played when a weapon packs up.  It has no target and is done with all of its rack salvos
    PlayFxWeaponPackSequence = function(self, blueprint)
	
        local bp = self.bp
        
        local unitBP = __blueprints[self.unit.BlueprintID].Audio

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon Pack Sequence "..repr(bp.Label).." at "..GetGameTick() )
        end
		
        if unitBP.Close then
            PlaySound( self, unitBP.Close)
        end
        
        if bp.WeaponUnpackAnimation and self.UnpackAnimator then
        
            self.ElapsedRepackTime = GetGameTick()
        
            self.UnpackAnimator:SetRate(-bp.WeaponUnpackAnimationRate)
        end
        
        if self.UnpackAnimator then

            WaitFor(self.UnpackAnimator)
            
            self.ElapsedRepackTime = GetGameTick() - self.ElapsedRepackTime

            if ScenarioInfo.WeaponStateDialog then
                if self.EconDrain then
                    LOG("*AI DEBUG DefaultWeapon Pack Sequence ends "..repr(bp.Label).." at "..GetGameTick() )
                else
                    LOG("*AI DEBUG DefaultWeapon Pack Sequence ends "..repr(bp.Label).." after "..self.ElapsedRepackTime.." ticks" )
                end
            end
            
            if self.ElapsedRepackTime > 0 and ( not bp.WeaponRepackTimeout or (math.floor(bp.WeaponRepackTimeout * 10) -self.ElapsedRepackTime < 0 ) ) then
                LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout (".. (bp.WeaponRepackTimeout or 0) ..") - during pack - is either not existant or less than the WeaponUnpackAnimation - "..self.ElapsedRepackTime.." ticks. "..repr(self.unit.BlueprintID))
            end

			if bp.WeaponRepackTimeout and (math.floor(bp.WeaponRepackTimeout * 10) - self.ElapsedRepackTime) > 1 then
            
                if ScenarioInfo.WeaponStateDialog then
                    if self.EconDrain then
                        LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout "..repr(bp.Label).." at "..GetGameTick() )
                    else
                        LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout "..repr(bp.Label).." waits "..math.floor(self.bp.WeaponRepackTimeout * 10) - self.ElapsedRepackTime.." ticks" )
                    end
                end

				WaitSeconds( bp.WeaponRepackTimeout - (self.ElapsedRepackTime/10) )
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

        for _, v in self.RecoilManipulators do
            WaitFor(v)
        end

        self:DestroyRecoilManips()
		
        if self.Animator then
            WaitFor(self.Animator)
            self.Animator:Destroy()
            self.Animator = nil
        end
    end,

    DestroyRecoilManips = function(self)

        for _, v in self.RecoilManipulators do
            v:Destroy()
        end

        self.RecoilManipulators = {}
    end,

    -- General State-less event handling
    OnLostTarget = function(self)
		
        local bp = self.bp
        
        local target = WeaponHasTarget(self)

        if target and self.WeaponIsEnabled then

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon OnLostTarget for "..repr(bp.Label).." Enabled is "..repr(self.WeaponWantEnabled).." at "..GetGameTick() )
            end
        
            Weapon.OnLostTarget(self)
            
            -- if the weapon unpacks and had a target --
            -- force a reload sequence, which in turn will force a repack
            if bp.WeaponUnpacks == true and target then

                LOUDSTATE(self, self.RackSalvoReloadState)

            else

                LOUDSTATE(self, self.IdleState)
            end
        end
    end,

    OnDestroy = function(self)
        LOUDSTATE(self, self.DeadState)
        Weapon.OnDestroy(self)
    end,

    OnEnterState = function(self)
    
        if self.WeaponWantEnabled and not self.WeaponIsEnabled then
		
            self.WeaponIsEnabled = true

            self:SetWeaponEnabled(true)
			
        elseif not self.WeaponWantEnabled or not self.WeaponIsEnabled then --and self.WeaponIsEnabled then

            self.WeaponIsEnabled = false

            self:SetWeaponEnabled(false)
        end
        
        if self.AimControl then
		
            if self.WeaponAimWantEnabled and not self.WeaponAimIsEnabled then
		
                self.WeaponAimIsEnabled = true

                self:AimManipulatorSetEnabled(true)
			
            elseif not self.WeaponAimWantEnabled or not self.WeaponAimIsEnabled then --and self.WeaponAimIsEnabled then
		
                self.WeaponAimIsEnabled = false

                self:AimManipulatorSetEnabled(false)
            end

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
            LOG("*AI DEBUG DefaultWeapon OnWeaponFired "..repr(self.bp.Label).." at "..GetGameTick() )
        end
        
		Weapon.OnWeaponFired(self)
    end,

    OnDisableWeapon = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon OnDisableWeapon "..repr(self.bp.Label) )
        end
        
        if self.EconDrain then 

            RemoveEconomyEvent( self, self.EconDrain)

            self.EconDrain = nil
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
         
            local bp = self.bp
            local unit = self.unit

            if unit.Dead then return end
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Idle State "..repr(self.bp.Label).." at "..GetGameTick() )
            end

            SetBusy( unit, false )
            
            if self.RecoilManipulators then
                self:WaitForAndDestroyManips()
            end

			if bp.EnergyRequired and bp.EnergyDrainPerSecond and not self.EconDrain then
                self:ForkThread( self.StartEconomyDrain )
			end
   	     
            if self.EconDrain then

                WaitFor(self.EconDrain)

                RemoveEconomyEvent( unit, self.EconDrain )
				
                self.EconDrain = nil                

                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon Idle State "..repr(self.bp.Label).." Economy Event Ends" )
                end

            end
			
            for _, v in bp.RackBones do
			
                if v.HideMuzzle == true then
				
                    for _, mv in v.MuzzleBones do
                        unit:ShowBone( mv, true )
                    end
                end
            end
            
			-- NOTE: This is setup so that it only works if there is more than 1 rack
            -- intended to force the reload rack process after a firing sequence
            if LOUDGETN(bp.RackBones) > 1 and self.CurrentRackNumber > 1 then

                self.CurrentRackNumber = 1 

                LOUDSTATE(self, self.RackSalvoReloadState)

            end
			
            if self.bp.CountedProjectile == true and not self.bp.NukeWeapon then
            
                if unit:GetTacticalSiloAmmoCount() <= 0 then
                    LOUDSTATE(self, self.WeaponEmptyState)
                end
            end
        end,

        OnGotTarget = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Idle State OnGotTarget "..repr(self.bp.Label).." at "..GetGameTick() )
            end
            
            local bp = self.bp
	
            if (bp.WeaponUnpackLocksMotion != true or (bp.WeaponUnpackLocksMotion == true and not self.unit:IsUnitState('Moving'))) then
			
                if bp.CountedProjectile == true and not self:CanWeaponFire() then
				
                    return
					
                end
				
                if bp.WeaponUnpacks == true then
				
                    LOUDSTATE(self, self.WeaponUnpackingState)
					
                else

                    LOUDSTATE(self, self.RackSalvoChargeState)
					
                end
				
            end
			
        end,

        OnFire = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Idle State OnFire "..repr(self.bp.Label).." at "..GetGameTick() )
            end
            
            local bp = self.bp
			
            if bp.WeaponUnpacks == true then    --and not bp.RackSalvoChargeTime then
			
                LOUDSTATE(self, self.WeaponUnpackingState)
				
            else

                LOUDSTATE(self, self.RackSalvoChargeState)

            end
			
        end,
    },
    
    -- this state specifically for empty tac and SMD launchers
    WeaponEmptyState = State {
    
        WeaponWantEnabled = true,   -- the weapon must be enabled to build ammo
        WeaponAimWantEnabled = true,
        
        Main = function(self)

            local bp = self.bp
            local unit = self.unit
            local resetradius = false
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Empty State "..repr(bp.Label).." at "..GetGameTick() )
            end

            self:ChangeMaxRadius( 1 )

            resetradius = true
            
            while not unit.Dead and unit:GetTacticalSiloAmmoCount() <= 0 do
                WaitTicks(16)
            end
            
            if resetradius then
                self:ChangeMaxRadius( bp.MaxRadius )
            end

            if not unit.Dead then
                LOUDSTATE(self, self.IdleState)
            end
        
        end,
    
    },
	
    WeaponUnpackingState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = false,

        Main = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Unpacking State "..repr(self.bp.Label).." at "..GetGameTick() )
            end

            local bp = self.bp
            local unit = self.unit
            
            --SetBusy( unit, true )

            if bp.WeaponUnpackLocksMotion then
                unit:SetImmobile(true)
            end

            -- this will play any animation and note the time it takes
            self:PlayFxWeaponUnpackSequence(bp)

            -- any weapon with a charge time or an energy requirement
            -- will now goto the Charge State
            if bp.RackSalvoChargeTime or bp.EnergyRequired then
			
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
                LOG("*AI DEBUG DefaultWeapon RackSalvo Charge State "..repr(self.bp.Label).." at "..GetGameTick() )
			end

            local bp = self.bp
            local unit = self.unit
            
            self.ElapsedRackChargeTime = 0
			
            if self.EconDrain then
            
                self.ElapsedRackChargeTime = GetGameTick()

                WaitFor(self.EconDrain)
				
                RemoveEconomyEvent( unit, self.EconDrain )
				
                self.EconDrain = nil
                
                self.ElapsedRackChargeTime = GetGameTick() - self.ElapsedRackChargeTime

                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Charge State "..repr(bp.Label).." Economy Event Ends after "..self.ElapsedRackChargeTime.." ticks at "..GetGameTick() )
                end

            end

            self:PlayFxRackSalvoChargeSequence(bp)

            if bp.RackSalvoChargeTime and (math.floor(bp.RackSalvoChargeTime*10) - self.ElapsedRackChargeTime) >= 1 then
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Charge for "..repr(bp.Label).." waiting "..math.floor(bp.RackSalvoChargeTime*10) - self.ElapsedRackChargeTime.." ticks at "..GetGameTick() )
                end
            
                WaitTicks( math.floor(bp.RackSalvoChargeTime*10) - self.ElapsedRackChargeTime ) 

            end
            
            --if bp.SkipReadyState then
              --  LOUDSTATE(self, self.RackSalvoFiringState)
            --else
                LOUDSTATE(self, self.RackSalvoFireReadyState)
            --end

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
                LOG("*AI DEBUG DefaultWeapon RackSalvo Fire Ready State "..repr(self.bp.Label).." at "..GetGameTick() )
            end
            
            local unit = self.unit

            self.WeaponCanFire = false
			
            if self.EconDrain then

                WaitFor(self.EconDrain)
				
                RemoveEconomyEvent( unit, self.EconDrain )
				
                self.EconDrain = nil

                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Fire Ready State "..repr(self.bp.Label).." Economy Event Ends at "..GetGameTick() )
                end

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
                LOG("*AI DEBUG DefaultWeapon RackSalvo Fire Ready State "..repr(self.bp.Label).." OnFire at "..GetGameTick() )
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
            
            local bp = self.bp
            local NotExclusive = bp.NotExclusive
            local unit = self.unit
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State for "..repr(bp.Label).." at "..GetGameTick() )
			end
            
            -- ok -- with multiple weaponed units - this is the command that halts other weapons from firing
            -- when Exclusive, all other weapons will 'pause' until this function completes
            --SetBusy( unit, (not NotExclusive or false) )
            
			if self.RecoilManipulators then
				self:DestroyRecoilManips()
			end
			
            local numRackFiring = self.CurrentRackNumber
		
			local TotalRacksOnWeapon = LOUDGETN(bp.RackBones)
			
            if bp.RackFireTogether == true then
                numRackFiring = TotalRacksOnWeapon
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
            while self.CurrentRackNumber <= numRackFiring and not self.HaltFireOrdered and not unit.Dead do
 			
                rackInfo = bp.RackBones[self.CurrentRackNumber]
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." - PREPARING RACK "..self.CurrentRackNumber.." "..repr(rackInfo.RackBone) )
                end

				MuzzlesToBeFired = LOUDGETN(bp.RackBones[self.CurrentRackNumber].MuzzleBones)
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

                    if bp.CountedProjectile == true then
					
                        if bp.NukeWeapon == true then
                            if unit:GetNukeSiloAmmoCount() <= 0 then
                                self.WeaponCanFire = false
                                continue
                            end
                        else
                            if unit:GetTacticalSiloAmmoCount() <= 0 then
                                self.WeaponCanFire = false
                                continue
                            end
                        end
                    end

                    self.FirstShot = false
                    
                    self:StartEconomyDrain() -- the recharge begins as soon as the weapon starts firing
					
                    muzzle = rackInfo.MuzzleBones[muzzleIndex]
            
                    if ScenarioInfo.WeaponStateDialog then
                        LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." - preps rack "..self.CurrentRackNumber.." "..repr(rackInfo.RackBone).." muzzle "..i.." "..repr(muzzle).." at "..GetGameTick() )
                    end
 					
                    if rackInfo.HideMuzzle == true then
                        ShowBone( unit, muzzle, true)
                    end
					
                    -------------------
					-- muzzle charge --
                    -------------------
                    if bp.MuzzleChargeDelay and bp.MuzzleChargeDelay > 0 then
					
                        if bp.Audio.MuzzleChargeStart then
                            PlaySound( self, bp.Audio.MuzzleChargeStart)
                        end
						
                        self:PlayFxMuzzleChargeSequence(muzzle)
            
                        if ScenarioInfo.WeaponStateDialog then
                            if self.EconDrain then
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." Muzzle Charge Delay "..math.floor(bp.MuzzleChargeDelay * 10).." ticks (not firing cycle) at "..GetGameTick() )
                            else
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." Muzzle Charge Delay waiting "..math.floor(bp.MuzzleChargeDelay * 10).." ticks at "..GetGameTick() )
                            end
                        end
						
                        WaitSeconds( bp.MuzzleChargeDelay )

                    end

                    ------------------
					-- muzzle fires --
                    ------------------					
            
                    if ScenarioInfo.WeaponStateDialog then
                        LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." - FIRES rack "..self.CurrentRackNumber.." muzzle "..i.." at "..GetGameTick() )
                    end

                    self:PlayFxMuzzleSequence(muzzle)                    
					
                    if rackInfo.HideMuzzle == true then
                        HideBone( unit, muzzle, true)
                    end

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

                    -------------------
					-- muzzle salvo  --
                    -------------------					
                    if bp.MuzzleSalvoDelay > 0 then
            
                        if ScenarioInfo.WeaponStateDialog then

                            if self.EconDrain then
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." Muzzle Salvo Delay "..math.floor(bp.MuzzleSalvoDelay * 10).." ticks (not firing cycle) at "..GetGameTick() )
                            else
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." Muzzle Salvo Delay waiting "..math.floor(bp.MuzzleSalvoDelay * 10).." ticks at "..GetGameTick() )
                            end
                        end
						
                        WaitSeconds( bp.MuzzleSalvoDelay )
                    end
                    
                end
                
                if bp.CameraShakeRadius or bp.ShipRock or bp.RackRecoilDistance != 0 then
                    self:PlayFxRackReloadSequence(bp)
                end
			
				-- advance the rack number --
                if self.CurrentRackNumber <= TotalRacksOnWeapon then
                    self.CurrentRackNumber = self.CurrentRackNumber + 1
                end

            end

			if bp.Buffs then
				self:DoOnFireBuffs(bp.Buffs)
			end

            self.HaltFireOrdered = false

			-- if all the racks have fired --
            if self.CurrentRackNumber > TotalRacksOnWeapon then
			
				-- reset the rack count
                self.CurrentRackNumber = 1

                -- this takes precedence - delay for reloading the rack
                if bp.RackSalvoReloadTime > 0 or bp.AnimationReload or self.EconDrain or bp.CountedProjectile then
				
                    LOUDSTATE(self, self.RackSalvoReloadState)

                -- anything else is just ready to fire again --
                else
				
                    LOUDSTATE(self, self.RackSalvoChargeState)
					
                end
				
            elseif bp.CountedProjectile == true then

				if not bp.WeaponUnpacks then
					LOUDSTATE(self, self.IdleState)
				else
					LOUDSTATE(self, self.WeaponPackingState)
				end
				
            else
			
                LOUDSTATE(self, self.RackSalvoChargeState)
				
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
                
                WaitTicks(1)                

                unit:SetWorkProgress( 1 - clockTime / rof )

            end
        end,
    },

    RackSalvoReloadState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)

            local WeaponStateDialog = ScenarioInfo.WeaponStateDialog

            if WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(self.bp.Label).." at "..GetGameTick() )		
            end

            local bp = self.bp
            local unit = self.unit	     
            
            self.ElapsedRackReloadTime = 0

            self:PlayFxRackSalvoReloadSequence(bp)
            
            if self.ElapsedRackReloadTime > 0 and ( not bp.RackSalvoReloadTime or ((bp.RackSalvoReloadTime*10) < self.ElapsedRackReloadTime )) then
                LOG("*AI DEBUG DefaultWeapon RackReloadTime - is either not existant or less than the RackSalvoReloadSequnce - "..self.ElapsedRackReloadTime.." ticks. "..repr(self.unit.BlueprintID))
            end
            
            if bp.RackSalvoReloadTime and (math.floor(bp.RackSalvoReloadTime * 10) - self.ElapsedRackReloadTime) >= 1 then
            
                if WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." RackSalvoReloadTime waits "..math.floor(bp.RackSalvoReloadTime * 10) - self.ElapsedRackReloadTime.." ticks" )
                end
            
                WaitSeconds( (math.floor(bp.RackSalvoReloadTime * 10) - self.ElapsedRackReloadTime)/10 )
            end

            if self.RecoilManipulators then
                self:WaitForAndDestroyManips()
            end

            -- if the weapon has a target follow normal steps
            if WeaponHasTarget( self ) then 
            
                if bp.RackSalvoChargeTime > 0 and self:CanWeaponFire() then
			
                    LOUDSTATE(self, self.RackSalvoChargeState)
				
                elseif self:CanWeaponFire() then
			
                    if not (bp.ManualFire or bp.CountedProjectile or bp.ForceSingleFire) then
			
                        LOUDSTATE(self, self.RackSalvoFireReadyState)

                    else
				
                        if bp.WeaponUnpacks == true then
                            LOUDSTATE(self, self.WeaponPackingState)
                        else
                            LOUDSTATE(self, self.IdleState)
                        end
                    end
                end

            else
                -- if no target and there is a RackReloadTimeout - process it - rare
                if bp.RackReloadTimeout and (bp.RackReloadTimeout) > 1 then

                    if WeaponStateDialog then
                        LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." - Rack Reload Timeout Waits "..bp.RackReloadTimeout.." ticks" )		
                    end
                    
                    WaitTicks( bp.RackReloadTimeout )
                end
				
                if bp.WeaponUnpacks == true then
                    LOUDSTATE(self, self.WeaponPackingState)
                else
                    LOUDSTATE(self, self.IdleState)
                end			

            end
			
        end,

        OnFire = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(self.bp.Label).." OnFire" )
            end

        end,
    },

    WeaponPackingState = State {
	
        WeaponWantEnabled = true,
        WeaponAimWantEnabled = false,

        Main = function(self)
          
            local bp = self.bp
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon WeaponPacking State "..repr(self.bp.Label) )
			end

            --SetBusy( self.unit, true )

			-- reset the rack count
            self.CurrentRackNumber = 1

            self:PlayFxWeaponPackSequence(bp)
      
            if bp.WeaponUnpackLocksMotion then
                self.unit:SetImmobile(false)
            end
			
            LOUDSTATE(self, self.IdleState)
			
        end,

        OnGotTarget = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon WeaponPacking State "..repr(self.bp.Label).." OnGotTarget" )		
            end
            
            if not self.bp.ForceSingleFire then
                LOUDSTATE(self, self.WeaponUnpackingState)
            end
			
        end,

        -- Override so that it doesn't play the firing sound when
        -- we're not actually creating the projectile yet
        OnFire = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon WeaponPacking State "..repr(self.bp.Label).." OnFire")
            end
            
            if self.bp.CountedProjectile == true and not self.bp.ForceSingleFire then
			
                LOUDSTATE(self, self.WeaponUnpackingState)
				
            end
			
        end,

    },

    DeadState = State {
	
		WeaponWantEnabled = false,
        WeaponAimWantEnabled = false,

        Main = function(self)
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Dead State "..repr(self.bp.Label).." at "..GetGameTick() )
            end

        end,
    },
	
}

KamikazeWeapon = Class(DefaultProjectileWeapon) {

    OnFire = function(self)

        DamageArea(self.unit, self.unit:GetPosition(), self.bp.DamageRadius, self.bp.Damage, self.bp.DamageType or 'Normal', self.bp.DamageFriendly or false)
        
        self.unit:Kill()
    end,
}

BareBonesWeapon = Class(DefaultProjectileWeapon) {
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
                    LOG("*AI DEBUG OnCreate Beam for weapon "..repr(bp.Label).." on muzzle "..repr(mv).." for unit "..repr(beam.Weapon.unit.BlueprintID))
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
                if self.Beams then
                    for _, v in self.Beams do
                        v.Beam:Disable()
                    end
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

