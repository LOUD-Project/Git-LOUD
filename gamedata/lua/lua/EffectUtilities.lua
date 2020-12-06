--	/lua/EffectUtilities.lua

-- This file is responsible for a lot of the faction specific visuals

local import = import

local util = import('utilities.lua')

local Cross = import('utilities.lua').Cross
local GetClosestVector = import('utilities.lua').GetClosestVector

local GetRandomFloat = import('utilities.lua').GetRandomFloat
local GetRandomInt = import('utilities.lua').GetRandomInt
local GetScaledDirectionVector = import('utilities.lua').GetScaledDirectionVector

local Entity = import('/lua/sim/Entity.lua').Entity

local EffectTemplate = import('/lua/EffectTemplates.lua')
local ReclaimBeams = import('/lua/EffectTemplates.lua').ReclaimBeams
local ReclaimObjectAOE = import('/lua/EffectTemplates.lua').ReclaimObjectAOE
local ReclaimObjectEnd = import('/lua/EffectTemplates.lua').ReclaimObjectEnd
local AeonBuildBeams01 = import('/lua/EffectTemplates.lua').AeonBuildBeams01
local AeonBuildBeams02 = import('/lua/EffectTemplates.lua').AeonBuildBeams02
local CybranBuildSparks01 = import('/lua/EffectTemplates.lua').CybranBuildSparks01
local CybranBuildFlash01 = import('/lua/EffectTemplates.lua').CybranBuildFlash01
local CybranBuildUnitBlink01 = import('/lua/EffectTemplates.lua').CybranBuildUnitBlink01
local SeraphimBuildBeams01 = import('/lua/EffectTemplates.lua').SeraphimBuildBeams01

local LOUDABS = math.abs
local LOUDCOS = math.cos
local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDPI = math.pi
local LOUDREMOVE = table.remove
local LOUDSIN = math.sin
local LOUDWARP = Warp
local CreateLightParticle = CreateLightParticle
local CreateProjectile = moho.entity_methods.CreateProjectile
local LOUDEMITONENTITY = CreateEmitterOnEntity
local LOUDEMITATENTITY = CreateEmitterAtEntity
local LOUDEMITATBONE = CreateEmitterAtBone
local LOUDATTACHEMITTER = CreateAttachedEmitter
local LOUDATTACHBEAMENTITY = AttachBeamEntityToEntity

local WaitTicks = coroutine.yield

--local GetArmy = moho.entity_methods.GetArmy
local GetBlueprint = moho.entity_methods.GetBlueprint
local GetFractionComplete = moho.entity_methods.GetFractionComplete
local BeenDestroyed = moho.entity_methods.BeenDestroyed
local SetVelocity = moho.projectile_methods.SetVelocity

function CreateEffects( obj, army, EffectTable )

    local emitters = {}
    local counter = 0
	
    for _, v in EffectTable do
		emitters[counter+1] = LOUDEMITATENTITY( obj, army, v )
        counter = counter + 1
    end
    
    return emitters
end

function CreateEffectsWithOffset( obj, army, EffectTable, x, y, z )

    local emitters = {}
    local counter = 0
	
    for _, v in EffectTable  do
		emitters[counter+1] = LOUDEMITATENTITY( obj, army, v ):OffsetEmitter(x, y, z)
        counter = counter + 1
    end
    
    return emitters
end

function CreateEffectsWithRandomOffset( obj, army, EffectTable, xRange, yRange, zRange )

    local emitters = {}
	local counter = 0
	
    for _, v in EffectTable do
		emitters[counter+1] = LOUDEMITONENTITY( obj, army, v ):OffsetEmitter(util.GetRandomOffset(xRange, yRange, zRange, 1))
		counter = counter + 1
    end
    
	return emitters
end


function CreateBoneEffects( obj, bone, army, EffectTable )

    local emitters = {}
    local counter = 0
	
    for _, v in EffectTable do
		emitters[counter+1] = LOUDEMITATBONE( obj, bone, army, v )
        counter = counter + 1
    end
    
    return emitters
end

function CreateBoneEffectsOffset( obj, bone, army, EffectTable, x, y, z )

    local emitters = {}
    local counter = 0

    for _, v in EffectTable do
		emitters[counter+1] = LOUDEMITATBONE( obj, bone, army, v ):OffsetEmitter(x, y, z)
        counter = counter + 1
    end

    return emitters
end

function CreateBoneTableEffects( obj, BoneTable, army, EffectTable )
	
    for _, vBone in BoneTable do
        for _, vEffect in EffectTable do
            LOUDINSERT(emitters,LOUDEMITATBONE( obj, vBone, army, vEffect ))
        end
    end
end

function CreateBoneTableRangedScaleEffects( obj, BoneTable, EffectTable, army, ScaleMin, ScaleMax )
	
    for _, vBone in BoneTable do
        for _, vEffect in EffectTable do
            LOUDEMITATBONE( obj, vBone, army, vEffect ):ScaleEmitter(GetRandomFloat(ScaleMin, ScaleMax))
        end
    end
end


function CreateRandomEffects( obj, army, EffectTable, NumEffects )
	
    local NumTableEntries = LOUDGETN(EffectTable)
    local emitters = {}
	local counter = 0
	
    for i = 1, NumEffects do
        emitters[counter+1] = LOUDEMITONENTITY( obj, army, EffectTable[GetRandomInt(1,NumTableEntries)] )
		counter = counter + 1
    end
	
    return emitters
end

function ScaleEmittersParam( Emitters, param, minRange, maxRange )
	
    for _, v in Emitters do
        v:SetEmitterParam( param, GetRandomFloat( minRange, maxRange ) )
    end
end


function CreateBuildCubeThread( unitBeingBuilt, builder, OnBeingBuiltEffectsBag )

	local LOUDABS = math.abs
	
    local bp = GetBlueprint(unitBeingBuilt)
	local pos = unitBeingBuilt:GetPosition()
	
    local xPos = pos[1]
	local yPos = pos[2]
	local zPos = pos[3]
    local proj, slice = nil
	
    yPos = yPos + (bp.Physics.MeshExtentsOffsetY or 0)

    local x = bp.Physics.MeshExtentsX or bp.SizeX or (bp.Footprint.SizeX * 1.05) 
    local z = bp.Physics.MeshExtentsZ or bp.SizeZ or (bp.Footprint.SizeZ * 1.05) 
    local y = bp.Physics.MeshExtentsY or bp.SizeY or (0.5 + (x + z) * 0.1) 

    local SlicePeriod = 1.5
    
    -- Create a quick glow effect at location where unit is goig to be built
    proj = unitBeingBuilt:CreateProjectile('/effects/Entities/UEFBuildEffect/UEFBuildEffect02_proj.bp',0,0,0, nil, nil, nil )
    proj:SetScale(x * 1.05, y * 0.2, z * 1.05)
    WaitTicks(1)
	
    if unitBeingBuilt.Dead then
        return
    end
	
    local BuildBaseEffect = unitBeingBuilt:CreateProjectile('/effects/Entities/UEFBuildEffect/UEFBuildEffect03_proj.bp', 0, 0, 0, nil, nil, nil )
	
	OnBeingBuiltEffectsBag:Add(BuildBaseEffect)

	unitBeingBuilt.Trash:Add(BuildBaseEffect)
	LOUDWARP( BuildBaseEffect, Vector(xPos, yPos-y, zPos))
	BuildBaseEffect:SetScale(x, y, z)
	BuildBaseEffect:SetVelocity(0, 1.4 * y, 0)

    WaitTicks(6)
	
    if unitBeingBuilt.Dead then
        return
    end
    
    if not BuildBaseEffect:BeenDestroyed() then
        BuildBaseEffect:SetVelocity(0)
    end
    
    unitBeingBuilt:ShowBone(0, true)
    unitBeingBuilt:HideLandBones()
    unitBeingBuilt.BeingBuiltShowBoneTriggered = true

    local lComplete = GetFractionComplete(unitBeingBuilt)
	
    WaitTicks(4)
	
    if unitBeingBuilt.Dead then
        return
    end
	
    local cComplete = GetFractionComplete(unitBeingBuilt)
	local BeenDestroyed = moho.entity_methods.BeenDestroyed

    -- Create glow slice cuts and resize base cube
    while not unitBeingBuilt.Dead and cComplete < 1.0 do
	
        if lComplete < cComplete and not BeenDestroyed(BuildBaseEffect) then
	        proj = CreateProjectile( BuildBaseEffect, '/effects/Entities/UEFBuildEffect/UEFBuildEffect02_proj.bp',0,y * (1-cComplete),0, nil, nil, nil )
			
			OnBeingBuiltEffectsBag:Add(proj)
			
            slice = LOUDABS(lComplete - cComplete)
            proj:SetScale(x, y * slice, z)
            BuildBaseEffect:SetScale(x, y * (1-cComplete), z)
        end
		
        WaitTicks(SlicePeriod * 10)
		
        if unitBeingBuilt.Dead then
            break
        end
		
        lComplete = cComplete
        cComplete = GetFractionComplete(unitBeingBuilt)
    end
	
	if not BeenDestroyed(BuildBaseEffect) then
		BuildBaseEffect:Destroy()
	end
end

function CreateUEFUnitBeingBuiltEffects( builder, unitBeingBuilt, BuildEffectsBag )

    BuildEffectsBag:Add( LOUDATTACHEMITTER( builder, builder:GetBlueprint().Display.BuildAttachBone, builder.Sync.army, '/effects/emitters/uef_mobile_unit_build_01_emit.bp' ) )
