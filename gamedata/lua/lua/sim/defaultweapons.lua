---  /lua/sim/DefaultWeapons.lua
---  Default definitions of weapons

local Weapon = import('/lua/sim/Weapon.lua').Weapon

local WeaponOnCreate    = Weapon.OnCreate
local WeaponOnDestroy   = Weapon.OnDestroy

local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local CalculateBallisticAcceleration = import('/lua/sim/CalcBallisticAcceleration.lua').CalculateBallisticAcceleration 

local LOUDABS       = math.abs
local LOUDGETN      = table.getn
local LOUDMAX       = math.max
local LOUDINSERT    = table.insert

local CreateAnimator            = CreateAnimator
local CreateEconomyEvent        = CreateEconomyEvent
local DamageArea                = DamageArea
local ForkThread                = ForkThread
local GetGameTick               = GetGameTick
local KillThread                = KillThread
local LOUDATTACHEMITTER         = CreateAttachedEmitter
local LOUDSTATE                 = ChangeState
local RemoveEconomyEvent        = RemoveEconomyEvent
local TrashAdd                  = TrashBag.Add
local WaitSeconds               = WaitSeconds
local WaitTicks                 = coroutine.yield

local GetEconomyIncome          = moho.aibrain_methods.GetEconomyIncome
local GetEconomyStored          = moho.aibrain_methods.GetEconomyStored

local PlayAnim                  = moho.AnimationManipulator.PlayAnim

local BeenDestroyed             = moho.entity_methods.BeenDestroyed
local GetAIBrain                = moho.entity_methods.GetAIBrain

local ScaleEmitter              = moho.IEffect.ScaleEmitter

local SetPrecedence             = moho.manipulator_methods.SetPrecedence

local ChangeDetonateAboveHeight = moho.projectile_methods.ChangeDetonateAboveHeight

local HideBone                  = moho.unit_methods.HideBone
local SetBusy                   = moho.unit_methods.SetBusy
local SetWorkProgress           = moho.unit_methods.SetWorkProgress
local ShowBone                  = moho.unit_methods.ShowBone


local WeaponMethods     = moho.weapon_methods

local CreateProjectile          = WeaponMethods.CreateProjectile
local GetBlueprint              = WeaponMethods.GetBlueprint
local GetCurrentTargetPos       = WeaponMethods.GetCurrentTargetPos
local PlaySound                 = WeaponMethods.PlaySound
local SetFiringRandomness       = WeaponMethods.SetFiringRandomness
local WeaponHasTarget           = WeaponMethods.WeaponHasTarget

WeaponMethods = nil


