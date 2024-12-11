---  /lua/defaultexplosions.lua

local import = import

local Entity = import('/lua/sim/Entity.lua').Entity
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtilities = import('EffectUtilities.lua')

local Debris                = '/effects/entities/DebrisMisc04/DebrisMisc04_proj.bp'
local DefaultHitExplosion   = EffectTemplate.DefaultHitExplosion01
local FireCloud             = EffectTemplate.FireCloudMed01

local TableCat = import('utilities.lua').TableCat

local Random = Random

local GetRandomOffset = import('utilities.lua').GetRandomOffset

local CreateEffects                     = EffectUtilities.CreateEffects
local CreateEffectsWithOffset           = EffectUtilities.CreateEffectsWithOffset
local CreateEffectsWithRandomOffset     = EffectUtilities.CreateEffectsWithRandomOffset
local CreateBoneEffects                 = EffectUtilities.CreateBoneEffects
local CreateBoneEffectsOffset           = EffectUtilities.CreateBoneEffectsOffset
local CreateRandomEffects               = EffectUtilities.CreateRandomEffects

EffectUtilities = nil

local LOUDFLOOR = math.floor
local LOUDPI = math.pi
local LOUDSIN = math.sin
local LOUDCOS = math.cos

local LOUDSPLAT = CreateSplat
local LOUDDECAL = CreateDecal

local CreateAttachedEmitter = CreateAttachedEmitter
local CreateEmitterOnEntity = CreateEmitterOnEntity
local CreateEmitterAtEntity = CreateEmitterAtEntity

local LOUDPARTICLE = CreateLightParticle
local ForkThread = ForkThread
local WaitTicks = coroutine.yield

local EntityMethods = moho.entity_methods

local BeenDestroyed         = EntityMethods.BeenDestroyed
local CreateProjectile      = EntityMethods.CreateProjectile
local GetArmy               = EntityMethods.GetArmy
local GetPosition           = EntityMethods.GetPosition

EntityMethods = nil

local function GetRandomFloat( Min, Max )
    return Min + (Random() * (Max-Min) )
end

local function GetRandomInt( nmin, nmax)
    return LOUDFLOOR(Random() * (nmax - nmin + 1) + nmin)
end

local ScorchSplatTextures = {
    'scorch_001_albedo',
    'scorch_002_albedo',
    'scorch_003_albedo',
    'scorch_004_albedo',
    'scorch_005_albedo',
    'scorch_006_albedo',
    'scorch_007_albedo',
    'scorch_008_albedo',
    'scorch_009_albedo',
    'scorch_010_albedo',}

local ScorchDecalTextures = {
    'scorch_001_albedo',
    'scorch_002_albedo',
    'scorch_003_albedo',
    'scorch_004_albedo',
    'scorch_005_albedo',
    'scorch_006_albedo',
    'scorch_007_albedo',
    'scorch_008_albedo',
    'scorch_009_albedo',
    'scorch_010_albedo',}

local ALLBPS = __blueprints



function GetUnitSizes( unit )

    local bp = ALLBPS[unit.BlueprintID]
    
    return bp.SizeX or 0, bp.SizeY or 0, bp.SizeZ or 0
end

function GetUnitVolume( unit )

    local x,y,z = GetUnitSizes( unit )
    
    return x*y*z
end

function GetAverageBoundingXZRadius( unit )

    local bp = ALLBPS[unit.BlueprintID]
    
    return ( ( (bp.SizeX or 1) + (bp.SizeZ or 1) ) * 0.25)
end

function GetAverageBoundingXYZRadius( unit )

    local bp = ALLBPS[unit.BlueprintID]
    
    return ( ( (bp.SizeX or 1) + (bp.SizeY or 1) + (bp.SizeZ or 1) ) * 0.166)
end

