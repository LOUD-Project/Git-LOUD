---  /lua/sim/Weapon.lua
---  Summary  : The base weapon class for all weapons in the game.

local LOUDENTITY = EntityCategoryContains
local ParseEntityCategory = ParseEntityCategory

local LOUDCOPY = table.copy
local LOUDFLOOR = math.floor
local LOUDINSERT = table.insert
local LOUDPARSE = ParseEntityCategory
local LOUDREMOVE = table.remove

local LOUDCREATEPROJECTILE = moho.weapon_methods.CreateProjectile

local ForkThread = ForkThread
local ForkTo = ForkThread

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local WaitSeconds = WaitSeconds
local WaitTicks = coroutine.yield

local BeenDestroyed = moho.entity_methods.BeenDestroyed
local GetBlueprint = moho.weapon_methods.GetBlueprint
local PlaySound = moho.weapon_methods.PlaySound

local SetBoneEnabled = moho.AnimationManipulator.SetBoneEnabled
local SetEnabled = moho.AimManipulator.SetEnabled
local SetFiringArc = moho.AimManipulator.SetFiringArc

local SetFireTargetLayerCaps = moho.weapon_methods.SetFireTargetLayerCaps
local SetResetPoseTime = moho.AimManipulator.SetResetPoseTime
local SetTargetingPriorities = moho.weapon_methods.SetTargetingPriorities

local PassDamageData = import('/lua/sim/Projectile.lua').Projectile.PassDamageData

local MISSILEOPTION = tonumber(ScenarioInfo.Options.MissileOption)
local STRUCTURE = categories.STRUCTURE

--LOG("*AI DEBUG Weapon Methods are "..repr(moho.weapon_methods))

