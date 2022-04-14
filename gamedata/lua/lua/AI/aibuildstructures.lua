--  File     :  /lua/AI/aibuildstructures.lua

local import = import

local BaseTemplates = import('/lua/basetemplates.lua').BaseTemplates
local BuildingTemplates = import('/lua/buildingtemplates.lua').BuildingTemplates

local AISortMarkersFromLastPosWithThreatCheck = import('/lua/ai/aiutilities.lua').AISortMarkersFromLastPosWithThreatCheck

local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt
local DecideWhatToBuild = moho.aibrain_methods.DecideWhatToBuild
local FindPlaceToBuild = moho.aibrain_methods.FindPlaceToBuild
local GetFractionComplete = moho.entity_methods.GetFractionComplete
local GetPosition = moho.entity_methods.GetPosition
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint

local LOUDCOPY = table.copy
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDMAX = math.max
local LOUDMIN = math.min
local LOUDPARSE = ParseEntityCategory
local LOUDREMOVE = table.remove
local LOUDUPPER = string.upper
local LOUDSORT = table.sort
local VDist3 = VDist3

function IsResource(buildingType)
    return buildingType == 'Resource' or buildingType == 'T1HydroCarbon' or buildingType == 'T1Resource' or buildingType == 'T2Resource' or buildingType == 'T3Resource'
end

