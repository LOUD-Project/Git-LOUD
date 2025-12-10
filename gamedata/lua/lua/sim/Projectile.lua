--  File     :  /lua/sim/Projectile.lua
--  Author(s):  John Comes, Gordon Duclos
--  This file governs the behavior of projectiles

--local Entity = import('/lua/sim/Entity.lua').Entity
--local EntityOnCreate = Entity.OnCreate
local EntityMethods = moho.entity_methods
local ProjectileMethods = moho.projectile_methods

local CreateRandomScorchSplatAtObject = import('/lua/defaultexplosions.lua').CreateRandomScorchSplatAtObject

local AreaDoTThread = import('/lua/sim/defaultdamage.lua').AreaDoTThread
local UnitDoTThread = import('/lua/sim/defaultdamage.lua').UnitDoTThread

local AAFlare       = import('/lua/defaultantiprojectile.lua').AAFlare
local DepthCharge   = import('/lua/defaultantiprojectile.lua').DepthCharge
local Flare         = import('/lua/defaultantiprojectile.lua').Flare

local LOUDCOPY          = table.copy
local LOUDEMPTY         = table.empty
local LOUDENTITY        = EntityCategoryContains
local LOUDEMITATENTITY  = CreateEmitterAtEntity
local LOUDEMITATBONE    = CreateEmitterAtBone
local LOUDGETN          = table.getn
local LOUDPARSE         = ParseEntityCategory

local ForkThread        = ForkThread
local ForkTo            = ForkThread

local STRINGSUB         = string.sub
local TONUMBER          = tonumber

local Damage            = Damage
local DamageArea        = DamageArea

local GetTerrainType    = GetTerrainType

local AdjustHealth              = EntityMethods.AdjustHealth
local BeenDestroyed             = EntityMethods.BeenDestroyed
local Destroy                   = EntityMethods.Destroy
local GetArmy                   = EntityMethods.GetArmy
local GetBlueprint              = EntityMethods.GetBlueprint
local GetHealth                 = EntityMethods.GetHealth
local GetMaxHealth              = EntityMethods.GetMaxHealth
local GetPosition               = EntityMethods.GetPosition
local PlaySound                 = EntityMethods.PlaySound
local SetHealth                 = EntityMethods.SetHealth
local SetMaxHealth              = EntityMethods.SetMaxHealth

EntityMethods = nil

local GetCurrentTargetPosition  = ProjectileMethods.GetCurrentTargetPosition
local GetLauncher               = ProjectileMethods.GetLauncher
local GetTrackingTarget         = ProjectileMethods.GetTrackingTarget

local GetUnitsAroundPoint       = moho.aibrain_methods.GetUnitsAroundPoint

local TrashBag          = TrashBag
local TrashAdd          = TrashBag.Add
local TrashDestroy      = TrashBag.Destroy

local DefaultTerrainType = GetTerrainType( -1, -1 )

local ALLBPS = __blueprints

