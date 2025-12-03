--	/lua/sim/collisionbeam.lua

-- CollisionBeam is the simulation (gameplay-relevant) portion of a beam. It wraps a special effect
-- that may or may not exist depending on how the simulation is executing.

local DefaultDamage = import('/lua/sim/defaultdamage.lua')

local ForkThread        = ForkThread
local LOUDATTACHEMITTER = CreateAttachedEmitter
local LOUDDAMAGE        = Damage
local LOUDDAMAGEAREA    = DamageArea
local LOUDEMITATBONE    = CreateEmitterAtBone
local LOUDENTITY        = EntityCategoryContains
local LOUDGETN          = table.getn
local LOUDINSERT        = table.insert
local LOUDPARSE         = ParseEntityCategory
local LOUDSPLAT         = CreateSplat
local STRINGSUB         = string.sub
local TONUMBER          = tonumber

local GetArmy           = moho.entity_methods.GetArmy
local GetLauncher       = moho.CollisionBeamEntity.GetLauncher

local GetRandomFloat = import('/lua/utilities.lua').GetRandomFloat

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

--LOG( "COLLISIONBEAM METHODS = ",repr(moho.CollisionBeamEntity) )

CollisionBeam = Class(moho.CollisionBeamEntity) {

    FxBeam                  = false,
    FxBeamStartPoint        = false,
    FxBeamStartPointScale   = 1,
    FxBeamEndPoint          = false,
    FxBeamEndPointScale     = 1,

    FxUnderWaterHitScale = 0.25,

    TerrainImpactType = 'Default',
    TerrainImpactScale = 1,

    OnCreate = function(self)
	
        self.Army = GetArmy(self)

        if ScenarioInfo.WeaponDialog then
            LOG("*AI DEBUG CollisionBeam Weapon OnCreate for "..repr(self) )
        end

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

        if self.BeamEffectsBag then
            self:DestroyBeamEffects()
        end

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

        if (not self.FxBeamStartPoint and (not self.FxBeamEndPoint) and (not self.FxBeam)) then return end
        
        local army = self.Army
		
		local LOUDATTACHEMITTER = CreateAttachedEmitter
		local LOUDGETN          = LOUDGETN
        
        local fx
    
        if ScenarioInfo.ProjectileDialog then
            LOG("*AI DEBUG CollisionBeam Creating Beam Effects for "..repr(self.Label).." on Muzzle "..repr(self.Muzzle) )
        end

        if not self.BeamEffectsBag then
            self.BeamEffectsBag = {}
            self.BeamEffectsBagCounter = 1
        end
        
        if self.FxBeamStartPoint then

            for k, y in self.FxBeamStartPoint do

                if ScenarioInfo.ProjectileDialog then
                    LOG("*AI DEBUG CollisionBeam Creating Beam StartPoint Effect "..repr(y).." for "..repr(self.Label).." on Muzzle "..repr(self.Muzzle).." Scale is "..repr(self.FxBeamStartPointScale) )
                end
        
                fx = LOUDATTACHEMITTER(self, 0, army, y ):ScaleEmitter(self.FxBeamStartPointScale)
            
                self.BeamEffectsBag[self.BeamEffectsBagCounter] = fx
                self.BeamEffectsBagCounter = self.BeamEffectsBagCounter + 1
                
            end

        end
		
        if self.FxBeamEndPoint then
        
            for k, y in self.FxBeamEndPoint do

                if ScenarioInfo.ProjectileDialog then
                    LOG("*AI DEBUG CollisionBeam Creating Beam EndPoint Effect "..repr(y).." for "..repr(self.Label).." on Muzzle "..repr(self.Muzzle).." Scale is "..repr(self.FxBeamEndPointScale) )
                end
        
                fx = LOUDATTACHEMITTER(self, 1, army, y ):ScaleEmitter(self.FxBeamEndPointScale)
            
                self.BeamEffectsBag[self.BeamEffectsBagCounter] = fx
                self.BeamEffectsBagCounter = self.BeamEffectsBagCounter + 1

            end
            
        end
		
        if self.FxBeam and LOUDGETN(self.FxBeam) != 0 then

            fx = CreateBeamEmitter(self.FxBeam[Random(1, LOUDGETN(self.FxBeam))], army)

            AttachBeamToEntity(fx, self, 0, army)

            -- when this value is 'true' - a free immediate collision occurs
            -- this was originally triggered if the beam delay was <= 0
            -- I can see how this may have had some value for beam based TMD
            self:SetBeamFx(fx, false )
            
            self.BeamEffectsBag[self.BeamEffectsBagCounter] = fx
            self.BeamEffectsBagCounter = self.BeamEffectsBagCounter + 1

        end
	
    end,

    DestroyBeamEffects = function(self)
    
        if not self.BeamEffectsBag then return end
    
        for k, v in self.BeamEffectsBag do
            v:Destroy()
            self.BeamEffectsBag[k] = nil
        end

        self.BeamEffectsBagCounter = 1
    
        if ScenarioInfo.ProjectileDialog then
            LOG("*AI DEBUG Destroy Beam Effects for Weapon - data "..repr(self.Label).." on Muzzle "..repr(self.Muzzle) )
        end

    end,

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
    
        if EffectTable then
    
            local emit

            if ScenarioInfo.ProjectileDialog then
                LOG("*AI DEBUG CollisionBeam CreateImpactEffects is "..repr(EffectTable) )
            end

            for k, v in EffectTable do
        
                emit = LOUDEMITATBONE(self,1,army,v)
            
                if emit and EffectScale and EffectScale != 1 then
                    emit:ScaleEmitter(EffectScale)
                end
            end
        end
        
    end,

    CreateTerrainEffects = function( self, army, EffectTable, EffectScale )
    
        local emit = nil
        
        if not EffectTable[1] then
            return
        end

        if ScenarioInfo.ProjectileDialog then
            LOG("*AI DEBUG CollisionBeam CreateTerrainEffects is "..repr(EffectTable) )
        end

        for k, v in EffectTable do
        
            emit = LOUDATTACHEMITTER(self,1,army,v)
            
            if not self.TerrainEffectsBag then
                self.TerrainEffectsBag = {}
                self.TerrainEffectsBagCounter = 1
            end
            
            self.TerrainEffectsBag[self.TerrainEffectsBagCounter] = emit
            self.TerrainEffectsBagCounter = self.TerrainEffectsBagCounter + 1
            
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale)
            end
            
        end

        if ScenarioInfo.ProjectileDialog then
            LOG("*AI DEBUG CollisionBeam CreateTerrainEffects bag is "..repr(self.TerrainEffectsBag) )
        end

    end,

    DestroyTerrainEffects = function( self )
    
        if self.TerrainEffectsBag then

            if ScenarioInfo.ProjectileDialog then
                LOG("*AI DEBUG CollisionBeam DestroyTerrainEffects bag is "..repr(self.TerrainEffectsBag) )
            end
     
            for k, v in self.TerrainEffectsBag do
                v:Destroy()
                self.TerrainEffectsBag[v] = nil
            end
        
            self.TerrainEffectsBagCounter = 1
        end
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

        if TerrainEffects and (self.LastTerrainType != TerrainType.Description) then

            if ScenarioInfo.ProjectileDialog then
                LOG("*AI DEBUG CollisionBeam UpdateTerrainCollisionEffects is "..repr(TerrainType.Description).." impact type "..repr(self.TerrainImpactType).." table data is "..repr(TerrainType.FXImpact[TargetType][self.TerrainImpactType]).." "..repr(TerrainEffects) )
            end
 
            self:DestroyTerrainEffects()
            
            if TerrainEffects[1] then
                self:CreateTerrainEffects( self.Army, TerrainEffects, self.TerrainImpactScale )
            end
            
            if TargetType == 'Terrain' then

                if self.SplatTexture and self.ScorchSize then

                    local pos = self:GetPosition(1)
            
                    LOUDSPLAT( pos, GetRandomFloat(0,6.28), self.SplatTexture, self.ScorchSize, self.ScorchSize, 100, self.ScorchTime or 60, self.Army )

                end
            end


            self.LastTerrainType = TerrainType.Description
        end
    end,

    -- This is called when the collision beam hits something.
    -- Expect Impacts with non-physical things like
    -- 'Air' (hitting nothing) and 'Underwater' (hitting nothing underwater).
    OnImpact = function(self, impactType, targetEntity)

        local damageTable = self.DamageTable
        
        local DamageAmount      = damageTable.DamageAmount

        local ProjectileDialog  = ScenarioInfo.ProjectileDialog

        if DamageAmount then

            if damageTable.Buffs then
                self:DoUnitImpactBuffs( targetEntity, damageTable )
            end		

            if impactType == 'Shield' then
            
                -- because we are going to change the damageTable we want a copy
                -- and not the original table
                local damageTable = table.copy(self.DamageTable)

                -- LOUD 'marshmallow shield effect' all AOE to 0 on shields
                if damageTable.DamageRadius > 0 then

                    damageTable.DamageRadius = nil
                end

                -- LOUD ShieldMult effect
                if STRINGSUB(damageTable.DamageType, 1, 10) == 'ShieldMult' then

                    local mult = TONUMBER( STRINGSUB(damageTable.DamageType, 11) ) or 1

                    damageTable.DamageAmount = damageTable.DamageAmount * mult
                end
            end

			self:DoDamage( GetLauncher(self) or self, damageTable, targetEntity)
		end

        local ImpactEffects = false
        local ImpactEffectScale = 1
        
        local army = self.Army

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
            
        elseif impactType == 'Prop' then
            ImpactEffects = self.FxImpactProp
            ImpactEffectScale = self.FxPropHitScale
            
        end
        
        if ImpactEffects then

            if ProjectileDialog then
        
                LOG("*AI DEBUG CollisionBeam OnImpact targetType is "..repr(impactType).." data is "..repr(damageTable).." at "..GetGameTick() )
			
                if targetEntity then
                    LOG("*AI DEBUG CollisionBeam Target entity is "..repr(targetEntity.BlueprintID))
                end
            end
        
            self:CreateImpactEffects( army, ImpactEffects, ImpactEffectScale )
        end
        
        self:UpdateTerrainCollisionEffects( impactType )
    end,

    --When this beam impacts with the target, do any buffs that have been passed to it.
    DoUnitImpactBuffs = function(self, target, data)

        for k, v in data.Buffs do

            if v.Add.OnImpact == true and not LOUDENTITY( v.TargetDisallow, target ) and LOUDENTITY( v.TargetAllow, target ) then

                target:AddBuff(v)
            end
        end
    end,

    ForkThread = function(self, fn, ...)
    
        if fn then

            local thread = ForkThread(fn, self, unpack(arg))
            
            if self.Trash then
            
                TrashAdd( self.Trash, thread )
            
            end

            return thread
        else
            return nil
        end
    end,
}