end

function CreateUEFBuildSliceBeams( builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag )

    local army = builder.Sync.army
    local BeamBuildEmtBp = '/effects/emitters/build_beam_01_emit.bp'
    
    local buildbp = GetBlueprint(unitBeingBuilt)

	local pos = unitBeingBuilt:GetPosition()

	local x = pos[1]
	local y = pos[2]
	local z = pos[3]
    
    y = y + (buildbp.Physics.MeshExtentsOffsetY or 0)    

    -- Create a projectile for the end of build effect and WARP it to the unit
    local BeamEndEntity = unitBeingBuilt:CreateProjectile('/effects/entities/UEFBuild/UEFBuild01_proj.bp',0,0,0,nil,nil,nil)
	
    BuildEffectsBag:Add( BeamEndEntity )

    -- Create build beams
    if BuildEffectBones != nil then
        local beamEffect = nil
        for i, BuildBone in BuildEffectBones do
            BuildEffectsBag:Add( LOUDATTACHBEAMENTITY( builder, BuildBone, BeamEndEntity, -1, army, BeamBuildEmtBp ) )
            BuildEffectsBag:Add( LOUDATTACHEMITTER( builder, BuildBone, army, '/effects/emitters/flashing_blue_glow_01_emit.bp' ) )             
        end
    end

    -- Determine beam positioning on build cube, this should match sizes of CreateBuildCubeThread
    local mul = 1.05
    local ox = buildbp.SizeX or buildbp.Physics.MeshExtentsX or (buildbp.Footprint.SizeX * mul) 
    local oz = buildbp.SizeZ or buildbp.Physics.MeshExtentsZ or (buildbp.Footprint.SizeZ * mul) 
    local oy = buildbp.SizeY or buildbp.Physics.MeshExtentsY or ((0.5 + (ox + oz) * 0.1))

    ox = ox * 0.5
    oz = oz * 0.5

    -- Determine the the 2 closest edges of the build cube and use those for the location of laser
    local VectorExtentsList = { Vector(x + ox, y + oy, z + oz), Vector(x + ox, y + oy, z - oz), Vector(x - ox, y + oy, z + oz), Vector(x - ox, y + oy, z - oz) }
    local endVec1 = GetClosestVector(builder:GetPosition(), VectorExtentsList )

    for k,v in VectorExtentsList do
        if(v == endVec1) then
            LOUDREMOVE(VectorExtentsList, k)
        end
    end

    local endVec2 = GetClosestVector(builder:GetPosition(), VectorExtentsList )
    local cx1 = endVec1[1]
	local cy1 = endVec1[2]
	local cz1 = endVec1[3]
    local cx2 = endVec2[1]
	local cy2 = endVec2[2]
	local cz2 = endVec2[3]

    #-- Determine a the velocity of our projectile, used for the scanning effect
    local velX = 2 * (endVec2.x - endVec1.x)
    local velY = 2 * (endVec2.y - endVec1.y)
    local velZ = 2 * (endVec2.z - endVec1.z)

    if unitBeingBuilt:GetFractionComplete() == 0 then
        LOUDWARP( BeamEndEntity, Vector( (cx1 + cx2) * 0.5, ((cy1 + cy2) * 0.5) - oy, (cz1 + cz2) * 0.5 ) ) 
        WaitTicks(8)   
    end 

    local flipDirection = true

    #-- WARP our projectile back to the initial corner and lower based on build completeness
    while not BeenDestroyed(builder) and not BeenDestroyed(unitBeingBuilt) do
        if flipDirection then
            LOUDWARP( BeamEndEntity, Vector( cx1, (cy1 - (oy * unitBeingBuilt:GetFractionComplete())), cz1 ) )
            BeamEndEntity:SetVelocity( velX, velY, velZ )
            flipDirection = false
        else
            LOUDWARP( BeamEndEntity, Vector( cx2, (cy2 - (oy * unitBeingBuilt:GetFractionComplete())), cz2 ) )
            BeamEndEntity:SetVelocity( -velX, -velY, -velZ )
            flipDirection = true
        end
		
        WaitTicks(8)
    end
end

function CreateUEFCommanderBuildSliceBeams( builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag )

    local army = builder.Sync.army
    local BeamBuildEmtBp = '/effects/emitters/build_beam_01_emit.bp'
    local buildbp = GetBlueprint(unitBeingBuilt)
	local pos = unitBeingBuilt:GetPosition()
	local x = pos[1]
	local y = pos[2]
	local z = pos[3]
    y = y + (buildbp.Physics.MeshExtentsOffsetY or 0)    

    -- Create a projectile for the end of build effect and WARP it to the unit
    local BeamEndEntity = unitBeingBuilt:CreateProjectile('/effects/entities/UEFBuild/UEFBuild01_proj.bp',0,0,0,nil,nil,nil)
    local BeamEndEntity2 = unitBeingBuilt:CreateProjectile('/effects/entities/UEFBuild/UEFBuild01_proj.bp',0,0,0,nil,nil,nil)
    BuildEffectsBag:Add( BeamEndEntity )
    BuildEffectsBag:Add( BeamEndEntity2 )
    
    -- Create build beams
    if BuildEffectBones != nil then
        local beamEffect = nil
        for i, BuildBone in BuildEffectBones do
            BuildEffectsBag:Add( LOUDATTACHBEAMENTITY( builder, BuildBone, BeamEndEntity, -1, army, BeamBuildEmtBp ) )
            BuildEffectsBag:Add( LOUDATTACHBEAMENTITY( builder, BuildBone, BeamEndEntity2, -1, army, BeamBuildEmtBp ) )
            BuildEffectsBag:Add( LOUDATTACHEMITTER( builder, BuildBone, army, '/effects/emitters/flashing_blue_glow_01_emit.bp' ) )                                    
        end
    end

    -- Determine beam positioning on build cube, this should match sizes of CreateBuildCubeThread
    local mul = 1.05
    local ox = buildbp.SizeX or buildbp.Physics.MeshExtentsX or (buildbp.Footprint.SizeX * mul)
    local oz = buildbp.SizeZ or buildbp.Physics.MeshExtentsZ or (buildbp.Footprint.SizeZ * mul)
    local oy = buildbp.SizeY or buildbp.Physics.MeshExtentsY or ((0.5 + (ox + oz) * 0.1))

    ox = ox * 0.5
    oz = oz * 0.5

    -- Determine the the 2 closest edges of the build cube and use those for the location of our laser
    local VectorExtentsList = { Vector(x + ox, y + oy, z + oz), Vector(x + ox, y + oy, z - oz), Vector(x - ox, y + oy, z + oz), Vector(x - ox, y + oy, z - oz) }
    local endVec1 = GetClosestVector(builder:GetPosition(), VectorExtentsList )

    for k,v in VectorExtentsList do
        if(v == endVec1) then
            LOUDREMOVE(VectorExtentsList, k)
        end
    end

    local endVec2 = GetClosestVector(builder:GetPosition(), VectorExtentsList )
    local cx1 = endVec1[1]
	local cy1 = endVec1[2]
	local cz1 = endVec1[3]
    local cx2 = endVec2[1]
	local cy2 = endVec2[2]
	local cz2 = endVec2[3]

    -- Determine a the velocity of our projectile, used for the scaning effect
    local velX = 2 * (endVec2.x - endVec1.x)
    local velY = 2 * (endVec2.y - endVec1.y)
    local velZ = 2 * (endVec2.z - endVec1.z)

    if GetFractionComplete(unitBeingBuilt) == 0 then
        LOUDWARP( BeamEndEntity, Vector( cx1, cy1 - oy, cz1 ) ) 
        LOUDWARP( BeamEndEntity2, Vector( cx2, cy2 - oy, cz2 ) )
        WaitTicks(8)   
    end    

    local flipDirection = true

    -- WARP our projectile back to the initial corner and lower based on build completeness
    while not BeenDestroyed(builder) and not BeenDestroyed(unitBeingBuilt) do
        if flipDirection then
            LOUDWARP( BeamEndEntity, Vector( cx1, (cy1 - (oy * unitBeingBuilt:GetFractionComplete())), cz1 ) )
            BeamEndEntity:SetVelocity( velX, velY, velZ )
            LOUDWARP( BeamEndEntity2, Vector( cx2, (cy2 - (oy * unitBeingBuilt:GetFractionComplete())), cz2 ) )
            BeamEndEntity2:SetVelocity( -velX, -velY, -velZ )
            flipDirection = false
        else
            LOUDWARP( BeamEndEntity, Vector( cx2, (cy2 - (oy * unitBeingBuilt:GetFractionComplete())), cz2 ) )
            BeamEndEntity:SetVelocity( -velX, -velY, -velZ )
            LOUDWARP( BeamEndEntity2, Vector( cx1, (cy1 - (oy * unitBeingBuilt:GetFractionComplete())), cz1 ) )
            BeamEndEntity2:SetVelocity( velX, velY, velZ )            
            flipDirection = true
        end
		
        WaitTicks(8)
    end
end