DefaultProjectileWeapon = Class(Weapon) {		

    FxRackChargeMuzzleFlash = false,
    FxRackChargeMuzzleFlashScale = 1,
    FxChargeMuzzleFlash = false,
    FxChargeMuzzleFlashScale = 1,
	
    FxMuzzleFlash = {'/effects/emitters/default_muzzle_flash_01_emit.bp','/effects/emitters/default_muzzle_flash_02_emit.bp'},
    FxMuzzleFlashScale = 1,    

    OnCreate = function(self)
	
        WeaponOnCreate(self)

        self.HadTarget = false
        self.WeaponCanFire = true
        self.WeaponIsEnabled = false

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

        if bp.EnergyChargeForFirstShot == false then
            self.WeaponCharged = true
        end
		
        if bp.RenderFireClock then
            self.unit:SetWorkProgress(1)
        end
		
        if bp.FixBombTrajectory then
        
            if bp.ProjectilesPerOnFire then
                self.CBFP_CalcBallAcc = { Do = true, ProjectilesPerOnFire = bp.ProjectilesPerOnFire }
            else
                self.CBFP_CalcBallAcc = { Do = true, ProjectilesPerOnFire = 1 }
            end
        end

        if not bp.EnabledByEnhancement then
            LOUDSTATE(self, self.IdleState)
        else
            LOUDSTATE(self, self.DeadState)
        end
	end,
	
    CheckBallisticAcceleration = function(self, proj, Projectiles )
	
        local acc = CalculateBallisticAcceleration( self, proj, Projectiles )

        proj:SetBallisticAcceleration( -acc)    --- change projectile trajectory so it hits the target, cure for engine bug

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

        local proj          = self:CreateProjectileForWeapon(muzzle)

        local bp            = self.bp
        local unit          = self.unit
        
        local Audio         = bp.Audio
        local CacheLayer    = unit.CacheLayer
	
		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG Projectile CreateProjectileAtMuzzle "..repr(bp.Label).." Muzzle "..repr(muzzle).." Projectile "..repr(proj.BlueprintID) )
		end
		
        if not proj or BeenDestroyed(proj) then
            return false
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
        
        if (CacheLayer == 'Water' or CacheLayer == 'Sub' or CacheLayer == 'Seabed') then

            if Audio.FireUnderWater then
                PlaySound( self, Audio.FireUnderWater )
            elseif Audio.Fire then
                PlaySound( self, Audio.Fire)
            end
        else
            if Audio.Fire then
                PlaySound( self, Audio.Fire)
            end
        end

		if self.CBFP_CalcBallAcc then
			self:CheckBallisticAcceleration(proj, self.CBFP_CalcBallAcc.ProjectilesPerOnFire )
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


    StartEconomyDrain = function(self)

        if self.WeaponCharged then return end
		
        local bp = self.bp
		
        if not self.EconDrain then
        
            if bp.EnergyRequired and bp.EnergyDrainPerSecond then
		
                local function ChargeProgress( self, progress)
                    SetWorkProgress( self, progress )
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

                end
            else
                self.WeaponCharged = true
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
    
        local FxMuzzleFlash = self.FxMuzzleFlash or false
	
        if FxMuzzleFlash then

            local unit = self.unit
            local army = unit.Army

            local emit
            
            local MuzzleFlashScale = self.FxMuzzleFlashScale or 1
		
            for _, v in FxMuzzleFlash do
            
                emit = LOUDATTACHEMITTER( unit, muzzle, army, v)
            
                if MuzzleFlashScale != 1 then
                    ScaleEmitter( emit, MuzzleFlashScale )
                end
            end
        end
    end,

    -- Played during the beginning of a MuzzleChargeDelay time when a muzzle in a rack is fired.
    PlayFxMuzzleChargeSequence = function(self, muzzle)
    
        local FxChargeMuzzleFlash = self.FxMuzzleChargeFlash or false
        
        if FxChargeMuzzleFlash then
	
            local unit = self.unit
            local army = unit.Army

            local emit
            
            local ChargeMuzzleFlashScale = self.FxChargeMuzzleFlashScale or 1
        
            for _, v in FxChargeMuzzleFlash do
        
                emit = LOUDATTACHEMITTER( unit, muzzle, army, v)
            
                if ChargeMuzzleFlashScale != 1 then
                    ScaleEmitter( emit, ChargeMuzzleFlashScale )
                end
            end
        end
    end,    

    -- Played when a rack charges (prior to firing).  If there is an animiation, the code will record the
    -- time taken to run it
    PlayFxRackSalvoChargeSequence = function(self, blueprint)
	
        local bp = blueprint or self.bp
        
        local unit = self.unit
        
        local AnimationCharge           = bp.AnimationCharge or false
        local Audio                     = bp.Audio.ChargeStart or false
        local FxRackChargeMuzzleFlash   = self.FxRackChargeMuzzleFlash or false

        if FxRackChargeMuzzleFlash then

            local army = unit.Army
            local emit
            
            local RackChargeMuzzleFlashScale = self.FxRackChargeMuzzleFlashScale or 1

            for _, v in FxRackChargeMuzzleFlash do
		
                for _, ev in bp.RackBones[self.CurrentRackNumber].MuzzleBones do
			
                    emit = LOUDATTACHEMITTER( unit, ev, army, v)
                
                    if RackChargeMuzzleFlashScale != 1 then
                        ScaleEmitter( emit, RackChargeMuzzleFlashScale)
                    end
                end
            end
        end
		
        if Audio then
            PlaySound( self, Audio)
        end
		
        if AnimationCharge and not self.Animator then

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon PlayFxRackSalvoChargeSequence "..repr(bp.Label).." at "..GetGameTick() )
            end
        
            self.ElapsedRackChargeTime = GetGameTick()
		
            self.Animator = CreateAnimator(unit)
            
            PlayAnim( self.Animator, AnimationCharge ):SetRate( bp.AnimationChargeRate or 1 )
            
            WaitFor(self.Animator)
            
            self.ElapsedRackChargeTime = GetGameTick() - self.ElapsedRackChargeTime
        end
        
    end,

    -- Played when a rack reloads (after firing).  
    PlayFxRackSalvoReloadSequence = function(self, blueprint)
    
        local bp = blueprint or self.bp
        
        local AnimationReload       = bp.AnimationReload or false

        -- play the reload animation and measure how long that takes --        
        if AnimationReload and not self.Animator then

            local WeaponStateDialog     = ScenarioInfo.WeaponStateDialog
            
            if WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." reload animation" )		
            end

            local seqtime = GetGameTick()

            self.Animator = CreateAnimator(self.unit)
        
            PlayAnim( self.Animator, AnimationReload):SetRate( bp.AnimationReloadRate or 1)
        
            WaitFor(self.Animator)

            seqtime = GetGameTick() - seqtime

            if WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." reload animation takes "..repr(seqtime).." ticks" )		
            end

            self.ElapsedRackReloadTicks = seqtime + self.ElapsedRackReloadTicks
        end
		
    end,

    -- Played when a rack reloads. Mostly used for Recoil.
    PlayFxRackReloadSequence = function(self, blueprint)
	
        local bp = self.bp
        local unit = self.unit

        local CameraShakeRadius     = bp.CameraShakeRadius or false
        local RackRecoilDistance    = bp.RackRecoilDistance or false

        if CameraShakeRadius then

            local CameraShakeMax        = bp.CameraShakeMax
            local CameraShakeMin        = bp.CameraShakeMin
            local CameraShakeDuration   = bp.CameraShakeDuration
        
            if CameraShakeMax and CameraShakeMin and CameraShakeDuration and
                CameraShakeRadius > 0 and CameraShakeMax > 0 and CameraShakeMin >= 0 and CameraShakeDuration > 0 then
			
                unit:ShakeCamera( CameraShakeRadius, CameraShakeMax, CameraShakeMin, CameraShakeDuration)
            end
            
        end
		
        if bp.ShipRock == true then
		
            local ix,iy,iz = unit:GetBoneDirection(bp.RackBones[self.CurrentRackNumber].RackBone)
			
            unit:RecoilImpulse(-ix,-iy,-iz)
        end
		
        if RackRecoilDistance and RackRecoilDistance != 0 then
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

        self.ElapsedRepackTime = GetGameTick()
        
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
        
            self.UnpackAnimator = CreateAnimator(self.unit)

            PlayAnim( self.UnpackAnimator, bp.WeaponUnpackAnimation ):SetRate(0)

            SetPrecedence( self.UnpackAnimator, bp.WeaponUnpackAnimatorPrecedence or 0)
            
            TrashAdd( self.unit.Trash, self.UnpackAnimator )
        end
        
        if self.UnpackAnimator then

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
                LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout -(".. (bp.WeaponRepackTimeout or 0) ..") during unpack - is either not existant or less than the WeaponUnpackAnimation - "..self.ElapsedRepackTime.." ticks. "..repr(self.unit.BlueprintID) )
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
    PlayFxWeaponPackSequence = function(self, blueprint, unit)
	
        local bp    = blueprint or self.bp
        local unit  = unit or self.unit
        
        local unitBP = __blueprints[unit.BlueprintID].Audio

        self.ElapsedRepackTime = GetGameTick()
  		
        if unitBP.Close then
            PlaySound( self, unitBP.Close)
        end
        
        if bp.WeaponUnpackAnimation and self.UnpackAnimator then

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Pack Sequence "..repr(bp.Label).." begins at "..GetGameTick() )
            end

            self.UnpackAnimator:SetRate(-bp.WeaponUnpackAnimationRate)
        end
        
        if self.UnpackAnimator then

            WaitFor(self.UnpackAnimator)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Pack Sequence "..repr(bp.Label).." ends at "..GetGameTick() )
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
        
        if self.WeaponIsEnabled then

            local target = WeaponHasTarget(self)

            if not target then
        
                Weapon.OnLostTarget(self)

            end

            if self.bp.WeaponUnpacks then

                LOUDSTATE(self, self.WeaponPackingState)

            else
                LOUDSTATE(self, self.IdleState)

            end

        end

    end,

    OnDestroy = function(self)

        self.Dead = true

        LOUDSTATE(self, self.DeadState)

        WeaponOnDestroy(self)
    end,

    OnEnterState = function(self)
    
        if not self.Dead then
    
            if self.WeaponWantEnabled != self.WeaponIsEnabled then

                self:SetWeaponEnabled(self.WeaponWantEnabled)

            end

            if self.AimControl then -- only turreted weapons have AimControl
		
                if self.WeaponAimEnabled != self.WeaponAimWantEnabled then

                    self:AimManipulatorSetEnabled(self.WeaponAimWantEnabled)

                end

            end
            
        end

    end,

    PackAndMove = function(self)
	
        LOUDSTATE(self, self.WeaponPackingState)
		
    end,

    CanWeaponFire = function(self, bp, unit)
    
        if bp.CountedProjectile and bp.MaxProjectileStorage > 0 then

            if not bp.NukeWeapon then
                
                if unit:GetTacticalSiloAmmoCount() <= 0 then
                    return false
                end
            else
                if unit:GetNukeSiloAmmoCount() <= 0 then
                    return false
                end
            end
        end

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

        Weapon.OnDisableWeapon(self)

    end, 
    
    OnEnableWeapon = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon OnEnableWeapon "..repr(self.bp.Label) )
        end
        
        Weapon.OnEnableWeapon(self)

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
                LOG("*AI DEBUG DefaultWeapon Idle State "..repr(bp.Label).." at "..GetGameTick() )
            end

            SetBusy( unit, false )

            if self.RecoilManipulators then
                self:WaitForAndDestroyManips()
            end

			if not self.EconDrain then
                self:ForkThread( self.StartEconomyDrain )
			end
   	     
            if self.EconDrain then

                WaitFor(self.EconDrain)
                
                self.WeaponCharged = true

                RemoveEconomyEvent( unit, self.EconDrain )
				
                self.EconDrain = nil                

                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon Idle State "..repr(self.bp.Label).." Economy Event Ends" )
                end

            end
            
            if bp.RackBones then
			
                for _, v in bp.RackBones do
			
                    if v.HideMuzzle == true then
				
                        for _, mv in v.MuzzleBones do
                            unit:ShowBone( mv, true )
                        end
                    end
                end
            
                -- NOTE: This is setup so that it only works if there is more than 1 rack to be fired
                -- but the rack wasn't reset (weapon didn't fire all the rackbones)
                -- we force the reload rack process
                -- this seems to happen when a multi-rackboned unit loses it's target during the fire sequence
                if LOUDGETN(bp.RackBones) > 1 and self.CurrentRackNumber > 1 then

                    self.CurrentRackNumber = 1 

                    LOUDSTATE(self, self.RackSalvoReloadState)

                end
                
            end
			
            if bp.CountedProjectile == true and bp.MaxProjectileStorage > 0 and not self.bp.NukeWeapon then
            
                if unit:GetTacticalSiloAmmoCount() <= 0 then
                    LOUDSTATE(self, self.WeaponEmptyState)
                end
            end
        end,

        OnGotTarget = function(self)
            
            local bp = self.bp
            local unit = self.unit

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Idle State OnGotTarget "..repr(bp.Label).." Target is "..repr(self:GetCurrentTargetPos()).." at "..GetGameTick() )
            end
	
            if (bp.WeaponUnpackLocksMotion != true or (bp.WeaponUnpackLocksMotion == true and not unit:IsUnitState('Moving'))) then

                if bp.CountedProjectile and bp.MaxProjectileStorage > 0 then

                    if not self:CanWeaponFire(bp,unit) then
				
                        unit.HasTMLTarget = true
                        return
                    else
                        unit.HasTMLTarget = true
                    end
                    
                end
				
                if bp.WeaponUnpacks == true then
				
                    LOUDSTATE(self, self.WeaponUnpackingState)
					
                else

                    LOUDSTATE(self, self.RackSalvoChargeState)
					
                end
				
            end
			
        end,

        OnFire = function(self)
            
            local bp = self.bp

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Idle State OnFire "..repr(bp.Label).." at "..GetGameTick() )
            end
			
            if bp.WeaponUnpacks == true then
			
                LOUDSTATE(self, self.WeaponUnpackingState)
				
            else

                LOUDSTATE(self, self.RackSalvoChargeState)

            end
			
        end,
    },
    
    -- this state specifically for empty tac and SMD launchers
    WeaponEmptyState = State {
    
        WeaponWantEnabled = true,   -- the weapon must be enabled to build ammo
        WeaponAimWantEnabled = false,
        
        Main = function(self)

            local bp = self.bp
            local unit = self.unit
            local resetradius = false
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon Empty State "..repr(bp.Label).." at "..GetGameTick() )
            end

            self:ChangeMaxRadius( 1 )

            resetradius = true
            
            if bp.MaxProjectileStorage > 0 then
            
                if not bp.NukeWeapon then
                
                    while not unit.Dead and unit:GetTacticalSiloAmmoCount() <= 0 do
                        WaitTicks(16)
                    end
                end
            
                if bp.NukeWeapon then
            
                    while not unit.Dead and unit:GetNukeSiloAmmoCount() <= 0 do
                        WaitTicks(36)
                    end

                end
                
            end
            
            if resetradius then
                self:ChangeMaxRadius( bp.MaxRadius )
            end

            LOUDSTATE(self, self.IdleState)
        
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

            local bp = self.bp
            local unit = self.unit
            local RackSalvoChargeTime = bp.RackSalvoChargeTime or false
  
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Charge State "..repr(bp.Label).." at "..GetGameTick() )
			end
          
            self.ElapsedRackChargeTime = 0
			
            if self.EconDrain then
            
                self.ElapsedRackChargeTime = GetGameTick()

                WaitFor(self.EconDrain)
                
                self.WeaponCharged = true
				
                RemoveEconomyEvent( unit, self.EconDrain )
				
                self.EconDrain = nil
                
                self.ElapsedRackChargeTime = GetGameTick() - self.ElapsedRackChargeTime

                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Charge State "..repr(bp.Label).." Economy Event Ends after "..self.ElapsedRackChargeTime.." ticks at "..GetGameTick() )
                end

            end

            self:PlayFxRackSalvoChargeSequence(bp)

            if RackSalvoChargeTime and (math.floor(RackSalvoChargeTime*10) - self.ElapsedRackChargeTime) >= 1 then
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Charge for "..repr(bp.Label).." waiting "..math.floor(RackSalvoChargeTime*10) - self.ElapsedRackChargeTime.." ticks at "..GetGameTick() )
                end
            
                WaitTicks( math.floor(RackSalvoChargeTime*10) - self.ElapsedRackChargeTime ) 
            end

            LOUDSTATE(self, self.RackSalvoFireReadyState)

        end,
--[[
        OnFire = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Charge State "..repr(self.bp.Label).." OnFire at "..GetGameTick() )
            end
            
            LOUDSTATE(self, self.RackSalvoFireReadyState)
        end,
--]]        
        OnGotTarget = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Charge State "..repr(self.bp.Label).." OnGotTarget at "..GetGameTick() )		
            end
          
        end,
    },
    
    RackSalvoFireReadyState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
            
            local bp = self.bp
            local unit = self.unit
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Fire Ready State "..repr(bp.Label).." at "..GetGameTick() )
            end

            self.WeaponCanFire = false
			
            if self.EconDrain then

                WaitFor(self.EconDrain)
                
                self.WeaponCharged = true
				
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
            if (bp.CountedProjectile and bp.MaxProjectileStorage > 0) or bp.AnimationReload then
            
                while unit:GetFireState() == 1 do
                    WaitTicks(1)
                end
                
                LOUDSTATE(self, self.RackSalvoFiringState)
            end

        end,

		-- while debugging the WeaponUnpackLocksMotion I discovered that if you have the value NeedsUnpack = true in the AI section
		-- then the weapon will Never do an OnFire() event unless the unit is set to IMMOBILE
        OnFire = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Fire Ready State "..repr(self.bp.Label).." OnFire at "..GetGameTick() )
            end

            if self.WeaponCanFire and WeaponHasTarget(self) then
                LOUDSTATE(self, self.RackSalvoFiringState)
            end
			
        end,
        
        OnGotTarget = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Fire Ready State "..repr(self.bp.Label).." OnGotTarget at "..GetGameTick() )		
            end
          
        end,

    },

    RackSalvoFiringState = State {
	
        WeaponWantEnabled       = true,
        WeaponAimWantEnabled    = true,

        Main = function(self)
            
            local bp                    = self.bp
            
            local Audio                 = bp.Audio
            local Buffs                 = bp.Buffs
            local CountedProjectile     = bp.CountedProjectile or false
            local MuzzleChargeDelay     = bp.MuzzleChargeDelay or false
            local MuzzleSalvoDelay      = bp.MuzzleSalvoDelay
            local MuzzleSalvoSize       = bp.MuzzleSalvoSize
            local NotExclusive          = bp.NotExclusive
            local RackBones             = bp.RackBones or {}
            local unit                  = self.unit
            
            local WeaponStateDialog     = ScenarioInfo.WeaponStateDialog
            
            if WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State for "..repr(bp.Label).." at "..GetGameTick() )
			end
            
            -- ok -- with multiple weaponed units - this is the command that halts other weapons from firing
            -- when Exclusive, all other weapons will 'pause' until this function completes
            if NotExclusive then
                SetBusy( unit, false )
            end
            
			if self.RecoilManipulators then
				self:DestroyRecoilManips()
			end
			
            local numRackFiring = self.CurrentRackNumber
		
			local TotalRacksOnWeapon = LOUDGETN(RackBones) or 1
			
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

            self:OnWeaponFired(bp)
            
            local CurrentRackInfo, MuzzlesToBeFired, NumMuzzlesFiring, muzzleIndex, muzzle, projectilefired

            local HideBone          = HideBone
            local LOUDGETN          = LOUDGETN
            local PlaySound         = PlaySound
            local ShowBone          = ShowBone
            local WaitSeconds       = WaitSeconds

            -- Most of the time this will only run once per rack, the only time it doesn't is when racks fire together.
            while self.CurrentRackNumber <= numRackFiring and not self.HaltFireOrdered and not unit.Dead do
 			
                CurrentRackInfo = RackBones[self.CurrentRackNumber] or {}

                if CurrentRackInfo.MuzzleBones then
                    MuzzlesToBeFired = LOUDGETN( CurrentRackInfo.MuzzleBones )
                else
                    MuzzlesToBeFired = 1
                end

                NumMuzzlesFiring = MuzzleSalvoSize or 1

                -- this is a highly questionable statement since it always overrides the MuzzleSalvoSize
                -- IF the number of muzzles is different and the MuzzleSalvoDelay is zero
                if MuzzleSalvoDelay == 0 then
                    NumMuzzlesFiring = MuzzlesToBeFired
                end

                muzzleIndex = 1

				-- fire all the muzzles --
                for i = 1, NumMuzzlesFiring do

                    if not self.HaltFireOrdered and (not self:GetCurrentTarget() and bp.CannotAttackGround) then

                        if WeaponStateDialog then
                            LOG("*AI DEBUG Weapon "..repr(bp.Label).." on "..repr(unit.BlueprintID).." has no target to shoot at")
                        end

                        self:OnLostTarget()

                        HaltFireOrdered = true
                    end

                    if self.HaltFireOrdered then
                        continue
                    end

                    if CountedProjectile == true and bp.MaxProjectileStorage > 0 then
					
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

                    self.WeaponCharged = false
                    
                    if self.FirstShot then
                        self.FirstShot = false
                    end
                    
                    self:StartEconomyDrain() -- the recharge begins as soon as the weapon starts firing
					
                    muzzle = CurrentRackInfo.MuzzleBones[muzzleIndex]
            
                    if WeaponStateDialog then
                        LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." - preps rack "..self.CurrentRackNumber.." "..repr(CurrentRackInfo.RackBone).." at "..GetGameTick() )
                    end
 					
                    if CurrentRackInfo.HideMuzzle == true then
                        ShowBone( unit, muzzle, true)
                    end
					
                    -------------------
					-- muzzle charge --
                    -------------------
                    if MuzzleChargeDelay and MuzzleChargeDelay > 0 then
					
                        if Audio.MuzzleChargeStart then
                            PlaySound( self, Audio.MuzzleChargeStart)
                        end
						
                        self:PlayFxMuzzleChargeSequence(muzzle)
            
                        if WeaponStateDialog then

                            if self.EconDrain then
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." Muzzle Charge Delay "..math.floor(MuzzleChargeDelay * 10).." ticks (not firing cycle) at "..GetGameTick() )
                            else
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." Muzzle Charge Delay waiting "..math.floor(MuzzleChargeDelay * 10).." ticks at "..GetGameTick() )
                            end

                        end
						
                        WaitSeconds( MuzzleChargeDelay )

                    end

                    ------------------
					-- muzzle fires --
                    ------------------					
            
                    if WeaponStateDialog then
                        LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." - FIRES rack "..self.CurrentRackNumber.." muzzle "..i.." at "..GetGameTick() )
                    end

                    self:PlayFxMuzzleSequence(muzzle)                    
					
                    if CurrentRackInfo.HideMuzzle == true then
                        HideBone( unit, muzzle, true)
                    end

                    projectilefired = self:CreateProjectileAtMuzzle(muzzle)
                    
                    if ScenarioInfo.ProjectileDialog and projectilefired then
                        LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." - FIRED rack "..self.CurrentRackNumber.." projectile is "..repr(projectilefired.BlueprintID).." at "..GetGameTick() )
                    end

                    if CountedProjectile and bp.MaxProjectileStorage > 0 then
					
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
                    if MuzzleSalvoDelay > 0 then
            
                        if WeaponStateDialog then

                            if self.EconDrain then
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." Muzzle Salvo Delay "..math.floor(MuzzleSalvoDelay * 10).." ticks (not firing cycle) at "..GetGameTick() )
                            else
                                LOG("*AI DEBUG DefaultWeapon RackSalvo Firing State "..repr(bp.Label).." Muzzle Salvo Delay waiting "..math.floor(MuzzleSalvoDelay * 10).." ticks at "..GetGameTick() )
                            end
                        end
						
                        WaitSeconds( MuzzleSalvoDelay )
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

			if Buffs then
				self:DoOnFireBuffs(Buffs)
			end

            self.HaltFireOrdered = false

			-- if all the racks have fired --
            if (self.CurrentRackNumber > TotalRacksOnWeapon) or CountedProjectile then
			
				-- reset the rack count
                self.CurrentRackNumber = 1

                -- this takes precedence - delay for reloading the rack
                if bp.RackSalvoReloadTime > 0 or bp.AnimationReload or self.EconDrain or CountedProjectile then
				
                    LOUDSTATE(self, self.RackSalvoReloadState)

                -- anything else is just ready to fire again --
                else
				
                    LOUDSTATE(self, self.RackSalvoChargeState)
					
                end

            else

                LOUDSTATE(self, self.RackSalvoChargeState)

            end
            
        end,
		
		OnFire = function(self)

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

            local bp = self.bp
            local unit = self.unit	     

            if WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." at "..GetGameTick() )		
            end
            
            self.ElapsedRackReloadTicks = 0

            self:PlayFxRackSalvoReloadSequence(bp)
            
            if self.ElapsedRackReloadTicks > 0 and ( not bp.RackSalvoReloadTime or ((bp.RackSalvoReloadTime*10) < self.ElapsedRackReloadTicks )) then
                LOG("*AI DEBUG DefaultWeapon RackReloadTime - is either not existant or less than the RackSalvoReloadSequnce - "..self.ElapsedRackReloadTicks.." ticks. "..repr(self.unit.BlueprintID))
            end
            
            if bp.RackSalvoReloadTime and (math.ceil(bp.RackSalvoReloadTime * 10) - self.ElapsedRackReloadTicks) > 0 then
            
                if WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." RackSalvoReloadTime waits "..math.ceil(bp.RackSalvoReloadTime * 10) - self.ElapsedRackReloadTicks.." ticks" )
                end
            
                WaitTicks( (math.ceil(bp.RackSalvoReloadTime * 10) - self.ElapsedRackReloadTicks) )
            end
            
            if self.BeamLifetimeWatch then
            
                while self.BeamLifetimeWatch do
                    WaitTicks(1)
                end

            end

            if self.RecoilManipulators then
                self:WaitForAndDestroyManips()
            end

            -- if the weapon has a target and is not a counted projectile
            if WeaponHasTarget( self ) and not bp.CountedProjectile then 

                LOUDSTATE(self, self.RackSalvoChargeState)

            else
           
                -- this just tests counted weapons to see if they have ammo
                -- all other weapons will return true
                self.WeaponCanFire = self:CanWeaponFire(bp,unit)

                -- if the weapon doesn't have a target but can fire
                if not WeaponHasTarget(self) and self.WeaponCanFire then
                
                    LOUDSTATE(self, self.WeaponPackingState)
                    
                else
           
                    if bp.RackReloadTimeout and (bp.RackReloadTimeout) > 1 then

                        if WeaponStateDialog then
                            LOG("*AI DEBUG DefaultWeapon RackSalvo Reload State "..repr(bp.Label).." - Rack Reload Timeout Waits "..repr(bp.RackReloadTimeout).." ticks" )		
                        end

                        WaitTicks( bp.RackReloadTimeout )
                    end
                    
                    if bp.CountedProjectile then
                        LOUDSTATE(self, self.WeaponPackingState)
                    else
                        LOUDSTATE(self, self.IdleState)
                    end    
                    
                end

            end
			
        end,

        OnFire = function(self)

        end,
        
        OnGotTarget = function(self)
        
        end,
    },

    WeaponPackingState = State {
	
        WeaponWantEnabled = false,
        WeaponAimWantEnabled = false,

        Main = function(self)
          
            local bp                    = self.bp
            local CountedProjectile     = bp.CountedProjectile
            local unit                  = self.unit
            
            local WeaponRepackTimeout   = bp.WeaponRepackTimeout or false
            local WeaponStateDialog     = ScenarioInfo.WeaponStateDialog
            
            if WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon WeaponPacking State "..repr(bp.Label).." at "..GetGameTick() )
			end
      
            if bp.WeaponUnpackLocksMotion then
                unit:SetImmobile(false)
            end

			-- reset the rack count
            self.CurrentRackNumber = 1

            self:PlayFxWeaponPackSequence(bp)
            
            self.ElapsedRepackTime = GetGameTick() - self.ElapsedRepackTime

            if self.ElapsedRepackTime > 0 and ( not WeaponRepackTimeout or (math.floor(WeaponRepackTimeout * 10) - self.ElapsedRepackTime < 0 ) ) then
                LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout (".. (WeaponRepackTimeout or 0) ..") - during pack - is either not existant or less than the WeaponUnpackAnimation - "..self.ElapsedRepackTime.." ticks. "..repr(unit.BlueprintID))
            end

			if WeaponRepackTimeout and (math.floor(WeaponRepackTimeout * 10) - self.ElapsedRepackTime) > 1 then
            
                if WeaponStateDialog then
                    if self.EconDrain then
                        LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout (EconDrain) "..repr(bp.Label).." at "..GetGameTick() )
                    else
                        LOG("*AI DEBUG DefaultWeapon WeaponRepackTimeout "..repr(bp.Label).." waits "..math.floor(WeaponRepackTimeout * 10) - self.ElapsedRepackTime.." ticks at "..GetGameTick() )
                    end
                end

                self:ChangeMaxRadius( 1 )

                WaitTicks( math.floor(WeaponRepackTimeout * 10) - self.ElapsedRepackTime )

                self.ElapsedRepackTime = self.ElapsedRepackTime + (math.floor(WeaponRepackTimeout * 10) - self.ElapsedRepackTime)

                self:ChangeMaxRadius( bp.MaxRadius )

			end

            -- this is a bit of kludge for projectile targeting weapons --
            -- we get here because we want those weapons to go offline for a spell
            -- so that inbound projectiles can be targeted by others, if needed (DesiredShooterCap)
            if CountedProjectile then
       
                if WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon WeaponPacking State (Counted Projectile) "..repr(bp.Label).." at "..GetGameTick() )
                end

                unit.HasTMLTarget = false
                
                if self.WeaponCanFire then
                
                    local target = WeaponHasTarget(self)
                
                    if target and not target.Dead then
                    
                        LOUDSTATE( self, self.RackSalvoChargeState)
                        
                    else
                        LOUDSTATE( self, self.IdleState )
                    end

                else
                    LOUDSTATE(self, self.WeaponEmptyState )
                end
            
            else
            
                if WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon WeaponPacking State "..repr(bp.Label).." complete at "..GetGameTick() )
                end

                LOUDSTATE(self, self.IdleState)
            
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

            else
                LOUDSTATE(self, self.RackSalvoChargeState)
            end
			
        end,

        OnGotTarget = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon WeaponPacking State "..repr(self.bp.Label).." OnGotTarget" )		
            end
            
            if not self.bp.ForceSingleFire then
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
            
            if self.BeamStarted then
            
                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG DefaultWeapon Dead State beam started "..repr(self.BeamStarted).." "..repr(self.Beams[1]) )
                end
                
                if self.Beams[1] then
                    self:PlayFxBeamEnd( self.Beams[1] )
                end
            end

        end,
    },
	
}