Weapon = Class(moho.weapon_methods) {

    __init = function(self, unit)

        -- this captures the parent unit of the weapon
        self.unit = unit
        
    end,

    ForkThread = function(self, fn, ...)
    
        local thread = ForkThread(fn, self, unpack(arg))
        
		TrashAdd( self.Trash, thread )
        
        return thread
    end,

    OnCreate = function(self)
        
        local LOUDCOPY = LOUDCOPY
        local LOUDFLOOR = LOUDFLOOR
        local WaitTicks = WaitTicks

		-- use the trash on the parent unit
		--self.Trash = self.unit.Trash
        self.Trash = TrashBag()

        -- store the blueprint of the weapon 
        self.bp = GetBlueprint(self)
		
        local bp = self.bp

		if ScenarioInfo.WeaponDialog then
			LOG("*AI DEBUG Weapon OnCreate for "..repr(__blueprints[self.unit.BlueprintID].Description).." "..self.unit.EntityID.." -- "..repr(self.bp.Label) )
		end

        -- brought this function local since it's the only place it gets called
        if bp.Turreted == true then
		
            local CreateAimController = CreateAimController
            local SetPrecedence = moho.manipulator_methods.SetPrecedence
            
            local yawBone = bp.TurretBoneYaw
            local pitchBone = bp.TurretBonePitch
            local muzzleBone = bp.TurretBoneMuzzle
            local precedence = bp.AimControlPrecedence or 10
            local pitchBone2
            local muzzleBone2
		
            if bp.TurretBoneDualPitch and bp.TurretBoneDualPitch != '' then
                pitchBone2 = bp.TurretBoneDualPitch
            end
		
            if bp.TurretBoneDualMuzzle and bp.TurretBoneDualMuzzle != '' then
                muzzleBone2 = bp.TurretBoneDualMuzzle
            end

            if yawBone and pitchBone and muzzleBone then
		
                if bp.TurretDualManipulators then
			
                    if not bp.TurretBoneAimYaw then
                        self.AimControl = CreateAimController(self, 'Torso', yawBone)
                    else
                        self.AimControl = CreateAimController(self, 'Torso', bp.TurretBoneAimYaw)
                    end
				
                    self.AimRight = CreateAimController(self, 'Right', pitchBone, pitchBone, muzzleBone)
                    self.AimLeft = CreateAimController(self, 'Left', pitchBone2, pitchBone2, muzzleBone2)
				
                    SetPrecedence( self.AimControl, precedence )
                    SetPrecedence( self.AimRight, precedence)
                    SetPrecedence( self.AimLeft, precedence)
				
                    if LOUDENTITY(STRUCTURE, self.unit) then
                        SetResetPoseTime( self.AimControl, 9999999 )
                    end
				
                    self:SetFireControl('Right')
                    
                    TrashAdd( self.Trash, self.AimControl )
                    TrashAdd( self.Trash, self.AimRight )
                    TrashAdd( self.Trash, self.AimLeft )
				
                else
                
                    if not bp.TurretBoneAimYaw then
                        self.AimControl = CreateAimController(self, 'Default', yawBone, pitchBone, muzzleBone)
                    else
                        self.AimControl = CreateAimController(self, 'Default', bp.TurretBoneAimYaw, pitchBone, muzzleBone)
                    end
				
                    if LOUDENTITY(STRUCTURE, self.unit) then
                        SetResetPoseTime( self.AimControl,9999999 )
                    end
				
                    TrashAdd( self.unit.Trash, self.AimControl )
                    
                    SetPrecedence( self.AimControl, precedence)
				
                    if bp.RackSlavedToTurret and bp.RackBones[1] then
                    
                        for k, v in bp.RackBones do

                            if v.RackBone != pitchBone then
                            
                                local slaver = CreateSlaver(self.unit, v.RackBone, pitchBone)
                                
                                SetPrecedence( slaver, precedence-1 )
                                
                                TrashAdd( self.Trash, slaver )
                            end
                        end
                    end
                end

            end

            local numbersexist = true
		
            local turretyawmin, turretyawmax, turretyawspeed
            local turretpitchmin, turretpitchmax, turretpitchspeed
        
            if bp.TurretYaw and bp.TurretYawRange then
                turretyawmin = bp.TurretYaw - bp.TurretYawRange
                turretyawmax = bp.TurretYaw + bp.TurretYawRange
            else
                numbersexist = false
            end
        
            if bp.TurretYawSpeed then
                turretyawspeed = bp.TurretYawSpeed
            else
                numbersexist = false
            end
        
            if bp.TurretPitch and bp.TurretPitchRange then
                turretpitchmin = bp.TurretPitch - bp.TurretPitchRange
                turretpitchmax = bp.TurretPitch + bp.TurretPitchRange
            else
                numbersexist = false
            end
        
            if bp.TurretPitchSpeed then
                turretpitchspeed = bp.TurretPitchSpeed
            else
                numbersexist = false
            end
        
            if numbersexist then
		
                SetFiringArc( self.AimControl, turretyawmin, turretyawmax, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
                
                if self.AimRight then
                    SetFiringArc( self.AimRight, turretyawmin/12, turretyawmax/12, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
                end
			
                if self.AimLeft then
                    SetFiringArc( self.AimLeft, turretyawmin/12, turretyawmax/12, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
                end
            end
        end

		-- store weapon buffs on the weapon itself so 
		-- we can bypass GetBlueprint every time the weapon fires
		if bp.Buffs then
			self.Buffs = LOUDCOPY(bp.Buffs)
		end

		-- if a weapon fires a round with these parameters 
		-- flag it so we can avoid GetBlueprint when it is NOT
        if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeOuterRingTicks and bp.NukeOuterRingTotalTime and
            bp.NukeInnerRingDamage and bp.NukeInnerRingRadius and bp.NukeInnerRingTicks and bp.NukeInnerRingTotalTime then
			
			self.NukeWeapon = true
		end

        self:SetValidTargetsForCurrentLayer( self.unit.CacheLayer, bp)
		
		-- next 3 conditions are for adv missile track and retarget
        if bp.advancedTracking then
		
        	self.advancedTracking = bp.advancedTracking
 		
			-- calc a lifetime if one is not provided
			if bp.ProjectileLifetime then
				self.ProjectileLifetime = bp.ProjectileLifetime
			else
				self.ProjectileLifetime = (bp.MaxRadius / bp.MuzzleVelocity) * 1.15
			end
		
			-- calc tracking radius if not provided
            -- if not set, the default is one - that's no good
            -- we'll force it to the MaxRadius
			if bp.TrackingRadius > 1 then
				self.TrackingRadius = bp.TrackingRadius
			else
				self.TrackingRadius = bp.MaxRadius
			end
            
            if bp.TargetRestrictOnlyAllow then
                self.TargetRestrictOnlyAllow = bp.TargetRestrictOnlyAllow
            end
		
		end
		
        self:SetWeaponPriorities(bp.TargetPriorities)
		
        local initStore = MISSILEOPTION or bp.InitialProjectileStorage or 0
		
        if initStore > 0 then
		
			-- if the weapon cant hold that amount - set it to its max amount
            if bp.MaxProjectileStorage and bp.MaxProjectileStorage < initStore then
                initStore = bp.MaxProjectileStorage
            end
			
            local nuke = false
			
            if bp.NukeWeapon then
                nuke = true
            end

            local function AmmoThread(amount)
	
                if not BeenDestroyed(self.unit) then
		
                    if nuke then
                        self.unit:GiveNukeSiloAmmo(amount)
                    else
                        self.unit:GiveTacticalSiloAmmo(amount)
                    end
                end

                WaitTicks(2)

            end
			
            ForkThread( AmmoThread, LOUDFLOOR(initStore))
        end
		
		self:SetDamageTable(bp)

    end,

    OnDestroy = function(self)
		-- this only triggers when the unit itself is destroyed
		-- but I don't see it all the time
		--if ScenarioInfo.WeaponDialog then
			--LOG("*AI DEBUG Weapon OnDestroy ")
		--end

        TrashDestroy(self.Trash)
    end,

    AimManipulatorSetEnabled = function(self, enabled)
 	
        if self.AimControl then
       
            if self.WeaponAimEnabled != enabled then
   
                if ScenarioInfo.WeaponDialog or ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG Weapon "..repr(self.bp.Label).." Aim Control is "..repr(self.WeaponAimEnabled).." at "..GetGameTick().." setting to "..repr(enabled) )
                end
                
                if self.unit.Dead then return end

                SetEnabled( self.AimControl, enabled )

                self.WeaponAimEnabled = enabled
                
            end
        end
		
    end,

    GetAimManipulator = function(self)
        return self.AimControl
    end,

    SetTurretYawSpeed = function(self, speed)
	
        local turretyawmin, turretyawmax = self:GetTurretYawMinMax()
        local turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
        local turretpitchspeed = self:GetTurretPitchSpeed()
		
        if self.AimControl then
            SetFiringArc( self.AimControl, turretyawmin, turretyawmax, speed, turretpitchmin, turretpitchmax, turretpitchspeed)
        end
    end,

    SetTurretPitchSpeed = function(self, speed)
	
        local turretyawmin, turretyawmax = self:GetTurretYawMinMax()
        local turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
        local turretpitchspeed = self:GetTurretYawSpeed()
		
        if self.AimControl then
            SetFiringArc( self.AimControl, turretyawmin, turretyawmax, turretyawspeed, turretpitchmin, turretpitchmax, speed)
        end
    end,

    GetTurretYawMinMax = function(self,blueprint)
        return self.bp.TurretYaw - self.bp.TurretYawRange, self.bp.TurretYaw + self.bp.TurretYawRange
    end,

    GetTurretYawSpeed = function(self,blueprint)
        return self.bp.TurretYawSpeed
    end,

    GetTurretPitchMinMax = function(self,blueprint)
        return self.bp.TurretPitch - self.bp.TurretPitchRange, self.bp.TurretPitch + self.bp.TurretPitchRange
    end,

    GetTurretPitchSpeed = function(self,blueprint)
        return self.bp.TurretPitchSpeed
    end,

    Fire = function(self)
    
    end,
    
    OnFire = function(self)
	
		if ScenarioInfo.WeaponDialog then
			LOG("*AI DEBUG Weapon OnFire for "..repr(__blueprints[self.unit.BlueprintID].Description).." "..repr(self.bp.Label).." on tick "..GetGameTick() )
		end

		if self.Buffs then
			self:DoOnFireBuffs(self.Buffs)
		end
    end,

	OnWeaponFired = function(self, target)
	
		if ScenarioInfo.WeaponDialog then
			LOG("*AI DEBUG Weapon OnWeaponFired for "..repr(__blueprints[self.unit.BlueprintID].Description).." "..repr(self.bp.Label).." on tick "..GetGameTick() )
		end

	end,

    OnDisableWeapon = function(self)
	
        if ScenarioInfo.WeaponDialog then
            LOG("*AI DEBUG Weapon OnDisableWeapon for "..repr(__blueprints[self.unit.BlueprintID].Description).." "..repr(self.bp.Label).." on tick "..GetGameTick() )
        end

    end,
    
    OnEnableWeapon = function(self)
	
        if ScenarioInfo.WeaponDialog then
            LOG("*AI DEBUG Weapon OnEnableWeapon for "..repr(__blueprints[self.unit.BlueprintID].Description).." "..repr(self.bp.Label).." on tick "..GetGameTick() )
        end

        self:SetValidTargetsForCurrentLayer(self.unit.CacheLayer, self.bp)
    end,

    OnGotTarget = function(self)

        if self.WeaponIsEnabled then
	
            if ScenarioInfo.WeaponDialog then
                LOG("*AI DEBUG Weapon OnGotTarget for "..repr(__blueprints[self.unit.BlueprintID].Description).." "..repr(self.bp.Label).." on tick "..GetGameTick() )
            end
    
            if self.DisabledFiringBones and self.unit.Animator then
		
                for _, value in self.DisabledFiringBones do
                    SetBoneEnabled( self.unit.Animator, value, false )
                end
            end

            self.HadTarget = true
        
        end
		
    end,

    OnLostTarget = function(self)
   
        if self.HadTarget then
	
            if ScenarioInfo.WeaponDialog then
                LOG("*AI DEBUG Weapon OnLostTarget for "..repr(__blueprints[self.unit.BlueprintID].Description).." "..repr(self.bp.Label).." on tick "..GetGameTick() )
            end
 
            if self.DisabledFiringBones and self.unit.Animator then
		
                for _, value in self.DisabledFiringBones do
                    SetBoneEnabled( self.unit.Animator, value, true )
                end
            end

        end
        
        self.HadTarget = false

    end,

    OnStartTracking = function(self, label)
    
        if self.WeaponIsEnabled then
	
            if ScenarioInfo.WeaponDialog then
                LOG("*AI DEBUG Weapon OnStartTracking for "..repr(self.bp.Label).." on tick "..GetGameTick() )
            end
 
            self:PlayWeaponSound('BarrelStart')
        end
    end,

    OnStopTracking = function(self, label)
	
        if self.WeaponIsEnabled then
	
            if ScenarioInfo.WeaponDialog then
                LOG("*AI DEBUG Weapon OnStopTracking for "..repr(self.bp.Label).." on tick "..GetGameTick() )
            end

            self:PlayWeaponSound('BarrelStop')
		
            if LOUDENTITY(STRUCTURE, self.unit) then
                SetResetPoseTime( self.AimControl, 9999999 )
            else
                SetResetPoseTime( self.AimControl, 3 )
            end
        end
    end,

    PlayWeaponSound = function(self, sound)

        if not self.bp.Audio[sound] then return end
		
        PlaySound( self, self.bp.Audio[sound] )
		
    end,

	-- as opposed to creating this data every time the weapon is fired
	-- lets create it once, store it, and eliminate all the function calls
	-- to GetDamageTable -- imagine that
    SetDamageTable = function(self, weaponBlueprint)
	
		-- at minimum the weapons damage table will have 
			--	Damage Amount
			--	Damage Type	                (used for armor type calculations - usually 'Normal')
			--	Damage Radius               (only for AOE weapons)

			--	Collide & Damage Friendly   (for those weapons which do that)
			--	Damage Over Time & Pulses   (for those weapons which do that)

			--	Artillery Shield Blocks     

			--	advancedTracking	        (used by tracking projectiles)
			--		also add ProjectileLifetime, TrackingRadius and TargetRestrictOnlyAllow
            --  TrackingWeapon              (used by weapons thattrack projectiles rather than units)

			
        self.damageTable = {
			DamageAmount = weaponBlueprint.Damage + (self.DamageMod or 0),
			DamageType = weaponBlueprint.DamageType,
		}
		
		if weaponBlueprint.CollideFriendly then
			self.damageTable.CollideFriendly = weaponBlueprint.CollideFriendly
		end
		
		if weaponBlueprint.DamageFriendly then
			self.damageTable.DamageFriendly = weaponBlueprint.DamageFriendly
		end
		
		if weaponBlueprint.DamageRadius > 0 then
			self.damageTable.DamageRadius = weaponBlueprint.DamageRadius + (self.DamageRadiusMod or 0)
		end
		
		if weaponBlueprint.advancedTracking then

			self.damageTable.advancedTracking = weaponBlueprint.advancedTracking
			self.damageTable.ProjectileLifetime = self.ProjectileLifetime
			self.damageTable.TargetRestrictOnlyAllow = self.TargetRestrictOnlyAllow
            self.damageTable.TrackingRadius = self.TrackingRadius
            
            self.damageTable.TrackingWeapon = self
		end
		
		if weaponBlueprint.ArtilleryShieldBlocks then
			self.damageTable.ArtilleryShieldBlocks = weaponBlueprint.ArtilleryShieldBlocks
		end
		
		if weaponBlueprint.DoTTime then
			self.damageTable.DoTTime = weaponBlueprint.DoTTime
			self.damageTable.DoTPulses = weaponBlueprint.DoTPulses or nil
		end

        if weaponBlueprint.Buffs != nil then
		
			self.damageTable.Buffs = {}
			
            for k, v in weaponBlueprint.Buffs do
                
                if v.TargetAllow and type(v.TargetAllow) == 'string' then
                    v.TargetAllow = LOUDPARSE(v.TargetAllow)
                end
                
                if v.TargetDisallow and type(v.TargetDisallow) == 'string' then
                    v.TargetDisallow = LOUDPARSE(v.TargetDisallow)
                end
                
                self.damageTable.Buffs[k] = {}
                self.damageTable.Buffs[k] = v

            end   
			
        end     
		
        --remove disabled buff
        if (self.Disabledbf != nil) and (self.damageTable.Buffs != nil) then
		
            for k, v in self.damageTable.Buffs do
			
                for j, w in self.Disabledbf do
				
                    if v.BuffType == w then
                        --Removing buff
                        LOUDREMOVE( self.damageTable.Buffs, k )
						
                    end
					
                end
				
            end 
			
        end 
	
		if ScenarioInfo.WeaponDialog then
			LOG("*AI DEBUG Weapon SetDamageTable for "..repr(self.bp.Label).." is "..repr(self.damageTable))
		end

    end,

    ChangeDamage = function(self, new)
        self.damageTable.DamageAmount = new + (self.DamageMod or 0)
	
		if ScenarioInfo.WeaponDialog then
			LOG("*AI DEBUG Weapon SetDamageTable after ChangeDamage for "..repr(self.bp.Label).." is "..repr(self.damageTable))
		end

    end,

	-- this event is triggered at the moment that a weapon fires a shell
    CreateProjectileForWeapon = function(self, bone)

        local proj = LOUDCREATEPROJECTILE( self, bone )
        
        if not proj.BlueprintID then
        
            local target
        
            while self and proj and not proj.BlueprintID do
            
                target = self:GetCurrentTarget()

                if target and not target.Dead then
            
                    WaitTicks(1)

                    proj = LOUDCREATEPROJECTILE( self, bone )
                else

                    -- the weapon has lost its target during firing
                    --LOG("*AI DEBUG Projectile for Weapon "..repr(self.bp.Label).." "..repr(bone).." failed at "..GetGameTick().." Weapon has target is "..repr(self:WeaponHasTarget()).." Current target is "..repr(target.BlueprintID).." Dead "..repr(target.Dead) )                                

                    break
                end
            end
        end
		
        if proj and not BeenDestroyed(proj) then

            if ScenarioInfo.ProjectileDialog then
                LOG("*AI DEBUG Weapon CreateProjectileForWeapon "..repr(self.bp.Label).." at bone "..repr(bone).." on tick "..GetGameTick() )
            end
            
            PassDamageData( proj, self.damageTable )
			
            if self.NukeWeapon then
			
                local bp = self.bp

                proj.Data = {
				
                    NukeInnerRingDamage = bp.NukeInnerRingDamage or 2000,
                    NukeInnerRingRadius = bp.NukeInnerRingRadius or 30,
                    NukeInnerRingTicks = bp.NukeInnerRingTicks or 5,
                    NukeInnerRingTotalTime = bp.NukeInnerRingTotalTime or 2,
					
                    NukeOuterRingDamage = bp.NukeOuterRingDamage or 10,
                    NukeOuterRingRadius = bp.NukeOuterRingRadius or 45,
                    NukeOuterRingTicks = bp.NukeOuterRingTicks or 20,
                    NukeOuterRingTotalTime = bp.NukeOuterRingTotalTime or 20,

                }

            end

        end
		
        return proj
    end,

    SetValidTargetsForCurrentLayer = function(self, newLayer, bp)

        local weaponBlueprint = self.bp
        
        local SetFireTargetLayerCaps = SetFireTargetLayerCaps
		
        if weaponBlueprint.FireTargetLayerCapsTable then
		
            if weaponBlueprint.FireTargetLayerCapsTable[newLayer] then
			
                SetFireTargetLayerCaps( self, weaponBlueprint.FireTargetLayerCapsTable[newLayer] )
				
            else
			
                SetFireTargetLayerCaps( self,'None')
            end
        end
    end,

    SetWeaponPriorities = function(self, priTable)
	
		local LOUDPARSE = ParseEntityCategory
        local SetTargetingPriorities = SetTargetingPriorities 
		
        if not priTable then

            if self.bp.TargetPriorities then
			
                local priorityTable = {}
				local counter = 1
				
                for k, v in self.bp.TargetPriorities do
                
                    priorityTable[counter] = LOUDPARSE(v)
					counter = counter + 1
                end
				
                SetTargetingPriorities( self, priorityTable )
            end
			
        else
        
            if type(priTable[1]) == 'string' then
			
                local priorityTable = {}
				local counter = 1
				
                for k, v in priTable do
                
                    priorityTable[counter] = LOUDPARSE(v)
					counter = counter + 1
                end
				
                SetTargetingPriorities( self, priorityTable )
                
            else
            
                SetTargetingPriorities( self, priTable )
                
            end
        end
    end,

    WeaponUsesEnergy = function(self)

        if self.bp.EnergyRequired then
			return self.bp.EnergyRequired > 0
        end
		
		return false
    end,

    AddDamageMod = function(self, dmgMod)
        self.DamageMod = (self.DamageMod or 0) + (dmgMod or 0)
    end,

    AddDamageRadiusMod = function(self, dmgRadMod)
        self.DamageRadiusMod = (self.DamageRadiusMod or 0) + (dmgRadMod or 0)
    end,
    
    -- rewritten to have buff data passed in to save the GetBlueprint function call
    DoOnFireBuffs = function(self, buffs)

        for k, v in buffs do
			if v.Add.OnFire == true then
                self.unit:AddBuff(v)
            end
        end
    end,

    DisableBuff = function(self, buffname)
	
        if buffname then

			if not self.Disabledbf then
				self.Disabledbf = {}
			end
		
            for k, v in self.Disabledbf do
			
                if v == buffname then
                    -- buff already in the table
                    return
                end
            end
            
            --Add to disabled buff list
            LOUDINSERT(self.Disabledbf, buffname)
        end
    end,
    
    ReEnableBuff = function(self, buffname)
	
        if buffname then
		
			LOG("*AI DEBUG Weapon ReEnableBuff "..repr(buffname))
			
            for k, v in self.Disabledbf do
			
                if v == buffname then
                    --Remove from disabled buff list
                    LOUDREMOVE(self.Disabledbf, k)
                end
            end
        end
    end,
    
    --Method to mark weapon when parent unit gets loaded on to a transport unit
    SetOnTransport = function(self, transportstate)

        -- if not allowed to fire from transport - disable/renable weapon
        if not __blueprints[self.unit.BlueprintID].Transport.CanFireFromTransport then
        
            if transportstate then
                self:SetWeaponEnabled(false)
            else
                self:SetWeaponEnabled(true)
            end
        end      

        -- mark weapon with status
        self.WeaponOnTransport = transportstate
		
        if not self.WeaponOnTransport then
            -- tell weapon that it just got dropped and needs to restart aim
            self:OnLostTarget()
            -- remove mark on the weapon
            self.WeaponOnTransport = nil
        end

    end,

    -- Method to retreive if the parent unit has been loaded onto a transport unit
    GetOnTransport = function(self)
        return self.WeaponOnTransport
    end,
    
    --This is the function to set a weapon enabled. 
    --If the weapon is enhabled by an enhancement, this will check to see if the unit has the enhancement before
    --allowing it to try to be enabled or disabled.
    SetWeaponEnabled = function(self, enable)

        -- standard disable path
        if not enable then
 
            if self.WeaponIsEnabled != enable then
    
                if ScenarioInfo.WeaponDialog or ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG Weapon SetWeaponEnabled "..repr(self.bp.Label).." to "..repr(enable).." at "..GetGameTick().." Enabled currently "..repr(self.WeaponIsEnabled) )
                end
            
                self.WeaponIsEnabled = false
    
                self:SetEnabled(enable)
               
                self:OnDisableWeapon()

            end

        end
        
        -- enabling path -- 
        
        local GetEntityId = moho.entity_methods.GetEntityId

        if enable and self.bp.EnabledByEnhancement then
		
            local id = GetEntityId(self.unit)
			
            if SimUnitEnhancements[id] then
 
                if ScenarioInfo.WeaponDialog or ScenarioInfo.WeaponStateDialog then
                    LOG("*AI DEBUG Weapon SetWeaponEnabled by Enhancement - unit enhancements are "..repr(SimUnitEnhancements[id]) )
                end
 			
                for k, v in SimUnitEnhancements[id] do
				
                    if v == self.bp.EnabledByEnhancement then
                    
                        if not self.WeaponIsEnabled then
    
                            if ScenarioInfo.WeaponDialog or ScenarioInfo.WeaponStateDialog then
                                LOG("*AI DEBUG Weapon SetWeaponEnabled by Enhancement "..repr(self.bp.Label).." to "..repr(enable).." at "..GetGameTick().." Enabled currently "..repr(self.WeaponIsEnabled) )
                            end
                        
                            self:SetEnabled(enable)
                            
                            self.WeaponIsEnabled = true
                            
                            self:OnEnableWeapon()
                            
                            ChangeState( self, self.IdleState )

                        end
                    end
                end
            end
			
            --Enhancement needed but doesn't have it, don't allow weapon to be enabled.
            return
        end
        
        -- standard enable path
        if self.WeaponIsEnabled != enable then
    
            if ScenarioInfo.WeaponDialog or ScenarioInfo.WeaponStateDialog then
                LOG("*AI DEBUG Weapon SetWeaponEnabled "..repr(self.bp.Label).." to "..repr(enable).." at "..GetGameTick().." Enabled currently "..repr(self.WeaponIsEnabled) )
            end
        
            self:SetEnabled(enable)
            
            self.WeaponIsEnabled = true
            
            self:OnEnableWeapon()
            
            ChangeState(self, self.IdleState)

        end
    end,    

}