function CreateDefaultBuildBeams( builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag )

    local BeamBuildEmtBp = '/effects/emitters/build_beam_01_emit.bp'
	local pos = unitBeingBuilt:GetPosition()
	local ox = pos[1]
	local oy = pos[2]
	local oz = pos[3]

    local BeamEndEntity = Entity()
    local army = builder.Sync.army
	
	local LOUDINSERT = table.insert
	local GetRandomFloat = GetRandomFloat
	
    BuildEffectsBag:Add( BeamEndEntity )
    LOUDWARP( BeamEndEntity, Vector(ox, oy, oz))   
   
    local BuildBeams = {}

    -- Create build beams
    if BuildEffectBones != nil then
        local beamEffect = nil
		
        for i, BuildBone in BuildEffectBones do
            local beamEffect = LOUDATTACHBEAMENTITY(builder, BuildBone, BeamEndEntity, -1, army, BeamBuildEmtBp )
            LOUDINSERT( BuildBeams, beamEffect )
            BuildEffectsBag:Add(beamEffect)
        end
    end    

    LOUDEMITONENTITY( BeamEndEntity, builder.Sync.army, '/effects/emitters/sparks_08_emit.bp')
	
    local waitTime = GetRandomFloat( 0.8, 1.6 ) * 10

    while not BeenDestroyed(builder) and not BeenDestroyed(unitBeingBuilt) do
        local x, y, z = builder.GetRandomOffset(unitBeingBuilt, 1 )
        LOUDWARP( BeamEndEntity, Vector(ox + x, oy + y, oz + z))
        WaitTicks(waitTime)
    end
end

-- effects used when building structures
function CreateAeonBuildBaseThread( unitBeingBuilt, builder, EffectsBag )

	local army = builder.Sync.army
    local bp = GetBlueprint(unitBeingBuilt)
	local pos = unitBeingBuilt:GetPosition()
	
	local x = pos[1]
	local y = pos[2]
	local z = pos[3]

    local sx = bp.Physics.MeshExtentsX or bp.SizeX or bp.Footprint.SizeX * 0.5
    local sz = bp.Physics.MeshExtentsZ or bp.SizeZ or bp.Footprint.SizeZ * 0.5
    local sy = bp.Physics.MeshExtentsY or bp.SizeY or sx + sz

    WaitTicks(1)

    -- Create a pool mercury that slowly draws into the build unit
    local BuildBaseEffect = CreateProjectile( unitBeingBuilt, '/effects/entities/AeonBuildEffect/AeonBuildEffect01_proj.bp', nil, 0, 0, nil, nil, nil )
	
	-- size the pool so that its slightly larger on the Y
    BuildBaseEffect:SetScale(sx, sy * 1.5, sz)
	
    LOUDWARP( BuildBaseEffect, Vector(x,y,z))
	
    BuildBaseEffect:SetOrientation(unitBeingBuilt:GetOrientation(), true)    
	
    unitBeingBuilt.Trash:Add(BuildBaseEffect)
	
    EffectsBag:Add(BuildBaseEffect)

    LOUDEMITONENTITY(BuildBaseEffect, army,'/effects/emitters/aeon_being_built_ambient_01_emit.bp'):SetEmitterCurveParam('X_POSITION_CURVE', 0, sx * 1.5):SetEmitterCurveParam('Z_POSITION_CURVE', 0, sz * 1.5)
    
    LOUDEMITONENTITY(BuildBaseEffect, army,'/effects/emitters/aeon_being_built_ambient_03_emit.bp'):ScaleEmitter( (sx + sz) * 0.3 )

    local slider = CreateSlider( unitBeingBuilt, 0 )
	
    slider:SetWorldUnits(true)
    slider:SetGoal(0, -sy, 0)
    slider:SetSpeed(-2)
    WaitFor(slider)
	
    slider:SetSpeed(0.25)

    -- while we are less than 95% complete, raise the model in small steps
    while not unitBeingBuilt.Dead and GetFractionComplete(unitBeingBuilt) < 0.95 do
		slider:SetGoal( 0, -sy + ( sy * GetFractionComplete(unitBeingBuilt)), 0 )
        WaitTicks(5)
    end
	
	slider:SetGoal( 0, 0, 0 )

    if not BuildBaseEffect:BeenDestroyed() then
	    BuildBaseEffect:SetScaleVelocity(-0.12, -0.12, -0.12)
	end    
	
    slider:SetSpeed(0.3)
	
	repeat
		WaitTicks(3)
	until unitBeingBuilt.Dead or GetFractionComplete(unitBeingBuilt) == 1
	
    slider:Destroy()
    BuildBaseEffect:Destroy()
end


function CreateCybranBuildBeams( builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag )

    if BuildEffectBones then
	
		WaitTicks(2)    -- this delay seems to be necessary so that the position of the unit is correct
		
		local BeamBuildEmtBp = '/effects/emitters/build_beam_02_emit.bp'

		local pos = unitBeingBuilt:GetPosition()
		local ox = pos[1]
		local oy = pos[2]
		local oz = pos[3]

		local army = builder.Sync.army
	
		local BeamEndEntities = {}
		local counter = 0
    
        for i, BuildBone in BuildEffectBones do
		
            local beamEnd = Entity()
			
            builder.Trash:Add(beamEnd)
			
            BeamEndEntities[counter+1] = beamEnd
			counter = counter + 1
			
            BuildEffectsBag:Add( beamEnd )
			
            LOUDWARP( beamEnd, Vector(ox, oy, oz))
			
            LOUDEMITONENTITY( beamEnd, army, CybranBuildSparks01 )
            LOUDEMITONENTITY( beamEnd, army, CybranBuildFlash01 )
			
            BuildEffectsBag:Add( LOUDATTACHBEAMENTITY( builder, BuildBone, beamEnd, -1, army, BeamBuildEmtBp ) )
			
        end
		
		-- move the beams around every 16 ticks
		while not BeenDestroyed(builder) and not BeenDestroyed(unitBeingBuilt) do
		
			for k, v in BeamEndEntities do
		
				local x, y, z = builder.GetRandomOffset(unitBeingBuilt, 1 )
			
				if v and not BeenDestroyed(v) then
					LOUDWARP( v, Vector(ox + x, oy + y, oz + z))
				end
			
			end
			
			WaitTicks(16)
		end
		
    end
	
end

function SpawnBuildBots( builder, unitBeingBuilt, numBots,  BuildEffectsBag )

    local army = builder.Sync.army
	
	local pos = builder:GetPosition()
	local x = pos[1]
	local y = pos[2]
	local z = pos[3]

	pos = builder:GetOrientation()
	local qx = pos[1]
	local qy = pos[2]
	local qz = pos[3]
	local qw = pos[4]

    local angle = (2*LOUDPI) / numBots

    local xVec = 0
    local yVec = builder:GetBlueprint().SizeY * 0.5
    local zVec = 0
	
    local BuilderUnits = {}
	local counter = 0
	
    local tunit = nil

    for i = 0, (numBots - 1) do
	
        xVec = LOUDSIN( 180 + (i*angle)) * 0.5
        zVec = LOUDCOS( 180 + (i*angle)) * 0.5
		
        tunit = CreateUnit('ura0001', army, x + xVec, y + yVec, z + zVec, qx, qy, qz, qw, 'Air' )

        -- Make build bots unkillable
        tunit:SetCanTakeDamage(false)
        tunit:SetCanBeKilled(false)
        
        BuilderUnits[counter+1] = tunit
		counter = counter + 1
		
        BuildEffectsBag:Add(tunit)
		
    end
	
    IssueGuard( BuilderUnits, unitBeingBuilt )
	
    return BuilderUnits
	
end

function CreateCybranEngineerBuildEffects( builder, BuildBones, BuildBots, BuildEffectsBag )

    -- Create constant build effect for each build bone defined
    if BuildBones then
	
        local army = builder.Sync.army
		
        for _, vBone in BuildBones do
            for _, vEffect in CybranBuildUnitBlink01 do
                BuildEffectsBag:Add( LOUDATTACHEMITTER(builder,vBone,army,vEffect))
            end
            WaitTicks( (GetRandomFloat(0.5, 1.1) * 10) )
        end

        if BeenDestroyed(builder) then
            return
        end

        local i = 1
		
        for _, vBot in BuildBots do
            if not vBot or BeenDestroyed(vBot) then
                continue
            end
            
            BuildEffectsBag:Add(LOUDATTACHBEAMENTITY(builder, BuildBones[i], vBot, -1, army, '/effects/emitters/build_beam_03_emit.bp'))        
            i = i + 1
        end
    end
end

function CreateCybranFactoryBuildEffects( builder, unitBeingBuilt, BuildBones, BuildEffectsBag )
	
    local BuildEffects = { '/effects/emitters/sparks_03_emit.bp', '/effects/emitters/flashes_01_emit.bp', }
    local UnitBuildEffects = { '/effects/emitters/build_cybran_spark_flash_04_emit.bp', '/effects/emitters/build_sparks_blue_02_emit.bp', }
	
    local army = builder.Sync.army
    
    for _,vB in BuildBones.BuildEffectBones do
        for _, vE in BuildEffects do
            BuildEffectsBag:Add( LOUDATTACHEMITTER(builder,vB,army,vE) )
        end 
    end
    
    BuildEffectsBag:Add( LOUDATTACHEMITTER( builder, BuildBones.BuildAttachBone, army, '/effects/emitters/cybran_factory_build_01_emit.bp' ) )

    -- Add sparks to the collision box of the unit being built
    local sx, sy, sz = 0
	
    while not unitBeingBuilt.Dead and GetFractionComplete(unitBeingBuilt) < 1 do
        sx, sy, sz = unitBeingBuilt:GetRandomOffset(1)
		
        for _, vE in UnitBuildEffects do
            LOUDEMITONENTITY(unitBeingBuilt,army,vE):OffsetEmitter(sx,sy,sz) 
        end         
        WaitTicks((GetRandomFloat( 0.6, 1.0 ) *10 ) )
    end    
