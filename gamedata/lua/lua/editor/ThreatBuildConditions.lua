---  /lua/editor/threatbuildconditions.lua

local LOUDFLOOR = math.floor
local LOUDLOG10 = math.log10
local LOUDSORT  = table.sort

local VDist2    = VDist2
local VDist2Sq  = VDist2Sq

local GetNumUnitsAroundPoint    = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetThreatsAroundPosition  = moho.aibrain_methods.GetThreatsAroundPosition


function ThreatCloserThan( aiBrain, locationType, distance, threatcutoff, threattype)
	
    local position = aiBrain.BuilderManagers[locationType].Position

	if position[1] then
  
		local threatTable = GetThreatsAroundPosition( aiBrain, position, 12, true, threattype)
        
        local adjustment = 0
        
        if threatTable[1] then
        
            if (threattype == 'Land' or threattype == 'AntiSurface') and aiBrain.LandRatio > 1 then

                adjustment = LOUDLOG10( aiBrain.VeterancyMult ) + LOUDLOG10( aiBrain.LandRatio )

                distance = LOUDFLOOR(distance * ( 1 / (1 + adjustment)))    -- don't look as far

                threatcutoff = LOUDFLOOR(threatcutoff - (threatcutoff * adjustment))   -- and require less threat to trigger
            end

            for _,v in threatTable do

                if v[3] > threatcutoff then

                    if VDist2( v[1], v[2], position[1], position[3] ) <= distance then

                        return true
                    end
                    
                end
            end
        
            --LOG("*AI DEBUG "..aiBrain.Nickname.." at "..repr(locationType).." fails ThreatCloserThan (TBC) "..distance.." for greater than "..threatcutoff.." "..threattype.." threat" )

        end

	end
	
    return false

end

-- this adds a check for strategic artillery alongside a threat check
function ThreatCloserThanOrArtillery( aiBrain, locationType, distance, threatcutoff, threattype)

    if GetNumUnitsAroundPoint( aiBrain, categories.ARTILLERY * categories.STRATEGIC, {0,0,0}, 999999, 'Enemy' ) > 0 then
        return true
    end
	
    local position = aiBrain.BuilderManagers[locationType].Position

	if position[1] then
  
		local threatTable = GetThreatsAroundPosition( aiBrain, position, 12, true, threattype)
        
        local adjustment = 0
        
        if threatTable[1] then
        
            if (threattype == 'Land' or threattype == 'AntiSurface') and aiBrain.LandRatio > 1 then

                adjustment = LOUDLOG10( aiBrain.VeterancyMult ) + LOUDLOG10( aiBrain.LandRatio )

                distance = LOUDFLOOR(distance * ( 1 / (1 + adjustment)))    -- don't look as far

                threatcutoff = LOUDFLOOR(threatcutoff - (threatcutoff * adjustment))   -- and require less threat to trigger
            end

            for _,v in threatTable do

                if v[3] > threatcutoff then

                    if VDist2( v[1], v[2], position[1], position[3] ) <= distance then

                        return true
                    end
                    
                end
            end
        
            --LOG("*AI DEBUG "..aiBrain.Nickname.." at "..repr(locationType).." fails ThreatCloserThan (TBC) "..distance.." for greater than "..threatcutoff.." "..threattype.." threat" )

        end

	end
	
    return false

end

function ThreatFurtherThan( aiBrain, locationType, distance, threattype, threatcutoff)

	local position = aiBrain.BuilderManagers[locationType].Position	

	if position[1] then

		local threatTable = GetThreatsAroundPosition( aiBrain, position, 12, true, threattype)
        
        local adjustment = 0
        
        if threatTable[1] then

            -- sort the table by closest first so we can abort as soon as we pass the distance check
            LOUDSORT(threatTable, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a[1],a[2], position[1],position[3]) < VDist2Sq(b[1],b[2], position[1],position[3]) end)
    
            -- this code makes this function dynamic via LandRatio and AIMult --
            -- adjusting the triggers when ratio is above 1
            if threattype == 'Land' and aiBrain.LandRatio > 1 then

                adjustment = LOUDLOG10( aiBrain.VeterancyMult ) + LOUDLOG10( aiBrain.LandRatio )

                distance = math.floor(distance * (1 + adjustment))           -- look farther out

                threatcutoff = math.floor(threatcutoff * (1 + adjustment))   -- and require more threat to fail
            
            end

            for _,v in threatTable do

                if VDist2( v[1],v[2], position[1],position[3] ) < distance then
			
                    if v[3] > threatcutoff then
                    
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..locationType.." sees "..math.floor(v[3]).." "..threattype.." threat CLOSER than "..distance.." threat trigger is "..threatcutoff )

                        return false
                    end
                
                else
                    break
                end
                
            end

            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..locationType.." sees no "..threattype.." threat above "..threatcutoff.." within "..distance.." Ratio "..aiBrain.LandRatio.." Adjust "..adjustment  )

        else
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..locationType.." sees no threats from "..repr(position) )
        end
        
	end

    return true
end
