local util = import('/lua/utilities.lua')
local Entity = import('/lua/sim/Entity.lua').Entity
local EffectTemplate = import('/lua/EffectTemplates.lua')

function CreateUEFDualBuildBeams( builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag )
    local army = builder:GetArmy()
    local BeamBuildEmtBp = '/effects/emitters/build_beam_01_emit.bp'
    local BeamBuildEmtBpTwo = '/effects/emitters/build_beam_01_emit.bp'
    local buildbp = unitBeingBuilt:GetBlueprint()
    local x, y, z = unpack(unitBeingBuilt:GetPosition())
    SecondaryBuildEffectBones = builder:GetBlueprint().General.BuildBones.SecondaryBuildEffectBones
    local BeamEndEntityX = Entity()
    local army = builder:GetArmy()
    
       
    BuildEffectsBag:Add( BeamEndEntityX )
    Warp( BeamEndEntityX, Vector(x, y, z))   
    local BuildBeams = {}
    y = y + (buildbp.Physics.MeshExtentsOffsetY or 0)    

    # Create a projectile for the end of build effect and warp it to the unit
    local BeamEndEntity = unitBeingBuilt:CreateProjectile('/effects/entities/UEFBuild/UEFBuild01_proj.bp',0,0,0,nil,nil,nil)
    local BeamEndEntity2 = unitBeingBuilt:CreateProjectile('/effects/entities/UEFBuild/UEFBuild01_proj.bp',0,0,0,nil,nil,nil)
    BuildEffectsBag:Add( BeamEndEntity )
    BuildEffectsBag:Add( BeamEndEntity2 )

    # Create build beams
    if BuildEffectBones != nil then
        local beamEffect = nil
        for i, BuildBone in BuildEffectBones do
            BuildEffectsBag:Add( AttachBeamEntityToEntity( builder, BuildBone, BeamEndEntity, -1, army, BeamBuildEmtBp ) )
            BuildEffectsBag:Add( AttachBeamEntityToEntity( builder, BuildBone, BeamEndEntity2, -1, army, BeamBuildEmtBp ) )
            BuildEffectsBag:Add( CreateAttachedEmitter( builder, BuildBone, army, '/effects/emitters/flashing_blue_glow_01_emit.bp' ) )                                    
        end
    end

    if SecondaryBuildEffectBones != nil then
        LOG('SecondaryBuildEffect')
        local beamEffect = nil
        for i, BuildBone in SecondaryBuildEffectBones do
            local beamEffect = AttachBeamEntityToEntity(builder, BuildBone, BeamEndEntityX, -1, army, BeamBuildEmtBpTwo )
            table.insert( BuildBeams, beamEffect )
            BuildEffectsBag:Add(beamEffect)     
			BuildEffectsBag:Add( CreateAttachedEmitter( builder, BuildBone, army, '/effects/emitters/flashing_blue_glow_01_emit.bp' ) )                                    			
        end
    end

    # Determine beam positioning on build cube, this should match sizes of CreateBuildCubeThread
    local mul = 1.15
    local ox = buildbp.Physics.MeshExtentsX or (buildbp.Footprint.SizeX * mul)
    local oz = buildbp.Physics.MeshExtentsZ or (buildbp.Footprint.SizeZ * mul)
    local oy = (buildbp.Physics.MeshExtentsY or (0.5 + (ox + oz) * 0.1))

    ox = ox * 0.5
    oz = oz * 0.5

    # Determine the the 2 closest edges of the build cube and use those for the location of our laser
    local VectorExtentsList = { Vector(x + ox, y + oy, z + oz), Vector(x + ox, y + oy, z - oz), Vector(x - ox, y + oy, z + oz), Vector(x - ox, y + oy, z - oz) }
    local endVec1 = util.GetClosestVector(builder:GetPosition(), VectorExtentsList )


    for k,v in VectorExtentsList do
        if(v == endVec1) then
            table.remove(VectorExtentsList, k)
        end
    end

    local endVec2 = util.GetClosestVector(builder:GetPosition(), VectorExtentsList )
    local cx1, cy1, cz1 = unpack(endVec1)
    local cx2, cy2, cz2 = unpack(endVec2)

    # Determine a the velocity of our projectile, used for the scaning effect
    local velX = 2 * (endVec2.x - endVec1.x)
    local velY = 2 * (endVec2.y - endVec1.y)
    local velZ = 2 * (endVec2.z - endVec1.z)

    if unitBeingBuilt:GetFractionComplete() == 0 then
        Warp( BeamEndEntity, Vector( cx1, cy1 - oy, cz1 ) ) 
        Warp( BeamEndEntity2, Vector( cx2, cy2 - oy, cz2 ) )
        WaitSeconds( 0.8 )   
    end    

    CreateEmitterOnEntity( BeamEndEntityX, builder:GetArmy(),'/effects/emitters/sparks_08_emit.bp')
    local waitTime = util.GetRandomFloat( 0.3, 1.5 )
    local flipDirection = true

    # Warp our projectile back to the initial corner and lower based on build completeness

    while not builder:BeenDestroyed() and not unitBeingBuilt:BeenDestroyed() do
        local xa, yb, zc = builder.GetRandomOffset(unitBeingBuilt, 1 )
        Warp( BeamEndEntityX, Vector(x + xa, y + yb, z + zc))
        if flipDirection then
            Warp( BeamEndEntity, Vector( cx1, (cy1 - (oy * unitBeingBuilt:GetFractionComplete())), cz1 ) )
            BeamEndEntity:SetVelocity( velX, velY, velZ )
            Warp( BeamEndEntity2, Vector( cx2, (cy2 - (oy * unitBeingBuilt:GetFractionComplete())), cz2 ) )
            BeamEndEntity2:SetVelocity( -velX, -velY, -velZ )
            flipDirection = false
        else
            Warp( BeamEndEntity, Vector( cx2, (cy2 - (oy * unitBeingBuilt:GetFractionComplete())), cz2 ) )
            BeamEndEntity:SetVelocity( -velX, -velY, -velZ ) 
            Warp( BeamEndEntity2, Vector( cx1, (cy1 - (oy * unitBeingBuilt:GetFractionComplete())), cz1 ) )
            BeamEndEntity2:SetVelocity( velX, velY, velZ ) 
            flipDirection = true   
        end
        WaitSeconds( 0.6 )
    end
end