end


function CreateAeonConstructionUnitBuildingEffects( builder, unitBeingBuilt, BuildEffectsBag )

    BuildEffectsBag:Add( LOUDEMITONENTITY(builder, builder.Sync.army,'/effects/emitters/aeon_build_01_emit.bp') )

    local beamEnd = Entity()
    BuildEffectsBag:Add(beamEnd)
    LOUDWARP( beamEnd, unitBeingBuilt:GetPosition() )

    for _, v in AeonBuildBeams01 do
		local beamEffect = LOUDATTACHBEAMENTITY(builder, 0, beamEnd, -1, builder.Sync.army, v )
		beamEffect:SetEmitterParam( 'POSITION_Z', 0.45 )
		BuildEffectsBag:Add(beamEffect)
	end
end

function CreateAeonCommanderBuildingEffects( builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag )

    local beamEnd = Entity()
    BuildEffectsBag:Add(beamEnd)
    LOUDWARP( beamEnd, unitBeingBuilt:GetPosition() )

    for _, vBone in BuildEffectBones do
		BuildEffectsBag:Add( LOUDATTACHEMITTER( builder, vBone, builder.Sync.army, '/effects/emitters/aeon_build_02_emit.bp' ) )

    	for _, v in AeonBuildBeams01 do
			local beamEffect = LOUDATTACHBEAMENTITY(builder, vBone, beamEnd, -1, builder.Sync.army, v )
			BuildEffectsBag:Add(beamEffect)
		end
	end
end

-- effects used by Factories building units
function CreateAeonFactoryBuildingEffects( builder, unitBeingBuilt, BuildEffectBones, BuildBone, EffectsBag )

    local bp = GetBlueprint(unitBeingBuilt)
    local army = builder.Sync.army
	local pos = table.copy(builder.CachePosition)
	
	local x = pos[1]
	local y = pos[2]
	local z = pos[3]

    local sx = bp.Physics.MeshExtentsX or bp.SizeX or bp.Footprint.SizeX
    local sz = bp.Physics.MeshExtentsZ or bp.SizeZ or bp.Footprint.SizeZ
    local sy = bp.Physics.MeshExtentsY or bp.SizeY or sx + sz

    -- Create a pool mercury that slowly draws into the build unit
    --local BuildBaseEffect = CreateProjectile( unitBeingBuilt, '/effects/entities/AeonBuildEffect/AeonBuildEffect01_proj.bp', 0, 0, 1, nil, nil, nil )
	
    --BuildBaseEffect:SetScale(sx, 1, sz)
    --LOUDWARP( BuildBaseEffect, Vector( x, y + 0.05 ,z ))
	
	--LOG("*AI DEBUG AeonFactoryBuildingEffects says "..repr( {x,y,z} ).."  unit is at "..repr(unitBeingBuilt:GetPosition()).."  Factory is at "..repr(builder.CachePosition) )
	
    --unitBeingBuilt.Trash:Add(BuildBaseEffect)
    --EffectsBag:Add(BuildBaseEffect)

    --LOUDEMITONENTITY(BuildBaseEffect, builder.Sync.army, '/effects/emitters/aeon_being_built_ambient_02_emit.bp')
    --:SetEmitterCurveParam('X_POSITION_CURVE', 0, sx * 1.5)
    --:SetEmitterCurveParam('Z_POSITION_CURVE', 0, sz * 1.5)
    
    --LOUDEMITONENTITY(BuildBaseEffect, builder.Sync.army, '/effects/emitters/aeon_being_built_ambient_03_emit.bp')
    --:ScaleEmitter( (sx + sz) * 0.3 )    

    for _, vBone in BuildEffectBones do
		
		if EffectsBag then
		
			EffectsBag:Add( LOUDATTACHEMITTER( builder, vBone, army, '/effects/emitters/aeon_build_03_emit.bp' ) )
		
			for _, vBeam in AeonBuildBeams02 do
			
				local beamEffect = LOUDATTACHBEAMENTITY(builder, vBone, builder, BuildBone, army, vBeam )
				
				EffectsBag:Add(beamEffect)
				
			end
			
		end
	end

	-- create a slider that will govern the Y value of the units position
--    local slider = CreateSlider( unitBeingBuilt, 0 )
	
    --unitBeingBuilt.Trash:Add(slider)
    --EffectsBag:Add(slider)    
	
--    slider:SetWorldUnits(true)
	
	-- bury the unit underground
    --slider:SetGoal(0, -sy, 0)
    --slider:SetSpeed(-1)
    --WaitFor(slider)
	
	-- set the slider move up now
	--slider:SetSpeed(1)
	
	-- set the slider goal to bring the unit to the surface
	-- at a rate of .05 units per what ? tick ? second ? this is not very clear
	-- the problem here is that the actual progress of the unit has nothing to do with this
	-- so more expensive units will look 'almost' finished when they aren't even close and
	-- really cheap units will go from almost nothing visible to practically complete in short order
--    if not unitBeingBuilt.Dead then 
  --      slider:SetGoal(0,0,0)
  --      slider:SetSpeed(.05)
--    end

    -- Wait till we are 80% done building
	--repeat
--		slider:SetGoal( 0, -sy + ( sy * GetFractionComplete(unitBeingBuilt)), 0 )
		--LOG("*AI DEBUG Slider Y is now "..repr( -sy + ( sy * GetFractionComplete(unitBeingBuilt))))
		--WaitTicks(5)
	
    --until unitBeingBuilt.Dead or GetFractionComplete(unitBeingBuilt) > 0.8
	
	--BuildBaseEffect:SetScaleVelocity(-0.2, -0.2, -0.2)    

    repeat
		--slider:SetGoal( 0, -sy + ( sy * GetFractionComplete(unitBeingBuilt)), 0 )

		--LOG("*AI DEBUG Slider Y is now "..repr( -sy + ( sy * GetFractionComplete(unitBeingBuilt))))
	    WaitTicks(5)
		
	until unitBeingBuilt.Dead or GetFractionComplete(unitBeingBuilt) == 1
	
    --slider:Destroy()
    --BuildBaseEffect:Destroy()
end


function CreateSeraphimUnitEngineerBuildingEffects( builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag )
	local army = builder.Sync.army

    for _, vBone in BuildEffectBones do
		BuildEffectsBag:Add( LOUDATTACHEMITTER( builder, vBone, army, '/effects/emitters/seraphim_build_01_emit.bp' ) )

    	for _, v in SeraphimBuildBeams01 do
			local beamEffect = LOUDATTACHBEAMENTITY(builder, vBone, unitBeingBuilt, -1, army, v )
			BuildEffectsBag:Add(beamEffect)
		end
	end
end

function CreateSeraphimFactoryBuildingEffects( builder, unitBeingBuilt, BuildEffectBones, BuildBone, EffectsBag )

    local bp = GetBlueprint(unitBeingBuilt)
    local army = builder.Sync.army
	local pos = builder:GetPosition(BuildBone)
	local x = pos[1]
	local y = pos[2]
	local z = pos[3]

    local mul = 1
    local sx = bp.Physics.MeshExtentsX or bp.SizeX or bp.Footprint.SizeX * mul
    local sz = bp.Physics.MeshExtentsZ or bp.SizeZ or bp.Footprint.SizeZ * mul
    local sy = bp.Physics.MeshExtentsY or bp.SizeY or sx + sz

    -- Create a seraphim whispy cloud effect that swirls around the build unit
    local BuildBaseEffect = CreateProjectile( unitBeingBuilt, '/effects/entities/SeraphimBuildEffect01/SeraphimBuildEffect01_proj.bp', nil, 0, 0, nil, nil, nil )
	
    BuildBaseEffect:SetScale(sx, 1, sz)
    BuildBaseEffect:SetOrientation( unitBeingBuilt:GetOrientation(), true)    
    LOUDWARP( BuildBaseEffect, Vector(x,y-0.05,z))
    unitBeingBuilt.Trash:Add(BuildBaseEffect)
    EffectsBag:Add(BuildBaseEffect)

    for _, vBone in BuildEffectBones do
		EffectsBag:Add( LOUDATTACHEMITTER( builder, vBone, army, '/effects/emitters/seraphim_build_01_emit.bp' ) )
		for _, vBeam in SeraphimBuildBeams01 do
			EffectsBag:Add(LOUDATTACHBEAMENTITY(builder, vBone, unitBeingBuilt, -1, army, vBeam ))
			EffectsBag:Add(LOUDATTACHEMITTER( unitBeingBuilt, -1, army, '/effects/emitters/seraphim_being_built_ambient_02_emit.bp'))
			EffectsBag:Add(LOUDATTACHEMITTER( unitBeingBuilt, -1, army, '/effects/emitters/seraphim_being_built_ambient_03_emit.bp'))			
			EffectsBag:Add(LOUDATTACHEMITTER( unitBeingBuilt, -1, army, '/effects/emitters/seraphim_being_built_ambient_04_emit.bp'))						
			EffectsBag:Add(LOUDATTACHEMITTER( unitBeingBuilt, -1, army, '/effects/emitters/seraphim_being_built_ambient_05_emit.bp'))				
		end
	end

    local slider = CreateSlider( unitBeingBuilt, 0 )
	
    unitBeingBuilt.Trash:Add(slider)
	
    EffectsBag:Add(slider)
	
    slider:SetWorldUnits(true)
    slider:SetGoal(0, sy, 0)
    slider:SetSpeed(-1)
	
    WaitFor(slider)
	
    if not slider:BeenDestroyed() then 
        slider:SetGoal(0,0,0)
        slider:SetSpeed(.05)
    end

    -- Wait till we are 80% done building, then snap our slider to
    while not unitBeingBuilt.Dead and GetFractionComplete(unitBeingBuilt) < 0.8 do
        WaitTicks(10)
    end
    
    if not unitBeingBuilt.Dead then
	
        if not BuildBaseEffect:BeenDestroyed() then
	        BuildBaseEffect:SetScaleVelocity(-0.6, -0.6, -0.6)
	    end
		
    	if not slider:BeenDestroyed() then
            slider:SetSpeed(2)
        end            
		
	    WaitTicks(5)
	end
	
	if not slider:BeenDestroyed() then
        slider:Destroy()
    end
    
    if not BuildBaseEffect:BeenDestroyed() then
        BuildBaseEffect:Destroy()
    end
