---  /lua/sim/Weapon.lua
---  Summary  : The base weapon class for all weapons in the game.

local LOUDENTITY = EntityCategoryContains
local ParseEntityCategory = ParseEntityCategory
local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove

local ForkThread = ForkThread
local ForkTo = ForkThread

local WaitSeconds = WaitSeconds
local WaitTicks = coroutine.yield

local GetBlueprint = moho.weapon_methods.GetBlueprint
local PlaySound = moho.weapon_methods.PlaySound

Weapon = Class(moho.weapon_methods) {

    __init = function(self, unit)
        self.unit = unit
    end,

    ForkThread = function(self, fn, ...)
        local thread = ForkThread(fn, self, unpack(arg))
        self.unit.Trash:Add(thread)
        return thread
    end,

    OnCreate = function(self)
	
        if not self.unit.Trash then
            self.unit.Trash = TrashBag()
        end
		
        local bp = GetBlueprint(self)		
		
        self:SetValidTargetsForCurrentLayer( self.unit:GetCurrentLayer(), bp)
		
        if bp.Turreted == true then
            self:SetupTurret(bp)
        end

		-- next 3 conditions are for adv missile track and retarget
        if bp.advancedTracking then
        	self.advancedTracking = bp.advancedTracking
        end
		
		-- calc a lifetime if one is not provided
        if bp.ProjectileLifetime then
        	self.ProjectileLifetime = bp.ProjectileLifetime
        else
			self.ProjectileLifetime = (bp.MaxRadius / bp.MuzzleVelocity) * 1.15
		end
		
		-- calc tracking radius if not provided
        if bp.TrackingRadius then
        	self.TrackingRadius = bp.TrackingRadius
        else
			self.TrackingRadius = bp.MaxRadius * 1.1
		end
		
        self:SetWeaponPriorities()
        self.Disabledbf = {}
        self.DamageMod = 0
        self.DamageRadiusMod = 0
		
        local initStore = tonumber(ScenarioInfo.Options.MissileOption) or bp.InitialProjectileStorage or 0
		
        if initStore > 0 then
		
            if bp.MaxProjectileStorage and bp.MaxProjectileStorage < initStore then
                initStore = bp.MaxProjectileStorage
            end
			
            local nuke = false
			
            if bp.NukeWeapon then
                nuke = true
            end
			
            ForkTo(self.AmmoThread, self, nuke, initStore)
        end
		
		self:SetDamageTable(bp)
		
    end,

    AmmoThread = function(self, nuke, amount)
	
        WaitTicks(2)
		
        if nuke then
            self.unit:GiveNukeSiloAmmo(amount)
        else
            self.unit:GiveTacticalSiloAmmo(amount)
        end
    end,

    SetupTurret = function(self, bp)
		
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
			
                self.AimControl = CreateAimController(self, 'Torso', yawBone)
                self.AimRight = CreateAimController(self, 'Right', pitchBone, pitchBone, muzzleBone)
                self.AimLeft = CreateAimController(self, 'Left', pitchBone2, pitchBone2, muzzleBone2)
                self.AimControl:SetPrecedence(precedence)
                self.AimRight:SetPrecedence(precedence)
                self.AimLeft:SetPrecedence(precedence)
				
                if LOUDENTITY(categories.STRUCTURE, self.unit) then
                    self.AimControl:SetResetPoseTime(9999999)
                end
				
                self:SetFireControl('Right')
                self.unit.Trash:Add(self.AimControl)
                self.unit.Trash:Add(self.AimRight)
                self.unit.Trash:Add(self.AimLeft)
				
            else
                self.AimControl = CreateAimController(self, 'Default', yawBone, pitchBone, muzzleBone)
				
                if LOUDENTITY(categories.STRUCTURE, self.unit) then
                    self.AimControl:SetResetPoseTime(9999999)
                end
				
                self.unit.Trash:Add(self.AimControl)
                self.AimControl:SetPrecedence(precedence)
				
                if bp.RackSlavedToTurret and LOUDGETN(bp.RackBones) > 0 then
                    for k, v in bp.RackBones do
                        if v.RackBone != pitchBone then
                            local slaver = CreateSlaver(self.unit, v.RackBone, pitchBone)
                            slaver:SetPrecedence(precedence-1)
                            self.unit.Trash:Add(slaver)
                        end
                    end
                end
            end
        end

        local numbersexist = true
		
        local turretyawmin, turretyawmax, turretyawspeed
        local turretpitchmin, turretpitchmax, turretpitchspeed
        
        if bp.TurretYaw and bp.TurretYawRange then
            turretyawmin, turretyawmax = self:GetTurretYawMinMax()
        else
            numbersexist = false
        end
        
        if bp.TurretYawSpeed then
            turretyawspeed = self:GetTurretYawSpeed()
        else
            numbersexist = false
        end
        
        if bp.TurretPitch and bp.TurretPitchRange then
            turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
        else
            numbersexist = false
        end
        
        if bp.TurretPitchSpeed then
            turretpitchspeed = self:GetTurretPitchSpeed()
        else
            numbersexist = false
        end
        
        if numbersexist then
		
            self.AimControl:SetFiringArc(turretyawmin, turretyawmax, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
			
            if self.AimRight then
                self.AimRight:SetFiringArc(turretyawmin/12, turretyawmax/12, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
            end
			
            if self.AimLeft then
                self.AimLeft:SetFiringArc(turretyawmin/12, turretyawmax/12, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
            end
			
        end
		
    end,

    AimManipulatorSetEnabled = function(self, enabled)
	
        if self.AimControl then
            self.AimControl:SetEnabled(enabled)
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
            self.AimControl:SetFiringArc(turretyawmin, turretyawmax, speed, turretpitchmin, turretpitchmax, turretpitchspeed)
        end
    end,

    SetTurretPitchSpeed = function(self, speed)
	
        local turretyawmin, turretyawmax = self:GetTurretYawMinMax()
        local turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
        local turretpitchspeed = self:GetTurretYawSpeed()
		
        if self.AimControl then
            self.AimControl:SetFiringArc(turretyawmin, turretyawmax, turretyawspeed, turretpitchmin, turretpitchmax, speed)
        end
    end,

    GetTurretYawMinMax = function(self)

		local bp = GetBlueprint(self)
		
        local halfrange = bp.TurretYawRange
        local yaw = bp.TurretYaw
		
        return yaw - halfrange, yaw + halfrange
    end,

    GetTurretYawSpeed = function(self)
		local bp = GetBlueprint(self)
		
        return bp.TurretYawSpeed
    end,

    GetTurretPitchMinMax = function(self)
		local bp = GetBlueprint(self)
		
        local halfrange = bp.TurretPitchRange
        local pitch = bp.TurretPitch
		
        return pitch - halfrange, pitch + halfrange
    end,

    GetTurretPitchSpeed = function(self)
		local bp = GetBlueprint(self)
		
        return bp.TurretPitchSpeed
    end,

    OnFire = function(self)
        local bp = GetBlueprint(self)
        
		if bp.Buffs then
			self:DoOnFireBuffs(bp.Buffs)
		end
    end,
	
	OnWeaponFired = function(self, target)
		-- I put this here just to see if it could be trapped (and it is) with the intention
		-- of discovering if it would be possible to turn cloaking off when a weapon on a
		-- cloaked unit fires
	end,

    OnEnableWeapon = function(self)
    end,

    OnGotTarget = function(self)
	
        if self.DisabledFiringBones and self.unit.Animator then
		
            for key, value in self.DisabledFiringBones do
			
                self.unit.Animator:SetBoneEnabled(value, false)
				
            end
			
        end
		
    end,

    OnLostTarget = function(self)
	
        if self.DisabledFiringBones and self.unit.Animator then
		
            for key, value in self.DisabledFiringBones do
			
                self.unit.Animator:SetBoneEnabled(value, true)
				
            end
			
        end

    end,

    OnStartTracking = function(self, label)
        --self:PlayWeaponSound('BarrelStart')
    end,

    OnStopTracking = function(self, label)
        --self:PlayWeaponSound('BarrelStop')
		
        if LOUDENTITY(categories.STRUCTURE, self.unit) then
            self.AimControl:SetResetPoseTime(9999999)
        end

    end,

    PlayWeaponSound = function(self, sound)
	
        local bp = GetBlueprint(self)
		
        if not bp.Audio[sound] then return end
		
        PlaySound( self, bp.Audio[sound] )
		
    end,
    
    GetDamageTable = function(self)
	
		if self.damageTable then
		
			return self.damageTable
			
		end
	
        local weaponBlueprint = GetBlueprint(self)

        local damageTable = {
		
			DamageRadius = weaponBlueprint.DamageRadius + (self.DamageRadiusMod or 0),
			DamageAmount = weaponBlueprint.Damage + (self.DamageMod or 0),
			DamageType = weaponBlueprint.DamageType,
			
			DamageFriendly = weaponBlueprint.DamageFriendly,

			CollideFriendly = weaponBlueprint.CollideFriendly,
			
			DoTTime = weaponBlueprint.DoTTime,
			DoTPulses = weaponBlueprint.DoTPulses,
		
			ArtilleryShieldBlocks = weaponBlueprint.ArtilleryShieldBlocks,
		
			advancedTracking = weaponBlueprint.advancedTracking,

			ProjectileLifetime = self.ProjectileLifetime,
			TrackingRadius = self.TrackingRadius,
		}

        if weaponBlueprint.Buffs != nil then
		
			damageTable.Buffs = {}
			
            for k, v in weaponBlueprint.Buffs do
                damageTable.Buffs[k] = {}
                damageTable.Buffs[k] = v
            end   
			
        end     
		
        #--remove disabled buff
        if (self.Disabledbf != nil) and (damageTable.Buffs != nil) then
		
            for k, v in damageTable.Buffs do
			
                for j, w in self.Disabledbf do
				
                    if v.BuffType == w then
                        #--Removing buff
                        LOUDREMOVE( damageTable.Buffs, k )
						
                    end
					
                end
				
            end 
			
        end  
		
        return damageTable
		
    end,
    
	-- as opposed to creating this data every time the weapon is fired
	-- lets create it once, store it, and eliminate all the function calls
	-- to GetDamageTable -- imagine that
    SetDamageTable = function(self, weaponBlueprint)

        self.damageTable = {
		
			DamageRadius = weaponBlueprint.DamageRadius + (self.DamageRadiusMod),
			DamageAmount = weaponBlueprint.Damage + (self.DamageMod),
			
			DamageType = weaponBlueprint.DamageType,
			
			DamageFriendly = weaponBlueprint.DamageFriendly,

			CollideFriendly = weaponBlueprint.CollideFriendly,
			
			DoTTime = weaponBlueprint.DoTTime,
			DoTPulses = weaponBlueprint.DoTPulses,
		
			ArtilleryShieldBlocks = weaponBlueprint.ArtilleryShieldBlocks,
		
			advancedTracking = weaponBlueprint.advancedTracking,

			ProjectileLifetime = self.ProjectileLifetime,
			TrackingRadius = self.TrackingRadius,
		}

        if weaponBlueprint.Buffs != nil then
		
			self.damageTable.Buffs = {}
			
            for k, v in weaponBlueprint.Buffs do
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

    end,

    CreateProjectileForWeapon = function(self, bone)

        local proj = moho.weapon_methods.CreateProjectile( self, bone )
		
        if proj and not proj:BeenDestroyed() then

            proj:PassDamageData( self.damageTable )
			
            local bp = GetBlueprint(self)

            if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeOuterRingTicks and bp.NukeOuterRingTotalTime and
                bp.NukeInnerRingDamage and bp.NukeInnerRingRadius and bp.NukeInnerRingTicks and bp.NukeInnerRingTotalTime then
				
                local data = {
				
                    NukeInnerRingDamage = bp.NukeInnerRingDamage or 2000,
                    NukeInnerRingRadius = bp.NukeInnerRingRadius or 30,
                    NukeInnerRingTicks = bp.NukeInnerRingTicks or 5,
                    NukeInnerRingTotalTime = bp.NukeInnerRingTotalTime or 2,
					
                    NukeOuterRingDamage = bp.NukeOuterRingDamage or 10,
                    NukeOuterRingRadius = bp.NukeOuterRingRadius or 45,
                    NukeOuterRingTicks = bp.NukeOuterRingTicks or 20,
                    NukeOuterRingTotalTime = bp.NukeOuterRingTotalTime or 20,

                }
				
                proj:PassData(data)
				
            end
        end
		
        return proj
    end,

    SetValidTargetsForCurrentLayer = function(self, newLayer, bp)

        local weaponBlueprint = bp or GetBlueprint(self)
		
        if weaponBlueprint.FireTargetLayerCapsTable then
		
            if weaponBlueprint.FireTargetLayerCapsTable[newLayer] then
			
                self:SetFireTargetLayerCaps( weaponBlueprint.FireTargetLayerCapsTable[newLayer] )
				
            else
			
                self:SetFireTargetLayerCaps('None')
				
            end
        end
    end,

    OnDestroy = function(self)
    end,

    SetWeaponPriorities = function(self, priTable)
	
		local LOUDPARSE = ParseEntityCategory
		
        if not priTable then
		
            local bp = GetBlueprint(self)
			
            if bp.TargetPriorities then
			
                local priorityTable = {}
				local counter = 0
				
                for k, v in bp.TargetPriorities do
                    priorityTable[counter+1] = LOUDPARSE(v)
					counter = counter + 1
                end
				
                self:SetTargetingPriorities(priorityTable)
            end
			
        else
            if type(priTable[1]) == 'string' then
			
                local priorityTable = {}
				local counter = 0
				
                for k, v in priTable do
                    priorityTable[counter+1] = LOUDPARSE(v)
					counter = counter + 1
                end
				
                self:SetTargetingPriorities(priorityTable)
            else
                self:SetTargetingPriorities(priTable)
            end
        end
    end,

    WeaponUsesEnergy = function(self)
	
        local bp = GetBlueprint(self)
		
        if bp.EnergyRequired then
		
			return bp.EnergyRequired > 0
			
        end
		
		return false
		
    end,

    OnVeteranLevel = function(self, old, new)
	
        local bp = GetBlueprint(self)
		
        if not bp.Buffs then return end

        local lvlkey = 'VeteranLevel' .. new
		
        for k, v in bp.Buffs do
		
            if v.Add[lvlkey] == true then
			
                self:AddBuff(v)
				
            end
			
        end
		
    end,

    AddBuff = function(self, buffTbl)
        self.unit:AddWeaponBuff(buffTbl, self)
    end,

    AddDamageMod = function(self, dmgMod)
        self.DamageMod = self.DamageMod + (dmgMod or 0)
    end,
    
    AddDamageRadiusMod = function(self, dmgRadMod)
        self.DamageRadiusMod = self.DamageRadiusMod + (dmgRadMod or 0)
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
            for k, v in self.Disabledbf do
                if v == buffname then
                    #this buff is already in the table
                    return
                end
            end
            
            --Add to disabled list
            LOUDINSERT(self.Disabledbf, buffname)
        end
    end,
    
    ReEnableBuff = function(self, buffname)
        if buffname then
            for k, v in self.Disabledbf do
                if v == buffname then
                    #Remove from disabled list
                    LOUDREMOVE(self.Disabledbf, k)
                end
            end
        end
    end,
    
    --Method to mark weapon when parent unit gets loaded on to a transport unit
    SetOnTransport = function(self, transportstate)
	
        self.onTransport = transportstate
		
        if not transportstate then
            --send a message to tell the weapon that the unit just got dropped and needs to restart aim
            self:OnLostTarget()
        end
		
        --Disable weapon if on transport and not allowed to fire from it
        if not self.unit:GetBlueprint().Transport.CanFireFromTransport then
            if transportstate then
                self.WeaponDisabledOnTransport = true
                self:SetWeaponEnabled(false)
            else
                self:SetWeaponEnabled(true)
                self.WeaponDisabledOnTransport = false
            end
        end        
    end,

    -- Method to retreive onTransport information. True if the parent unit has been loaded on to a transport unit
    GetOnTransport = function(self)
        return self.onTransport
    end,
    
    --This is the function to set a weapon enabled. 
    --If the weapon is enhabled by an enhancement, this will check to see if the unit has the enhancement before
    --allowing it to try to be enabled or disabled.
    SetWeaponEnabled = function(self, enable)
	
        if not enable then
            self:SetEnabled(enable)
            return
        end
		
        local bp = GetBlueprint(self)
		
        if bp.EnabledByEnhancement then
		
            local id = self.unit:GetEntityId()
			
            if SimUnitEnhancements[id] then
			
                for k, v in SimUnitEnhancements[id] do
				
                    if v == bp.EnabledByEnhancement then
                        self:SetEnabled(enable)
                        return
                    end
                end
            end
			
            --Enhancement needed but doesn't have it, don't allow weapon to be enabled.
            return
        end
		
        self:SetEnabled(enable)
    end,
}

    -- PlayWeaponAmbientSound = function(self, sound)
        -- local bp = GetBlueprint(self)
        -- if not bp.Audio[sound] then return end
		
        -- if not self.AmbientSounds then
            -- self.AmbientSounds = {}
        -- end
		
        -- if not self.AmbientSounds[sound] then
            -- local sndEnt = Entity {}
            -- self.AmbientSounds[sound] = sndEnt
            -- self.unit.Trash:Add(sndEnt)
            -- sndEnt:AttachTo(self.unit,-1)
        -- end
		
        -- self.AmbientSounds[sound]:SetAmbientSound( bp.Audio[sound], nil )
    -- end,
    
    -- StopWeaponAmbientSound = function(self, sound)
        -- if not self.AmbientSounds then return end
        -- if not self.AmbientSounds[sound] then return end
		
        -- local bp = GetBlueprint(self)
		
        -- if not bp.Audio[sound] then return end
        -- self.AmbientSounds[sound]:Destroy()
        -- self.AmbientSounds[sound] = nil
    -- end,

    -- OnEnableWeapon = function(self)
    -- end,

    -- OnMotionHorzEventChange = function(self, new, old)
    -- end,