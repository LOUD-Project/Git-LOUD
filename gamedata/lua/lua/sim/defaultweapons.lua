---  /lua/sim/DefaultWeapons.lua
---  Default definitions of weapons

local Weapon = import('/lua/sim/Weapon.lua').Weapon

local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local CalculateBallisticAcceleration = import('/lua/sim/CalcBallisticAcceleration.lua').CalculateBallisticAcceleration 

local LOUDABS = math.abs
local LOUDGETN = table.getn
local LOUDINSERT = table.insert

local CreateAnimator = CreateAnimator
local LOUDATTACHEMITTER = CreateAttachedEmitter

local LOUDSTATE = ChangeState
local ForkThread = ForkThread
local KillThread = KillThread
local WaitSeconds = WaitSeconds
local DamageArea = DamageArea

local GetBlueprint = moho.weapon_methods.GetBlueprint
local PlaySound = moho.weapon_methods.PlaySound
local SetBusy = moho.unit_methods.SetBusy

local CreateProjectile = moho.weapon_methods.CreateProjectile

local GetAIBrain = moho.entity_methods.GetAIBrain
local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome
local GetEconomyStored = moho.aibrain_methods.GetEconomyStored


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
		
        local bp = GetBlueprint(self)
		
        self.WeaponCanFire = true
        self.CurrentRackSalvoNumber = 1
		
        if bp.RackRecoilDistance and bp.RackRecoilDistance != 0 then
		
			if bp.MuzzleSalvoDelay != 0 then
				local strg = '*ERROR: You can not have a RackRecoilDistance with a MuzzleSalvoDelay not equal to 0, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
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
		
		if bp.MuzzleSalvoDelay != nil then
		
			local totalMuzzleFiringTime = ((NumMuzzles - 1) * bp.MuzzleSalvoDelay)
		
			if totalMuzzleFiringTime > (1 / bp.RateOfFire) and not bp.EnergyDrainPerSecond then
			
				local strg = '*ERROR: The total time to fire ('..totalMuzzleFiringTime..') '..NumMuzzles..' muzzles is longer than the RateOfFire '..bp.RateOfFire..' allows, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
				error(strg, 2)
				return false
				
			end
		else
			LOG("*AI DEBUG value is "..repr(bp.MuzzleSalvoDelay).." for "..repr(bp).." on unit "..self.BlurprintID)
		end
		
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
	
        if self.CBFP_CalcBallAcc.Do then
            local acc = CalculateBallisticAcceleration( self, proj, self.CBFP_CalcBallAcc.ProjectilesPerOnFire )
            proj:SetBallisticAcceleration( -acc) #-- change projectile trajectory so it hits the target, cure for engine bug
        end
    end,

	-- modded this so only retrieve bp if old or new is 'stopped'
    OnMotionHorzEventChange = function(self, new, old)
		
		if old == 'Stopped' then
		
			local bp = GetBlueprint(self)
		
			if bp.WeaponUnpackLocksMotion == true then
				self:PackAndMove()
			end
		
            if bp.FiringRandomnessWhileMoving then
                self:SetFiringRandomness(bp.FiringRandomnessWhileMoving)
            end
			
        elseif new == 'Stopped' then
		
			local bp = GetBlueprint(self)
			
			if bp.FiringRandomnessWhileMoving then
				self:SetFiringRandomness(bp.FiringRandomness or 0)
			end
        end
    end,

    CreateProjectileAtMuzzle = function(self, muzzle)
	
        local proj = self:CreateProjectileForWeapon(muzzle)
		
        if not proj or proj:BeenDestroyed()then
            return proj
        end
		
        local bp = GetBlueprint(self)

        if bp.DetonatesAtTargetHeight == true then
		
            local pos = self:GetCurrentTargetPos()
			
            if pos then
                local theight = GetSurfaceHeight(pos[1], pos[3])
                local hght = pos[2] - theight
                proj:ChangeDetonateAboveHeight(hght)
            end
        end
		
        if bp.Flare then
            proj:AddFlare(bp.Flare)
        end
		
        if self.unit:GetCurrentLayer() == 'Water' and bp.Audio.FireUnderWater then
            PlaySound( self, bp.Audio.FireUnderWater )
        elseif bp.Audio.Fire then
            PlaySound( self, bp.Audio.Fire)
        end
		
		if self.CBFP_CalcBallAcc then
			self:CheckBallisticAcceleration(proj)
		end
		
		if bp.CountedProjectile then
			self:CheckCountedMissileLaunch(bp)
		end

        return proj
    end,
	
	-- passed in the bp data to avoid the call
    CheckCountedMissileLaunch = function(self, bp)
	
		--LOG("*AI DEBUG CheckCountedMissileLaunch ")
		
        if bp.NukeWeapon then
            self.unit:OnCountedMissileLaunch('nuke')
        else
            self.unit:OnCountedMissileLaunch('tactical')
        end
    end,

	-- passed in the bp data to save the call
    StartEconomyDrain = function(self, bp)
	
        if self.FirstShot then return end
		
        local bp = bp or GetBlueprint(self)
		
        if not self.EconDrain and bp.EnergyRequired and bp.EnergyDrainPerSecond then
		
			local function ChargeProgress( self, progress)
				moho.unit_methods.SetWorkProgress( self, progress )
			end
		
            local nrgReq = self:GetWeaponEnergyRequired(bp)
            local nrgDrain = self:GetWeaponEnergyDrain(bp)
			
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

    -- The adjacency mod only effects the overall cost, not the drain per second. So, the drain will be about the same
    -- but the time it takes to drain will not be.
	-- passed in the bp data to save the call
    GetWeaponEnergyRequired = function(self, bp)
	
		local bp = bp or GetBlueprint(self)
        local weapNRG = (bp.EnergyRequired or 0) * (self.AdjEnergyMod or 1)
		
        if weapNRG < 0 then
            weapNRG = 0
        end

        return weapNRG
    end,

	-- passed in the bp data to save the call
    GetWeaponEnergyDrain = function(self, bp)
		
		local bp = bp or GetBlueprint(self)
        local weapNRG = (bp.EnergyDrainPerSecond or 0)
		
        return weapNRG
    end,

    -- Effect functions: Not only visual effects but also plays animations, recoil, etc.

    -- Played when a muzzle is fired.  Mostly used for muzzle flashes
    PlayFxMuzzleSequence = function(self, muzzle)
	
        local army = self.unit.Sync.army
		
        for _, v in self.FxMuzzleFlash do
            LOUDATTACHEMITTER(self.unit, muzzle, army, v):ScaleEmitter(self.FxMuzzleFlashScale)
        end
    end,

    -- Played during the beginning of the MuzzleChargeDelay time when a muzzle in a rack is fired.
    PlayFxMuzzleChargeSequence = function(self, muzzle)
	
        local army = self.unit.Sync.army
		
        for _, v in self.FxChargeMuzzleFlash do
            LOUDATTACHEMITTER(self.unit, muzzle, army, v):ScaleEmitter(self.FxChargeMuzzleFlashScale)
        end
    end,    

    -- Played when a rack salvo charges.  Do not put a wait in here or you'll
    -- make the time value in the bp off.  Spawn another thread to do waits.
    PlayFxRackSalvoChargeSequence = function(self, blueprint)
	
        local bp = blueprint or GetBlueprint(self)
        local army = self.unit.Sync.army
		
        for _, v in self.FxRackChargeMuzzleFlash do
		
            for _, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
			
                LOUDATTACHEMITTER(self.unit, ev, army, v):ScaleEmitter(self.FxRackChargeMuzzleFlashScale)
				
            end
			
        end
		
        if bp.Audio.ChargeStart then
		
            PlaySound( self, bp.Audio.ChargeStart)
			
        end
		
        if bp.AnimationCharge and not self.Animator then
		
            self.Animator = CreateAnimator(self.unit)
            self.Animator:PlayAnim( bp.AnimationCharge ):SetRate( bp.AnimationChargeRate or 1 )
			
        end
    end,

    -- Played when a rack salvo reloads.  Do not put a wait in here or you'll
    -- make the time value in the bp off.  Spawn another thread to do waits.
    PlayFxRackSalvoReloadSequence = function(self, blueprint)
	
        local bp = blueprint or GetBlueprint(self)
		
        self.Animator = CreateAnimator(self.unit)
		self.Animator:PlayAnim(bp.AnimationReload):SetRate(bp.AnimationReloadRate or 1)
		
    end,

    -- Played when a rack reloads. Mostly used for Recoil.
    PlayFxRackReloadSequence = function(self, blueprint)
	
        local bp = blueprint or GetBlueprint(self)
		
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

    -- Played when a weapon unpacks.  Here a wait is used because by definition a weapon can not fire while packed up.
    PlayFxWeaponUnpackSequence = function(self, blueprint)
	
        local bp = blueprint or GetBlueprint(self)
        local unitBP = self.unit:GetBlueprint()
		
        if unitBP.Audio.Activate then
            PlaySound( self, unitBP.Audio.Activate)
        end
        if unitBP.Audio.Open then
            PlaySound( self, unitBP.Audio.Open)
        end
        if bp.Audio.Unpack then
            PlaySound( self, bp.Audio.Unpack)
        end
        if bp.WeaponUnpackAnimation and not self.UnpackAnimator then
            self.UnpackAnimator = CreateAnimator(self.unit)
            self.UnpackAnimator:PlayAnim(bp.WeaponUnpackAnimation):SetRate(0)
            self.UnpackAnimator:SetPrecedence(bp.WeaponUnpackAnimatorPrecedence or 0)
            self.unit.Trash:Add(self.UnpackAnimator)
        end
        if self.UnpackAnimator then
            self.UnpackAnimator:SetRate(bp.WeaponUnpackAnimationRate)
            WaitFor(self.UnpackAnimator)
        end
    end,

    -- Played when a weapon packs up.  It has no target and is done with all of its rack salvos
    PlayFxWeaponPackSequence = function(self, blueprint)
	
        local bp = blueprint or GetBlueprint(self)
        local unitBP = self.unit:GetBlueprint()
		
        if unitBP.Audio.Close then
            PlaySound( self, unitBP.Audio.Close)
        end
        if bp.WeaponUnpackAnimation and self.UnpackAnimator then
            self.UnpackAnimator:SetRate(-bp.WeaponUnpackAnimationRate)
        end
        if self.UnpackAnimator then
            WaitFor(self.UnpackAnimator)
        end
    end,

    PlayRackRecoil = function(self, rackList, blueprint)
	
        local bp = blueprint or GetBlueprint(self)
		
        for _, v in rackList do
		
            local tmpSldr = CreateSlider(self.unit, v.RackBone)
			
            LOUDINSERT(self.RecoilManipulators, tmpSldr)
			
            tmpSldr:SetPrecedence(11)
            tmpSldr:SetGoal(0, 0, bp.RackRecoilDistance)
            tmpSldr:SetSpeed(-1)
			
            self.unit.Trash:Add(tmpSldr)
			
            if v.TelescopeBone then
                tmpSldr = CreateSlider(self.unit, v.TelescopeBone)
                LOUDINSERT(self.RecoilManipulators, tmpSldr)
                tmpSldr:SetPrecedence(11)
                tmpSldr:SetGoal(0, 0, v.TelescopeRecoilDistance or bp.RackRecoilDistance)
                tmpSldr:SetSpeed(-1)
                self.unit.Trash:Add(tmpSldr)
            end
        end
        self:ForkThread(self.PlayRackRecoilReturn, rackList)
    end,

    PlayRackRecoilReturn = function(self, rackList)
	
        WaitTicks(1)
		
        for _, v in rackList do
            for _, mv in self.RecoilManipulators do
                mv:SetGoal(0, 0, 0)
                mv:SetSpeed(self.RackRecoilReturnSpeed)
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

		--LOG("*AI DEBUG OnLostTarget")
		
        Weapon.OnLostTarget(self)
		
        local bp = self:GetBlueprint()
		
        if bp.WeaponUnpacks == true then
            LOUDSTATE(self, self.WeaponPackingState)
        else
            LOUDSTATE(self, self.IdleState)
        end
    end,

    OnDestroy = function(self)
        LOUDSTATE(self, self.DeadState)
    end,

    OnEnterState = function(self)
	
        if self.WeaponWantEnabled and not self.WeaponIsEnabled then
		
            self.WeaponIsEnabled = true
            self:SetWeaponEnabled(true)
			
        elseif not self.WeaponWantEnabled and self.WeaponIsEnabled then
		
            local bp = self:GetBlueprint()
			
            if bp.CountedProjectile != true then
                self.WeaponIsEnabled = false
                self:SetWeaponEnabled(false)
            end
        end
		
        if self.WeaponAimWantEnabled and not self.WeaponAimIsEnabled then
		
            self.WeaponAimIsEnabled = true
            self:AimManipulatorSetEnabled(true)
			
        elseif not self.WeaponAimWantEnabled and self.WeaponAimIsEnabled then
		
            self.WeaponAimIsEnabled = false
            self:AimManipulatorSetEnabled(false)
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

		Weapon.OnWeaponFired(self)
		
    end,

    OnEnableWeapon = function(self)
    end,


    -- WEAPON STATES:

    -- A Weapon is idle state when it has no target
	-- also note that a weapon is created BEFORE the actual unit is completed - so you'll see
	-- any first shot charging take place before the unit is finished - that's ok.
    IdleState = State {
	
		WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
		
			--LOG("*AI DEBUG Weapon Idle State")

            if self.unit.Dead then return end
            
            self.unit:SetBusy(false)
            self:WaitForAndDestroyManips()
            
            local bp = GetBlueprint(self)
			
            for _, v in bp.RackBones do
			
                if v.HideMuzzle == true then
				
                    for _, mv in v.MuzzleBones do
					
                        self.unit:ShowBone(mv, true)
						
                    end
					
                end
				
            end

			if bp.EnergyRequired and bp.EnergyDrainPerSecond then
            
				self:StartEconomyDrain(bp)
			
			end
            
			-- if the weapon has fired prior to coming back to Idle, execute the reload timeout
			-- and reset the rack salvo number back to 1
			-- NOTE: This is setup so that it only works if there is more than 1 rack
            if LOUDGETN(bp.RackBones) > 1 and self.CurrentRackSalvoNumber > 1 then
			
				--LOG("*AI DEBUG Weapon IdleState RackReload")
            
                WaitSeconds(bp.RackReloadTimeout)
                
                if bp.AnimationReload and not self.Animator then
                    self:PlayFxRackSalvoReloadSequence(bp)
                end
                
                self.CurrentRackSalvoNumber = 1
            end
			
        end,

        OnGotTarget = function(self)
		
			--LOG("*AI DEBUG Weapon IdleState OnGotTarget")

            local bp = GetBlueprint(self)
	
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
		
			--LOG("*AI DEBUG Weapon IdleState OnFire")
	
            local bp = GetBlueprint(self)
			
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
		
			--LOG("*AI DEBUG Weapon Unpacking State")
		
            self.unit:SetBusy(true)

            local bp = GetBlueprint(self)
            
            if bp.WeaponUnpackLocksMotion then
			
                self.unit:SetImmobile(true)
				
            end
            
            self:PlayFxWeaponUnpackSequence(bp)
			
            local rackSalvoChargeTime = bp.RackSalvoChargeTime
            
            if rackSalvoChargeTime and rackSalvoChargeTime > 0 then
			
                LOUDSTATE(self, self.RackSalvoChargeState)
				
            else
			
                LOUDSTATE(self, self.RackSalvoFireReadyState)
				
            end
        end,

        OnFire = function(self)
		
			--LOG("*AI DEBUG Weapon Unpacking State OnFire")

        end,
    },
	

    RackSalvoChargeState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
		
			--LOG("*AI DEBUG Weapon RackSalvo Charge State")
			
            self.unit:SetBusy(true)
			
            local bp = GetBlueprint(self)
			
            self:PlayFxRackSalvoChargeSequence(bp)
			
            if bp.NotExclusive then
                self.unit:SetBusy(false)
            end
            
            WaitSeconds(bp.RackSalvoChargeTime)
            
            if bp.NotExclusive then
                self.unit:SetBusy(true)
            end
            
            if bp.RackSalvoFiresAfterCharge == true then
			
                LOUDSTATE(self, self.RackSalvoFiringState)
				
            else
			
                LOUDSTATE(self, self.RackSalvoFireReadyState)
				
            end
			
        end,

        OnFire = function(self)
		
			--LOG("*AI DEBUG Weapon RackSalvo Charge OnFire")

        end,
    },

    RackSalvoFireReadyState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)

			--LOG("*AI DEBUG Weapon RackSalvo FireReady State")
			
            local bp = GetBlueprint(self)
			
            if (bp.CountedProjectile == true and bp.WeaponUnpacks == true) then
			
                self.unit:SetBusy(true)
				
            else
			
                self.unit:SetBusy(false)
				
            end
			
            self.WeaponCanFire = false
			
            if self.EconDrain then
			
				--LOG("*AI DEBUG Weapon RackSalvo FireReady - waiting for eco drain")

                WaitFor(self.EconDrain)
				
                RemoveEconomyEvent(self.unit, self.EconDrain)
				
                self.EconDrain = nil

            end
			
            self.WeaponCanFire = true

            --We change the state on counted projectiles because we won't get another OnFire call.
            --The second part is a hack for units with reload animations.  They have the same problem
            --they need a RackSalvoReloadTime that's 1/RateOfFire set to avoid firing twice on the first shot
            if bp.CountedProjectile == true or bp.AnimationReload then
			
                LOUDSTATE(self, self.RackSalvoFiringState)
				
            end
        end,

		-- while debugging the WeaponUnpackLocksMotion I discovered that if you have the value NeedsUnpack = true in the AI section
		-- then the weapon will Never do an OnFire() event unless the unit is set to IMMOBILE
        OnFire = function(self)

			--LOG("*AI DEBUG Weapon RackSalvo FireReady OnFire")
			
            if self.WeaponCanFire then
                LOUDSTATE(self, self.RackSalvoFiringState)
            end
			
        end,
    },

    RackSalvoFiringState = State {
	
        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)

			--LOG("*AI DEBUG Weapon RackSalvo Firing State")
			
            self.unit:SetBusy(true)
			
            local bp = GetBlueprint(self)
			
			if self.RecoilManipulators then
				self:DestroyRecoilManips()
			end
			
            local numRackFiring = self.CurrentRackSalvoNumber
		
			local RacksToBeFired = LOUDGETN(bp.RackBones)
			
            if bp.RackFireTogether == true then
                numRackFiring = RacksToBeFired
            end			

            -- Most of the time this will only run once, the only time it doesn't is when racks fire together.
            while self.CurrentRackSalvoNumber <= numRackFiring and not self.HaltFireOrdered do
			
                local rackInfo = bp.RackBones[self.CurrentRackSalvoNumber]			
				
				local MuzzlesToBeFired = LOUDGETN(bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones)
                local numMuzzlesFiring = bp.MuzzleSalvoSize

                if bp.MuzzleSalvoDelay == 0 then
                    numMuzzlesFiring = MuzzlesToBeFired
                end
				
                local muzzleIndex = 1
	
				-- fire all the muzzles --
                for i = 1, numMuzzlesFiring do
				
					--LOG("*AI DEBUG Weapon RackSalvo Firing State Rack "..repr(self.CurrentRackSalvoNumber).." firing muzzle "..repr(i).." of "..repr(numMuzzlesFiring) )
				
                    if self.HaltFireOrdered then
                        continue
                    end
					
                    local muzzle = rackInfo.MuzzleBones[muzzleIndex]
					
                    if rackInfo.HideMuzzle == true then
                        self.unit:ShowBone(muzzle, true)
                    end
					
					-- muzzle charge delay -- 
                    if bp.MuzzleChargeDelay and bp.MuzzleChargeDelay > 0 then
					
                        if bp.Audio.MuzzleChargeStart then
                            PlaySound( self, bp.Audio.MuzzleChargeStart)
                        end
						
                        self:PlayFxMuzzleChargeSequence(muzzle)
						
                        if bp.NotExclusive then
                            self.unit:SetBusy(false)
                        end
						
                        WaitSeconds(bp.MuzzleChargeDelay)
						
                        if bp.NotExclusive then
                            self.unit:SetBusy(true)
                        end
						
                    end
					
                    self:PlayFxMuzzleSequence(muzzle)                    
					
                    if rackInfo.HideMuzzle == true then
                        self.unit:HideBone(muzzle, true)
                    end
					
                    if self.HaltFireOrdered then
                        continue
                    end
					
					-- create the projectile --
                    self:CreateProjectileAtMuzzle(muzzle)

                    if bp.CountedProjectile == true then
					
                        if bp.NukeWeapon == true then
						
                            self.unit:NukeCreatedAtUnit()
                            self.unit:RemoveNukeSiloAmmo(1)
							
                        else
						
                            self.unit:RemoveTacticalSiloAmmo(1)
							
                        end
						
                    end
					
                    muzzleIndex = muzzleIndex + 1

					-- reset the muzzle index if fired all muzzles
                    if muzzleIndex > MuzzlesToBeFired then
                        muzzleIndex = 1
                    end
					
					-- muzzle salvo delay -- 
                    if bp.MuzzleSalvoDelay > 0 then
					
                        if bp.NotExclusive then
                            self.unit:SetBusy(false)
                        end
						
                        WaitSeconds(bp.MuzzleSalvoDelay)
						
                        if bp.NotExclusive then
                            self.unit:SetBusy(true)
                        end
						
                    end
					
                end
                
                if bp.CameraShakeRadius or bp.ShipRock or bp.RackRecoilDistance != 0 then
                    self:PlayFxRackReloadSequence(bp)
                end
				
				-- advance the rack number --
                if self.CurrentRackSalvoNumber <= RacksToBeFired then
                    self.CurrentRackSalvoNumber = self.CurrentRackSalvoNumber + 1
                end
				
            end

			if bp.Buffs then
				self:DoOnFireBuffs(bp.Buffs)
			end

            self.FirstShot = false

            self:OnWeaponFired()

            self:StartEconomyDrain(bp)
			
            if bp.RenderFireClock and bp.RateOfFire > 0 then
			
	            if not self:BeenDestroyed() and not self.unit.Dead then
				
                    local rof = 1 / bp.RateOfFire                
                    self:ForkThread(self.RenderClockThread, rof)                
                end
            end

            self.HaltFireOrdered = false

			-- if all the racks have fired --
            if self.CurrentRackSalvoNumber > RacksToBeFired then
			
				-- reset the rack count
                self.CurrentRackSalvoNumber = 1
				
				-- OK so this is revealing - neither one of these is often used but its clear
				-- that ChargeTime here
				
                if bp.RackSalvoReloadTime > 0 then
				
                    LOUDSTATE(self, self.RackSalvoReloadState)
					
                elseif bp.RackSalvoChargeTime > 0 then
				
                    LOUDSTATE(self, self.IdleState)
					
                elseif bp.CountedProjectile == true then
				
					if bp.WeaponUnpacks == true then
					
						LOUDSTATE(self, self.WeaponPackingState)
						
					else
					
						LOUDSTATE(self, self.IdleState)
						
					end
					
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
		
			--LOG("*AI DEBUG Weapon RackSalvo Firing State OnFire")

		end,

        OnLostTarget = function(self)
		
			--LOG("*AI DEBUG Weapon RackSalvo Firing State OnLostTarget")		
		
            Weapon.OnLostTarget(self)
			
            if self:GetBlueprint().WeaponUnpacks == true then
			
                LOUDSTATE(self, self.WeaponPackingState)
				
            end
			
        end,

        -- Set a bool so we won't fire if the target reticle is moved
        OnHaltFire = function(self)
		
			--LOG("*AI DEBUG Weapon RackSalvo Firing State OnHaltFire")
			
            self.HaltFireOrdered = true
        end,
		
        RenderClockThread = function(self, rof)
		
            local clockTime = rof
			local WaitTicks = coroutine.yield
			
            while clockTime > 0.0 and not self:BeenDestroyed() and not self.unit.Dead do
			
                self.unit:SetWorkProgress( 1 - clockTime / rof )
                clockTime = clockTime - 0.1
                WaitTicks(1)
				
            end
			
        end,
    },

    RackSalvoReloadState = State {

        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)
		
			--LOG("*AI DEBUG Weapon RackSalvo Reload State")		

            self.unit:SetBusy(true)
			
            local bp = self:GetBlueprint()
            
            if bp.AnimationReload and not self.Animator then
                self:PlayFxRackSalvoReloadSequence(bp)
            end
			
            if bp.NotExclusive then
                self.unit:SetBusy(false)
            end
            
            WaitSeconds(bp.RackSalvoReloadTime)
			
            self:WaitForAndDestroyManips()
            
            if bp.NotExclusive then
                self.unit:SetBusy(true)
            end
			
			--LOG("*AI DEBUG Has Target is "..repr(self:WeaponHasTarget()).." Can Fire is "..repr(self:CanWeaponFire()))
			
            if self:WeaponHasTarget() and bp.RackSalvoChargeTime > 0 and self:CanWeaponFire() then
			
                LOUDSTATE(self, self.RackSalvoChargeState)
				
            elseif self:WeaponHasTarget() and self:CanWeaponFire() then
			
				if not bp.ManualFire then
			
					LOUDSTATE(self, self.RackSalvoFireReadyState)
					
				else
				
					if bp.WeaponUnpacks == true then
						
						LOUDSTATE(self, self.WeaponPackingState)

					else
					
						LOUDSTATE(self, self.IdleState)
						
					end
				
				end
				
            elseif not self:WeaponHasTarget() and bp.WeaponUnpacks == true and bp.WeaponUnpackLocksMotion != true then
			
                LOUDSTATE(self, self.WeaponPackingState)
				
            else
			
                LOUDSTATE(self, self.IdleState)
				
            end
			
        end,

        OnFire = function(self)
		
			--LOG("*AI DEBUG Weapon RackSalvo Reload State OnFire")		

        end,
    },

    WeaponPackingState = State {
	
        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        Main = function(self)

			--LOG("*AI DEBUG Weapon WeaponPacking State")
			
            self.unit:SetBusy(true)
			
            local bp = GetBlueprint(self)
            
			if bp.WeaponRepackTimeout then
				WaitSeconds(bp.WeaponRepackTimeout)
			end
			
            self:AimManipulatorSetEnabled(false)
			
            self:PlayFxWeaponPackSequence(bp)
            
            if bp.WeaponUnpackLocksMotion then
                self.unit:SetImmobile(false)
            end
			
            LOUDSTATE(self, self.IdleState)
			
        end,

        OnGotTarget = function(self)
		
			--LOG("*AI DEBUG Weapon WeaponPacking State OnGotTarget")		
		
            if not GetBlueprint(self).ForceSingleFire then
			
                LOUDSTATE(self, self.WeaponUnpackingState)
				
            end
			
        end,

        -- Override so that it doesn't play the firing sound when
        -- we're not actually creating the projectile yet
        OnFire = function(self)
		
            local bp = GetBlueprint(self)
			
			--LOG("*AI DEBUG Weapon WeaponPacking State OnFire")			
			
            if bp.CountedProjectile == true and not bp.ForceSingleFire then
			
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
        local myBlueprint = GetBlueprint(self)
        DamageArea(self.unit, self.unit:GetPosition(), myBlueprint.DamageRadius, myBlueprint.Damage, myBlueprint.DamageType or 'Normal', myBlueprint.DamageFriendly or false)
        self.unit:Kill()
    end,
}