end

function CreateSeraphimBuildBaseThread( unitBeingBuilt, builder, EffectsBag )
    local army = builder.Sync.army
    local bp = GetBlueprint(unitBeingBuilt)
	local pos = unitBeingBuilt:GetPosition()
	local x = pos[1]
	local y = pos[2]
	local z = pos[3]

    local mul = 0.5
    local sx = bp.Physics.MeshExtentsX or bp.SizeX or bp.Footprint.SizeX * mul
    local sz = bp.Physics.MeshExtentsZ or bp.SizeZ or bp.Footprint.SizeZ * mul
    local sy = bp.Physics.MeshExtentsY or bp.SizeY or sx + sz

    WaitTicks(1)

    local BuildBaseEffect = CreateProjectile( unitBeingBuilt, '/effects/entities/SeraphimBuildEffect01/SeraphimBuildEffect01_proj.bp', nil, 0, 0, nil, nil, nil )
	
    BuildBaseEffect:SetScale(sx, 1, sz)
    BuildBaseEffect:SetOrientation( unitBeingBuilt:GetOrientation(), true)    
    LOUDWARP( BuildBaseEffect, Vector(x,y,z))
    unitBeingBuilt.Trash:Add(BuildBaseEffect)
    EffectsBag:Add(BuildBaseEffect)

    local BuildEffectBaseEmitters = {
        '/effects/emitters/seraphim_being_built_ambient_01_emit.bp',
    }

    local BuildEffectsEmitters = {
        '/effects/emitters/seraphim_being_built_ambient_02_emit.bp',
        '/effects/emitters/seraphim_being_built_ambient_03_emit.bp',
        '/effects/emitters/seraphim_being_built_ambient_04_emit.bp', 
        '/effects/emitters/seraphim_being_built_ambient_05_emit.bp',       
    }
    
    local AdjustedEmitters = {}
    local effect = nil
	
    for _, vEffect in BuildEffectsEmitters do
        effect = LOUDATTACHEMITTER( unitBeingBuilt, -1, army, vEffect)
        LOUDINSERT( AdjustedEmitters, effect )
        EffectsBag:Add(effect)
    end

    for _, vEffect in BuildEffectBaseEmitters do
        effect = LOUDATTACHEMITTER( BuildBaseEffect, -1, army, vEffect)
        LOUDINSERT( AdjustedEmitters, effect )
        EffectsBag:Add(effect)
    end

    -- Poll the unit being built every second to adjust the effects to match
    local fractionComplete = GetFractionComplete(unitBeingBuilt)
    local unitScaleMetric = unitBeingBuilt:GetFootPrintSize() * 0.65
	
    while not unitBeingBuilt.Dead and fractionComplete < 1.0 do
        WaitTicks(10)
        fractionComplete = GetFractionComplete(unitBeingBuilt)
		
        for _, vEffect in AdjustedEmitters do
            vEffect:ScaleEmitter( 1 + (unitScaleMetric * fractionComplete))	    
        end        
    end
	
    local unitsArmy = unitBeingBuilt.Sync.army
	local footprintsize = unitBeingBuilt:GetFootPrintSize()
    local focusArmy = GetFocusArmy()

    if focusArmy == -1 or IsAlly(unitsArmy,focusArmy) then
        CreateLightParticle( unitBeingBuilt, -1, unitsArmy, footprintsize * 7, 8, 'glow_02', 'ramp_blue_22' ) 
		
    elseif IsEnemy(unitsArmy,focusArmy) then
        local blip = unitBeingBuilt:GetBlip(focusArmy)
		
        if blip ~= nil and blip:IsSeenNow(focusArmy) then
            CreateLightParticle( unitBeingBuilt, -1, unitsArmy, footprintsize * 7, 8, 'glow_02', 'ramp_blue_22' ) 
        end
    end

    unitBeingBuilt:CreateTarmac(true, true, true, false, false)
    WaitTicks(5)
    BuildBaseEffect:Destroy()
end

function CreateSeraphimExperimentalBuildBaseThread( unitBeingBuilt, builder, EffectsBag )
    local bp = GetBlueprint(unitBeingBuilt)
	local pos = unitBeingBuilt:GetPosition()
	local x = pos[1]
	local y = pos[2]
	local z = pos[3]

    local mul = 0.5
    local sx = bp.Physics.MeshExtentsX or bp.Footprint.SizeX * mul
    local sz = bp.Physics.MeshExtentsZ or bp.Footprint.SizeZ * mul
    local sy = bp.Physics.MeshExtentsY or sx + sz

    WaitTicks(1)

    local BuildBaseEffect = CreateProjectile( unitBeingBuilt, '/effects/entities/SeraphimBuildEffect01/SeraphimBuildEffect01_proj.bp', nil, 0, 0, nil, nil, nil )
	
    BuildBaseEffect:SetScale(sx, 1, sz)
    BuildBaseEffect:SetOrientation( unitBeingBuilt:GetOrientation(), true)    
    LOUDWARP( BuildBaseEffect, Vector(x,y,z))
    unitBeingBuilt.Trash:Add(BuildBaseEffect)
    EffectsBag:Add(BuildBaseEffect)

    local BuildEffectBaseEmitters = {
        '/effects/emitters/seraphim_being_built_ambient_01_emit.bp',
    }

    local BuildEffectsEmitters = {
        '/effects/emitters/seraphim_being_built_ambient_02_emit.bp',
        '/effects/emitters/seraphim_being_built_ambient_03_emit.bp',
        '/effects/emitters/seraphim_being_built_ambient_04_emit.bp', 
        '/effects/emitters/seraphim_being_built_ambient_05_emit.bp',       
    }
    
    local AdjustedEmitters = {}
	local counter = 0
	
    local effect = nil
	
    for _, vEffect in BuildEffectsEmitters do
        effect = LOUDATTACHEMITTER( unitBeingBuilt, -1, builder.Sync.army, vEffect ):ScaleEmitter(2)
        AdjustedEmitters[counter+1] = effect
		counter = counter + 1
        EffectsBag:Add(effect)
    end

    -- for k, vEffect in BuildEffectBaseEmitters do
        -- effect = LOUDATTACHEMITTER( BuildBaseEffect, -1, builder.Sync.army, vEffect ):ScaleEmitter(2)
        -- LOUDINSERT( AdjustedEmitters, effect )
        -- EffectsBag:Add(effect)
    -- end


    #-- Poll the unit being built every second to adjust the effects to match
    local fractionComplete = GetFractionComplete(unitBeingBuilt)
    local unitScaleMetric = unitBeingBuilt:GetFootPrintSize() * 0.65
	
    while not unitBeingBuilt.Dead and fractionComplete < 1.0 do
	
        WaitTicks(10)
        fractionComplete = GetFractionComplete(unitBeingBuilt)
		
        for _, vEffect in AdjustedEmitters do
            vEffect:ScaleEmitter( 2 + (unitScaleMetric * fractionComplete) )	    
        end        
    end

    local unitsArmy = unitBeingBuilt.Sync.army
	local footprintsize = unitBeingBuilt:GetFootPrintSize()
    local focusArmy = GetFocusArmy()
	
    if focusArmy == -1 or IsAlly(unitsArmy,focusArmy) then
        CreateLightParticle( unitBeingBuilt, -1, unitsArmy, footprintsize  * 4, 6, 'glow_02', 'ramp_blue_22' ) 
		
    elseif IsEnemy(unitsArmy,focusArmy) then
        local blip = unitBeingBuilt:GetBlip(focusArmy)
        if blip ~= nil and blip:IsSeenNow(focusArmy) then
            CreateLightParticle( unitBeingBuilt, -1, unitsArmy, footprintsize * 4, 6, 'glow_02', 'ramp_blue_22' ) 
        end
    end

    WaitTicks(5)
    BuildBaseEffect:Destroy()
end

