function GeneratePath(aiBrain, startNode, endNode, threatType, threatWeight, destination, location, testPath)
	if not aiBrain.PathCache then
		#Create path cache table. Paths are stored in this table and saved for 1 minute so
		#any other platoons needing to travel the same route can get the path without the extra work.
		aiBrain.PathCache = {}
	end
	if not aiBrain.PathCache[startNode.name] then
		aiBrain.PathCache[startNode.name] = {}
		aiBrain.PathCache[startNode.name][endNode.name] = {}
	end
	if not aiBrain.PathCache[startNode.name][endNode.name] then
		aiBrain.PathCache[startNode.name][endNode.name] = {}
	end
	
	if aiBrain.PathCache[startNode.name][endNode.name].path and aiBrain.PathCache[startNode.name][endNode.name].path != 'bad'
	and aiBrain.PathCache[startNode.name][endNode.name].settime + 60 > GetGameTimeSeconds() then
		return aiBrain.PathCache[startNode.name][endNode.name].path
	--elseif aiBrain.PathCache[startNode.name][endNode.name].path and aiBrain.PathCache[startNode.name][endNode.name].path == 'bad' then
	--	return false
	end
	
    threatWeight = threatWeight or 1
    
    local graph = GetPathGraphs()[startNode.layer][startNode.graphName]

    local closed = {}

    local queue = {
            path = {startNode, },
    }
	
	if testPath and VDist2Sq(location[1], location[3], startNode.position[1], startNode.position[3]) > 10000 and 
	SUtils.DestinationBetweenPoints(destination, location, startNode.position) then
		local newPath = {
				path = {newNode = {position = destination}, },
		}
		return newPath
	end
	
	local lastNode = startNode
	
	repeat
	
		if closed[lastNode] then 
			--aiBrain.PathCache[startNode.name][endNode.name] = { settime = 36000 , path = 'bad' }
			return false 
		end
		
		closed[lastNode] = true
		
        local mapSizeX = ScenarioInfo.size[1]
        local mapSizeZ = ScenarioInfo.size[2]
		
		local lowCost = false
		local bestNode = false
			
		for i, adjacentNode in lastNode.adjacent do
		
            local newNode = graph[adjacentNode]
			
			if not newNode or closed[newNode] then
				continue
			end
			
			if testPath and SUtils.DestinationBetweenPoints(destination, lastNode.position, newNode.position) then
				return queue
			end
            
			local dist = VDist2Sq(newNode.position[1], newNode.position[3], endNode.position[1], endNode.position[3])

            # this brings the dist value from 0 to 100% of the maximum length with can travel on a map
			dist = 100 * dist / ( mapSizeX + mapSizeZ )
			
            --get threat from current node to adjacent node
            local threat = aiBrain:GetThreatBetweenPositions(newNode.position, lastNode.position, nil, threatType)
            
            --update path stuff
            local cost = dist + threat*threatWeight
			
			if lowCost and cost >= lowCost then
				continue
			end
			
			bestNode = newNode
			lowCost = cost
		end
		
		if bestNode then
			table.insert(queue.path,bestNode)
			lastNode = bestNode
		end		
		
	until lastNode == endNode
	
	aiBrain.PathCache[startNode.name][endNode.name] = { settime = GetGameTimeSeconds(), path = queue }
	
	return queue
end
