--  File     :  /lua/AI/aibuildstructures.lua

local import = import

local BaseTemplates = import('/lua/basetemplates.lua').BaseTemplates
local BuildingTemplates = import('/lua/buildingtemplates.lua').BuildingTemplates

local LOUDINSERT = table.insert


function AddToBuildQueue(aiBrain, eng, whatToBuild, buildLocation, relative)
    LOUDINSERT(eng.EngineerBuildQueue, { whatToBuild, buildLocation } )
end

function IsResource(buildingType)
    return buildingType == 'Resource' or buildingType == 'T1HydroCarbon' or buildingType == 'T1Resource' or buildingType == 'T2Resource' or buildingType == 'T3Resource'
end

-- This function is usually used for building items in no particular location but still contained within a base template
-- The FindPlaceToBuild function usually returns the location closest to the reference point (relativeTo) that is open
function AIExecuteBuildStructure( aiBrain, engineer, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, NearMarkerType)

    local whatToBuild = aiBrain:DecideWhatToBuild( engineer, buildingType, buildingTemplate)

    if not whatToBuild or engineer.Dead then
	
		LOG("*AI DEBUG AIEXBuildStructure "..aiBrain.Nickname.." failed DecideWhatToBuild - "..repr(buildingType).."  template "..repr(buildingTemplate).."  platoon ".. repr(engineer.BuilderName) .." - ".. engineer.Sync.id)
		
        return false
		
    end
	
    local relativeTo = aiBrain.BuilderManagers[engineer.LocationType].Position or false
	
    if closeToBuilder then
	
        relativeTo = engineer:GetPosition()
		
    end
	
    local location = false
	
    if IsResource(buildingType) then
	
		-- OK - Here is an important piece of code particularily for Engineers building Mass Extractors
		-- Notice the final parameter ?  It's supposed to tell the command to ignore places with threat greater than that
		-- If so -- it has no specific range or threat types associated with it - which means we have no idea what it's measuring
		-- Most certainly it won't be related to any threat check we do elsewhere in our code - as far as I can tell.
		-- The biggest result - ENGINEERS GO WANDERING INTO HARMS WAY FREQUENTLY -- I'm going to try various values
		-- I am now passing along the engineers ThreatMax from his platoon (if it's there)
        location = aiBrain:FindPlaceToBuild( buildingType, whatToBuild, baseTemplate, relative, engineer, 'Enemy', relativeTo[1], relativeTo[3], engineer.PlatoonHandle.PlatoonData.Construction.ThreatMax or 7.5)	
		
		if not location then
		
			engineer.PlatoonHandle:SetAIPlan('ReturnToBaseAI', aiBrain)
			
		end
		
    else
	
        location = aiBrain:FindPlaceToBuild( buildingType, whatToBuild, baseTemplate, relative, engineer, nil, relativeTo[1], relativeTo[3])
		
    end
	
    if location and not engineer.Dead then
	
        local relativeLoc = { location[1], 0, location[2] }
		
        if relative then
		
            relativeLoc = {relativeLoc[1] + relativeTo[1], relativeLoc[2] + relativeTo[2], relativeLoc[3] + relativeTo[3]}
			
        end

        AddToBuildQueue(aiBrain, engineer, whatToBuild, { relativeLoc[1], relativeLoc[3], 0 } )
		
		return true
		
    end
	
	return false
	
end

function AIBuildBaseTemplate( aiBrain, builder, buildingType , closeToBuilder, relative, buildingTemplate, baseTemplate, reference, NearMarkerType)

    local whatToBuild = aiBrain:DecideWhatToBuild( builder, buildingType, buildingTemplate)

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
function AIBuildBaseTemplateOrdered( aiBrain, eng, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, NearMarkerType)

    local whatToBuild = aiBrain:DecideWhatToBuild( eng, buildingType, buildingTemplate)

    if whatToBuild and not eng.Dead then

        if IsResource(buildingType) then
		
            return AIExecuteBuildStructure( aiBrain, eng, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference)
			
        else
		
			local function EngineerTryRepair( buildlocation )

				for _,v in aiBrain:GetUnitsAroundPoint( categories.STRUCTURE, buildlocation, 1, 'Ally' ) do
			
					if not v.Dead and v:GetFractionComplete() < 1 then
					
						IssueRepair( {eng}, v )

						--LOG("*AI DEBUG Eng "..eng.Sync.id.." repairs "..v:GetBlueprint().Description )

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
							
								if not eng.Dead and aiBrain:CanBuildStructureAt( whatToBuild, { position[1], 0, position[2] } ) or EngineerTryRepair( { position[1],0,position[2] } ) then
									
									AddToBuildQueue( aiBrain, eng, whatToBuild, position )
									
									table.remove(bType,n)
									
									return true
								end
								
							end
							
                        end
						
                        break
						
                    end 
					
                end
				
            end
			
        end
		
		--LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.Sync.id.." could not find place to to build "..repr(buildingType).." platoon "..repr(eng.BuilderName))	--.." template is "..repr(baseTemplate))
		
    else
	
		WARN("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.Sync.id.." failed DecideWhatToBuild - "..repr(buildingType).."  platoon ".. repr(eng.BuilderName))	--	.." template is "..repr(buildingTemplate))

	end

    return false
end

function AIBuildBaseTemplateFromLocation( baseTemplate, location )

	local LOUDFLOOR = math.floor
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

function AIBuildAdjacency( aiBrain, builder, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, NearMarkerType)

    local whatToBuild = aiBrain:DecideWhatToBuild( builder, buildingType, buildingTemplate )

    if whatToBuild and not builder.Dead then
	
        local upperString = ParseEntityCategory( string.upper(whatToBuild) )
        local unitSize = aiBrain:GetUnitBlueprint( whatToBuild ).Physics
        local template = {}
		
        LOUDINSERT( template, {} )
        LOUDINSERT( template[1], { buildingType } )
		
        for k,v in reference do
		
            if not v.Dead then
			
                local targetSize = v:GetBlueprint().Physics
                local targetPos = table.copy( v:GetPosition() )
				
                targetPos[1] = targetPos[1] - (targetSize.SkirtSizeX * 0.5)
                targetPos[3] = targetPos[3] - (targetSize.SkirtSizeZ * 0.5)
				
                -- check Top/bottom of unit
                for i=0,((targetSize.SkirtSizeX * 0.5)-1) do
				
                    local testPos = { targetPos[1] + 1 + (i * 2), targetPos[3]-(unitSize.SkirtSizeZ * 0.5), 0 }
                    local testPos2 = { targetPos[1] + 1 + (i * 2), targetPos[3]+targetSize.SkirtSizeZ+(unitSize.SkirtSizeZ* 0.5), 0 }
					
                    LOUDINSERT( template[1], testPos )
                    LOUDINSERT( template[1], testPos2 )
					
                end
				
                -- check sides of unit
                for i=0,((targetSize.SkirtSizeZ * 0.5)-1) do
				
                    local testPos = { targetPos[1]+targetSize.SkirtSizeX + (unitSize.SkirtSizeX * 0.5), targetPos[3] + 1 + (i * 2), 0 }
                    local testPos2 = { targetPos[1]-(unitSize.SkirtSizeX * 0.5), targetPos[3] + 1 + (i*2), 0 }
					
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
		
        local location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, template, false, builder, baseLocation[1], baseLocation[3])
		
        if location then
		
            AddToBuildQueue( aiBrain, builder, whatToBuild, location )
			
            return true
			
        end
		
        -- Build in a regular spot if adjacency not found - commented out by LOUD so that build fails when adjacency fails
		LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..builder.Sync.id.." Unable to build "..repr(buildingType).." adjacent to "..repr(reference).." near base at "..repr(baseLocation))
		
    end

	--LOG("*AI DEBUG "..aiBrain.Nickname.." failed DecideWhatToBuild - "..repr(buildingType).."  template "..repr(buildingTemplate).."  platoon ".. repr(builder.BuilderName) .." - ".. builder.Sync.id)

    return false, false
	
