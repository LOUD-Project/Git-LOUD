---  /lua/utilities.lua
---  Summary  :  Utility functions for scripts.

local LOUDACOS = math.acos
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn
local LOUDPI = math.pi
local LOUDPOW = math.pow
local LOUDSQRT = math.sqrt
local LOUDINSERT = table.insert
local Random = Random
local VDist2 = VDist2
local VDist3 = VDist3

function GetDistanceBetweenTwoEntities(entity1, entity2)
    return VDist3(entity1:GetPosition(),entity2:GetPosition())
end

function GetEnemyUnitsInSphere(unit, position, radius)

	local UnitsinRec = GetUnitsInRect( Rect(position.x - radius, position.z - radius, position.x + radius, position.z + radius) )
	
	--Check for empty rectangle
	if not UnitsinRec then
		return false
	end
	
	local GetArmy = moho.entity_methods.GetArmy
	local GetPosition = moho.entity_methods.GetPosition
	
	local RadEntities = {}
	local counter = 0
    local army = GetArmy(unit)
	local checkrange = radius * radius
	
    for _, v in UnitsinRec do
		local pos = GetPosition(v)
		
		if (army != GetArmy(v)) and ( VDist2Sq(position[1],position[3], pos[1],pos[3] ) <= checkrange) then
			RadEntities[counter+1] = v
			counter = counter + 1
		end
	end
	if counter > 0 then 
		return RadEntities
	end
	return false
end

function GetDistanceBetweenTwoPoints(x1, y1, z1, x2, y2, z2)
    return ( LOUDSQRT( (x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2 ) )
end

function GetDistanceBetweenTwoVectors( v1, v2 )
    return VDist3(v1, v2)
end

function XZDistanceTwoVectors( v1, v2 )
    return VDist2( v1[1], v1[3], v2[1], v2[3] )
end

function GetVectorLength( v )
    return LOUDSQRT( math.pow( v[1], 2 ) + math.pow( v[2], 2 ) + math.pow(v[3], 2 ) )
end

function NormalizeVector( v )

	if v.x then
		v = {v.x, v.y, v.z}
	end
	
    local length = LOUDSQRT( math.pow( v[1], 2 ) + math.pow( v[2], 2 ) + math.pow(v[3], 2 ) )
	
    if length > 0 then
        local invlength = 1 / length
        return Vector( v[1] * invlength, v[2] * invlength, v[3] * invlength )
    else
        return Vector( 0,0,0 )
    end
end

function GetDifferenceVector( v1, v2 )
    return Vector(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3])
end

function GetDirectionVector( v1, v2 )
    return NormalizeVector( Vector(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3]) )
end

function GetDirectionInDegrees( v1, v2 )

	local vec = GetDirectionVector( v1, v2)
	
	if vec[1] >= 0 then
		return LOUDACOS(vec[3]) * (360/(LOUDPI*2))
	end
	
	return 360 - (LOUDACOS(vec[3]) * (360/(LOUDPI*2)))
end

function GetScaledDirectionVector( v1, v2, scale )
    local vec = GetDirectionVector( v1, v2 )
    return Vector( vec.x * scale, vec.y * scale, vec.z * scale )
end

function GetMidPoint( v1, v2 )
	return Vector( (v1.x + v2.x) * 0.5, (v1.y + v2.y) * 0.5, (v1.z + v2.z) * 0.5 )
end

function GetRandomFloat( nmin, nmax)
    return (Random() * (nmax - nmin) + nmin)
end

function GetRandomInt( nmin, nmax)
    return LOUDFLOOR(Random() * (nmax - nmin + 1) + nmin)
end

function GetRandomOffset( sx, sy, sz, scalar )
    sx = sx * scalar
    sy = sy * scalar
    sz = sz * scalar

    return Random()*sx - (sx*.5), Random()*sy, Random()*sz - (sz*.5)
end

function GetClosestVector( vFrom, vToList )
    local dist, cDist, retVec = 0
    if( vToList ) then
        dist = VDist3( vFrom, vToList[1] )
        retVec = vToList[1]
    end
    for kTo, vTo in vToList do
        cDist = VDist3( vFrom, vTo )
        if( dist > cDist) then
            dist = cDist
            retVec = vTo
        end 
    end
    return retVec
end

function Cross( v1, v2 )
	return Vector( (v1.y * v2.z) - (v1.z * v2.y), (v1.z * v2.x) - (v1.x * v2.z ), (v1.x * v2.y) - (v1.y * v2.x))
end

function DotP( v1, v2 )
    return (v1[1] * v2[1]) + (v1[2] * v2[2]) + (v1[3] * v2[3])
end

function GetAngleInBetween(v1, v2)
    return LOUDACOS( DotP( NormalizeVector(v1), NormalizeVector(v2) ) ) * ( 360/(LOUDPI*2) )
end

function UserConRequest(string)
    if not Sync.UserConRequests then
        Sync.UserConRequests = {}
    end
    LOUDINSERT(Sync.UserConRequests, string)
end

-- TableCat - Concatenates multiple tables into one single table
function TableCat( ... )
    local ret = {}
	
	local LOUDINSERT = table.insert
	
    for index = 1, LOUDGETN(arg) do
	
        if arg[index] != nil then
            for k, v in arg[index] do
                LOUDINSERT( ret, v )
            end
        end
    end
	
    return ret
end
