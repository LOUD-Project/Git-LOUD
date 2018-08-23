--------------------------------------------------------------------------------
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local AIUtils = import('/lua/ai/aiutilities.lua')
local AnimationThread = import('/lua/effectutilities.lua').IntelDishAnimationThread

local TeleportLocationBlocked = import('/lua/loudutilities.lua').TeleportLocationBlocked

SEB3404 = Class(TStructureUnit) {

    OnStopBeingBuilt = function(self, ...)
	
        TStructureUnit.OnStopBeingBuilt(self, unpack(arg) )
		
        self.PanopticonUpkeep = self:GetBlueprint().Economy.MaintenanceConsumptionPerSecondEnergy
		
        self:SetScriptBit('RULEUTC_WeaponToggle', true)
		
        local aiBrain = self:GetAIBrain()
		
        self:ForkThread(
            function()
                while true do
				
                    if self.Intel == true then
                        self:IntelSearch(aiBrain)
                    end
					
                    WaitSeconds(1)
					
                end
				
            end
        )
		
        self:ForkThread(AnimationThread,{
            {
                'Xband_Base',
                'Xband_Dish',
                bounds = {-180,180,-90,0,},
                speed = 3,
            },
            {
                'Tiny_Dish_00',
                c = 2,
                cont = true
            },
            {
                'Small_XBand_Stand_00',
                'Small_XBand_Dish_00',
                c = 4,
                bounds = {-180,180,-90,0,},
            },
            {
                'Small_Dish_00',
                'Small_Dish_00',
                c = 4,
                bounds = {-180,180,-90,90,},
                speed = 20,
            },
            {
                'Med_Dish_Stand_00',
                'Med_Dish_00',
                c = 4,
                bounds = {-180,180,-90,90,},
                speed = 6,
            },
            {
                'Large_Dish_Base',
                'Large_Dish',
                bounds = {-180,180,-90,0,},
                speed = 2,
            },
        })
		
        for i, v in {{'Panopticon','Domes'},{'Large_Dish','Dish_Scaffolds'}} do
		
            local entity = import('/lua/sim/Entity.lua').Entity({Owner = self,})
			
            entity:AttachBoneTo( -1, self, v[1] )
            entity:SetMesh(import( '/lua/game.lua' ).BrewLANPath() .. '/units/SEB3404/SEB3404_' .. v[2] .. '_mesh')
            entity:SetDrawScale(self:GetBlueprint().Display.UniformScale)
            entity:SetVizToAllies('Intel')
            entity:SetVizToNeutrals('Intel')
            entity:SetVizToEnemies('Intel')
			
            self.Trash:Add(entity)
        end
    end,

    IntelSearch = function(self, aiBrain)

		local function FindAllUnits( aiBrain, category, range, cloakcheck )
	
			local Ftable = {}
		
			for i, unit in aiBrain:GetUnitsAroundPoint(category, self:GetPosition(), range, 'Enemy' ) do
		
				if cloakcheck and unit:IsIntelEnabled('Cloak') then
					--LOG("Counterintel guy")
				else
					table.insert(Ftable, unit)
				end
			
			end
		
			return Ftable
			
		end
		
        local maxrange = self:GetIntelRadius('radar') or self:GetBlueprint().Intel.RadarRadius or 6000
		
        -- Find visible things to attach vis entities to
        local LocalUnits = FindAllUnits( aiBrain, categories.SELECTABLE - categories.COMMAND - categories.SUBCOMMANDER - categories.ANTITELEPORT - categories.WALL - categories.HEAVYWALL - categories.MEDIUMWALL - categories.MINE, maxrange, true)
		
        ------------------------------------------------------------------------
        -- IF self.ActiveConsumptionRestriction Sort the table by distance
        ------------------------------------------------------------------------
        if self.ActiveConsumptionRestriction then
		
            local DistanceSortedLocalUnits = {}
			
            for i, v in LocalUnits do
			
                local uniqueDistanceKey = math.floor(VDist2Sq(v:GetPosition()[1], v:GetPosition()[3], self:GetPosition()[1], self:GetPosition()[3]) ) .. "." .. v:GetEntityId()
				
                DistanceSortedLocalUnits[uniqueDistanceKey] = v
                v = nil
            end
			
            LocalUnits = DistanceSortedLocalUnits
			
        end
		
        ------------------------------------------------------------------------
        -- Calculate the overall cost and cut off point for the energy restricted radius
        ------------------------------------------------------------------------
		local Eco = self:GetBlueprint().Economy
		
        local NewUpkeep = Eco.MaintenanceConsumptionPerSecondEnergy
		
		local MinimumPerBuilding = Eco.MinimumPerBuilding or 75
		local MaximumPerBuilding = Eco.MaximumPerBuilding or 500
		
		local MinimumPerMobile = Eco.MinimumPerMobile or 50
		local MaximumPerMobile = Eco.MaximumPerMobile or 600
		
		local SpyBlipRadius = self:GetBlueprint().Intel.SpyBlipRadius or 2
		
        local SpareEnergy = self:GetAIBrain():GetEconomyIncome( 'ENERGY' ) - self:GetAIBrain():GetEconomyRequested('ENERGY') + self.PanopticonUpkeep
		
        for i, v in LocalUnits do

            --Calculate costs per unit as we go
            local ebp = v:GetBlueprint().Economy
            local cost
			
            if string.lower(ebp.Physics.MotionType or 'NOPE') == string.lower('RULEUMT_None') then
			
                --If building cost
                cost = math.min( math.max( (ebp.BuildCostEnergy or 10000) / 1000, MinimumPerBuilding), MaximumPerBuilding)
                LocalUnits[i].cost = cost
				
            else
			
                --If mobile cost
                cost = math.min( math.max( (ebp.BuildCostEnergy or 10000) / 500, MinimumPerMobile), MaximumPerMobile)
                LocalUnits[i].cost = cost
				
            end

            --Do things with those calculated costs
            if self.ActiveConsumptionRestriction and NewUpkeep + cost > SpareEnergy then
			
                if i == 1 then
                    NewUpkeep = Eco.MaintenanceConsumptionPerSecondEnergy
                end

                break
				
            else
			
                NewUpkeep = NewUpkeep + cost
				
                self:AttachVisEntityToTargetUnit(v,SpyBlipRadius)

            end
        end
		
        self.PanopticonUpkeep = NewUpkeep
		
        self:SetMaintenanceConsumptionActive()
        self:SetEnergyMaintenanceConsumptionOverride(self.PanopticonUpkeep)
		
    end,

    AttachVisEntityToTargetUnit = function(self, unit, SpyBlipRadius)
	
        local location = unit:GetPosition()

		if not TeleportLocationBlocked( self, location ) then
		
			local spec = {
				X = location[1],
				Z = location[3],
				Radius = SpyBlipRadius,
				LifeTime = 1,
				Omni = false,
				Radar = false,
				Vision = true,
				Army = self:GetAIBrain():GetArmyIndex(),
			}
		
			local visentity = VizMarker(spec)
		
			visentity:AttachTo(unit, -1)
			
		end
		
    end,

    OnScriptBitSet = function(self, bit)
	
        TStructureUnit.OnScriptBitSet(self, bit)
		
        if bit == 1 then
            self.ActiveConsumptionRestriction = false
        end
		
    end,


    OnScriptBitClear = function(self, bit)
	
        TStructureUnit.OnScriptBitClear(self, bit)
		
        if bit == 1 then
            self.ActiveConsumptionRestriction = true
        end
		
    end,

    OnIntelDisabled = function(self)
	
        TStructureUnit.OnIntelDisabled(self)
        self.Intel = false
		
    end,

    OnIntelEnabled = function(self)
	
        TStructureUnit.OnIntelEnabled(self)
        self.Intel = true
		
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        TStructureUnit.OnKilled(self, instigator, type, overkillRatio)
		
    end,

    OnDestroy = function(self)
	
        TStructureUnit.OnDestroy(self)
		
    end,

    OnCaptured = function(self, captor)
	
        TStructureUnit.OnCaptured(self, captor)
		
    end,
}

TypeClass = SEB3404