function QuatFromRotation( rotation, x, y, z )

    local angleRot, qw, qx, qy, qz, angle
    
	local LOUDSIN = math.sin
	local LOUDCOS = math.cos
    
    angle = 0.00872664625 * rotation
    
    angleRot = LOUDSIN( angle )
    
    qw = LOUDCOS( angle )
    qx = x * angleRot
    qy = y * angleRot
    qz = z * angleRot
    return qx, qy, qz, qw
end

function CreateScalableUnitExplosion( unit, overKillRatio )

	if not BeenDestroyed(unit) then
	
		if IsUnit(unit) then 
			ForkThread( _CreateScalableUnitExplosion, CreateUnitExplosionEntity( unit, overKillRatio, unit.Army, GetPosition(unit) ))
		end
		
    end
end

function CreateDefaultHitExplosion( obj, scale )

    if obj and not BeenDestroyed(obj) then
	
		local army = obj.Army
	
		LOUDPARTICLE( obj, -1, army, 3 + (Random() * (2) ), 8.5 + (Random() * (4) ), 'glow_03', 'ramp_flare_02' )
		
        CreateEffects( obj, army, FireCloud )
		
    end
end

function CreateDefaultHitExplosionOffset( obj, scale, xOffset, yOffset, zOffset )

    if not BeenDestroyed(obj) then 
		CreateBoneEffectsOffset( obj, -1, obj.Army, DefaultHitExplosion, xOffset, yOffset, zOffset )
	end
end

function CreateDefaultHitExplosionAtBone( obj, boneName, scale )

	if not BeenDestroyed(obj) then
	
		local army = obj.Army
		
		LOUDPARTICLE( obj, boneName, army, 3 + (Random() * (2) ) * scale, 8.5 + (Random() * (4) ), 'glow_03', 'ramp_flare_02' )

		CreateBoneEffects( obj, boneName, army, FireCloud )
	end
end

function CreateTimedStuctureUnitExplosion( obj )

	local LOUDFLOOR = math.floor
	local WaitTicks = coroutine.yield
	
    local numExplosions = LOUDFLOOR( GetAverageBoundingXYZRadius(obj) * (Random() * (4) + 2) )
    
    local x,y,z = GetUnitSizes(obj)
	
    obj:ShakeCamera( 30, 1, 0, 0.45 * numExplosions )
	
    for i = 0, numExplosions do
        CreateDefaultHitExplosionOffset( obj, 1.0, unpack({GetRandomOffset(x,y,z,1.2)}))
        obj:PlayUnitSound('DeathExplosion')
        WaitTicks( 2 + (Random() * (4) ) )
    end
end

function MakeExplosionEntitySpec( unit, overKillRatio, army )

    return {
        Army = army,
        Dimensions = {GetUnitSizes( unit )},
        BoundingXZRadius = GetAverageBoundingXZRadius(unit),
        BoundingXYZRadius = GetAverageBoundingXYZRadius(unit),
        OverKillRatio = overKillRatio,
        Volume = GetUnitVolume( unit ), 
        Layer = unit:GetCurrentLayer(),
    }
    
end

function CreateUnitExplosionEntity( unit, overKillRatio, army, pos )

    local localentity = Entity(MakeExplosionEntitySpec( unit, overKillRatio, army ))

    Warp( localentity, pos or GetPosition(unit))
	
    return localentity
end