-- I modded this to reduce the number of entities created by the adjacency beams
-- only Sera effect remains untouched
-- At this time, I am considering just how pointless most of this is and that it's really just **BLING**
-- this detail is SO small that I'm considering replacing it with a simple beam between the two entities for ALL factions
-- and getting rid of all this complex calculation for position and intermediate nodes
function CreateAdjacencyBeams( unit, adjacentUnit )

	--local LOUDGETN = table.getn
	local LOUDINSERT = table.insert
	--local LOUDWARP = Warp
	local LOUDATTACHEMITTER = CreateAttachedEmitter

	local info = { Unit = adjacentUnit:GetEntityId(), Trash = TrashBag(), }
    
    --local uBp =  __blueprints[unit.BlueprintID]
    --local aBp =  __blueprints[adjacentUnit.BlueprintID]
    local army = unit.Sync.army
    local faction = __blueprints[unit.BlueprintID].General.FactionName

    -- Determine which effects we will be using	-- default to Cybran
    --local nodeMesh = '/effects/entities/cybranadjacencynode/cybranadjacencynode_mesh'
    local beamEffect = '/effects/emitters/adjacency_cybran_beam_01_emit.bp'
	
    --local emitterNodeEffects = {}  
    --local numNodes = 0
    --local nodeList = {}
    --local validAdjacency = true

	-- Create hub start/end and all midpoint nodes -- NOTE: since adjacency can only
	-- happen between structures I make direct use of the CachePosition value and save
	-- calling the GetPosition function -- I use a table.copy since we dont want the
	-- code to start playing with the CachePosition directly -- which is was doing 
	-- until I put this in place
    --local unitHub = { entity = Entity{}, pos = table.copy(unit.CachePosition) }
	--local adjacentHub = { entity = Entity{}, pos = table.copy(adjacentUnit.CachePosition) }
	
    --local unitHub = { entity = unit, pos = table.copy(unit.CachePosition) }
	--local adjacentHub = { entity = adjacentUnit, pos = table.copy(adjacentUnit.CachePosition) }

    --local spec = { Owner = unit }
   
    if faction == 'Aeon' then
        --nodeMesh = '/effects/entities/aeonadjacencynode/aeonadjacencynode_mesh'
        beamEffect = '/effects/emitters/adjacency_aeon_beam_01_emit.bp'
		
    elseif faction == 'UEF' then
        --nodeMesh = '/effects/entities/uefadjacencynode/uefadjacencynode_mesh'
        beamEffect = '/effects/emitters/adjacency_uef_beam_01_emit.bp'	
		
    --elseif faction == 'Seraphim' then
        --nodeMesh = '/effects/entities/seraphimadjacencynode/seraphimadjacencynode_mesh'
--[[		
        LOUDINSERT( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient01 )
		
        if  VDist2( unitHub.pos[1],unitHub.pos[3], adjacentHub.pos[1], adjacentHub.pos[3] ) < 2.5 then
            numNodes = 1
        else
            numNodes = 3
            LOUDINSERT( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient02 )
            LOUDINSERT( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient03 )
        end
--]]
    end    
--[[
	if numNodes > 0 then
		for i = 1, numNodes do
			local node = { entity = Entity(spec), pos = {0,0,0}, mesh = nil,}
			node.entity:SetVizToNeutrals('Intel')
			node.entity:SetVizToEnemies('Intel')
			LOUDINSERT( nodeList, node )
		end
	end
--]]
	--local verticalOffset = 0.05
--[[
	-- Move Unit Pos towards adjacent unit by bounding box size
	local uBpSizeX = uBp.SizeX * 0.5
	local uBpSizeZ = uBp.SizeZ * 0.5
	local aBpSizeX = aBp.SizeX * 0.5
	local aBpSizeZ = aBp.SizeZ * 0.5

	-- To Determine positioning, need to use the bounding box or skirt size
	local uBpSkirtX = uBp.Physics.SkirtSizeX * 0.5
	local uBpSkirtZ = uBp.Physics.SkirtSizeZ * 0.5
	local aBpSkirtX = aBp.Physics.SkirtSizeX * 0.5
	local aBpSkirtZ = aBp.Physics.SkirtSizeZ * 0.5	

	-- Get edge corner positions, { TOP, LEFT, BOTTOM, RIGHT }
	local unitSkirtBounds = {
		unitHub.pos[3] - uBpSkirtZ,
		unitHub.pos[1] - uBpSkirtX,
		unitHub.pos[3] + uBpSkirtZ,
		unitHub.pos[1] + uBpSkirtX,
	}
	
	local adjacentSkirtBounds = {
		adjacentHub.pos[3] - aBpSkirtZ,
		adjacentHub.pos[1] - aBpSkirtX,
		adjacentHub.pos[3] + aBpSkirtZ,
		adjacentHub.pos[1] + aBpSkirtX,
	}

	-- Figure out the best matching ogrid position on units bounding box
	-- depending on it's skirt size

	-- Unit bottom or top skirt is aligned to adjacent unit
	if (unitSkirtBounds[3] == adjacentSkirtBounds[1]) or (unitSkirtBounds[1] == adjacentSkirtBounds[3]) then
	
		local sharedSkirtLower = unitSkirtBounds[4] - (unitSkirtBounds[4] - adjacentSkirtBounds[2])
		local sharedSkirtUpper = unitSkirtBounds[4] - (unitSkirtBounds[4] - adjacentSkirtBounds[4])
		local sharedSkirtLen = sharedSkirtUpper - sharedSkirtLower
    	
		-- Depending on shared skirt bounds, determine the position of unit hub
		-- Find out how many times the shared skirt fits into the unit hub shared skirt
		local numAdjSkirtsOnUnitSkirt = (uBpSkirtX * 2) / sharedSkirtLen
		local numUnitSkirtsOnAdjSkirt = (aBpSkirtX * 2) / sharedSkirtLen
 		
 		-- Z-offset, offset adjacency hub positions the proper direction
		if unitSkirtBounds[3] == adjacentSkirtBounds[1] then
			unitHub.pos[3] = unitHub.pos[3] + uBpSizeZ														 
			adjacentHub.pos[3] = adjacentHub.pos[3] - aBpSizeZ
		else
			unitHub.pos[3] = unitHub.pos[3] - uBpSizeZ
			adjacentHub.pos[3] = adjacentHub.pos[3] + aBpSizeZ			
		end    
		
		-- X-offset, Find the shared adjacent x position range			
		-- If we have more than skirt on this section, then we need to adjust the x position of the unit hub 
		if numAdjSkirtsOnUnitSkirt > 1 or numUnitSkirtsOnAdjSkirt < 1 then
			local uSkirtLen = (unitSkirtBounds[4] - unitSkirtBounds[2]) * 0.5           # Unit skirt length			
			local uGridUnitSize = (uBpSizeX * 2) / uSkirtLen                            # Determine one grid of adjacency along that length
			local xoffset = LOUDABS(unitSkirtBounds[2] - adjacentSkirtBounds[2]) * 0.5 # Get offset of the unit along the skirt
			unitHub.pos[1] = (unitHub.pos[1] - uBpSizeX) + (xoffset * uGridUnitSize) + (uGridUnitSize * 0.5) # Now offset the position of adjacent point
		end
		
		-- If we have more than skirt on this section, then we need to adjust the x position of the adjacent hub 
		if numUnitSkirtsOnAdjSkirt > 1  or numAdjSkirtsOnUnitSkirt < 1 then
			local aSkirtLen = (adjacentSkirtBounds[4] - adjacentSkirtBounds[2]) * 0.5   # Adjacent unit skirt length			
			local aGridUnitSize = (aBpSizeX * 2) / aSkirtLen                            # Determine one grid of adjacency along that length ??
			local xoffset = LOUDABS(adjacentSkirtBounds[2] - unitSkirtBounds[2]) * 0.5	# Get offset of the unit along the adjacent unit
			adjacentHub.pos[1] = (adjacentHub.pos[1] - aBpSizeX) + (xoffset * aGridUnitSize) + (aGridUnitSize * 0.5) # Now offset the position of adjacent point
        end			

	-- Unit right or top left is aligned to adjacent unit
	elseif (unitSkirtBounds[4] == adjacentSkirtBounds[2]) or (unitSkirtBounds[2] == adjacentSkirtBounds[4]) then
	
		local sharedSkirtLower = unitSkirtBounds[3] - (unitSkirtBounds[3] - adjacentSkirtBounds[1])
		local sharedSkirtUpper = unitSkirtBounds[3] - (unitSkirtBounds[3] - adjacentSkirtBounds[3])
		local sharedSkirtLen = sharedSkirtUpper - sharedSkirtLower
   	
		-- Depending on shared skirt bounds, determine the position of unit hub
		-- Find out how many times the shared skirt fits into the unit hub shared skirt
		local numAdjSkirtsOnUnitSkirt = (uBpSkirtX * 2) / sharedSkirtLen
		local numUnitSkirtsOnAdjSkirt = (aBpSkirtX * 2) / sharedSkirtLen

		-- X-offset
		if (unitSkirtBounds[4] == adjacentSkirtBounds[2]) then
			unitHub.pos[1] = unitHub.pos[1] + uBpSizeX
			adjacentHub.pos[1] = adjacentHub.pos[1] - aBpSizeX
		else
			unitHub.pos[1] = unitHub.pos[1] - uBpSizeX
			adjacentHub.pos[1] = adjacentHub.pos[1] + aBpSizeX
		end
		
		-- Z-offset, Find the shared adjacent x position range			
		-- If we have more than skirt on this section, then we need to adjust the x position of the unit hub 
		if numAdjSkirtsOnUnitSkirt > 1 or numUnitSkirtsOnAdjSkirt < 1 then
			local uSkirtLen = (unitSkirtBounds[3] - unitSkirtBounds[1]) * 0.5           # Unit skirt length			
			local uGridUnitSize = (uBpSizeZ * 2) / uSkirtLen                            # Determine one grid of adjacency along that length
			local zoffset = LOUDABS(unitSkirtBounds[1] - adjacentSkirtBounds[1]) * 0.5 # Get offset of the unit along the skirt
			unitHub.pos[3] = (unitHub.pos[3] - uBpSizeZ) + (zoffset * uGridUnitSize) + (uGridUnitSize * 0.5) # Now offset the position of adjacent point
		end
		
		-- If we have more than skirt on this section, then we need to adjust the x position of the adjacent hub 
		if numUnitSkirtsOnAdjSkirt > 1 or numAdjSkirtsOnUnitSkirt < 1 then
			local aSkirtLen = (adjacentSkirtBounds[3] - adjacentSkirtBounds[1]) * 0.5   # Adjacent unit skirt length			
			local aGridUnitSize = (aBpSizeZ * 2) / aSkirtLen                            # Determine one grid of adjacency along that length ??
			local zoffset = LOUDABS(adjacentSkirtBounds[1] - unitSkirtBounds[1]) * 0.5	# Get offset of the unit along the adjacent unit
			adjacentHub.pos[3] = (adjacentHub.pos[3] - aBpSizeZ) + (zoffset * aGridUnitSize) + (aGridUnitSize * 0.5) # Now offset the position of adjacent point
        end				
    end
--]]

	-- Setup our midpoint positions
