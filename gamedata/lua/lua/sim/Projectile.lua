--  File     :  /lua/sim/Projectile.lua
--  Author(s):  John Comes, Gordon Duclos
--  This file governs the behavior of projectiles

local Entity = import('/lua/sim/Entity.lua').Entity

local CreateRandomScorchSplatAtObject = import('/lua/defaultexplosions.lua').CreateRandomScorchSplatAtObject

local AreaDoTThread = import('/lua/sim/defaultdamage.lua').AreaDoTThread
local UnitDoTThread = import('/lua/sim/defaultdamage.lua').UnitDoTThread

local AAFlare = import('/lua/defaultantiprojectile.lua').AAFlare
local Flare = import('/lua/defaultantiprojectile.lua').Flare

local LOUDEMPTY = table.empty
local LOUDENTITY = EntityCategoryContains
local LOUDEMITATENTITY = CreateEmitterAtEntity
local LOUDEMITATBONE = CreateEmitterAtBone
local LOUDPARSE = ParseEntityCategory

local ForkThread = ForkThread
local ForkTo = ForkThread

local STRINGSUB = string.sub
local TONUMBER = tonumber

local Damage = Damage
local DamageArea = DamageArea

local GetTerrainType = GetTerrainType

local AdjustHealth = moho.entity_methods.AdjustHealth
local BeenDestroyed = moho.entity_methods.BeenDestroyed
local Destroy = moho.entity_methods.Destroy
local GetArmy = moho.entity_methods.GetArmy

local GetBlueprint = moho.entity_methods.GetBlueprint

local GetHealth = moho.entity_methods.GetHealth
local GetMaxHealth = moho.entity_methods.GetMaxHealth

local GetLauncher = moho.projectile_methods.GetLauncher
local GetPosition = moho.entity_methods.GetPosition

local SetHealth = moho.entity_methods.SetHealth
local SetMaxHealth = moho.entity_methods.SetMaxHealth

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add


local PlaySound = moho.entity_methods.PlaySound

local DefaultTerrainType = GetTerrainType( -1, -1 )

local ALLBPS = __blueprints

