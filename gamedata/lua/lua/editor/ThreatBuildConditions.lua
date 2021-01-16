---  /lua/editor/threatbuildconditions.lua

function ThreatCloserThan( aiBrain, locationType, distance, threatcutoff, threattype)
	
	if aiBrain.BuilderManagers[locationType].Position then
	
		local position = aiBrain.BuilderManagers[locationType].Position
		local threatTable = aiBrain:GetThreatsAroundPosition( position, 12, true, threattype)

		for _,v in threatTable do

			if v[3] > threatcutoff then
			
				--LOG("*AI DEBUG "..aiBrain.Nickname.." has "..v[3].." "..threattype.." threat within "..distance.." of "..locationType.." - "..VDist2( v[1], v[2], position[1], position[3] ))
		
				if VDist2( v[1], v[2], position[1], position[3] ) <= distance then
					--LOG("*AI DEBUG "..aiBrain.Nickname.." has "..v[3].." "..threattype.." threat closer than "..distance.." of "..locationType.." - "..VDist2( v[1], v[2], position[1], position[3] ))
					return true
				end
			end
		end
	end
	
    return false

end

function ThreatFurtherThan( aiBrain, locationType, distance, threattype, threatcutoff)
	
	if aiBrain.BuilderManagers[locationType].Position then
	
		local position = aiBrain.BuilderManagers[locationType].Position
		local threatTable = aiBrain:GetThreatsAroundPosition( position, 12, true, threattype)

        -- this code makes this function dynamic via LandRatio and AIMult --
        if threattype == 'Land' and aiBrain.LandRatio > 1.1 then
        
            -- affect the distance with ratio AND AIMult --
            distance = distance * ( 1 / aiBrain.LandRatio )         -- if we have a high ratio threat needs to be closer to impact us
            
            distance = distance * ( 1 / (1 + math.log10( aiBrain.VeterancyMult )))        -- and our cheat level makes us more tolerant as well
            
            -- but the threat is only affected by actual ratio
            threatcutoff = threatcutoff * aiBrain.LandRatio         -- and the amount of threat needs to be higher as well
            
        end
		
		local closest = 9999
		local value = 0

		for _,v in threatTable do

			local threatdistance = VDist2( v[1], v[2], position[1], position[3] )
			
			if threatdistance < closest and v[3] > threatcutoff then 
				closest = threatdistance
				value = v[3]
			end
			
			if v[3] > threatcutoff then
		
				if threatdistance <= distance then
					--LOG("*AI DEBUG "..aiBrain.Nickname.." at "..repr(locationType).." has "..threattype.." threat closer than "..math.floor(distance).." is at ("..math.floor(threatdistance)..")	threat is "..math.floor(v[3]).." trigger ("..math.floor(threatcutoff)..") comes from "..repr(v) )
					return false
				end
			end
		end
		
		if closest < 9999 then
			--LOG("*AI DEBUG "..aiBrain.Nickname.." at "..repr(locationType).." reports closest threat is below "..math.floor(threatcutoff).." and/or beyond "..math.floor(distance) )
		end
	end

    return true
end