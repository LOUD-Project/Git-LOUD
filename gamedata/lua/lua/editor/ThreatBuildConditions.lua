---  /lua/editor/threatbuildconditions.lua

local LOUDLOG10 = math.log10
local LOUDSORT = table.sort

local VDist2 = VDist2
local VDist2Sq = VDist2Sq

local GetThreatsAroundPosition = moho.aibrain_methods.GetThreatsAroundPosition


function ThreatCloserThan( aiBrain, locationType, distance, threatcutoff, threattype)
	
	if aiBrain.BuilderManagers[locationType].Position then
	
		local position = aiBrain.BuilderManagers[locationType].Position
        
		local threatTable = GetThreatsAroundPosition( aiBrain, position, 12, true, threattype)
        
        if threatTable[1] then
        
            if threattype == 'Land' and aiBrain.LandRatio > 1.1 then

                distance = distance * ( 1 / (1 + LOUDLOG10( aiBrain.VeterancyMult )))          -- cheat level makes us look farther

            end

            for _,v in threatTable do

                if v[3] > threatcutoff then

                    if VDist2( v[1], v[2], position[1], position[3] ) <= distance then

                        return true
                    end
                    
                end
            end
        end
	end
	
    return false

end

function ThreatFurtherThan( aiBrain, locationType, distance, threattype, threatcutoff)
	
	if aiBrain.BuilderManagers[locationType].Position then
	
		local position = aiBrain.BuilderManagers[locationType].Position
        
		local threatTable = GetThreatsAroundPosition( aiBrain, position, 12, true, threattype)
        
        if threatTable[1] then

            -- sort the table by closest first so we can abort as soon as we pass the distance check
            LOUDSORT(threatTable, function(a,b) return VDist2Sq(a[1],a[2], position[1],position[3]) < VDist2Sq(b[1],b[2], position[1],position[3]) end)
    
            -- this code makes this function dynamic via LandRatio and AIMult --
            if threattype == 'Land' and aiBrain.LandRatio > 1.1 then
        
                -- affect the distance with ratio AND AIMult --
                --distance = distance * ( 1 / aiBrain.LandRatio )                             -- if we have a high ratio threat needs to be closer to impact us
            
                distance = distance * ( 1 / (1 + LOUDLOG10( aiBrain.VeterancyMult )))      -- cheat level makes us look farther
            
                -- but the threat is only affected by actual ratio
                -- threatcutoff = threatcutoff * aiBrain.LandRatio                             -- and the amount of threat needs to be higher as well
            
            end

            for _,v in threatTable do

                if VDist2( v[1],v[2], position[1],position[3] ) < distance then
			
                    if v[3] > threatcutoff then
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." at "..repr(locationType).." has "..threattype.." threat closer than "..math.floor(distance).." is at ("..math.floor(VDist2(v[1],v[2], position[1],position[3]))..")	threat is "..math.floor(v[3]).." trigger ("..math.floor(threatcutoff)..") comes from "..repr(v) )
                        return false
                    end
                
                else
                    break
                end
                
            end
        end
	end

    return true
end