BareBonesWeapon = Class(Weapon) {
    Data = {},

    OnFire = function(self)
        local myBlueprint = GetBlueprint(self)
        local myProjectile = CreateProjectile( self.unit, myBlueprint.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
        if self.Data then
            myProjectile:PassData(self.Data)
        end
    end,
}

DefaultBeamWeapon = Class(DefaultProjectileWeapon) {

    BeamType = CollisionBeam,

    OnCreate = function(self)
	
        self.Beams = {}
		
        local bp = GetBlueprint(self)

        for rk, rv in bp.RackBones do
		
			local LOUDINSERT = table.insert
			
            for mk, mv in rv.MuzzleBones do
			
                local beam
				
                beam = self.BeamType{
                    Weapon = self,
                    BeamBone = 0,
                    OtherBone = mv,
                    CollisionCheckInterval = bp.BeamCollisionDelay * 10,
                }
				
                local beamTable = { Beam = beam, Muzzle = mv, Destroyables = {} }
				
                LOUDINSERT(self.Beams, beamTable)
				
                self.unit.Trash:Add(beam)
                beam:SetParentWeapon(self)
                beam:Disable()
				
            end
			
        end
		
        DefaultProjectileWeapon.OnCreate(self)
    end,

    CreateProjectileAtMuzzle = function(self, muzzle)
		
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
        
        local bp = GetBlueprint(self)
        
        if self.unit:GetCurrentLayer() == 'Water' and bp.Audio.FireUnderWater then
            PlaySound( self, bp.Audio.FireUnderWater )
        elseif bp.Audio.Fire then
            PlaySound( self, bp.Audio.Fire)
        end
    end,

    PlayFxBeamStart = function(self, muzzle)
	
        local bp = GetBlueprint(self)
		
        self.BeamDestroyables = {}
		
        local beam
        local beamTable
		
        for _, v in self.Beams do
            if v.Muzzle == muzzle then
                beam = v.Beam
                beamTable = v
            end
        end
		
        if beam:IsEnabled() then return end
		
        beam:Enable()
		
        self.unit.Trash:Add(beam)
		
        if bp.BeamLifetime > 0 then
            self:ForkThread(self.BeamLifetimeThread, beam, bp.BeamLifetime or 1)
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
	
        local bp = GetBlueprint(self)
		
        if (bp.BeamLifetime > 0) or ((bp.BeamLifetime <= 0) and not self.ContBeamOn) then
            DefaultProjectileWeapon.PlayFxWeaponUnpackSequence(self,bp)
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
            local bp = GetBlueprint(self)

            if (bp.BeamLifetime > 0) then
                self:PlayFxBeamEnd()
            else
                self.ContBeamOn = true
            end
            DefaultProjectileWeapon.WeaponPackingState.Main(self)
        end,
    },

    PlayFxBeamEnd = function(self, beam)
	
        if not self.unit.Dead then
		
            local bp = GetBlueprint(self)
			
            if bp.Audio.BeamStop and self.BeamStarted then
                PlaySound( self, bp.Audio.BeamStop )
            end
			
            if bp.Audio.BeamLoop and self.Beams[1].Beam then
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
        self.ContBeamOn = false
    end,

    BeamLifetimeThread = function(self, beam, lifeTime)
        WaitTicks(lifeTime * 10)
		WaitTicks(1)
        self:PlayFxBeamEnd(beam)
    end,
    
    WatchForHoldFire = function(self, beam)
		WaitTicks = coroutine.yield
        while true do
            WaitTicks(10)

            if self.unit and self.unit:GetFireState() == 1 then
                self.BeamStarted = false
                self:PlayFxBeamEnd(beam)
            end
        end
    end,
    
    StartEconomyDrain = function(self)
	
        local bp = GetBlueprint(self)
		
        if not self.EconDrain and bp.EnergyRequired and bp.EnergyDrainPerSecond then
            if not self:EconomySupportsBeam() then
                return
            end
        end
		
        DefaultProjectileWeapon.StartEconomyDrain(self,bp)
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
        local energyIncome = GetEconomyIncome( aiBrain, 'ENERGY' ) * 10 # per tick to per seconds
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