function _CreateScalableUnitExplosion( obj )

    local army = obj.Spec.Army
    local scale = obj.Spec.BoundingXZRadius
    local layer = obj.Spec.Layer
	
    -- Determine effect table to use, based on unit bounding box scale	
	-- Most units
    local BaseEffectTable = EffectTemplate.ExplosionEffectsMed01
    local ShakeTimeModifier = 0
    local ShakeMaxMul = 0.15 
	
	local LOUDEMITATENTITY = CreateEmitterAtEntity

	-- small units
    if scale < 1 then   
        BaseEffectTable = EffectTemplate.ExplosionEffectsSml01
        ShakeTimeModifier = -0.4
		ShakeMaxMul = 0.05
	-- large units
    elseif scale > 6 then 
        BaseEffectTable = EffectTemplate.ExplosionEffectsLrg01
        ShakeTimeModifier = 0.5
        ShakeMaxMul = 0.25
    end

	if scale > 1 and layer == 'Water' then
		local EnvironmentalEffectTable = GetUnitEnvironmentalExplosionEffects( layer, scale )
		
		if EnvironmentalEffectTable[1] then
			BaseEffectTable = TableCat( BaseEffectTable, EnvironmentalEffectTable )
		end
	end

    -- Create Generic emitter effects
    for _, v in BaseEffectTable do
		LOUDEMITATENTITY( obj, army, v )
    end	
	

    -- Create Light particle flash
	LOUDPARTICLE( obj, -1, army, 5 + (Random() * 3 ) * scale, 6 + (Random() * 3 ), 'glow_03', 'ramp_flare_02' )

    -- Create scorch mark on land
    if layer == 'Land' then
	
        if scale > 6.0 then
            CreateScorchMarkDecal( obj, scale * 0.65, army )
        else
            CreateScorchMarkSplat( obj, scale * 0.8, army )
        end
		
		-- Camera Shake  (.radius .maxshake .minshake .lifetime)
		obj:ShakeCamera( 24 * scale, scale * ShakeMaxMul, 0, 0.5 + ShakeTimeModifier )
    end

    -- Create GenericDebris chunks
    CreateDebrisProjectiles( obj, obj.Spec.BoundingXYZRadius, obj.Spec.Dimensions )

    obj:Destroy()
end

function GetUnitEnvironmentalExplosionEffects( layer, scale )

    local EffectTable = {}
	
    if layer == 'Water' then
        if scale < 1 then
            EffectTable = EffectTemplate.WaterSplash01      
        else
            EffectTable = EffectTemplate.DefaultProjectileWaterImpact      
        end
    end 
	
    return EffectTable
end

function CreateFlash( obj, bone, scale, army )
    LOUDPARTICLE( obj, bone, army, 5 + (Random() * 3 ) * scale, 6 + (Random() * 3 ), 'glow_03', 'ramp_flare_02' )
end

function CreateScorchMarkSplat( obj, scale, army )
    LOUDSPLAT( GetPosition(obj), (Random() * 6.28 ), ScorchSplatTextures[ LOUDFLOOR(Random() * (10) + 1) ], scale * 3, scale * 3, 110, 40 + (Random() * (60) ), army )
end

function CreateScorchMarkDecal( obj, scale, army )
    LOUDDECAL( GetPosition(obj), (Random() * 6.28 ), ScorchDecalTextures[ LOUDFLOOR(Random() * (10) + 1) ], '', 'Albedo', scale * 3, scale * 3, 110, 40 + (Random() * (60) ), army)
end

function CreateRandomScorchSplatAtObject( obj, scale, LOD, lifetime, army )
    LOUDSPLAT( GetPosition(obj), (Random() * 6.28 ), ScorchSplatTextures[ LOUDFLOOR(Random() * (10) + 1) ], scale, scale, LOD, lifetime, army )
end

function CreateWreckageEffects( obj, prop )

    if IsUnit(obj) then
	
        local army = GetArmy(obj)
		
        local scale = GetAverageBoundingXYZRadius( obj )
		
        local Emitters = {}
		
        local layer = obj:GetCurrentLayer()

        if scale < 0.5 then
		
            Emitters = CreateRandomEffects( prop, army, EffectTemplate.DefaultWreckageEffectsSml01, 1 )
			
        elseif scale > 1.5 then
		
            local x,y,z = GetUnitSizes(obj)
			
            Emitters = CreateEffectsWithRandomOffset( prop, army, EffectTemplate.DefaultWreckageEffectsLrg01, x, 0, z )
			
        else
            Emitters = CreateRandomEffects( prop, army, EffectTemplate.DefaultWreckageEffectsMed01, 2 )
        end

		-- random lifetime and scale
		for _, v in Emitters do
			v:SetEmitterParam( 'LIFETIME', 30 + (Random() * (90) ))
			v:ScaleEmitter(0.25 + (Random() * (0.75) ))
		end

    end