--[[
	if  faction == 'Seraphim' then 
		local DirectionVec = util.GetDifferenceVector( unitHub.pos, adjacentHub.pos )
		local Dist = VDist3( unitHub.pos, adjacentHub.pos )
		local PerpVec = Cross( DirectionVec, Vector(0,0.35,0) )
		local segmentLen = 1 / (numNodes + 1)
		local halfDist = Dist * 0.5

		if GetRandomInt(0,1) == 1 then
			PerpVec[1] = -PerpVec[1]
			PerpVec[2] = -PerpVec[2]
			PerpVec[3] = -PerpVec[3]
		end

		local offsetMul = 0.15

		for i = 1, numNodes do
			local segmentMul = i * segmentLen

			if segmentMul <= 0.5 then
				offsetMul = offsetMul + 0.12
			else
				offsetMul = offsetMul - 0.12
			end

			nodeList[i].pos = {
				unitHub.pos[1] - (DirectionVec[1] * segmentMul) - (PerpVec[1] * offsetMul),
				nil,
				unitHub.pos[3] - (DirectionVec[3] * segmentMul) - (PerpVec[3] * offsetMul),
			}
		end
    end
--]]	


    --if validAdjacency then
--[[
        -- Offset beam positions above the ground at current positions terrain height
        for _, v in nodeList do
            v.pos[2] = GetTerrainHeight(v.pos[1], v.pos[3]) + verticalOffset
        end

        unitHub.pos[2] = GetTerrainHeight(unitHub.pos[1], unitHub.pos[3]) + verticalOffset
        adjacentHub.pos[2] = GetTerrainHeight(adjacentHub.pos[1], adjacentHub.pos[3]) + verticalOffset
        
		if numNodes > 0 then
			-- Set the mesh of the entity and attach any node effects
			for i = 1, numNodes do
				nodeList[i].entity:SetMesh(nodeMesh, false)
				nodeList[i].mesh = true
			
				if emitterNodeEffects[i] != nil and LOUDGETN(emitterNodeEffects[i]) != 0 then

					for _, vEmit in emitterNodeEffects[i] do
						emit = LOUDATTACHEMITTER( nodeList[i].entity, 0, army, vEmit )
						info.Trash:Add(emit)
						--unit.Trash:Add(emit)
					end
				end
			end
		end
--]]
        -- Insert start and end points into our list
        --LOUDINSERT(nodeList, 1, unitHub )
        --LOUDINSERT(nodeList, adjacentHub )
--[[
        -- WARP everything to its final position
		-- the +2 accounts for the start and end nodes
        for i = 1, numNodes + 2 do
            LOUDWARP( nodeList[i].entity, nodeList[i].pos )
            info.Trash:Add(nodeList[i].entity)
            --unit.Trash:Add(nodeList[i].entity)
        end
--]]
        -- Attach beams to the adjacent unit
        --for i = 1, numNodes + 1 do
--[[		
            if nodeList[i].mesh != nil then
                local vec = util.GetDirectionVector(Vector(nodeList[i].pos[1], nodeList[i].pos[2], nodeList[i].pos[3]), Vector(nodeList[i+1].pos[1], nodeList[i+1].pos[2], nodeList[i+1].pos[3]))
                nodeList[i].entity:SetOrientation( OrientFromDir( vec ),true)
            end
--]]			
            if beamEffect then
                local beam = LOUDATTACHBEAMENTITY( unit, -1, adjacentUnit, -1, army, beamEffect )
                info.Trash:Add(beam)
                unit.Trash:Add(beam)
            end
        --end
		
		LOUDINSERT( unit.AdjacencyBeamsBag, info)
    --end
	

end


function PlaySacrificingEffects( unit, target_unit )
	--local army = unit.Sync.army
	local bp = GetBlueprint(unit)
	local faction = bp.General.FactionName

	if faction == 'Aeon' then
		for _, v in EffectTemplate.ASacrificeOfTheAeon01 do
			unit.Trash:Add( LOUDEMITONENTITY( unit, unit.Sync.army, v) )
		end
	end
end

function PlaySacrificeEffects( unit, target_unit )
	local army = unit.Sync.army
	local bp = GetBlueprint(unit)
	local faction = bp.General.FactionName

	if faction == 'Aeon' then
		for _, v in EffectTemplate.ASacrificeOfTheAeon02 do
			LOUDEMITATENTITY( target_unit, army, v)
		end
	end
end


function PlayReclaimEffects( reclaimer, reclaimed, BuildEffectBones, EffectsBag )

    local pos = reclaimed:GetPosition()
	
    --pos[2] = GetSurfaceHeight(pos[1], pos[3])

    local beamEnd = Entity()
    EffectsBag:Add(beamEnd)
    LOUDWARP( beamEnd, pos )

    for _, vBone in BuildEffectBones do
		for _, vEmit in ReclaimBeams do
			local beamEffect = LOUDATTACHBEAMENTITY(reclaimer, vBone, beamEnd, -1, reclaimer.Sync.army, vEmit )
			EffectsBag:Add(beamEffect)
		end
	end
	
	for _, v in ReclaimObjectAOE do
	    EffectsBag:Add( LOUDEMITONENTITY( reclaimed, reclaimer.Sync.army, v ) )
	end
end

function PlayReclaimEndEffects( reclaimer, reclaimed )

    local army = -1
	
    if reclaimer then
        army = reclaimer.Sync.army
    end
	for _, v in ReclaimObjectEnd do
	    LOUDEMITATENTITY( reclaimed, army, v )
	end
	
	CreateLightParticleIntel( reclaimed, -1, army, 4, 6, 'glow_02', 'ramp_flare_02' )
end


function PlayCaptureEffects( capturer, captive, BuildEffectBones, EffectsBag )
	local army = capturer.Sync.army

    for _, vBone in BuildEffectBones do
		for _, vEmit in EffectTemplate.CaptureBeams do
			EffectsBag:Add(LOUDATTACHBEAMENTITY(capturer, vBone, captive, -1, army, vEmit ))
		end
	end
end


function CreateCybranQuantumGateEffect( unit, bone1, bone2, TrashBag, startwaitSeed )
    -- Adding a quick wait here so that unit bone positions are correct
    WaitTicks( startwaitSeed * 10 )
    
    local BeamEmtBp = '/effects/emitters/cybran_gate_beam_01_emit.bp'
    local pos1 = unit:GetPosition(bone1)
    local pos2 = unit:GetPosition(bone2)
    pos1[2] = pos1[2] - 0.72
    pos2[2] = pos2[2] - 0.72

    -- Create a projectile for the end of build effect and LOUDWARP it to the unit
    local BeamStartEntity = unit:CreateProjectile('/effects/entities/UEFBuild/UEFBuild01_proj.bp',0,0,0,nil,nil,nil)
    TrashBag:Add( BeamStartEntity )
    LOUDWARP( BeamStartEntity, pos1)
    
    local BeamEndEntity = unit:CreateProjectile('/effects/entities/UEFBuild/UEFBuild01_proj.bp',0,0,0,nil,nil,nil)
    TrashBag:Add( BeamEndEntity )
    LOUDWARP( BeamEndEntity, pos2)    

    -- Create beam effect
    TrashBag:Add(LOUDATTACHBEAMENTITY(BeamStartEntity, -1, BeamEndEntity, -1, unit.Sync.army, BeamEmtBp ))

    -- Determine a the velocity of our projectile, used for the scaning effect
    local velY = 1
    BeamEndEntity:SetVelocity( 0, velY, 0 )

    local flipDirection = true

    -- LOUDWARP our projectile back to the initial corner and lower based on build completeness
    while not unit:BeenDestroyed() do

        if flipDirection then
            BeamStartEntity:SetVelocity( 0, velY, 0 )
            BeamEndEntity:SetVelocity( 0, velY, 0 )
            flipDirection = false
        else
            BeamStartEntity:SetVelocity( 0, -velY, 0 )
            BeamEndEntity:SetVelocity( 0, -velY, 0 )
            flipDirection = true
        end
        WaitTicks( 40 )
    end
end

