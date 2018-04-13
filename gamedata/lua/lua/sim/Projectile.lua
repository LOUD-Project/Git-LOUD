--  File     :  /lua/sim/Projectile.lua
--  Author(s):  John Comes, Gordon Duclos
--  This file governs the behavior of projectiles

local Entity = import('/lua/sim/Entity.lua').Entity

local CreateRandomScorchSplatAtObject = import('/lua/defaultexplosions.lua').CreateRandomScorchSplatAtObject

local AreaDoTThread = import('/lua/sim/defaultdamage.lua').AreaDoTThread
local UnitDoTThread = import('/lua/sim/defaultdamage.lua').UnitDoTThread

local Flare = import('/lua/defaultantiprojectile.lua').Flare

local LOUDENTITY = EntityCategoryContains
local LOUDEMITATENTITY = CreateEmitterAtEntity
local LOUDEMITATBONE = CreateEmitterAtBone
local LOUDPARSE = ParseEntityCategory
local ForkThread = ForkThread
local ForkTo = ForkThread

local Damage = Damage
local DamageArea = DamageArea

local GetTerrainType = GetTerrainType

local AdjustHealth = moho.entity_methods.AdjustHealth
local BeenDestroyed = moho.entity_methods.BeenDestroyed
local Destroy = moho.entity_methods.Destroy
local GetArmy = moho.entity_methods.GetArmy
local GetBlueprint = moho.entity_methods.GetBlueprint
local GetHealth = moho.entity_methods.GetHealth
local GetLauncher = moho.projectile_methods.GetLauncher
local GetPosition = moho.entity_methods.GetPosition

local PlaySound = moho.entity_methods.PlaySound

