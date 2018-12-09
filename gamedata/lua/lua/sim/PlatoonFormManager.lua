--  File     :  /lua/sim/PlatoonFormManager.lua
--  The Platoon Formation Manager (PFM) is responsible for formation of ALL platoons ( Land, Air, Naval )
--  Each active base will have it's own PFM
--  Essentially, the PFM is a loop that will try to create all possible platoons that meet conditions every pass
--  Engineers form their own platoons, see the Engineer Manager for that

local import = import

local BuilderManager = import('/lua/sim/BuilderManager.lua').BuilderManager

local GetMostRestrictiveLayer = import('/lua/ai/aiattackutilities.lua').GetMostRestrictiveLayer 
local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
local CreatePlatoonBuilder = import('/lua/sim/Builder.lua').CreatePlatoonBuilder

local factionnames = { 'UEF','Aeon','Cybran','Seraphim' }

local LOUDGETN = table.getn
local LOUDINSERT = table.insert

function CreatePlatoonFormManager(brain, lType, position, radius)

    local pfm = PlatoonFormManager()
	
	--LOG("*AI DEBUG "..brain.Nickname.." creating PFM for "..lType)
	
    pfm:Create(brain, lType, position, radius)
    pfm.BuilderCheckInterval = 40	-- default starting value
	
    return pfm
	
end