-- This function is usually used for building items in no particular location but still contained within a base template
-- The FindPlaceToBuild function usually returns the location closest to the reference point (relativeTo) that is open
-- Be AWARE - it does not appear to do ANY threat evaluation that I can understand or see working --
function AIExecuteBuildStructure( aiBrain, engineer, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, constructionData)

    local whatToBuild = DecideWhatToBuild( aiBrain, engineer, buildingType, buildingTemplate)

    if not whatToBuild or engineer.Dead then
    
        if not engineer.Dead then
	
            LOG("*AI DEBUG AIExecuteBuildStructure "..aiBrain.Nickname.." failed DecideWhatToBuild - "..repr(buildingType).."  template "..repr(buildingTemplate).."  platoon ".. repr(engineer.BuilderName) .." - ".. engineer.Sync.id)
            
        end
		
        return false
    end
	
    local SourcePosition = aiBrain.BuilderManagers[engineer.LocationType].Position or false
	
    if closeToBuilder then
        SourcePosition = LOUDCOPY(GetPosition(engineer))
    end
	
    local location = false
    local relativeLoc = false
	
    if IsResource(buildingType) then
	
		-- OK - Here is an important piece of code particularily for Engineers building Mass Extractors
		-- Notice the final parameter ?  It's supposed to tell the command to ignore places with threat greater than that
		-- If so -- it has no specific range or threat types associated with it - which means we have no idea what it's measuring
		-- Most certainly it won't be related to any threat check we do elsewhere in our code - as far as I can tell.
		-- The biggest result - ENGINEERS GO WANDERING INTO HARMS WAY FREQUENTLY -- I'm going to try various values
		-- I am now passing along the engineers ThreatMax from his platoon (if it's there)
        
        --location = aiBrain:FindPlaceToBuild( buildingType, whatToBuild, baseTemplate, relative, engineer, 'Enemy', SourcePosition[1], SourcePosition[3], constructionData.ThreatMax or 7.5)	

        local CanBuildStructureAt = CanBuildStructureAt

        local testunit = 'ueb1102'  -- Hydrocarbon
        local testtype = 'Hydrocarbon'
        
        if buildingType != 'T1HydroCarbon' then
            testunit = 'ueb1103'    -- Extractor
            testtype = 'Mass'
        end

        -- this is the code that enables the StartingMassPointList which provides
        -- early engineers with direct goals based on mass point share requirements
        -- As the entries are taken, they are removed until the list is empty at which point the original code takes over 
        if testtype == 'Mass' and aiBrain.StartingMassPointList[1] then
        
            location = LOUDREMOVE(aiBrain.StartingMassPointList, 1)
            location = location.Position

            if CanBuildStructureAt( aiBrain, testunit, location ) then
                --LOG("*AI DEBUG "..aiBrain.Nickname.." Engineer can build at initial mass point at "..repr(location))
                constructionData.MaxRange = 1500
            else
                --LOG("*AI DEBUG "..aiBrain.Nickname.." Engineer CANNOT build at initial mass point at "..repr(location))
                location = false
            end
        end
        
        if not location then

            local markerlist = ScenarioInfo[testtype]
        
            local mlist = {}
            local counter = 0
        
            local mindistance = constructionData.MinRange or 0
            local maxdistance = constructionData.MaxRange or 500
            local tMin = constructionData.ThreatMin or 0
            local tMax = constructionData.ThreatMax or 20
            local tRings = constructionData.ThreatRings or 0
            local tType = constructionData.ThreatType or 'AntiSurface'
            local maxlist = constructionData.MaxChoices or 1
            
            local VDist3 = VDist3
        
            LOUDSORT( markerlist, function (a,b) return VDist3( a.Position, SourcePosition ) < VDist3( b.Position, SourcePosition ) end )

            for _,v in markerlist do
            
                if VDist3( v.Position, SourcePosition ) >= mindistance then
                
                    if VDist3( v.Position, SourcePosition ) <= maxdistance then
                
                        if CanBuildStructureAt( aiBrain, testunit, v.Position ) then

                            counter = counter + 1
                            mlist[counter] = v
                        end
                    end
                end
            end
		
            if counter > 0 then
            
                local markerTable = AISortMarkersFromLastPosWithThreatCheck(aiBrain, mlist, maxlist, tMin, tMax, tRings, tType, SourcePosition)

                if markerTable then

                    -- pick one of the points randomly
                    location = LOUDCOPY( markerTable[ Random(1,LOUDGETN(markerTable)) ] )
                end
            end	
        
        end

        -- if no result or out of range - then abort
		if not location or VDist3( SourcePosition, location ) > constructionData.MaxRange then
        
			engineer.PlatoonHandle:SetAIPlan('ReturnToBaseAI', aiBrain)
            
            location = false
            
		end

        if location then
 	
            relativeLoc = { location[1], 0, location[3] }

            relative = false
        
            location = {relativeLoc[1],relativeLoc[3]}
        
            if constructionData.LoopBuild then
            
                -- loop builders have minimum range to start with
                -- reduced after first build
                constructionData.MinRange = 0
            end
            
		end
        
    else
	
        location = FindPlaceToBuild( aiBrain, buildingType, whatToBuild, baseTemplate, relative, engineer, nil, SourcePosition[1], SourcePosition[3])
		
    end
	
    if location and not engineer.Dead then
	
        local relativeLoc = { location[1], 0, location[2] }
		
        if relative then
		
            relativeLoc = {relativeLoc[1] + SourcePosition[1], relativeLoc[2] + SourcePosition[2], relativeLoc[3] + SourcePosition[3]}
			
        end

        --AddToBuildQueue(aiBrain, engineer, whatToBuild, { relativeLoc[1], relativeLoc[3], 0 } )
        LOUDINSERT(engineer.EngineerBuildQueue, { whatToBuild, {relativeLoc[1], relativeLoc[3], 0 } } )
		
		return true
    end
	
	return false
end

function AIBuildBaseTemplate( aiBrain, builder, buildingType , closeToBuilder, relative, buildingTemplate, baseTemplate, reference, constructionData)

    local whatToBuild = DecideWhatToBuild( aiBrain, builder, buildingType, buildingTemplate)

    if whatToBuild and not builder.Dead then
	
        for _,bType in baseTemplate do
		
            for n,bString in bType[1] do
			
                return AIExecuteBuildStructure( aiBrain, builder, buildingType , closeToBuilder, relative, buildingTemplate, baseTemplate, reference)
				
            end
			
        end
		
    else
	
		LOG("*AI DEBUG "..aiBrain.Nickname.." failed DecideWhatToBuild - "..repr(buildingType).."  template "..repr(buildingTemplate).."  platoon ".. repr(builder.BuilderName) .." - ".. builder.Sync.id)
		
	end
	
    return false
end

-- This function will attempt to build units in the order specified in the base template
-- a building template can have many bType sections in it -- loop thru all to find a match
-- each section can be host for multiple buildings -- loop to find match for the type
-- loop thru all the the possible locations until you find one you can build at
function AIBuildBaseTemplateOrdered( aiBrain, eng, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, constructionData)

    local whatToBuild = DecideWhatToBuild( aiBrain, eng, buildingType, buildingTemplate)

    if whatToBuild and not eng.Dead then

        if IsResource(buildingType) then
		
            return AIExecuteBuildStructure( aiBrain, eng, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference)
			
        else
        
      		local CanBuildStructureAt = CanBuildStructureAt
           	local GetFractionComplete = GetFractionComplete
            local GetUnitsAroundPoint = GetUnitsAroundPoint
            local LOUDINSERT = LOUDINSERT
            local LOUDREMOVE = LOUDREMOVE
		
			local function EngineerTryRepair( buildlocation )

				for _,v in GetUnitsAroundPoint( aiBrain, categories.STRUCTURE, buildlocation, 1, 'Ally' ) do
			
					if not v.Dead and GetFractionComplete(v) < 1 then
					
						IssueRepair( {eng}, v )

						eng.IssuedBuildCommand = true
						eng.IssuedReclaimCommand = false
						
						return true
					end
				end

				return false
			end
			
            for _,bType in baseTemplate do

                for _,bString in bType[1] do

                    if bString == buildingType then       

                        for n, position in bType do

							if n > 1 then
							
								if not eng.Dead and CanBuildStructureAt( aiBrain, whatToBuild, { position[1], 0, position[2] } ) or EngineerTryRepair( { position[1],0,position[2] } ) then
									
                                    LOUDINSERT(eng.EngineerBuildQueue, { whatToBuild, position } )
									
									LOUDREMOVE(bType,n)
									
									return true
								end
								
							end
							
                        end
						
                        break
                    end 
                end
            end
        end
		
    else
	
		WARN("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.Sync.id.." failed DecideWhatToBuild - "..repr(buildingType).."  platoon ".. repr(eng.BuilderName)	.." template is "..repr(buildingTemplate))
	end

    return false
end

function AIBuildBaseTemplateFromLocation( baseTemplate, location )

	local LOUDFLOOR = LOUDFLOOR
    local baseT = {}
	
    if location and baseTemplate then
	
        for templateNum, template in baseTemplate do
		
            baseT[templateNum] = {}
			
            for rowNum,rowData in template do 
			
                if type(rowData[1]) == 'number' then
				
                    baseT[templateNum][rowNum] = {}
                    baseT[templateNum][rowNum][1] = LOUDFLOOR( rowData[1] + location[1] ) + 0.5
                    baseT[templateNum][rowNum][2] = LOUDFLOOR( rowData[2] + location[3] ) + 0.5
                    baseT[templateNum][rowNum][3] = 0
					
                else
				
                    baseT[templateNum][rowNum] = template[rowNum]
					
                end
				
            end
			
        end
		
    end
	
    return baseT
end

function AIBuildAdjacency( aiBrain, builder, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, constructionData)

    local whatToBuild = DecideWhatToBuild( aiBrain, builder, buildingType, buildingTemplate )
    
    local LOUDINSERT = LOUDINSERT

    if whatToBuild and not builder.Dead then

        local unitSize = __blueprints[whatToBuild].Physics
        
        local template = {}
		
        LOUDINSERT( template, {} )
        LOUDINSERT( template[1], { buildingType } )
        
        local targetSize, targetPos, testPos, testPos2
		
        for k,v in reference do
		
            if not v.Dead then
			
                targetSize = __blueprints[v.BlueprintID].Physics
                targetPos = LOUDCOPY( GetPosition(v) )
				
                targetPos[1] = targetPos[1] - (targetSize.SkirtSizeX * 0.5)
                targetPos[3] = targetPos[3] - (targetSize.SkirtSizeZ * 0.5)
				
                -- check Top/bottom of unit
                for i=0,((targetSize.SkirtSizeX * 0.5)-1) do
				
                    testPos = { targetPos[1] + 1 + (i * 2), targetPos[3]-(unitSize.SkirtSizeZ * 0.5), 0 }
                    testPos2 = { targetPos[1] + 1 + (i * 2), targetPos[3]+targetSize.SkirtSizeZ+(unitSize.SkirtSizeZ* 0.5), 0 }
					
                    LOUDINSERT( template[1], testPos )
                    LOUDINSERT( template[1], testPos2 )
					
                end
				
                -- check sides of unit
                for i=0,((targetSize.SkirtSizeZ * 0.5)-1) do
				
                    testPos = { targetPos[1]+targetSize.SkirtSizeX + (unitSize.SkirtSizeX * 0.5), targetPos[3] + 1 + (i * 2), 0 }
                    testPos2 = { targetPos[1]-(unitSize.SkirtSizeX * 0.5), targetPos[3] + 1 + (i*2), 0 }
					
                    LOUDINSERT( template[1], testPos )
                    LOUDINSERT( template[1], testPos2 )
                end
				
            end
			
        end
		
        -- build near the base the engineer is part of, rather than the engineer location
        local baseLocation = {nil, nil, nil}
		
        if builder.BuildManagerData and builder.BuildManagerData.EngineerManager then
		
            baseLocation = builder.BuildManagerdata.EngineerManager.Location
        end        
		
        local location = FindPlaceToBuild( aiBrain, buildingType, whatToBuild, template, false, builder, baseLocation[1], baseLocation[3])
		
        if location then
		
            LOUDINSERT(builder.EngineerBuildQueue, { whatToBuild, location } )
			
            return true
        end
		
        -- Build in a regular spot if adjacency not found - commented out by LOUD so that build fails when adjacency fails
		LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..builder.Sync.id.." Unable to build "..repr(buildingType).." adjacent to "..repr(reference).." near base at "..repr(baseLocation))
    end

    return false, false
end

-- I modded this function to pick up two new values -- ExpansionRadius &  RallyPointRadius from the builder spec
-- This does two things, ExpansionRadius controls the area that this base will draw pool units from
-- the RallyPointRadius determiness the creation of auto-rally points for this base
-- both values get defaulted if not present  
function AINewExpansionBase( aiBrain, baseName, position, engineer, constructionData )

	if (not engineer.Dead) then

		local baseValues = {}
        local count = 0
        
		local highPri = false

		-- determines if this base is counted against total allowed bases -- defaults to false
		local countedbase = constructionData.CountedBase or false
		local expansionradius = constructionData.ExpansionRadius or 150
		local rallypointradius = constructionData.RallyPointRadius or 50

		if not expansionradius then
		
			-- set the expansion base POOL radius according to map size
			-- should help minimize overlap on maps where bases might be crowded in
			expansionradius = LOUDMAX(100, (ScenarioInfo.size[1]/16))	#-- should give a value between 100 and 256
			expansionradius = LOUDMIN(expansionradius, 150)	#-- will limit it to 150 maximum for Expansions (MAIN minimum is 200)
		end
        
        local basevalue, island
        
		-- build a list of possible base plan choices
		for templateName, baseData in BaseBuilderTemplates do
			
			-- the highest basevalue is 100 - this value gets reduced if there is threat at the position
			-- the ExpansionFunction is a part of the basebuildertemplate so look there for how it works
			-- technically, some basebuildertemplates could be less affected by threat but I don't see it
			-- essentially the expansion function just returns a reduced value according to how close threat is to the position
			-- this was originally intended to select different base plans
			baseValue,island = baseData.ExpansionFunction( aiBrain, position, constructionData.NearMarkerType )

			if baseValue > 0 then
            
                count = count + 1
				baseValues[count] = { Base = templateName, Island = island, Value = baseValue }
            
				if not highPri or baseValue > highPri then
					highPri = baseValue
				end
			end
		end

		-- if more than one with highest value - pick randomly
		local validNames = {}
        count = 0

		for k,v in baseValues do
		
			if v.Value == highPri then
			
                count = count + 1
				validNames[count] = {Base = v.Base, Island = v.Island}
			end
		end
		
		local pick = validNames[ Random( 1, count ) ] or false
        
		if not pick then
        
            if not engineer.Dead then
                --LOG('*AI DEBUG '..aiBrain.Nickname.." yielded no base pick for engineer "..repr(engineer.platoonhandle.BuilderName).." from "..engineer.LocationType )
            end
            
		else

			-- this function would level the area around a new base
			--import('/lua/loudutilities.lua').LevelStartBaseArea( position, rallypointradius )

			aiBrain:AddBuilderManagers( position, expansionradius, baseName, true, rallypointradius, countedbase )

			import('/lua/ai/AIAddBuilderTable.lua').AddGlobalBaseTemplate(aiBrain, baseName, pick.Base )
       
			-- remove the engineer from his current base --
			aiBrain.BuilderManagers[engineer.LocationType].EngineerManager:RemoveEngineerUnit(engineer)
			
			-- assign him to his new base
			aiBrain.BuilderManagers[baseName].EngineerManager:AddEngineerUnit(engineer, true)
			
			return true
		end
	end

	return false
end