local DefaultProjectileWeaponOnCreate = DefaultProjectileWeapon.OnCreate

KamikazeWeapon = Class(DefaultProjectileWeapon) {

    OnWeaponFired = function(self)

        local unit = self.unit

        DamageArea( unit, unit:GetPosition(), self.bp.DamageRadius, self.bp.Damage, self.bp.DamageType or 'Normal', self.bp.DamageFriendly or false)
        
        LOUDSTATE( self, self.DeadState)
        
        unit:Kill()
    end,
 
}

BareBonesWeapon = Class(DefaultProjectileWeapon) {
    
    RackSalvoFireReadyState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
            
            local bp = self.bp
            local unit = self.unit
            
            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG BareBonesWeapon RackSalvo Fire Ready State "..repr(bp.Label).." at "..GetGameTick() )
            end

            self.WeaponCanFire = false
			
            if self.EconDrain then

                WaitFor(self.EconDrain)
                
                self.WeaponCharged = true
				
                RemoveEconomyEvent( unit, self.EconDrain )
				
                self.EconDrain = nil

                if ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG BareBonesWeapon RackSalvo Fire Ready State "..repr(self.bp.Label).." Economy Event Ends at "..GetGameTick() )
                end

            end
			
            self.WeaponCanFire = true

            LOUDSTATE(self, self.RackSalvoFiringState)

        end,

    },

    OnFire = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG BareBonesWeapon RackSalvo Fire Ready State "..repr(self.bp.Label).." OnFire at "..GetGameTick() )
        end

        local myProjectile = CreateProjectile( self.unit, projectilebp, 0, 0, 0, nil, nil, nil):SetCollision(false)
        
        if self.Data then
            myProjectile:PassData(self.Data)
        end
    end,

}