PlatoonFormManager = Class(BuilderManager) {

    Create = function(self, brain, lType, position, radius)
	
        BuilderManager.Create(self,brain)
		
		self.ChecksPerTick = 1
        self.Location = position
        self.LocationType = lType
		self.ManagerType = 'PFM'
        self.Radius = radius
		
        self:AddBuilderType('Any')

		self:SetEnabled(brain, true)
		
	end,
   
    AddBuilder = function(self, brain, builderData, locationType, builderType)
	
        local newBuilder = CreatePlatoonBuilder( self, brain, builderData, locationType)
		
		if newBuilder then
		
			self:AddInstancedBuilder(newBuilder, builderType, brain)
			
		end
		
        return newBuilder
		
    end,
	
    -- I finished the ability to have faction based squads which was obviously intended but never fully coded
	-- so now you can specify a single platoon but have faction unique compositions for them
    GetPlatoonTemplate = function( self, templateName, aiBrain )

        if PlatoonTemplates[templateName].GlobalSquads then
		
            return { PlatoonTemplates[templateName].Name, PlatoonTemplates[templateName].Plan or 'none', unpack(PlatoonTemplates[templateName].GlobalSquads) }
			
        else
			
			local factionitem = factionnames[aiBrain.FactionIndex]
			
            if PlatoonTemplates[templateName].FactionSquads[factionitem] then
			
				return { PlatoonTemplates[templateName].Name, PlatoonTemplates[templateName].Plan or 'none', unpack(PlatoonTemplates[templateName].FactionSquads[factionitem]) }
				
            end
			
        end
		
    end,
    
    GetUnitsBeingBuilt = function( self, aiBrain, buildingCategory, builderCategory)
		
        local filterUnits = GetOwnUnitsAroundPoint( aiBrain, builderCategory, self.Location, self.Radius )
		
		local LOUDENTITY = EntityCategoryContains
		local IsUnitState = moho.unit_methods.IsUnitState

        local retUnits = {}
		local counter = 0
        
        for _,v in filterUnits do
		
			if not v.DesiresAssist or not v.UnitBeingBuilt then
			
				continue
				
			end

            if (not IsUnitState(v, 'Building') and not IsUnitState(v, 'Upgrading')) then
			
                continue
				
            end

            if not LOUDENTITY( buildingCategory, v.UnitBeingBuilt ) then
			
                continue
				
            end

            if v.NumAssistees and LOUDGETN( v:GetGuards() ) >= v.NumAssistees then
			
                continue
				
            end

            retUnits[counter+1] = v
			counter = counter + 1
			
        end
		
		return retUnits
		
    end,
 
    GetNumberOfUnitsBeingBuilt = function(self, aiBrain, buildingCategory, builderCategory, range)
		
        local filterUnits = GetOwnUnitsAroundPoint( aiBrain, builderCategory, self.Location, range or self.Radius )
		
		local LOUDENTITY = EntityCategoryContains
		local IsUnitState = moho.unit_methods.IsUnitState

		local counter = 0
        
        for k,v in filterUnits do
		
			if not v.DesiresAssist or not v.UnitBeingBuilt then
			
				continue
				
			end
			
            if (not IsUnitState(v, 'Building') and not IsUnitState(v, 'Upgrading')) then
			
                continue
				
            end

            if not LOUDENTITY( buildingCategory, v.UnitBeingBuilt ) then
			
                continue
				
            end
            
            if v.NumAssistees and LOUDGETN( v:GetGuards() ) >= v.NumAssistees then
			
                continue
				
            end

			counter = counter + 1
			
        end
		
		return counter
		
    end,
	
	-- Just to note that this only runs if the task has passed all of its conditions
	-- platoon priorityfunctions (for the PFM) only run when the base changes its status between Primary and not Primary
	-- hmm..might make sense if they were run each time the PFM started a new cycle...perhaps...
    ManagerLoopBody = function( self, builder, bType, aiBrain)
		
		local CanFormPlatoon = moho.platoon_methods.CanFormPlatoon
		local FormPlatoon = moho.platoon_methods.FormPlatoon
		local GetPlatoonUnits = moho.platoon_methods.GetPlatoonUnits
		
		if aiBrain.BuilderManagers[self.LocationType] and builder.InstancesAvailable > 0 then
		
			local template = self.GetPlatoonTemplate( self, builder:GetPlatoonTemplate(), aiBrain )
			
			if template and self.Location and self.Radius and CanFormPlatoon( aiBrain.ArmyPool, template, 1, self.Location, self.Radius) then
			
				if ScenarioInfo.PlatoonDialog then
					LOG("*AI DEBUG "..aiBrain.Nickname.." PFM "..self.LocationType.." forms "..repr(template[1]))
				end
				
				local hndl = FormPlatoon( aiBrain.ArmyPool, template, 1, self.Location, self.Radius)
				
				if not builder:StoreHandle( hndl, self, 'Any' ) then
					return aiBrain:DisbandPlatoon(hndl)
				end

				hndl.LocationType = self.LocationType
				hndl.PlanName = template[2]
				hndl.RTBLocation = builder.RTBLocation or false
				
				hndl.PlatoonData = builder:GetBuilderData(self.LocationType)
				
				hndl:OnUnitsAddedToPlatoon()
				
				GetMostRestrictiveLayer(hndl)

				if Builders[builder.BuilderName].PlatoonAIPlan then
					hndl.PlanName = Builders[builder.BuilderName].PlatoonAIPlan
					hndl:SetAIPlan(hndl.PlanName, aiBrain)
				end

				if Builders[builder.BuilderName].PlatoonAddPlans then
				
					for _, papv in Builders[builder.BuilderName].PlatoonAddPlans do
					
						if ScenarioInfo.PlatoonDialog then
							LOG("*AI DEBUG "..aiBrain.Nickname.." "..builder.BuilderName.." adds plan "..repr(papv))
						end
					
						hndl:ForkThread( hndl[papv], aiBrain )
						
					end
					
				end

				if Builders[builder.BuilderName].PlatoonAddFunctions then
				
					for _, papv in Builders[builder.BuilderName].PlatoonAddFunctions do
					
						-- this will run a non critical function -- Wait ?  What do you think that means ? 
						-- these forks are NOT put into the platoons TRASH -- so they save on processing and storage - BUT 
						-- they must terminate themselves -- ideally independent of the platoon entirely
						if ScenarioInfo.PlatoonDialog then
							LOG("*AI DEBUG "..aiBrain.Nickname.." "..builder.BuilderName.." adds function "..repr(papv[2]))
						end
						
						ForkThread( import(papv[1])[papv[2]], hndl, aiBrain )
					end
				end

				if Builders[builder.BuilderName].PlatoonAddBehaviors then
				
					for _, papv in Builders[builder.BuilderName].PlatoonAddBehaviors do

						if ScenarioInfo.PlatoonDialog then
							LOG("*AI DEBUG "..aiBrain.Nickname.." "..builder.BuilderName.." adds behavior "..repr(papv))
						end
					
						hndl:ForkThread( import('/lua/ai/aibehaviors.lua')[papv], aiBrain )
						
					end
				end

			else
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." PFM "..self.LocationType.." unable to form platoon "..repr(template))
			
			end
			
        end
		
    end,
	
}