Projectile = Class( ProjectileMethods ) {

    DestroyOnImpact = true,
	
    FxImpactTrajectoryAligned = true,

    ForkThread = function(self, fn, ...)
    
        if not self.Trash then
            self.Trash = TrashBag()
        end

        local thread = ForkThread(fn, self, unpack(arg))
		
        TrashAdd( self.Trash, thread )
		
        return thread
		
    end,
	
    ForkThread4 = function(fn, self, opt1, opt2, opt3)
    
        if not self.Trash then
            self.Trash = TrashBag()
        end
	
        local thread = ForkThread(fn, self, opt1, opt2, opt3)
		
        TrashAdd( self.Trash, thread )
		
    end,

    OnCreate = function(self, InWater)

		local bp = GetBlueprint(self)
        
        local AudioExist        = bp.Audio.ExistLoop or false
        local TrackTargetGround = bp.Physics.TrackTargetGround or false
        
        self.Army = GetArmy(self)        
        self.BlueprintID = bp.BlueprintId or false
		
        SetMaxHealth( self, bp.Defense.MaxHealth or 1)
        SetHealth( self, self, GetMaxHealth(self))

        if AudioExist then
            self:SetAmbientSound( AudioExist, nil)
        end
        
        if TrackTargetGround then
		
            local pos = GetCurrentTargetPosition(self)
			
            pos[2] = GetSurfaceHeight( pos[1], pos[3] )
            self:SetNewTargetGround(pos)
        end

		if ScenarioInfo.ProjectileDialog then

            if self.BlueprintID then
                LOG("*AI DEBUG Projectile OnCreate BlueprintID is "..repr(self.BlueprintID) )
            else
                LOG("*AI DEBUG Projectile OnCreate BlueprintID is FALSE "..repr(bp) )
            end

		end

    end,

	-- adv missile track and retarget
	Tracking = function(self)
    
        if self.AdvancedTrackinglock then return end
        
        if self:BeenDestroyed() then return end

  	    local launcher = GetLauncher(self) or false
        
        if not launcher then return end
        
    	local aiBrain = launcher:GetAIBrain()
        
    	local target = GetTrackingTarget(self)
        
        if not target then return end
        
        local targetlauncher = false
        
        --if ScenarioInfo.ProjectileTrackingDialog then
          --  LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Projectile "..repr(self.BlueprintID).." starts - target is "..repr(target.BlueprintID) )
        --end

        local BeenDestroyed = BeenDestroyed
        local GetHealth = GetHealth
        local GetPosition = GetPosition
        local SetNewTarget = ProjectileMethods.SetNewTarget
        local WaitTicks = WaitTicks
        

        local function Retarget()
        
            local GetHealth = GetHealth
            local GetUnitsAroundPoint = GetUnitsAroundPoint
            local SetNewTarget = SetNewTarget

            local position = GetPosition(self)
            
            local weapon = false
            local targetlist
            
            if self.DamageData.TrackingWeapon then
                weapon = self.DamageData.TrackingWeapon
            end
        
            self.AdvancedTrackinglock = nil
		
            if not weapon then
                targetlist = GetUnitsAroundPoint( aiBrain, categories.AIR - categories.SATELLITE, position, self.range ,'ENEMY') 
            else
            
                if not weapon:BeenDestroyed() then
                
                    targetlist = { weapon:GetCurrentTarget() or target }
                    
                    if not targetlist[1] then
                    
                        if ScenarioInfo.ProjectileTrackingDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Projectile Weapon has no current target")
                        end
                        
                    else
                        if ScenarioInfo.ProjectileTrackingDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Weapon target "..repr(target.BlueprintID).." Incomming Damage is "..repr(target.IncommingDamage))
                        end
                    end
                    
                else
                    return
                end
            end
            
            if targetlist[1] then

                if ScenarioInfo.ProjectileTrackingDialog and weapon then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Projectile "..repr(self.BlueprintID).." activates retargeting "..repr(targetlist[1].BlueprintID) )
                end
                
               
                if targetlist[1] == target and self.DamageData.TargetRestrictOnlyAllow then

                    position = GetPosition(self)                    

                    local x = position[1]
                    local y = position[3]
                    
                    local trackradius = self.DamageData.TrackingRadius
                    local trackcategory = ParseEntityCategory( self.DamageData.TargetRestrictOnlyAllow )
                    
                    targetlist = GetEntitiesInRect( x-trackradius,y-trackradius, x+trackradius, y+trackradius )
                    
                    if targetlist then
                    
                        targetlist = EntityCategoryFilterDown( trackcategory, targetlist)
                        
                        if targetlist[2] then
                            table.sort( targetlist, function(a,b) return VDist3( position, GetPosition(a)) < VDist3( position, GetPosition(b)) end )
                        end

                        if targetlist[1] then
                            
                            if ScenarioInfo.ProjectileTrackingDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Projectile "..repr(self.BlueprintID).." Found "..table.getn(targetlist).." "..repr(self.DamageData.TargetRestrictOnlyAllow).." targets")
                            end

                        else
                            
                            if ScenarioInfo.ProjectileTrackingDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Projectile "..repr(self.BlueprintID).." Found NO "..repr(self.DamageData.TargetRestrictOnlyAllow).." targets - weapon is "..repr(weapon.bp.Label) )
                            end                        

                            targetlist = false
                        end
                    end

                end
                
                if targetlist then
			
                    for k, v in targetlist do
                
                        if IsEnemy( v.Army, self.Army ) then
			
                            if not v.IncommingDamage or v.IncommingDamage < GetHealth(v) then
				
                                SetNewTarget( self, v )

                                if ScenarioInfo.ProjectileTrackingDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Projectile "..repr(self.BlueprintID).." Retargeted to "..repr(v.BlueprintID).." total "..repr(v.IncommingDamage) )
                                end
                            
                                if v.IncommingDamage then
                                    v.IncommingDamage = v.IncommingDamage + self.DamageData.DamageAmount
                                else
                                    v.IncommingDamage = self.DamageData.DamageAmount
                                end
                    
                                self.AdvancedTrackinglock = true
                            
                                target = v
                            
                                targetlauncher = false
                            
                                if not BeenDestroyed(target) then
                                
                                    if not IsUnit(target) then
                                        targetlauncher = GetLauncher(target)
                                    end

                                end
                            
                                break

                            end

                        end
                        
                    end

                end
                
                if not self.AdvancedTrackinglock then
                
                    if targetlauncher and not targetlauncher:BeenDestroyed() then
                
                        if ScenarioInfo.ProjectileTrackingDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Projectile "..repr(self.BlueprintID).." No target found - targeting launcher")
                        end
                    
                        SetNewTarget( self, targetlauncher )
                    
                        self.AdvancedTrackinglock = true
                    
                        target = false
                        targetlauncher = false
                    end    

                    return
                    
                end
                
            else

                if ScenarioInfo.ProjectileTrackingDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Tracking Projectile "..repr(self.BlueprintID).." Advanced Tracking fails" )
                end

                return
            end  
        end


        self.range = 60 	-- now using maxradius & tracking radius
		
		local rangedecrement = 6    -- this controls the retargeting range of the missile, shrinking by 6 every .5 seconds
        
		-- if the target already has damage assigned to it
        if target.IncommingDamage then
		
			-- if that damage is less than target health then assign to this target
        	if target.IncommingDamage < GetHealth(target) then
			
        		target.IncommingDamage = target.IncommingDamage + self.DamageData.DamageAmount
                
        		self.AdvancedTrackinglock = true
                
        	else
        		Retarget()
        	end
			
        else 
        	target.IncommingDamage = self.DamageData.DamageAmount
            
        	self.AdvancedTrackinglock = true
        end
        
        while not BeenDestroyed(self) and self.AdvancedTrackinglock do 
            
			self.range = self.range - rangedecrement

        	if not target then
            
                self.AdvancedTrackinglock = false

        		Retarget()   		

        	elseif BeenDestroyed(target) then
            
                self.AdvancedTrackinglock = false

                Retarget()
                
            else
			
                WaitTicks(3)
                
            end

        end
		
    end,
	
    OnCollisionCheck = function(self,other)
    
        local ProjectileDialog = ScenarioInfo.ProjectileDialog
        
        local LOUDENTITY    = LOUDENTITY
        local LOUDPARSE     = LOUDPARSE
	
		--if ProjectileDialog then
			--LOG("*AI DEBUG Projectile OnCollisionCheck ")
		--end
        
        local TORPEDO       = categories.TORPEDO
        local DIRECTFIRE    = categories.DIRECTFIRE
        local MISSILE       = categories.MISSILE
        local ANTIMISSILE   = categories.ANTIMISSILE

        if (LOUDENTITY(TORPEDO, self) and ( LOUDENTITY(TORPEDO, other) or LOUDENTITY(DIRECTFIRE, other))) or 
           (LOUDENTITY(MISSILE, self) and ( LOUDENTITY(MISSILE, other) or LOUDENTITY(DIRECTFIRE, other))) or 
           (LOUDENTITY(DIRECTFIRE, self) and LOUDENTITY(MISSILE, other)) or
           (LOUDENTITY(ANTIMISSILE, self) and not LOUDENTITY(MISSILE, other)) or
           (self.Army) == (other.Army) then
            return false
        end

		local bp = ALLBPS[other.BlueprintID]
        
        if bp.Physics.HitAssignedTarget then
            if GetTrackingTarget(other) != self then
                return false
            end
        end
        
        bp = bp.DoNotCollideList
    
		if bp then
			for _,v in bp do
				if LOUDENTITY(LOUDPARSE(v), self) then
					return false
				end
			end
		end
		
		bp = ALLBPS[self.BlueprintID].DoNotCollideList
        
		if bp then
			for _,v in bp do
				if LOUDENTITY(LOUDPARSE(v), other) then
					return false
				end
			end
		end
		
		if ProjectileDialog then
			ForkThread( function() LOG("*AI DEBUG Projectile "..self.BlueprintID.." OnCollisionCheck true with "..repr(other.BlueprintID)) end )
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
			ForkThread( function() LOG("*AI DEBUG Projectile OnDestroy "..repr(self.BlueprintID) ) end )
		end

        local DD = self.DamageData or false	
		
        if DD then
        
            if self.AdvancedTrackinglock then
		
                -- from adv missile track and retarget
                local target = GetTrackingTarget(self)
		
                if target and (not target.Dead) and target.IncommingDamage then
		
                    -- reduce the amount of damage incoming to this target
                    target.IncommingDamage = target.IncommingDamage - DD.DamageAmount
			
                    if target.IncommingDamage <= 0 then
                        target.IncommingDamage = nil
                    end
                end	
            end
        end

        TrashDestroy(self.Trash)

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
    
        if self.FXOnKilled then
	
            self:CreateImpactEffects( self.Army, self.FxOnKilled, self.FxOnKilledScale or 1 )
            
        end
		
        Destroy(self)
		
    end,

    DoDamage = function(self, instigator, damageData, targetEntity)
	
        local damage = damageData.DamageAmount or 0
		
        if damage > 0 then
		
            local radius = damageData.DamageRadius or false
			
            if radius then

                local pos = LOUDCOPY(GetPosition(self))		

                if ScenarioInfo.ProjectileDialog then
                    ForkThread( function() LOG("*AI DEBUG Projectile OnDamage Area at "..repr(pos).." for "..damage.." - damageData is "..repr(damageData) ) end )
                end

                if not damageData.DoTTime then

                    DamageArea( instigator, pos, radius, damage, damageData.DamageType, damageData.DamageFriendly or false, damageData.DamageSelf or false)
					
                else
					
                    ForkTo( AreaDoTThread, instigator, pos, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), radius, damage, damageData.DamageType, damageData.DamageFriendly or false)
					
                end
				
            elseif damageData.DamageAmount and targetEntity then
		
                if ScenarioInfo.ProjectileDialog then
                    ForkThread( function() LOG("*AI DEBUG Projectile OnDamage to "..repr(targetEntity.BlueprintID).." for "..damage ) end )
                end
			
                if not damageData.DoTTime then
				
                    Damage( instigator, GetPosition(self), targetEntity, damage, damageData.DamageType or "Normal")
					
                else
				
                    ForkTo( UnitDoTThread, instigator, targetEntity, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), damage, damageData.DamageType, damageData.DamageFriendly or false)
					
                end
            end
        end
    end,

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
    
        if not EffectTable then return end

        local LOUDEMITATBONE = LOUDEMITATBONE
        local LOUDEMITATENTITY = LOUDEMITATENTITY

		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG Projectile CreateImpactEffects Scale "..repr(EffectScale).." for "..repr(EffectTable) )
		end	

        for _,v in EffectTable do
		
			if self.FxImpactTrajectoryAligned then
            
                if EffectScale then
                    LOUDEMITATBONE( self, -2, army, v ):ScaleEmitter(EffectScale)
                else
                    LOUDEMITATBONE( self, -2, army, v )
                end
			else
                if EffectScale then
                    LOUDEMITATENTITY( self, army, v ):ScaleEmitter(EffectScale)
                else
                    LOUDEMITATENTITY( self, army, v )
                end
			end 
        end
    end,
    
    CreateTerrainEffects = function( self, army, EffectTable, EffectScale )
    
        local BeenDestroyed = BeenDestroyed
        local LOUDEMITATBONE = LOUDEMITATBONE

		if ScenarioInfo.ProjectileDialog then
			LOG("*AI DEBUG Projectile CreateTerrainEffects for "..LOUDGETN(EffectTable) )
		end

        for k, v in EffectTable do
		
			if not BeenDestroyed(self) then
		
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
		
		-- if this unit category is on the weapon's do-not-collide list, skip!
		local DNC = firingWeapon.bp.DoNotCollideList

		if DNC then

            if ScenarioInfo.ProjectileDialog then
                LOG("*AI DEBUG Projectile OnCollisionCheckWeapon")
            end
		
			local LOUDENTITY = LOUDENTITY
			local LOUDPARSE = LOUDPARSE
			
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
    
        local ProjectileDialog = ScenarioInfo.ProjectileDialog
    
        local DD            = self.DamageData
        local DamageType    = DD.DamageType
        
        local STRINGSUB     = STRINGSUB
        local TONUMBER      = TONUMBER
    
        if DD.DamageAmount then

            if DD.Buffs then
                self:DoUnitImpactBuffs( GetPosition(self), targetEntity )
            end		

            -- because shield effects directly change the damage table
            -- we'll take a copy of and use that instead
            if targetType == 'Shield' then
            
                local DD = LOUDCOPY(self.DamageData)

                -- LOUD 'marshmallow shield effect' all AOE to 0 on shields
                if DD.DamageRadius > 0 then
                    self.DamageData.DamageRadius = nil
                end

                -- LOUD ShieldMult effect
                if STRINGSUB(DamageType, 1, 10) == 'ShieldMult' then

                    local mult = TONUMBER( STRINGSUB(DamageType, 11) ) or 1
                    self.DamageData.DamageAmount = DD.DamageAmount * mult

                end
            end

            if ProjectileDialog then
        
                LOG("*AI DEBUG Projectile OnImpact targetType is "..repr(targetType).." damage data is "..repr(DD.DamageAmount).." at "..GetGameTick() )
			
                if targetEntity then
                    LOG("*AI DEBUG Projectile OnImpact Target entity is "..repr(targetEntity.BlueprintID)..repr(targetEntity))
                end
            end

			self:DoDamage( GetLauncher(self) or self, DD, targetEntity)
		end

        local bp = ALLBPS[self.BlueprintID]
        

	
		-- when simspeed drops too low turn off visual impact effects
		if Sync.SimData.SimSpeed > -1 then

			local ImpactEffects = false
			local ImpactEffectScale = 0.8     -- default scaling
	
			local army = self.Army
	
			--ImpactEffects
			if targetType == 'Shield' then
		
				ImpactEffects = self.FxImpactShield
				ImpactEffectScale = self.FxShieldHitScale
			
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
			
			elseif targetType == 'Prop' then
		
				ImpactEffects = self.FxImpactProp
				ImpactEffectScale = self.FxPropHitScale

			elseif targetType == 'Water' then
		
				ImpactEffects = self.FxImpactWater
				ImpactEffectScale = self.FxWaterHitScale

			elseif targetType == 'Underwater' then
		
				ImpactEffects = self.FxImpactUnderWater
				ImpactEffectScale = self.FxUnderWaterHitScale

			elseif  targetType == 'UnitUnderwater' then
		
				ImpactEffects = self.FxImpactUnitUnderWater or self.FxImpactUnderWater
				ImpactEffectScale = self.FxUnderWaterHitScale

			elseif targetType == 'Air' then
		
				ImpactEffects = self.FxImpactNone
				ImpactEffectScale = self.FxNoneHitScale
			
			elseif targetType == 'Projectile' then
		
				ImpactEffects = self.FxImpactProjectile
				ImpactEffectScale = self.FxProjectileHitScale
			
			elseif targetType == 'ProjectileUnderwater' then
		
				ImpactEffects = self.FxImpactProjectileUnderWater or self.FxImpactProjectile
				ImpactEffectScale = self.FxUnderWaterHitScale			
			
			end

            if ProjectileDialog then
                LOG("*AI DEBUG Projectile OnImpact ImpactEffects "..repr(ImpactEffects).." from self "..repr(self) )
            end

			if ImpactEffects then
            
                if targetType != 'Shield' then

                    self:CreateImpactEffects( army, ImpactEffects, ImpactEffectScale )
                end
			end
            
            local ImpactEffectsType = bp.Display.ImpactEffects.Type

            if ProjectileDialog then
                LOG("*AI DEBUG Projectile OnImpact ImpactEffectsType "..repr(ImpactEffectsType) )
            end
	
			if ImpactEffectsType then

				local TerrainType = DefaultTerrainType
			
				if TerrainType.FXImpact[targetType][ImpactEffectsType] == nil then
					TerrainType = DefaultTerrainType
				end
			
				local TerrainEffect = TerrainType.FXImpact[targetType][ImpactEffectsType] or false
                
                if ProjectileDialog then
                    LOG("*AI DEBUG Projectile OnImpact ImpactEffects Terrain "..repr(TerrainType).." Effect "..repr(TerrainEffect) )
                end
			
				if TerrainEffect[1] then

                    if ProjectileDialog then
                        LOG("*AI DEBUG CollisionBeam UpdateTerrainCollisionEffects is "..repr(TerrainType.Description).." impact type "..repr(self.TerrainImpactType).." table data is "..repr(TerrainType.FXImpact[targetType][ImpactEffectsType]).." "..repr(TerrainEffect) )
                    end
			
					if not BeenDestroyed(self) then
                        ForkTo( self.CreateTerrainEffects, self, army, TerrainEffect, bp.Display.ImpactEffects.Scale or 1 )
					end
				end
			end
        end

        -- Railgun damage drops by 20% per target it collides with
		if DamageType == 'Railgun' then
            
            local DD = LOUDCOPY(self.DamageData)

			DD.DamageAmount = DD.DamageAmount * 0.8
			
			bp.Physics.ImpactTimeout = 0.1
		else
        
            self:SetCollisionShape( 'none' )

        end
        
        local Audio = bp.Audio['Impact'..targetType] or bp.Audio.Impact or false
		
        if Audio then
            PlaySound( self, Audio )
        end
        
        local ImpactTimeout = bp.Physics.ImpactTimeout
	
        if ImpactTimeout and (targetType == 'Terrain' or targetType == 'Air' or targetType == 'Underwater') then
		
            ForkTo( self.ImpactTimeoutThread, self, ImpactTimeout )
			
        else

			if DamageType != 'Railgun' then
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

	-- modified to carry only active data so any fields which are empty won't be created
    PassDamageData = function(self, damageData)

        self.DamageData = { DamageAmount = false, DamageType = 'Normal' }
		
        self.DamageData.DamageAmount = damageData.DamageAmount
        self.DamageData.DamageType = damageData.DamageType or 'Normal'

		if damageData.advancedTracking then
			self.DamageData.AdvancedTracking = damageData.advancedTracking
        end
		
		if damageData.ArtilleryShieldBlocks then
			self.DamageData.ArtilleryShieldBlocks = damageData.ArtilleryShieldBlocks
		end
		
		if damageData.Buffs then
			self.DamageData.Buffs = damageData.Buffs
		end
		
		if damageData.CollideFriendly then
			self.DamageData.CollideFriendly = damageData.CollideFriendly
		end

		if damageData.DamageRadius then
			self.DamageData.DamageRadius = damageData.DamageRadius
		end
	
		if damageData.DamageFriendly then
			self.DamageData.DamageFriendly = damageData.DamageFriendly
		end
		
		if damageData.DoTTime then
			self.DamageData.DoTTime = damageData.DoTTime
		end
		
		if damageData.DoTPulses then
			self.DamageData.DoTPulses = damageData.DoTPulses
		end

        if damageData.TrackingWeapon then
            self.DamageData.TrackingRadius          = damageData.TrackingRadius
            self.DamageData.TargetRestrictOnlyAllow = damageData.TargetRestrictOnlyAllow
            self.DamageData.TrackingWeapon          = damageData.TrackingWeapon

			ForkTo( self.Tracking, self )
        end            
		
        --LOG("*AI DEBUG PassDamageData result for "..repr(self.BlueprintID).." is "..repr(self.DamageData) )
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

    AddDepthCharge = function(self, tbl)
	
        if not tbl then return end
        if not tbl.Radius then return end
		
        self.MyDepthCharge = DepthCharge { Owner = self, Radius = tbl.Radius or 10 }
		
		if not self.Trash then
			self.Trash = TrashBag()
		end

        TrashAdd( self.Trash, self.MyDepthCharge )
    end,
    
    AddFlare = function(self, tbl)
	
        if not tbl then return end
        if not tbl.Radius then return end
		
        self.MyFlare = Flare {  Category = tbl.Category or '', Owner = self, Radius = tbl.Radius,  RadiusGrowth = tbl.RadiusGrowth or .4, RadiusGrowthTicks = tbl.RadiusGrowthTicks or 1,  RadiusStart = tbl.RadiusStart or 3 }
		
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
