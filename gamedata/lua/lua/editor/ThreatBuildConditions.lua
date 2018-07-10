---  /lua/editor/threatbuildconditions.lua

function ThreatCloserThan( aiBrain, locationType, distance, threatcutoff, threattype)
	
	if aiBrain.BuilderManagers[locationType].Position then
	
		local position = aiBrain.BuilderManagers[locationType].Position
		local threatTable = aiBrain:GetThreatsAroundPosition( position, 8, true, threattype)

		for _,v in threatTable do

			if v[3] > threatcutoff then
			
				--LOG("*AI DEBUG "..aiBrain.Nickname.." has "..v[3].." "..threattype.." threat within "..distance.." of "..locationType.." - "..VDist2( v[1], v[2], position[1], position[3] ))
		
				if VDist2( v[1], v[2], position[1], position[3] ) <= distance then
					--LOG("*AI DEBUG "..aiBrain.Nickname.." has "..v[3].." "..threattype.." threat within "..distance.." of "..locationType.." - "..VDist2( v[1], v[2], position[1], position[3] ))
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
					--LOG("*AI DEBUG "..aiBrain.Nickname.." at "..repr(locationType).." has "..repr(threattype).." threat closer than "..distance.." ("..repr(threatdistance)..")	threat is "..repr(v[3]))
					return false
				end
			end
		end
		
		--if closest < 9999 then
			--LOG("*AI DEBUG "..aiBrain.Nickname.." at "..repr(locationType).." reports closest threat above "..threatcutoff.." is at "..closest.." - value is "..value)
		--end
	end

    return true
end