end

function CreateDebrisProjectiles( obj, volume, dimensions )
	
	local sx = dimensions[1]
	local sy = dimensions[2]
	local sz = dimensions[3]

    for i = 1, LOUDFLOOR(Random() * ( (volume*6) - (1 + volume*2) + 1) + (1 + (volume*2)) ) do
	
        local xpos, xpos, zpos = GetRandomOffset( sx, sy, sz, 1 )
        local xdir,ydir,zdir = GetRandomOffset( sx, sy, sz, 10 )

        CreateProjectile( obj, Debris, xpos, xpos, zpos, xdir, ydir + 2, zdir)
    end
	
end

function CreateDefaultExplosion( unit, scale, overKillRatio )

    CreateConcussionRing( Explosion, scale )

end

function CreateDestructionFire( object, scale )

    local proj = CreateProjectile( object, '/effects/entities/DestructionFire01/DestructionFire01_proj.bp', 0, 0, 0, nil, nil, nil)
	
    proj:SetBallisticAcceleration(-2 + (Random() * (-1) )):SetCollision(false)
	
    CreateEmitterOnEntity( proj, GetArmy(proj), '/effects/emitters/destruction_explosion_fire_01_emit.bp'):ScaleEmitter(scale)
end

function CreateDestructionSparks( object, scale )

    local proj
	local army = GetArmy(object)
	
    for i = 1, LOUDFLOOR(Random() * (5) + 3) do
	
        proj = CreateProjectile( object, '/effects/entities/DestructionSpark01/DestructionSpark01_proj.bp', 0, 0, 0, nil, nil, nil)
		
        proj:SetBallisticAcceleration(-2 + (Random() * (-1) )):SetCollision(false)
		
        CreateEmitterOnEntity( proj, army,'/effects/emitters/destruction_explosion_sparks_02_emit.bp'):ScaleEmitter(scale)
    end
end

function CreateFirePlume( object, scale )

    local proj
	local army = GetArmy(object)
	
    for i = 1, LOUDFLOOR(Random() * (5) + 3) do
	
        proj = CreateProjectile( object, '/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', 0, 0, 0, nil, nil, nil)
		
        proj:SetBallisticAcceleration(-2 + (Random() * (-1) )):SetCollision(false)
		
        local emitter = CreateEmitterOnEntity( proj, army,'/effects/emitters/destruction_explosion_fire_plume_02_emit.bp')

        local lifetime = 10 + (Random() * (10) )
        
        emitter:SetEmitterParam('REPEATTIME',lifetime)
        emitter:SetEmitterParam('LIFETIME', lifetime)
    end
end

function CreateExplosionProjectile( object, projectile, minnumber, maxnumber, effect, fxscalemin, fxscalemax, gravitymin, gravitymax, xpos, ypos, zpos, emitterparam)

    local fxscale = (Random() * (fxscalemax - fxscalemin) + fxscalemin)
    local yaccel = (Random() * (gravitymax - gravitymin) + gravitymin) * fxscale
    local number = (Random() * (maxnumber - minnumber) + minnumber)
	
    local proj, emitter
	local LOUDFLOOR = math.floor
	
    ypos = ypos * 0.5
	
    for j = 1, number do
        proj = CreateProjectile( object, projectile, xpos, ypos, zpos, nil, nil, nil):SetBallisticAcceleration(yaccel):SetCollision(false)
        emitter = CreateEmitterOnEntity( proj, GetArmy(proj), effect):ScaleEmitter(fxscale)
		
        if emitterparam then
            emitter:SetEmitterParam('REPEATTIME',LOUDFLOOR(12 * fxscale + 0.5))
            emitter:SetEmitterParam('LIFETIME',LOUDFLOOR(12 * fxscale + 0.5))
        end
    end