local DefaultTerrainType = GetTerrainType( -1, -1 )

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
	
		--LOG("*AI DEBUG Projectile Forkthread")
		
        local thread = ForkThread(fn, self, unpack(arg))
		
        self.Trash:Add(thread)
		
        return thread
		
    end,
	
    ForkThread4 = function(fn, self, opt1, opt2, opt3)
	
        local thread = ForkThread(fn, self, opt1, opt2, opt3)
		
        self.Trash:Add(thread)
		
    end,

    OnCreate = function(self, inWater)
	
        self.DamageData = { DamageRadius = nil, DamageAmount = nil, DamageType = nil, DamageFriendly = false, }
		
        self.Trash = TrashBag()
		
		local bp = GetBlueprint(self)
		
        self:SetMaxHealth(bp.Defense.MaxHealth or 1)
		
        self:SetHealth(self, self:GetMaxHealth())
	
        if bp.Audio.ExistLoop then
		
            self:SetAmbientSound( bp.Audio.ExistLoop, nil)
			
        end
        
        if bp.Physics.TrackTargetGround and bp.Physics.TrackTargetGround == true then
		
            local pos = self:GetCurrentTargetPosition()
			
            pos[2] = GetSurfaceHeight( pos[1], pos[3] )
            self:SetNewTargetGround(pos)
			
        end
		
		-- for adv missile track and retarget
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
        	self.range = self.range - rangedecrement
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
        
        if (LOUDENTITY(categories.TORPEDO, self) and ( LOUDENTITY(categories.TORPEDO, other) or LOUDENTITY(categories.DIRECTFIRE, other))) or 
           (LOUDENTITY(categories.MISSILE, self) and ( LOUDENTITY(categories.MISSILE, other) or LOUDENTITY(categories.DIRECTFIRE, other))) or 
           (LOUDENTITY(categories.DIRECTFIRE, self) and LOUDENTITY(categories.MISSILE, other)) or 
           (GetArmy(self) == GetArmy(other)) then
            return false
        end

		local bp = GetBlueprint(other)
        
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
		
		bp = GetBlueprint(self)
        
		if bp.DoNotCollideList then
			for _,v in bp.DoNotCollideList do
				if LOUDENTITY(LOUDPARSE(v), other) then
					return false
				end
			end
		end		            
        
        return true
    end,

    OnDamage = function(self, instigator, amount, vector, damageType)
	
        local bp = GetBlueprint(self).Defense.MaxHealth
		
        if bp then
		
            self:DoTakeDamage(instigator, amount, vector, damageType)
			
        else
		
            self:OnKilled(instigator, damageType )
			
        end
		
    end,

    OnDestroy = function(self)
	
		-- from adv missile track and retarget
    	local target = self:GetTrackingTarget()
		
    	if target and not target.Dead and self.advancedTrackinglock and target.IncommingDamage then
		
			-- reduce the amount of damage incoming to this target
    		target.IncommingDamage = target.IncommingDamage - self.DamageData.DamageAmount
			
    		if target.IncommingDamage <= 0 then
    			target.IncommingDamage = nil
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
				
                #-- Calculate the excess damage amount
                local excess = health - amount
                local maxHealth = GetBlueprint(self).Defense.MaxHealth or 10
				
                if (excess < 0 and maxHealth > 0) then
                    excessDamageRatio = -excess / maxHealth
                end

                self:OnKilled(instigator, damageType, excessDamageRatio)
            end
			
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        self:CreateImpactEffects( GetArmy(self), self.FxOnKilled, self.FxOnKilledScale )
        Destroy(self)
		
    end,

    DoDamage = function(self, instigator, damageData, targetEntity)
	
        local damage = damageData.DamageAmount
		
        if damage > 0 then
		
            local radius = damageData.DamageRadius or 0
			
            if radius > 0 then

                if damageData.DoTTime <= 0 then

                    DamageArea( instigator, GetPosition(self), radius, damage, damageData.DamageType, damageData.DamageFriendly, damageData.DamageSelf or false)
					
                else
				
                    ForkTo( AreaDoTThread, instigator, GetPosition(self), damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), radius, damage, damageData.DamageType, damageData.DamageFriendly)
					
                end
				
            elseif damageData.DamageAmount and targetEntity then
			
                if damageData.DoTTime <= 0 then
				
                    Damage( instigator, GetPosition(self), targetEntity, damageData.DamageAmount, damageData.DamageType)
					
                else
				
                    ForkTo( UnitDoTThread, instigator, targetEntity, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), damage, damageData.DamageType, damageData.DamageFriendly)
					
                end
            end
        end
    end,

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
		
        for _,v in EffectTable do
		
			local emit = nil
			
			if self.FxImpactTrajectoryAligned then
			
				emit = LOUDEMITATBONE(self,-2,army,v)
				
			else
			
				emit = LOUDEMITATENTITY(self,army,v)
				
			end 
			
            if emit and EffectScale != 1 then
			
                emit:ScaleEmitter(EffectScale or 1)
				
            end
			
        end
		
    end,
    
    CreateTerrainEffects = function( self, army, EffectTable, EffectScale )

        for k, v in EffectTable do
		
			if not self:BeenDestroyed() then
		
				local emit = LOUDEMITATBONE(self,-2,army,v)
			
				if emit and EffectScale != 1 then
					emit:ScaleEmitter(EffectScale or 1)
				end
			
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
	
		-- if this unit category is on the weapon's do-not-collide list, skip!
		local DNC = firingWeapon:GetBlueprint().DoNotCollideList
		
		--LOG("*AI DEBUG Projectile OnCollisionCheckWeapon")
		
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

    OnImpact = function(self, targetType, targetEntity)
	
		--LOG("*AI DEBUG Projectile OnImpact at "..repr(GetPosition(self)))
		--LOG("*AI DEBUG OnImpact targetType is "..repr(targetType))
		--LOG("*AI DEBUG OnImpact targetEntity is "..repr(GetBlueprint(targetEntity).Description).." at "..repr(GetPosition(targetEntity)))
		
		if targetType == 'Shield' and self.DamageData.DamageRadius > 0 then
			self.DamageData.DamageRadius = 0
		end
		
		if self.DamageData.Buffs then
			self:DoUnitImpactBuffs( GetPosition(self), targetEntity )
		end		
		
		if self.DamageData.DamageAmount > 0 then
			self:DoDamage( GetLauncher(self) or self, self.DamageData, targetEntity)
		end

        # Possible 'target' values are:
        #  'Unit'
        #  'Terrain'
        #  'Water'
        #  'Air'
        #  'Prop'
        #  'Shield'
        #  'UnitAir'
        #  'UnderWater'
        #  'UnitUnderwater'
        #  'Projectile'
        #  'ProjectileUnderWater'

        local ImpactEffects = {}
        local ImpactEffectScale = 1
		
        local army = GetArmy(self)
		
        local bp = GetBlueprint(self)
		
        if bp.Audio['Impact'..targetType] then
		
            PlaySound( self, bp.Audio['Impact'..targetType] )
			
        elseif bp.Audio.Impact then
		
            PlaySound( self, bp.Audio.Impact)
			
        end

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
			
                CreateRandomScorchSplatAtObject(self, self.FxImpactLandScorchScale, 150, 20, army)
				
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

		if not targetType == 'Shield' then
		
			ForkTo( self.CreateImpactEffects, self, army, ImpactEffects, ImpactEffectScale )
			
		end

        if bp.Display.ImpactEffects.Type then
		
			local pos = GetPosition(self)
            local TerrainType = DefaultTerrainType
			
            if TerrainType.FXImpact[targetType][bp.Display.ImpactEffects.Type] == nil then
			
			    TerrainType = DefaultTerrainType
				
		    end
			
			local TerrainEffect = TerrainType.FXImpact[targetType][bp.Display.ImpactEffects.Type] or false
			
			if TerrainEffect then
			
				if not self:BeenDestroyed() then
			
					ForkTo( self.CreateTerrainEffects, self, army, TerrainEffect, bp.Display.ImpactEffects.Scale or 1 )
			
				end
				
			end

        end

		
        if bp.Physics.ImpactTimeout and targetType == 'Terrain' then
		
            ForkTo( self.ImpactTimeoutThread, self, bp.Physics.ImpactTimeout )
			
        else
		
			if self.DestroyOnImpact or not targetEntity or 
			(not self.DestroyOnImpact and targetEntity and not LOUDENTITY(categories.ANTIMISSILE * categories.ALLPROJECTILES, targetEntity)) then
			
				Destroy(self)
				
			end 
			
			--self:OnImpactDestroy(targetType, targetEntity)
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

    PassDamageData = function(self, damageData)
		
        self.DamageData.DamageRadius = damageData.DamageRadius or 0
        self.DamageData.DamageAmount = damageData.DamageAmount or 0.1
        self.DamageData.DamageType = damageData.DamageType
		
        self.DamageData.DamageFriendly = damageData.DamageFriendly or false
		
        self.DamageData.CollideFriendly = damageData.CollideFriendly or false
		
        self.DamageData.DoTTime = damageData.DoTTime or 0
        self.DamageData.DoTPulses = damageData.DoTPulses
		
		self.DamageData.advancedTracking = damageData.advancedTracking

        self.DamageData.Buffs = damageData.Buffs or false
        self.DamageData.ArtilleryShieldBlocks = damageData.ArtilleryShieldBlocks
    end,
    
    OnExitWater = function(self)
	
        local bp = GetBlueprint(self).Audio['ExitWater']
		
        if bp then
            PlaySound(self,bp)
        end
		
    end,    
    
    OnEnterWater = function(self)
	
        local bp = GetBlueprint(self).Audio['EnterWater']
		
        if bp then
            PlaySound(self,bp)
        end
		
    end,
    
    AddFlare = function(self, tbl)
	
        if not tbl then return end
        if not tbl.Radius then return end
		
        self.MyFlare = Flare { Owner = self, Radius = tbl.Radius or 5 }
		
        self.Trash:Add(self.MyFlare)
		
    end,
    
    OnLostTarget = function(self)
	
        local bp = GetBlueprint(self).Physics
		
        if (bp.TrackTarget and bp.TrackTarget == true) then
		
            if (bp.OnLostTargetLifetime) then
			
                self:SetLifetime(bp.OnLostTargetLifetime)
				
            else
			
                self:SetLifetime(0.5)
				
            end
			
        end
		
    end,

}