end

-- I modded this function to pick up two new values -- ExpansionRadius &  RallyPointRadius from the builder spec
-- This does two things, ExpansionRadius controls the area that this base will draw pool units from
-- the RallyPointRadius determiness the creation of auto-rally points for this base
-- both values get defaulted if not present  
function AINewExpansionBase( aiBrain, baseName, position, engineer, constructionData )

	local LOUDGETN = table.getn

	if (not engineer.Dead) then

		local baseValues = {}
		local highPri = false

		-- determines if this base is counted against total allowed bases -- defaults to false
		local countedbase = constructionData.CountedBase or false
		local expansionradius = constructionData.ExpansionRadius or 150
		local rallypointradius = constructionData.RallyPointRadius or 50

		if not expansionradius then
		
			-- set the expansion base POOL radius according to map size
			-- should help minimize overlap on maps where bases might be crowded in
			expansionradius = math.max(100, (ScenarioInfo.size[1]/16))	#-- should give a value between 100 and 256
			expansionradius = math.min(expansionradius, 150)	#-- will limit it to 150 maximum for Expansions (MAIN minimum is 200)
			
		end
        
		-- build a list of possible base plan choices
		for templateName, baseData in BaseBuilderTemplates do
			
			-- the highest basevalue is 100 - this value gets reduced if there is threat at the position
			-- the ExpansionFunction is a part of the basebuildertemplate so look there for how it works
			-- technically, some basebuildertemplates could be less affected by threat but I don't see it
			-- essentially the expansion function just returns a reduced value according to how close threat is to the position
			-- this was originally intended to select different base plans
			local baseValue,island = baseData.ExpansionFunction( aiBrain, position, constructionData.NearMarkerType )

			if baseValue > 0 then
			
				LOUDINSERT( baseValues, { Base = templateName, Island = island, Value = baseValue } )
            
				if not highPri or baseValue > highPri then
					highPri = baseValue
				end
			end
		end

		-- if more than one with highest value - pick randomly
		local validNames = {}
        
		for k,v in baseValues do
		
			if v.Value == highPri then
			
				LOUDINSERT( validNames, {Base = v.Base, Island = v.Island} )
				
			end
		end
		
		local pick = validNames[ Random( 1, LOUDGETN(validNames) ) ] or false
        
		if not pick then
        
            if not engineer.Dead then
                LOG('*AI DEBUG '..aiBrain.Nickname.." yielded no base pick for engineer "..repr(engineer.platoonhandle.BuilderName).." from "..engineer.LocationType )
            end
		else

			-- this function would level the area around a new base
			--import('/lua/loudutilities.lua').LevelStartBaseArea( position, rallypointradius )
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..engineer.Sync.id.." creating new base "..repr(baseName))
			
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