function CreateEnhancementEffectAtBone( unit, bone, TrashBag )

    for _, vEffect in EffectTemplate.UpgradeBoneAmbient do
	
        TrashBag:Add(LOUDATTACHEMITTER( unit, bone, unit.Sync.army, vEffect ))
		
    end
	
end

function CreateEnhancementUnitAmbient( unit, bone, TrashBag )

    for _, vEffect in EffectTemplate.UpgradeUnitAmbient do
	
        TrashBag:Add(LOUDATTACHEMITTER( unit, bone, unit.Sync.army, vEffect ))
		
    end
	
end

function CleanupEffectBag( self, EffectBag )

	if self[EffectBag] then
	
		for _, v in self[EffectBag] do

			v:Destroy()
		end
		
	end
	
    self[EffectBag] = {}
	
end

function SeraphimRiftIn( unit )

	unit:HideBone(0, true)
	
	for _, v in EffectTemplate.SerRiftIn_Small do
		LOUDATTACHEMITTER ( unit, -1, unit.Sync.army, v )
	end
	
	WaitTicks (20)	
	CreateLightParticle( unit, -1, unit.Sync.army, 4, 15, 'glow_05', 'ramp_jammer_01' )	
	WaitTicks(1)	
	unit:ShowBone(0, true)	
	WaitTicks(2)
	
	for _, v in EffectTemplate.SerRiftIn_SmallFlash do
		LOUDATTACHEMITTER ( unit, -1, unit.Sync.army, v )
	end	
end

function SeraphimRiftInLarge( unit )

	unit:HideBone(0, true)
	
	for _, v in EffectTemplate.SerRiftIn_Large do
		LOUDATTACHEMITTER ( unit, -1, unit.Sync.army, v )
	end
	
	WaitTicks(20)	
	CreateLightParticle( unit, -1, unit.Sync.army, 25, 15, 'glow_05', 'ramp_jammer_01' )	
	WaitTicks(1)	
	unit:ShowBone(0, true)	
	WaitTicks(2)
	
	for _, v in EffectTemplate.SerRiftIn_LargeFlash do
		LOUDATTACHEMITTER ( unit, -1, unit.Sync.army, v )
	end	
end

function CybranBuildingInfection( unit )
	for k, v in EffectTemplate.CCivilianBuildingInfectionAmbient do
		LOUDATTACHEMITTER ( unit, -1, unit.Sync.army, v )
	end	
end

function CybranQaiShutdown( unit )
	for k, v in EffectTemplate.CQaiShutdown do
		LOUDATTACHEMITTER ( unit, -1, unit.Sync.army, v )
	end	
end

function AeonHackACU( unit )
	for k, v in EffectTemplate.AeonOpHackACU do
		LOUDATTACHEMITTER ( unit, -1, unit.Sync.army, v )
	end		
end

function PlayTeleportChargeEffects(self)

    local army = self.Sync.army
    local bp = GetBlueprint(self)

    self.TeleportChargeBag = {}

    for k, v in EffectTemplate.GenericTeleportCharge01 do
        local fx = LOUDEMITATENTITY( self, army, v ):OffsetEmitter(0, ( bp.Physics.MeshExtentsY or 1 ) * 0.5, 0)
        self.Trash:Add(fx)
        LOUDINSERT( self.TeleportChargeBag, fx)
    end

	-- from BO:U
    if not self.Dead and not self.EXPhaseEnabled == true then
		--EXTeleportChargeEffects(self)
    end		
end

function PlayTeleportInEffects(self)

    local army = self.Sync.army
    local bp = GetBlueprint(self)

    for k, v in EffectTemplate.GenericTeleportIn01 do
        LOUDEMITATENTITY( self, army, v ):OffsetEmitter(0, ( bp.Physics.MeshExtentsY or 1 ) * 0.5, 0)
    end

    if not self.Dead and not self.EXPhaseEnabled == false then   
		EXTeleportCooldownEffects(self)
    end
end

function PlayTeleportOutEffects(self)

    local army = self.Sync.army
	
    for k, v in EffectTemplate.GenericTeleportOut01 do
        LOUDEMITATENTITY(self,army,v)
    end
end	

function CleanupTeleportChargeEffects(self)

    if self.TeleportChargeBag then
        for keys,values in self.TeleportChargeBag do
            values:Destroy()
        end
        self.TeleportChargeBag = {}
    end
end

function EXTeleportChargeEffects(self)

    if not self.Dead then

		local bpe = self:GetBlueprint().Economy

		self.EXPhaseEnabled = true
		self.EXPhaseCharge = 1
		self.EXPhaseShieldPercentage = 0

		if bpe then
			local mass = bpe.BuildCostMass * math.min(.1, bpe.TeleportMassMod or 0.01)
			local energy = bpe.BuildCostEnergy * math.min(.01, bpe.TeleportEnergyMod or 0.001)

			energyCost = mass + energy
			EXTeleTime = energyCost * (bpe.TeleportTimeMod or 0.0001)
			
			self.EXTeleTimeMod1 = (EXTeleTime * 10) * 0.2
			self.EXTeleTimeMod2 = self.EXTeleTimeMod1 * 2
			self.EXTeleTimeMod3 = (EXTeleTime * 10) - ((self.EXTeleTimeMod1 * 2) + self.EXTeleTimeMod2)
			self.EXTeleTimeMod4 = (self.EXTeleTimeMod3) - 7

			local bp = self:GetBlueprint()
			local bpDisplay = bp.Display

			if self.EXPhaseCharge == 1 then
				WaitTicks(self.EXTeleTimeMod1)
			end

			if self.EXPhaseCharge == 1 then
				self:SetMesh(bpDisplay.Phase1MeshBlueprint, true)
				self.EXPhaseShieldPercentage = 33
				WaitTicks(self.EXTeleTimeMod2)
			end

			if self.EXPhaseCharge == 1 then
				self.EXPhaseShieldPercentage = 66
				WaitTicks(self.EXTeleTimeMod1)
			end

			if self.EXPhaseCharge == 1 then
				self.EXPhaseShieldPercentage = 100
				if self.EXTeleTimeMod3 >= 7 then
					WaitTicks(self.EXTeleTimeMod4)
				end
			end
			
			if self.EXPhaseCharge == 1 then
				self:SetMesh(bpDisplay.Phase2MeshBlueprint, true)
			end
		end
    end
end

function EXTeleportCooldownEffects(self)

    if not self.Dead then

        local bp = self:GetBlueprint()
		local bpDisplay = bp.Display

		self.EXPhaseCharge = 0

		if self.EXPhaseCharge == 0 then
			self.EXPhaseShieldPercentage = 100
			WaitTicks(5)
		end

		if self.EXPhaseCharge == 0 then
			self.EXPhaseShieldPercentage = 100
			self:SetMesh(bpDisplay.Phase1MeshBlueprint, true)
			WaitTicks(8)
		end
		
		if self.EXPhaseCharge == 0 then
			self.EXPhaseShieldPercentage = 75
			self:SetMesh(bpDisplay.Phase1MeshBlueprint, true)
			WaitTicks(25)
		end

		if self.EXPhaseCharge == 0 then
			self.EXPhaseShieldPercentage = 50
			self:SetMesh(bpDisplay.MeshBlueprint, true)
			WaitTicks(10)
			self.EXPhaseShieldPercentage = 0
			self.EXPhaseEnabled = false
		end
    end
end

function CreateUnitDestructionDebris( self, high, low, chassis )
--[[
    local HighDestructionParts = LOUDGETN(self.DestructionPartsHighToss)
    local LowDestructionParts = LOUDGETN(self.DestructionPartsLowToss)
    local ChassisDestructionParts = LOUDGETN(self.DestructionPartsChassisToss)

	local ShowBone = moho.unit_methods.ShowBone
	local CreateProjectileAtBone = moho.entity_methods.CreateProjectileAtBone
	local AttachBoneToEntityBone = moho.entity_methods.AttachBoneToEntityBone

    -- Create projectiles and accelerate them out and away from the unit
    if high and (HighDestructionParts > 0) then
        for i = 1, Random( 1, HighDestructionParts) do
            ShowBone( self, self.DestructionPartsHighToss[i], false )
            boneProj = CreateProjectileAtBone( self, '/effects/entities/DebrisBoneAttachHigh01/DebrisBoneAttachHigh01_proj.bp', self.DestructionPartsHighToss[i] )
            AttachBoneToEntityBone( self, self.DestructionPartsHighToss[i],boneProj, -1, false )
        end
    end

    if low and (LowDestructionParts > 0) then
        for i = 1, Random( 1, LowDestructionParts) do
            ShowBone( self, self.DestructionPartsLowToss[i], false )
            boneProj = CreateProjectileAtBone( self, '/effects/entities/DebrisBoneAttachLow01/DebrisBoneAttachLow01_proj.bp', self.DestructionPartsLowToss[i] )
            AttachBoneToEntityBone( self, self.DestructionPartsLowToss[i],boneProj, -1, false )
        end
    end
	
    if chassis and (ChassisDestructionParts > 0) then
        for i = 1, Random( 1, ChassisDestructionParts) do
            ShowBone( self, self.DestructionPartsChassisToss[i], false )
            boneProj = CreateProjectileAtBone( self, '/effects/entities/DebrisBoneAttachChassis01/DebrisBoneAttachChassis01_proj.bp', self.DestructionPartsChassisToss[i] )
            AttachBoneToEntityBone( self, self.DestructionPartsChassisToss[i],boneProj, -1, false )
        end
    end
--]]
end	