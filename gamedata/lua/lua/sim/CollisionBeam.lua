--	/lua/sim/collisionbeam.lua

-- CollisionBeam is the simulation (gameplay-relevant) portion of a beam. It wraps a special effect
-- that may or may not exist depending on how the simulation is executing.

local DefaultDamage = import('/lua/sim/defaultdamage.lua')

local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDENTITY = EntityCategoryContains
local LOUDPARSE = ParseEntityCategory
local LOUDDAMAGE = Damage
local LOUDDAMAGEAREA = DamageArea
local LOUDEMITATBONE = CreateEmitterAtBone
local LOUDATTACHEMITTER = CreateAttachedEmitter
local ForkThread = ForkThread

local GetArmy = moho.entity_methods.GetArmy

local STRINGSUB = string.sub
local TONUMBER = tonumber

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy


CollisionBeam = Class(moho.CollisionBeamEntity) {

    FxBeam = {},
    FxBeamStartPoint = {},
    FxBeamStartPointScale = 1,
    FxBeamEndPoint = {},
    FxBeamEndPointScale = 1,

    FxUnderWaterHitScale = 0.25,

    TerrainImpactType = 'Default',
    TerrainImpactScale = 1,

    OnCreate = function(self)
	
        self.Army = GetArmy(self)
        
        self.BeamEffectsBag = {}

    end,

    OnDestroy = function(self)
        if self.Trash then
            TrashDestroy(self.Trash)
        end
    end,

    OnEnable = function(self)
        self:CreateBeamEffects()
    end,

    OnDisable = function(self)
        self:DestroyBeamEffects()
        self:DestroyTerrainEffects()
        self.LastTerrainType = nil
    end,

    SetParentWeapon = function(self, weapon)
        self.Weapon = weapon
    end,

    DoDamage = function(self, instigator, damageData, targetEntity)
	
        local damage = damageData.DamageAmount or 0
        local dmgmod = 1
		
        if self.Weapon.DamageModifiers then
            for k, v in self.Weapon.DamageModifiers do
                dmgmod = v * dmgmod
            end
        end
		
        damage = damage * dmgmod
		
        if instigator and damage > 0 then
		
            local radius = damageData.DamageRadius or 0
			
			local LOUDDAMAGEAREA = DamageArea
			local LOUDDAMAGE = Damage
			
            if radius > 0 then
			
                if not damageData.DoTTime or damageData.DoTTime <= 0 then
                    LOUDDAMAGEAREA(instigator, self:GetPosition(1), radius, damage, damageData.DamageType or 'Normal', damageData.DamageFriendly or false)
                else
                    ForkThread(DefaultDamage.AreaDoTThread, instigator, self:GetPosition(1), damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), radius, damage, damageData.DamageType, damageData.DamageFriendly)
                end
				
            elseif targetEntity then
			
                if not damageData.DoTTime or damageData.DoTTime <= 0 then
                    LOUDDAMAGE(instigator, self:GetPosition(1), targetEntity, damage, damageData.DamageType)
                else
                    ForkThread(DefaultDamage.UnitDoTThread, instigator, targetEntity, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), damage, damageData.DamageType, damageData.DamageFriendly)
                end
				
            else
                LOUDDAMAGEAREA(instigator, self:GetPosition(1), 0.25, damage, damageData.DamageType, damageData.DamageFriendly)
            end

        end
    end,

    CreateBeamEffects = function(self)
	
        local army = self.Army
		
		local LOUDATTACHEMITTER = CreateAttachedEmitter
		local LOUDGETN = table.getn
		local LOUDINSERT = table.insert
        
        local fx
        
        if not self.Trash then
            self.Trash = TrashBag()
        end
		
        for k, y in self.FxBeamStartPoint do
        
            fx = LOUDATTACHEMITTER(self, 0, army, y ):ScaleEmitter(self.FxBeamStartPointScale)
            
            LOUDINSERT( self.BeamEffectsBag, fx)
            
            TrashAdd( self.Trash, fx )
        end
		
        for k, y in self.FxBeamEndPoint do
        
            fx = LOUDATTACHEMITTER(self, 1, army, y ):ScaleEmitter(self.FxBeamEndPointScale)
            
            LOUDINSERT( self.BeamEffectsBag, fx)
            
            TrashAdd( self.Trash, fx )
        end
		
        if LOUDGETN(self.FxBeam) != 0 then
        
            local fxBeam = CreateBeamEmitter(self.FxBeam[Random(1, LOUDGETN(self.FxBeam))], army)
            
            AttachBeamToEntity(fxBeam, self, 0, army)
            
            -- collide on start if it's a continuous beam
            --local weaponBlueprint = self.Weapon:GetBlueprint()
            --local bCollideOnStart = self.Weapon:GetBlueprint().BeamLifetime <= 0
			
            self:SetBeamFx(fxBeam, self.Weapon.bp.BeamLifetime <= 0 )
            
            LOUDINSERT( self.BeamEffectsBag, fxBeam )
            
            TrashAdd( self.Trash, fxBeam )
        end
    end,

    DestroyBeamEffects = function(self)
        for k, v in self.BeamEffectsBag do
            v:Destroy()
        end
        self.BeamEffectsBag = {}
    end,

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
    
        if not EffectTable then return end
    
        local emit

        for k, v in EffectTable do
        
            emit = LOUDEMITATBONE(self,1,army,v)
            
            if emit and EffectScale and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale)
            end
            
        end
        
    end,

    CreateTerrainEffects = function( self, army, EffectTable, EffectScale )
    
        local emit = nil
        
        for k, v in EffectTable do
        
            emit = LOUDATTACHEMITTER(self,1,army,v)
            
            if not self.TerrainEffectsBag then
                self.TerrainEffectsBag = {}
            end
            
            LOUDINSERT(self.TerrainEffectsBag, emit )
            
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale)
            end
            
        end
        
    end,

    DestroyTerrainEffects = function( self )
    
        for k, v in self.TerrainEffectsBag do
            v:Destroy()
        end
        
        self.TerrainEffectsBag = nil
    end,

    UpdateTerrainCollisionEffects = function( self, TargetType )

        local TerrainType = nil

        if self.TerrainImpactType != 'Default' then
			local pos = self:GetPosition(1)
            TerrainType = GetTerrainType( pos.x,pos.z )
        else
            TerrainType = GetTerrainType( -1, -1 )
        end

        local TerrainEffects = TerrainType.FXImpact[TargetType][self.TerrainImpactType] or nil

        if TerrainEffects and (self.LastTerrainType != TerrainType) then
            self:DestroyTerrainEffects()
            self:CreateTerrainEffects( self.Army, TerrainEffects, self.TerrainImpactScale )
            self.LastTerrainType = TerrainType
        end
    end,

    -- This is called when the collision beam hits something new. Because the beam
    -- is continuously detecting collisions it only executes this function when the
    -- thing it is touching changes. Expect Impacts with non-physical things like
    -- 'Air' (hitting nothing) and 'Underwater' (hitting nothing underwater).
    OnImpact = function(self, impactType, targetEntity)
	
        --LOG('*AI DEBUG: COLLISION BEAM ONIMPACT ', repr(self))
        --LOG('*AI DEBUG: COLLISION BEAM ONIMPACT, WEAPON =  ', repr(self.Weapon), 'Type = ', impactType)
        --LOG('CollisionBeam impacted with: ' .. impactType )
        --# Possible 'type' values are:
        --#  'Unit'
        --#  'Terrain'
        --#  'Water'
        --#  'Air'
        --#  'UnitAir'
        --#  'Underwater'
        --#  'UnitUnderwater'
        --#  'Projectile'
        --#  'Prop'
        --#  'Shield'

        -- set the damage parameters from the blueprint
        self:SetDamageTable()
        
        if self.DamageData.DamageAmount then

            if impactType == 'Shield' then

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
		
                LOG("*AI DEBUG Beam OnImpact targetType is "..repr(impactType))
                LOG("*AI DEGUG Beam OnImpact data is "..repr(self.DamageData))
			
                if targetEntity then
                    LOG("*AI DEBUG Beam Target entity is "..repr(targetEntity.BlueprintID))
                end
            end

            if self.DamageData.Buffs then
                self:DoUnitImpactBuffs( targetEntity )
            end		

			self:DoDamage( self:GetLauncher() or self, self.DamageData, targetEntity)
		end

        local ImpactEffects = false
        local ImpactEffectScale = 1

        if impactType == 'Unit' then
            ImpactEffects = self.FxImpactUnit
            ImpactEffectScale = self.FxUnitHitScale
            
        elseif impactType == 'UnitAir' then
            ImpactEffects = self.FxImpactAirUnit
            ImpactEffectScale = self.FxAirUnitHitScale
            
        elseif impactType == 'Shield' then
            ImpactEffects = self.FxImpactShield
            ImpactEffectScale = self.FxShieldHitScale            
            
		elseif impactType == 'Water' then
            ImpactEffects = self.FxImpactWater
            ImpactEffectScale = self.FxWaterHitScale
            
        elseif impactType == 'Underwater' or impactType == 'UnitUnderwater' then
            ImpactEffects = self.FxImpactUnderWater
            ImpactEffectScale = self.FxUnderWaterHitScale
            
        elseif impactType == 'Terrain' then
            ImpactEffects = self.FxImpactLand
            ImpactEffectScale = self.FxLandHitScale
            
        elseif impactType == 'Air' or impactType == 'Projectile' then
            ImpactEffects = self.FxImpactNone
            ImpactEffectScale = self.FxNoneHitScale
            
        elseif impactType == 'Prop' then
            ImpactEffects = self.FxImpactProp
            ImpactEffectScale = self.FxPropHitScale
            
        end
		
        if ImpactEffects then
            self:CreateImpactEffects( self.Army, ImpactEffects, ImpactEffectScale )
        end
        
        self:UpdateTerrainCollisionEffects( impactType )
    end,

    GetCollideFriendly = function(self)
        return self.DamageData.CollideFriendly
    end,

    SetDamageTable = function(self)
    
        local damageData = self.Weapon.bp
        
        self.DamageData = { DamageAmount = false, DamageType = 'Normal' }
		
        self.DamageData.DamageAmount = damageData.Damage or 0.1
        self.DamageData.DamageType = damageData.DamageType

		if damageData.DamageRadius > 0 then
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
			LOG("*AI DEBUG CollisionBeam SetDamageTable is "..repr(self.DamageData))
		end

    end,

    --When this beam impacts with the target, do any buffs that have been passed to it.
    DoUnitImpactBuffs = function(self, target)
        local data = self.DamageData
        if data.Buffs then
            for k, v in data.Buffs do
                if v.Add.OnImpact == true and not LOUDENTITY((LOUDPARSE(v.TargetDisallow) or ''), target) 
                    and LOUDENTITY((LOUDPARSE(v.TargetAllow) or categories.ALLUNITS), target) then
                    
                    target:AddBuff(v)
                end
            end
        end
    end,

    ForkThread = function(self, fn, ...)
    
        if fn then
        
            local thread = ForkThread(fn, self, unpack(arg))
            
            TrashAdd( self.Trash, thread )

            return thread
        else
            return nil
        end
    end,
}