end

function CreateUnitDebrisEffects( object, bone )

    local Effects = {'/effects/emitters/destruction_explosion_smoke_09_emit.bp'}
    local army = GetArmy(object)

    for k, v in Effects do
        CreateAttachedEmitter(object, bone, army, v)
    end
end

function CreateExplosionMesh( object, projBP, posX, posY, posZ, scale, scaleVelocity, Lifetime, velX, velY, VelZ, orientRot, orientX, orientY, orientZ  )

    proj = CreateProjectile( object, projBP, posX, posY, posZ, nil, nil, nil)
    proj:SetScale(scale,scale,scale):SetScaleVelocity( scaleVelocity ):SetLifetime( Lifetime ):SetVelocity( velX, velY, VelZ )

    local orient = {0,0,0,0}
    orient[1], orient[2], orient[3], orient[4] = QuatFromRotation( orientRot, orientX, orientY, orientZ )

    proj:SetOrientation( orient, true)

    CreateEmitterAtEntity(proj, GetArmy(proj), '/effects/emitters/destruction_explosion_smoke_10_emit.bp')
    return proj
end

function CreateCompositeExplosionMeshes( object )

    local lifetime = 6.0
    local explosionMeshProjectiles = {}
    local scalingmin = 0.065
    local scalingmax = 0.135
	
	local GF = 0.1 + (Random() * (0.1) )

    explosionMeshProjectiles[1] = CreateExplosionMesh( object, '/effects/Explosion/Explosion01_a_proj.bp', 0.4, 0.4, 0.4, GF, scalingmin + (Random() * (scalingmax - scalingmin)), lifetime, 0.1, 0.1, 0.1, -45, 1,0,0 )
    explosionMeshProjectiles[2] = CreateExplosionMesh( object, '/effects/Explosion/Explosion01_b_proj.bp', -0.4, 0.4, 0.4, GF, scalingmin + (Random() * (scalingmax - scalingmin)), lifetime, -0.1, 0.1, 0.1, -80, 1, 0, -1  )
    explosionMeshProjectiles[3] = CreateExplosionMesh( object, '/effects/Explosion/Explosion01_c_proj.bp', -0.2, 0.4, -0.4, GF( 0.1, 0.2 ), scalingmin + (Random() * (scalingmax - scalingmin)), lifetime, -0.04, 0.1, -0.1, -90, -1,0,0 )
    explosionMeshProjectiles[4] = CreateExplosionMesh( object, '/effects/Explosion/Explosion01_d_proj.bp', 0.0, 0.7, 0.4, 0.1 + (Random() * (.04) ), scalingmin + (Random() * (scalingmax - scalingmin)), lifetime, 0, 0.1, 0, 90, 1,0,0 )

    WaitTicks( 3 )

end

function CreateSmoke( object, scale )

    local SmokeEffects = {'/effects/emitters/destruction_explosion_smoke_03_emit.bp','/effects/emitters/destruction_explosion_smoke_07_emit.bp'}

    for k, v in SmokeEffects do
        CreateEmitterAtEntity( object, GetArmy(object), v ):ScaleEmitter(scale)
    end
end

function CreateConcussionRing( object, scale )
    CreateEmitterAtEntity( object, GetArmy(object), '/effects/emitters/destruction_explosion_concussion_ring_01_emit.bp'):ScaleEmitter(scale)
end

function CreateFireShadow( object, scale )
    CreateEmitterAtEntity( object, GetArmy(object), '/effects/emitters/destruction_explosion_fire_shadow_01_emit.bp'):ScaleEmitter(scale)
end

function OldCreateWreckageEffects( object )
    local Effects = {'/effects/emitters/destruction_explosion_smoke_08_emit.bp'}

    for k, v in Effects do
        CreateEmitterAtEntity( object, GetArmy(object), v):SetEmitterParam('LIFETIME', 60 + (Random() * (90) ) )
    end
end