DefaultBeamWeapon = Class(DefaultProjectileWeapon) {

    BeamType = CollisionBeam,

    OnCreate = function(self)
		
        DefaultProjectileWeaponOnCreate(self)	

        self.Beams = {}
        
        local counter = 1
		local beam

        local bp                    = self.bp
        local beamcollisiondelay    = bp.BeamCollisionDelay or 0
        local label                 = bp.Label
        
        if bp.RackBones then

            for rk, rv in bp.RackBones do

                for mk, mv in rv.MuzzleBones do

                    --- create the beam -- initially disabled -- this will start the OnCreate in CollisionBeam
                    beam = self.BeamType{ BeamBone = 0, CollisionCheckInterval = beamcollisiondelay * 10, OtherBone = mv, Weapon = self }

                    beam.CollsionDelay  = beamcollisiondelay >= 0 
                    beam.DamageTable    = self.damageTable
                    beam.Label          = label
                    beam.Muzzle         = mv

                    beam:Disable()

                    if ScenarioInfo.WeaponDialog then
                        LOG("*AI DEBUG DefaultWeapon BEAM OnCreate for weapon "..repr(label).." on muzzle "..repr(mv).." for unit "..repr( self.unit.BlueprintID))
                    end

                    TrashAdd( self.Trash, beam)

                    self.Beams[counter] = { Beam = beam }
                    counter = counter + 1
                end

            end
        
            if ScenarioInfo.WeaponDialog then
                LOG("*AI DEBUG DefaultWeapon BEAM OnCreate beams table is "..repr(self.Beams) )
            end
        end

    end,

    CreateProjectileAtMuzzle = function(self, muzzle)
		
        local enabled = false
  	
		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG DefaultWeapon BEAM CreateProjectileAtMuzzle For "..repr(self.bp.Label).." for "..repr(__blueprints[self.unit.BlueprintID].Description) )
		end
		
        for _, v in self.Beams do
            if v.Beam.Muzzle == muzzle and v.Beam:IsEnabled() then
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
            if v.Beam.Muzzle == muzzle then
                beam = v.Beam
                break
            end
        end
		
        if not beam or beam:IsEnabled() then return end
	
        local bp = self.bp
		
        if bp.BeamLifetime > 0 then
            beam.BeamLifetimeWatch = self:ForkThread( self.BeamLifetimeThread, beam, bp.BeamLifetime or 1)
        end
		
        if bp.BeamLifetime == 0 then
            self.HoldFireThread = self:ForkThread(self.WatchForHoldFire, beam)
        end

        beam:Enable()
		
        TrashAdd( self.Trash, beam )
		
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
            LOG("*AI DEBUG DefaultWeapon BEAM Unpack Sequence "..repr(self.bp.Label) )
        end

        if ( self.bp.BeamLifetime > 0 ) or (( self.bp.BeamLifetime <= 0 ) and not self.ContBeamOn) then
        
            DefaultProjectileWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,

    IdleState = State (DefaultProjectileWeapon.IdleState) {
	
        Main = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon BEAM Idle State "..repr(self.bp.Label).." at "..GetGameTick() )
			end
       
            DefaultProjectileWeapon.IdleState.Main(self)
            
            self:PlayFxBeamEnd()
            
            self:ForkThread(self.ContinuousBeamFlagThread)
        end,
    },

    -- beam weapons will return to Idle State if not marked as 'charged'
    RackSalvoFireReadyState = State (DefaultProjectileWeapon.RackSalvoFireReadyState) {

        Main = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon BEAM Fire Ready State "..repr(self.bp.Label).." at "..GetGameTick() )
			end

            -- this had to have FirstShot included for backwards compatability
            if not self.WeaponCharged and not self.FirstShot then

                self:PlayFxBeamEnd()

                LOUDSTATE(self, self.IdleState)

                return
            end

            DefaultProjectileWeapon.RackSalvoFireReadyState.Main(self)
        end,
    },

    WeaponPackingState = State (DefaultProjectileWeapon.WeaponPackingState) {
	
        Main = function(self)

            if ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG DefaultWeapon BEAM Packing State "..repr(self.bp.Label).." at "..GetGameTick() )
			end
			
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

            if self.Beams then
            
                for _, v in self.Beams do

                    if beam then
                        if beam.Muzzle == v.Beam.Muzzle then
                            v.Beam:Disable()
                        end
                    else
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
    
        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon BEAM Lifetime Thread starts "..repr(self.bp.Label).." for beam on muzzle "..repr(beam.Muzzle).." at "..GetGameTick().." for "..lifeTime.." seconds" )        
        end

        WaitTicks( math.floor(lifeTime * 10.001) + 1 )
    
        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon BEAM Lifetime Thread ends "..repr(self.bp.Label).." for beam on muzzle "..repr(beam.Muzzle).." at "..GetGameTick() )
        end
        
        self.PlayFxBeamEnd( self, beam)

        beam.BeamLifetimeWatch = nil

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
    
    OnHaltFire = function(self)

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG DefaultWeapon BEAM OnHaltFire "..repr(self.bp.Label).." at "..GetGameTick() )
        end

        for _,v in self.Beams do

            if not v.Beam:IsEnabled() then
                continue
            end

            self:PlayFxBeamEnd( v.Beam )
        end
    end,


}