Projectile = Class(moho.projectile_methods, Entity) {

    __init = function(self,spec)
    end,
    __post_init = function(self,spec)
    end,

    DestroyOnImpact = true,
	
    FxImpactTrajectoryAligned = true,

    FxImpactAirUnit = {},
    FxImpactLand = {},
    FxImpactNone = {},
    FxImpactProp = {},
    FxImpactShield = {},
    FxImpactWater = {},
    FxImpactUnderWater = {},
    FxImpactUnit = {},
    FxImpactProjectile = {},
    FxImpactProjectileUnderWater = {},
    FxOnKilled = {},

    FxAirUnitHitScale = 1,
    FxLandHitScale = 1,
    FxNoneHitScale = 1,
    FxPropHitScale = 1,
    FxProjectileHitScale = 1,
    FxProjectileUnderWaterHitScale = 1,
    FxShieldHitScale = 1,
    FxUnderWaterHitScale = 0.25,
    FxUnitHitScale = 1,
    FxWaterHitScale = 1,
    FxOnKilledScale = 1,

    FxImpactLandScorch = false,
    FxImpactLandScorchScale = 1.0,

    ForkThread = function(self, fn, ...)

        local thread = ForkThread(fn, self, unpack(arg))
		
        TrashAdd( self.Trash, thread )
		
        return thread
		
    end,
	
    ForkThread4 = function(fn, self, opt1, opt2, opt3)
	
        local thread = ForkThread(fn, self, opt1, opt2, opt3)
		
        TrashAdd( self.Trash, thread )
		
    end,

    OnCreate = function(self, inWater)

        self.Army = GetArmy(self)
	
        self.DamageData = { DamageAmount = false, DamageType = 'Normal' }

        self.Trash = TrashBag()
		
		local bp = GetBlueprint(self)
        
        self.BlueprintID = bp.BlueprintId
		
		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG Projectile OnCreate blueprint is "..repr(bp.BlueprintId))
		end
		
        SetMaxHealth( self, bp.Defense.MaxHealth or 1)
		
        SetHealth( self, self, GetMaxHealth(self))
	
        if bp.Audio.ExistLoop then
		
            self:SetAmbientSound( bp.Audio.ExistLoop, nil)
			
        end
        
        if bp.Physics.TrackTargetGround and bp.Physics.TrackTargetGround == true then
		
            local pos = self:GetCurrentTargetPosition()
			
            pos[2] = GetSurfaceHeight( pos[1], pos[3] )
            self:SetNewTargetGround(pos)
			
        end
		
		-- for adv missile track and retarget
		-- THIS REALLY NEEDS TO BE RELOCATED TO THE PASSDAMAGEDATA FUNCTION
		if self.DamageData.advancedTracking then
		
			ForkTo( self.Tracking, self )
			
		end

		
    end,

	-- adv missile track and retarget
	Tracking = function(self)
    
    	local target = self:GetTrackingTarget() 
        local position = self:GetPosition() 
        local targetlist
		
        local rangedecrement = self.DamageData.TrackingRadius / self.DamageData.ProjectileLifetime * 2
		
        self.range = 60 	-- now using maxradius & tracking radius #--self.DamageData.TrackingRadius
		
		rangedecrement = 60 / (5*2) 	-- this controls the retargeting range of the missile, shrinking by 6 every .5 seconds
        
		-- if the target already has damage assigned to it
        if target.IncommingDamage then
		
			-- if that damage is less the 2x target health then assign to this target
        	if target.IncommingDamage < target:GetHealth() * 2 then
			
        		target.IncommingDamage = target.IncommingDamage + self.DamageData.DamageAmount
        		self.advancedTrackinglock = true
			-- else look for another target
        	else
        		self.advancedTrackinglock = nil
        		self:Retarget()
        	end
			
		-- assign incoming damage to this target
        else 
        	target.IncommingDamage = self.DamageData.DamageAmount
        	self.advancedTrackinglock = true
        end
        
        while not BeenDestroyed(self) do 
		
        	if target.Dead then
        		self:Retarget()   		
        	end
			
        	WaitTicks(5)
			
			--if not BeenDestroyed(self) then
				self.range = self.range - rangedecrement
			--end
        end
		
    end,
    
	-- adv missile track and retarget for AA missiles
    Retarget = function(self)
	
  	    local launcher = self:GetLauncher()
    	local aiBrain = launcher:GetAIBrain() 
    	local position = self:GetPosition()
		
    	local targetlist = aiBrain:GetUnitsAroundPoint( categories.AIR - categories.SATELLITE, position, self.range ,'ENEMY') 
		
        if targetlist[1] then
		
          	self:SetNewTarget(targetlist[1])
			
          	for k, v in targetlist do
			
          		if not v.IncommingDamage then
				
          			self:SetNewTarget(v)
          			v.IncommingDamage = self.DamageData.DamageAmount
          			self.advancedTrackinglock = true
          			break
          		else
          			if v.IncommingDamage < v:GetHealth()*2 then
					
        				self:SetNewTarget(v)	
          				v.IncommingDamage = v.IncommingDamage + self.DamageData.DamageAmount
          				self.advancedTrackinglock = true
          				break
        			end 
          		end
            end
        else
          	Destroy(self) 
      	end  
    end,
	
    OnCollisionCheck = function(self,other)
    
        local ProjectileDialog = ScenarioInfo.ProjectileDialog
	
		if ProjectileDialog then
			LOG("*AI DEBUG Projectile OnCollisionCheck ")
		end
        
        local TORPEDO = categories.TORPEDO
        local DIRECTFIRE = categories.DIRECTFIRE
        local MISSILE = categories.MISSILE

        if (LOUDENTITY(TORPEDO, self) and ( LOUDENTITY(TORPEDO, other) or LOUDENTITY(DIRECTFIRE, other))) or 
           (LOUDENTITY(MISSILE, self) and ( LOUDENTITY(MISSILE, other) or LOUDENTITY(DIRECTFIRE, other))) or 
           (LOUDENTITY(DIRECTFIRE, self) and LOUDENTITY(MISSILE, other)) or 
           (self.Army) == (other.Sync.army) then
            return false
        end

		local bp = ALLBPS[other.BlueprintID]
        
        if bp.Physics.HitAssignedTarget then
            if other:GetTrackingTarget() != self then
                return false
            end
        end
	
		if bp.DoNotCollideList then
			for _,v in bp.DoNotCollideList do
				if LOUDENTITY(LOUDPARSE(v), self) then
					return false
				end
			end
		end
		
		bp = ALLBPS[self.BlueprintID]
        
		if bp.DoNotCollideList then
			for _,v in bp.DoNotCollideList do
				if LOUDENTITY(LOUDPARSE(v), other) then
					return false
				end
			end
		end
		
		if ProjectileDialog then
			LOG("*AI DEBUG Projectile OnCollisionCheck true with "..repr(other))
		end

        return true
    end,

    OnDamage = function(self, instigator, amount, vector, damageType)
	
        local bp = ALLBPS[self.BlueprintID].Defense.MaxHealth
		
        if bp then
		
            self:DoTakeDamage(instigator, amount, vector, damageType)
			
        else
		
            self:OnKilled(instigator, damageType )
			
        end
		
    end,

    OnDestroy = function(self)
	
		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG Projectile OnDestroy for "..repr(self) )
		end
	
		if self.DamageData and not LOUDEMPTY(self.DamageData) then
		
			-- from adv missile track and retarget
			local target = self:GetTrackingTarget()
		
			if target and not target.Dead and self.advancedTrackinglock and target.IncommingDamage then
		
				-- reduce the amount of damage incoming to this target
				target.IncommingDamage = target.IncommingDamage - self.DamageData.DamageAmount
			
				if target.IncommingDamage <= 0 then
					target.IncommingDamage = nil
				end
			end	
		end

		if self.Trash then
			self.Trash:Destroy()
		end

    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
	
        -- check for valid projectile
        if not self or BeenDestroyed(self) then
            return
        end

        AdjustHealth( self, instigator, -amount)
		
        local health = GetHealth(self)
		
        if (health <= 0) then
		
            if (damageType == 'Reclaimed') then
				Destroy(self)
            else
                local excessDamageRatio = 0.0
				
                -- Calculate the excess damage ratio
                local maxHealth = ALLBPS[self.BlueprintID].Defense.MaxHealth or 10
				
                if (health - amount < 0 and maxHealth > 0) then
                    excessDamageRatio = -(health - amount) / maxHealth
                end

                self:OnKilled(instigator, damageType, excessDamageRatio)
            end
			
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        self:CreateImpactEffects( self.Army, self.FxOnKilled, self.FxOnKilledScale )
		
        Destroy(self)
		
    end,

    DoDamage = function(self, instigator, damageData, targetEntity)
	
        local damage = damageData.DamageAmount or 0
		
        if damage > 0 then
		
			if ScenarioInfo.ProjectileDialog then
				LOG("*AI DEBUG Projectile OnDamage for "..damage)
			end
		
            local radius = damageData.DamageRadius or false
			
            if radius then

                if not damageData.DoTTime then

                    DamageArea( instigator, GetPosition(self), radius, damage, damageData.DamageType, damageData.DamageFriendly or false, damageData.DamageSelf or false)
					
                else
					
                    ForkTo( AreaDoTThread, instigator, GetPosition(self), damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), radius, damage, damageData.DamageType, damageData.DamageFriendly or false)
					
                end
				
            elseif damageData.DamageAmount and targetEntity then
			
                if not damageData.DoTTime then
				
                    Damage( instigator, GetPosition(self), targetEntity, damage, damageData.DamageType or "Normal")
					
                else
				
                    ForkTo( UnitDoTThread, instigator, targetEntity, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), damage, damageData.DamageType, damageData.DamageFriendly or false)
					
                end
            end
        end
    end,

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )

        for _,v in EffectTable do

			if ScenarioInfo.ProjectileDialog then
				LOG("*AI DEBUG Projectile CreateImpactEffects for "..repr(v).." Scale "..repr(EffectScale or 1) )
			end	
			
			if self.FxImpactTrajectoryAligned then
			
				LOUDEMITATBONE( self, -2, army, v ):ScaleEmitter(EffectScale or 1)
				
			else
			
				LOUDEMITATENTITY( self, army, v ):ScaleEmitter(EffectScale or 1)
				
			end 
			
        end
		
    end,
    
    CreateTerrainEffects = function( self, army, EffectTable, EffectScale )

        for k, v in EffectTable do
		
			if not BeenDestroyed(self) then
				
				if ScenarioInfo.ProjectileDialog then
					LOG("*AI DEBUG Projectile CreateTerrainEffects for impact on "..repr(targetType).." terrain "..repr(v) )
				end
		
				LOUDEMITATBONE( self, -2, army, v ):ScaleEmitter(EffectScale or 1)

			end
			
        end
		
    end,    

    GetTerrainEffects = function( self, TargetType, ImpactEffectType )

        local TerrainType = nil

        if ImpactEffectType then
		
			local pos = GetPosition(self)
			
            TerrainType = GetTerrainType( pos.x,pos.z )
			
            if TerrainType.FXImpact[TargetType][ImpactEffectType] == nil then
			    TerrainType = DefaultTerrainType
		    end                  
        else
            TerrainType = DefaultTerrainType
            ImpactEffectType = 'Default'
        end
        
        return TerrainType.FXImpact[TargetType][ImpactEffectType] or {}
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)

		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG Projectile OnCollisionCheckWeapon")
		end
		
		-- if this unit category is on the weapon's do-not-collide list, skip!
		local DNC = firingWeapon.bp.DoNotCollideList

		if DNC then
		
			local LOUDENTITY = EntityCategoryContains
			local LOUDPARSE = ParseEntityCategory
			
			for _,v in DNC do
				if LOUDENTITY( LOUDPARSE(v), self) then
					return false
				end
			end
		end    
        return true
    end,

    -- Possible 'targetType' values are:
    --  'Unit'
    --  'Terrain'
    --  'Water'
    --  'Air'
    --  'Prop'
    --  'Shield'
    --  'UnitAir'
    --  'UnderWater'
    --  'UnitUnderwater'
    --  'Projectile'
    --  'ProjectileUnderWater'
    OnImpact = function(self, targetType, targetEntity)

		if targetType == 'Shield' then

            -- LOUD 'marshmallow shield effect' all AOE to 0 on shields
            if self.DamageData.DamageRadius > 0 then
                self.DamageData.DamageRadius = nil
            end

            -- LOUD ShieldMult effect
            if STRINGSUB(self.DamageData.DamageType, 1, 10) == 'ShieldMult' then

                local mult = TONUMBER( STRINGSUB(self.DamageData.DamageType, 11) ) or 1
                self.DamageData.DamageAmount = self.DamageData.DamageAmount * mult

            end

		end

		if ScenarioInfo.ProjectileDialog then
		
			LOG("*AI DEBUG Projectile OnImpact targetType is "..repr(targetType))
			LOG("*AI DEGUG Projectile OnImpact data is "..repr(self.DamageData))
			
			if targetEntity then
				LOG("*AI DEBUG Projectile Target entity is "..repr(targetEntity.BlueprintID))
			end
		end

		if self.DamageData.Buffs then
			self:DoUnitImpactBuffs( GetPosition(self), targetEntity )
		end		
		
		if self.DamageData.DamageAmount and self.DamageData.DamageAmount > 0 then
			self:DoDamage( GetLauncher(self) or self, self.DamageData, targetEntity)
		end

        local bp = ALLBPS[self.BlueprintID]
		
        if bp.Audio['Impact'..targetType] then
		
            PlaySound( self, bp.Audio['Impact'..targetType] )
			
        elseif bp.Audio.Impact then
		
            PlaySound( self, bp.Audio.Impact)
			
        end
		
		-- when simspeed drops too low turn off visual impact effects
		if Sync.SimData.SimSpeed > -1 then

			local ImpactEffects = {}
			local ImpactEffectScale = 1
	
			local army = self.Army
	
			--ImpactEffects
			if targetType == 'Water' then
		
				ImpactEffects = self.FxImpactWater
				ImpactEffectScale = self.FxWaterHitScale
			
			elseif targetType == 'Underwater' or targetType == 'UnitUnderwater' then
		
				ImpactEffects = self.FxImpactUnderWater
				ImpactEffectScale = self.FxUnderWaterHitScale
			
			elseif targetType == 'Unit' then
		
				ImpactEffects = self.FxImpactUnit
				ImpactEffectScale = self.FxUnitHitScale
			
			elseif targetType == 'UnitAir' then
		
				ImpactEffects = self.FxImpactAirUnit
				ImpactEffectScale = self.FxAirUnitHitScale
			
			elseif targetType == 'Terrain' then
		
				ImpactEffects = self.FxImpactLand
				ImpactEffectScale = self.FxLandHitScale
			
				if (self.FxImpactLandScorch) then
			
					CreateRandomScorchSplatAtObject(self, self.FxImpactLandScorchScale, 110, 20, army)
				
				end
			
			elseif targetType == 'Air' then
		
				ImpactEffects = self.FxImpactNone
				ImpactEffectScale = self.FxNoneHitScale
			
			elseif targetType == 'Projectile' then
		
				ImpactEffects = self.FxImpactProjectile
				ImpactEffectScale = self.FxProjectileHitScale
			
			elseif targetType == 'ProjectileUnderwater' then
		
				ImpactEffects = self.FxImpactProjectileUnderWater
				ImpactEffectScale = self.FxProjectileUnderWaterHitScale			
			
			elseif targetType == 'Prop' then
		
				ImpactEffects = self.FxImpactProp
				ImpactEffectScale = self.FxPropHitScale
			
			elseif targetType == 'Shield' then
		
				ImpactEffects = self.FxImpactShield
				ImpactEffectScale = self.FxShieldHitScale
			
			end

			if targetType != 'Shield' then

				if ScenarioInfo.ProjectileDialog then
					LOG("*AI DEBUG Projectile CreateImpactEffects for "..repr(targetType))
				end

				self:CreateImpactEffects( army, ImpactEffects, ImpactEffectScale )
			
			end

			if bp.Display.ImpactEffects.Type then

				local TerrainType = DefaultTerrainType
			
				if TerrainType.FXImpact[targetType][bp.Display.ImpactEffects.Type] == nil then
			
					TerrainType = DefaultTerrainType
				
				end
			
				local TerrainEffect = TerrainType.FXImpact[targetType][bp.Display.ImpactEffects.Type] or false
			
				if TerrainEffect then
			
					if (not LOUDEMPTY(TerrainEffect)) and (not BeenDestroyed(self)) then

						ForkTo( self.CreateTerrainEffects, self, army, TerrainEffect, bp.Display.ImpactEffects.Scale or 1 )
			
					end
				
				end

			end
			
		end

        -- Railgun damage drops by 20% per target it collides with
		if self.DamageData.DamageType == 'Railgun' then

			self.DamageData.DamageAmount = self.DamageData.DamageAmount * 0.8
			
			bp.Physics.ImpactTimeout = 0.1

		end

        if bp.Physics.ImpactTimeout and (targetType == 'Terrain' or targetType == 'Air' or targetType == 'Underwater') then
		
            ForkTo( self.ImpactTimeoutThread, self, bp.Physics.ImpactTimeout )
			
        else

			if self.DamageData.DamageType != 'Railgun' then

				self:OnImpactDestroy( targetType, targetEntity)
				
			end 

        end
		
    end,
    
    OnImpactDestroy = function( self, targetType, targetEntity )

        if self.DestroyOnImpact or not targetEntity or 		
            (not self.DestroyOnImpact and targetEntity and not LOUDENTITY(categories.ANTIMISSILE * categories.ALLPROJECTILES, targetEntity)) then

            Destroy(self)
			
        end 
		
    end,

    ImpactTimeoutThread = function(self, seconds)

        WaitSeconds(seconds)

        Destroy(self)
		
    end,

    -- When this projectile impacts, do any buffs that have been passed to it.
	-- buffs are either applied to the target directly, or targets within a radius of the impact point
    DoUnitImpactBuffs = function(self, position, target)

		for _, v in self.DamageData.Buffs do
			
			if v.Add.OnImpact == true then
			
				if (target and IsUnit(target)) or (v.Radius and (v.Radius > 0)) then
				
					local AddBuff = import('/lua/sim/Unit.lua').Unit.AddBuff
			
					if not (v.Radius and (v.Radius > 0)) then
					
						target:AddBuff(v)
						
					else
					
						-- this will execute the Buff at the position
						AddBuff(GetLauncher(self) or self, v, position)
						
					end
				end
		    end
        end
    end,

    PassData = function(self, data)
        self.Data = data
    end,

	-- modified to carry only active data so any fields which are
	-- empty won't be created
    PassDamageData = function(self, damageData)
		
		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG Projectile PassDamageData DATA is "..repr(damageData))
		end
		
        self.DamageData.DamageAmount = damageData.DamageAmount or 0.1
        self.DamageData.DamageType = damageData.DamageType

		if damageData.DamageRadius then
			self.DamageData.DamageRadius = damageData.DamageRadius
		end
	
		if damageData.DamageFriendly then
			self.DamageData.DamageFriendly = damageData.DamageFriendly
		end
		
		if damageData.CollideFriendly then
			self.DamageData.CollideFriendly = damageData.CollideFriendly
		end
		
		if damageData.DoTTime then
			self.DamageData.DoTTime = damageData.DoTTime
		end
		
		if damageData.DoTPulses then
			self.DamageData.DoTPulses = damageData.DoTPulses
		end

		if damageData.advancedTracking then
			self.DamageData.advancedTracking = damageData.advancedTracking
		end
		
		if damageData.Buffs then
			self.DamageData.Buffs = damageData.Buffs
		end
		
		if damageData.ArtilleryShieldBlocks then
			self.DamageData.ArtilleryShieldBlocks = damageData.ArtilleryShieldBlocks
		end
		
		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG Projectile PassDamageData is "..repr(self))
		end
		
    end,
    
    OnExitWater = function(self)
	
        local bp = ALLBPS[self.BlueprintID].Audio['ExitWater']
		
        if bp then
            PlaySound(self,bp)
        end
		
    end,    
    
    OnEnterWater = function(self)
	
        local bp = ALLBPS[self.BlueprintID].Audio['EnterWater']
		
        if bp then
            PlaySound(self,bp)
        end
		
    end,
    
    AddFlare = function(self, tbl)
	
        if not tbl then return end
        if not tbl.Radius then return end
		
        self.MyFlare = Flare { Owner = self, Radius = tbl.Radius or 5 }
		
		if not self.Trash then
		
			self.Trash = TrashBag()
			
		end
		
        TrashAdd( self.Trash, self.MyFlare )
		
    end,

    OnLostTarget = function(self)
	
        local bp = ALLBPS[self.BlueprintID].Physics
		
        if (bp.TrackTarget and bp.TrackTarget == true) then
		
            if (bp.OnLostTargetLifetime) then
			
                self:SetLifetime(bp.OnLostTargetLifetime)
				
            else
			
                self:SetLifetime(0.5)
				
            end
			
        end
		
    end,

}
