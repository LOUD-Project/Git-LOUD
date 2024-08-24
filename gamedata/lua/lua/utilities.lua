---  /lua/utilities.lua
---  Summary  :  Utility functions for scripts.

local LOUDACOS = math.acos
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn

local LOUDPOW = math.pow
local LOUDSQRT = math.sqrt
local LOUDINSERT = table.insert

local Random = Random
	
local GetArmy = moho.entity_methods.GetArmy
local GetPosition = moho.entity_methods.GetPosition
    
local VDist2 = VDist2
local VDist2Sq = VDist2Sq
local VDist3 = VDist3

function GetDistanceBetweenTwoEntities(entity1, entity2)
    return VDist3(entity1:GetPosition(),entity2:GetPosition())
end

function GetEnemyUnitsInSphere(unit, position, radius)

	local UnitsinRec = GetUnitsInRect( Rect(position[1] - radius, position[3] - radius, position[1] + radius, position[3] + radius) )
	
	--Check for empty rectangle
	if not UnitsinRec then
		return false
	end
	
	local GetArmy = GetArmy
	local GetPosition = GetPosition
    local VDist2Sq = VDist2Sq
	
	local RadEntities = {}
	local counter = 0
    local army = unit.Sync.army
	local checkrange = radius * radius
    local pos
	
    for _, v in UnitsinRec do
    
		pos = GetPosition(v)
		
		if (army != v.Sync.army) and ( VDist2Sq(position[1],position[3], pos[1],pos[3] ) <= checkrange) then
        
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
	local a = (x1-x2)
	local b = (y1-y2)
	local c = (z1-z2)
	return ( LOUDSQRT( a*a + b*b + c*c ) )
end

function GetDistanceBetweenTwoVectors( v1, v2 )
    return VDist3(v1, v2)
end

function XZDistanceTwoVectors( v1, v2 )
    return VDist2( v1[1], v1[3], v2[1], v2[3] )
end

function GetVectorLength( v )
    return LOUDSQRT( LOUDPOW( v[1], 2 ) + LOUDPOW( v[2], 2 ) + LOUDPOW(v[3], 2 ) )
end

function NormalizeVector( v )

	if v.x then
		v = {v.x, v.y, v.z}
	end
	
    local length = LOUDSQRT( LOUDPOW( v[1], 2 ) + LOUDPOW( v[2], 2 ) + LOUDPOW(v[3], 2 ) )
	
    if length > 0 then
    
        local invlength = 1 / length
        
        v[1] = v[1]*invlength
        v[2] = v[2]*invlength
        v[3] = v[3]*invlength
        
        return v    --Vector( v[1] * invlength, v[2] * invlength, v[3] * invlength )
    else
    
        return { 0,0,0 }
    end
end

function GetDifferenceVector( v1, v2 )
    return Vector(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3])
end

function GetDirectionVector( v1, v2 )
    return NormalizeVector( Vector(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3]) )
end

function GetDirectionInDegrees( v1, v2 )

	local vec = NormalizeVector( Vector(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3]) )
	
	if vec[1] >= 0 then
		return LOUDACOS(vec[3]) * (360/ 6.28)
	end
	
	return 360 - (LOUDACOS(vec[3]) * (360/ 6.28))
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
    local VDist3Sq = VDist3Sq
    
    if( vToList ) then
        dist = VDist3Sq( vFrom, vToList[1] )
        retVec = vToList[1]
    end
    
    for kTo, vTo in vToList do
    
        cDist = VDist3Sq( vFrom, vTo )
        
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
    return LOUDACOS( DotP( NormalizeVector(v1), NormalizeVector(v2) ) ) * ( 360/6.28 )
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
	
	local LOUDINSERT = LOUDINSERT
	
    for index = 1, LOUDGETN(arg) do
	
        if arg[index] != nil then
            for k, v in arg[index] do
                LOUDINSERT( ret, v )
            end
        end
    end
	
    return ret
end

function LOUD_TitleCase(string)
	local function tchelper(first, rest)
		return first:upper()..rest:lower()
	end
	return string:gsub("(%a)([%w_']*)", tchelper)
end
