-- Transportutilities.lua --
-- This module is a core module of The LOUD Project and the work in it, is a creative work of Alexander W.G. Brown
-- Please feel free to use it, but please respect and preserve all the 'LOUD' references within

--- HOW IT WORKS --
-- By creating a 'pool' (TransportPool) just for transports - we can quickly find - and assemble - platoons of transports
-- A platoon of transports will be used to move platoons of units - the two entities remaining entirely separate from each other

-- Every transport created has a callback added that will return it back to the transport pool after a unit detach event
-- This 'ReturnTransportsToPool' process will separate out those which need fuel/repair - and return both groups to the nearest base
-- Transports which do not require fuel/repair are returned to the TransportPool
-- Transports which require fuel/repair will be assigned to the 'Refuel Pool' until that task is accomplished
-- The 'Refuel Pool' functionality (ProcessAirUnits) is NOT included in this module.  See LOUDUTILITIES for that.

local import = import

local loudUtils = import('/lua/loudutilities.lua')

local LOUDCOPY      = table.copy
local LOUDENTITY    = EntityCategoryContains
local LOUDFLOOR     = math.floor
local LOUDGETN      = table.getn
local LOUDINSERT    = table.insert
local LOUDSORT      = table.sort

local ForkTo        = ForkThread
local tostring      = tostring
local type          = type
local VDist2        = VDist2
local VDist3        = VDist3
local WaitTicks     = coroutine.yield

local AssignUnitsToPlatoon  = moho.aibrain_methods.AssignUnitsToPlatoon
local GetListOfUnits        = moho.aibrain_methods.GetListOfUnits
local PlatoonExists         = moho.aibrain_methods.PlatoonExists

local GetFractionComplete   = moho.entity_methods.GetFractionComplete
local GetPosition           = moho.entity_methods.GetPosition

local GetPlatoonPosition    = moho.platoon_methods.GetPlatoonPosition
local GetPlatoonUnits       = moho.platoon_methods.GetPlatoonUnits
local GetSquadUnits         = moho.platoon_methods.GetSquadUnits

local GetFuelRatio      = moho.unit_methods.GetFuelRatio
local IsBeingBuilt      = moho.unit_methods.IsBeingBuilt
local IsIdleState       = moho.unit_methods.IsIdleState
local IsUnitState       = moho.unit_methods.IsUnitState

local AIRTRANSPORTS     = categories.AIR * categories.TRANSPORTFOCUS
local ENGINEERS         = categories.ENGINEER

-- this function will create the TransportPool platoon and put the reference to it in the brain
function CreateTransportPool( aiBrain )

    local TransportDialog = ScenarioInfo.TransportDialog or false
    
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." Creates TRANSPORTPOOL" )
    end

    local transportplatoon = aiBrain:MakePlatoon( 'TransportPool', 'none' )

    transportplatoon:UniquelyNamePlatoon('TransportPool') 
    transportplatoon.BuilderName = 'TPool'
    transportplatoon.UsingTransport = true      -- never review this platoon during a merge

	aiBrain.TransportPool = transportplatoon

end

-- This utility should get called anytime a transport is built or created
-- it will force the transport into the Transport pool & pass control over to the ReturnToPool function
-- it not already done so, it will create the callback that fires when a transport unloads any unit
function AssignTransportToPool( unit, aiBrain )

    if not aiBrain.TransportPool then
        CreateTransportPool( aiBrain)
    end

    local TransportDialog = ScenarioInfo.TransportDialog or false

    -- this sets up the OnTransportDetach callback so that this function runs EVERY time a transport drops units
	if not unit.EventCallbacks['OnTransportDetach'] then

		unit:AddUnitCallback( function(unit)
    
            if TransportDialog then
                LOG("*AI DEBUG TRANSPORT "..unit.PlatoonHandle.BuilderName.." Transport "..unit.EntityID.." Fires ReturnToPool callback" )
            end
	
			if LOUDGETN(unit:GetCargo()) == 0 then

				if unit.WatchUnloadThread then
					KillThread(unit.WatchUnloadThread)
					unit.WatchUnloadThread = nil
				end

				ForkTo( AssignTransportToPool, unit, aiBrain )

			end
            
		end, 'OnTransportDetach')

	end

    -- if the unit is not already in the transport Pool --
	if not unit.Dead and (not unit.PlatoonHandle != aiBrain.TransportPool) then
    
        if TransportDialog then
            LOG("*AI DEBUG TRANSPORT "..repr(unit.PlatoonHandle.BuilderName).." Transport "..unit.EntityID.." starts assigning to Transport Pool" )
        end

		IssueClearCommands( {unit} )

		-- if not in need of repair or fuel -- 
		if not loudUtils.ProcessAirUnits( unit, aiBrain ) then
            
            if aiBrain.TransportPool then
                AssignUnitsToPlatoon( aiBrain, aiBrain.TransportPool, {unit}, 'Support','')
            else
                return
            end

            unit.Assigning = false        

			unit.PlatoonHandle = aiBrain.TransportPool
            
            if not IsBeingBuilt(unit) then
                ForkTo( ReturnTransportsToPool, aiBrain, {unit}, true )
                return
            end
		end
        
	else
    
        if not unit.Dead and (not IsBeingBuilt(unit)) then
            LOG("*AI DEBUG "..aiBrain.Nickname.." Transport "..unit.EntityID.." already in Transport Pool")
        end
    end
    
    unit.InUse = false
    unit.Assigning = false    
    
    if TransportDialog then
        LOG("*AI DEBUG TRANSPORT "..repr(unit.PlatoonHandle.BuilderName).." Transport "..unit.EntityID.." now available to Transport Pool" )
    end

end

-- This utility will traverse all true transports to insure they are in the TransportPool
-- and a perfunctory cleanup on the path requests reply table for dead platoons
function CheckTransportPool( aiBrain )

    if not aiBrain.PathRequests then
        return
    end

    if not aiBrain.TransportPool then
        CreateTransportPool( aiBrain)
    end
    
    local TransportDialog = ScenarioInfo.TransportDialog or false
    
	local IsIdleState   = IsIdleState
    local PlatoonExists = PlatoonExists

    local ArmyPool = aiBrain.ArmyPool

    local RefuelPool    = aiBrain.RefuelPool or false
    local StructurePool = aiBrain.StructurePool or false
	local TransportPool = aiBrain.TransportPool
    
    local oldplatoonname, platoon

	-- get all idle, fully built transports except UEF gunship --
	local unitlist = GetListOfUnits( aiBrain, AIRTRANSPORTS - categories.uea0203, true, true)
	
	for k,v in unitlist do
    
        if v and v.PlatoonHandle == TransportPool then
            loudUtils.ProcessAirUnits( v, aiBrain )
        end
        
		if v and v.PlatoonHandle != TransportPool and v.PlatoonHandle != RefuelPool and GetFractionComplete(v) == 1 then
		
			platoon = v.PlatoonHandle or false
			oldplatoonname = false
			
			if platoon then
				oldplatoonname = platoon.BuilderName or false
			end
			
			if (not IsIdleState(v)) or v.InUse or v.Assigning or (platoon and PlatoonExists(aiBrain,platoon)) then
			
				if not IsIdleState(v) then
					continue
				end
				
				if platoon.CreationTime and (aiBrain.CycleTime - platoon.CreationTime) < 360 then
					continue
				end
			end
			
			IssueClearCommands( {v} )
			
			if v.WatchLoadingThread then
            
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Killing Watch Loading thread - transport "..v.EntityID.." in CheckTransportPool")
                end
                
				KillThread(v.WatchLoadingThread)
				v.WatchLoadingThread = nil
			end
			
			if v.WatchTravelThread then
            
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Killing Watch Travel thread - transport "..v.EntityID.." in CheckTransportPool")
                end            

				KillThread(v.WatchTravelThread)
				v.WatchTravelThread = nil
			end
			
			if platoon and PlatoonExists(aiBrain,platoon) then
			
				if platoon != ArmyPool and platoon != RefuelPool and platoon != StructurePool then
				
					aiBrain:DisbandPlatoon(platoon)
				end
			end

            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Assigning Transport "..v.EntityID.." to Pool in CheckTransportPool")
            end
            
			ForkTo( AssignTransportToPool, v, aiBrain )

        end
	end
	
	aiBrain.CheckTransportPoolThread = nil

    -- this loop just clears the reply queue of pathfinding replies
    -- I know - this isn't the most suitable place for this function
    
    local gametime = LOUDFLOOR(GetGameTimeSeconds())

    for k,v in aiBrain.PathRequests['Replies'] do

        if ((not type(k)=='string') and not PlatoonExists( aiBrain, k )) or (k.CreationTime and (gametime > k.CreationTime + 180)) then
        
            aiBrain.PathRequests['Replies'][k] = nil
        end
    end
    
end

-- This function attempts to locate the required number of transports to move the platoon.
-- if insufficient transport available, the brain is marked with needing to build more transport
-- restricts the use of out/low fuel transports and to keep transports moving back to a base when not in use
-- Will now also limit transport selection to those within 16 km
function GetTransports( platoon, aiBrain)

    if platoon.UsingTransport then
        return false, false, 0
    end
    
    if not aiBrain.TransportPool then
        CreateTransportPool(aiBrain)
    end

	local IsEngineer = platoon:PlatoonCategoryCount( ENGINEERS ) > 0
    
    local TransportDialog = ScenarioInfo.TransportDialog or false

	-- GATHER PHASE -- gather info on all available transports
    
	local Special = false
	
	if aiBrain.FactionIndex == 1 then
		Special = true      -- notes if faction has 'special' transport units - ie. UEF T2 gunship
	end
	
    local transportpool = aiBrain.TransportPool
	local armypool = aiBrain.ArmyPool
	
	local armypooltransports = {}
	local TransportPoolTransports = false
	
	-- build table of transports to use
    -- engineers - only use T1/T2 - T3 is not permitted for them
	if IsEngineer then
		TransportPoolTransports = EntityCategoryFilterDown( AIRTRANSPORTS - categories.TECH3 - categories.EXPERIMENTAL, GetPlatoonUnits(transportpool) )
    else
		TransportPoolTransports = EntityCategoryFilterDown( AIRTRANSPORTS, GetPlatoonUnits(transportpool) )
    end
    
	-- get special transports from the army pool
	if Special then
		armypooltransports = EntityCategoryFilterDown( categories.uea0203, GetPlatoonUnits(armypool) )
	end
    
    -- if there are no transports available at all - we're done
    if (armypooltransports and LOUDGETN(armypooltransports) < 1) and (TransportPoolTransports and LOUDGETN(TransportPoolTransports) < 1) then
    
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." no transports available")
        end
    
        aiBrain.NeedTransports = true   -- turn on need flag

        return false, false, 0
    end


    -- REQUIREMENT PHASE - determine what transports are required to move the unit platoon
    
	local CanUseTransports = false 	-- used to indicate if units in the platoon can actually use transports

    -- this is a table of 'slots' required
	local neededTable = { Small = 0, Medium = 0, Large = 0, Total = 0 }
	
    -- loop thru the unit platoon and summarize the number of slots required 
    -- take into account the flex of slots required - so larger units add extra Small/Medium requirements
    -- this sometimes means we'll select one extra transport above what we may actually need but we're never short
	for _, v in GetPlatoonUnits(platoon) do
	
		if v and not v.Dead then
			
			if v.TransportClass == 1 then
				CanUseTransports = true
				neededTable.Small = neededTable.Small + 1.0
                neededTable.Total = neededTable.Total + 1
				
			elseif v.TransportClass == 2 then
				CanUseTransports = true
				neededTable.Small = neededTable.Small + 0.34
				neededTable.Medium = neededTable.Medium + 1.0
                neededTable.Total = neededTable.Total + 1                    
				
			elseif v.TransportClass == 3 then
                CanUseTransports = true
				neededTable.Small = neededTable.Small + 0.5
				neededTable.Medium = neededTable.Medium + 0.25
				neededTable.Large = neededTable.Large + 1.0
                neededTable.Total = neededTable.Total + 1

			else
				LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." during GetTransports - "..v:GetBlueprint().Description.." has no TransportClass value")
			end
		end	
	end

    if not CanUseTransports then
    
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." no units in platoon can use transports")
        end
        
        return false, false, 0
    end
    
    
    -- COLLECTION PHASE - collect and count available transports

    local GetPlatoonPosition = GetPlatoonPosition
	local LOUDCOPY = LOUDCOPY
	local LOUDENTITY = LOUDENTITY
    local VDist2 = VDist2
	local WaitTicks = WaitTicks
    
	platoon.UsingTransport = true	-- this will keep the platoon from doing certain things while it's looking for transport
	
	-- OK - so we now have 2 lists of units and we want to make sure the 'specials' get utilized first
	-- so we'll add the specials to the Available list first, and then the standard ones
	-- in this way, the specials will get utilized first, making good use of both the UEF T2 gunship
	-- and the Cybran Gargantuan, if available
	local AvailableTransports = {}
    local transportcount = 0

    -- if the unit platoon is still available collect a list of all available transports
	if PlatoonExists(aiBrain,platoon) then
    
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." getting available transports")
        end

        -- move upto 15 army pool transports into the transport pool
		if armypooltransports[1] then

			for _,trans in armypooltransports do
            
                if IsBeingBuilt(trans) then
                    continue
                end
			
				if not trans.InUse then
                
                    if not trans.Assigning then
                    
                        transportcount = transportcount + 1				
                        AvailableTransports[transportcount] = trans

                        -- this puts specials into the transport pool -- occurs to me that they
                        -- may get stuck in here if it turns out we cant use transports
                        AssignUnitsToPlatoon( aiBrain, transportpool, {trans}, 'Support','none')
                    
                        -- limit collection of armypool transports to 15
                        if transportcount == 15 then
                            break
                        end
                    end
                    
				else
                    if TransportDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..trans.EntityID.." in ArmyPool in Use or Assigning during collection")
                    end
                end
			end
		end

        -- count the total number of transports now fully available
		if TransportPoolTransports[1] then

			for _,trans in TransportPoolTransports do
            
                if IsBeingBuilt(trans) then
                    continue
                end
                
				if not trans.InUse then
                
                    if not trans.Assigning then
                
                        transportcount = transportcount + 1
                        AvailableTransports[transportcount] = trans

                    end
                    
				else
                
                    if TransportDialog then
                    
                        if trans.InUse then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..trans.EntityID.." in Use during collection")
                        end
                        if trans.Assigning then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..trans.EntityID.." Assigning during collection")
                        end
                        
                    end
                end
			end
		end

	end
	
    -- we no longer need the source lists
	armypooltransports = nil
	TransportPoolTransports = nil

    -- the platoon may have died while we did all this
	local location = false
	
    -- recheck the platoon again and store it's location
    -- if no location then platoon may be dead/disbanded
	if PlatoonExists(aiBrain,platoon) then
		
		for _,u in GetPlatoonUnits(platoon) do
			if not u.Dead then
                location = LOUDCOPY(GetPlatoonPosition(platoon))
                break
			end
		end
	end	
	
	-- if we cant find any transports or platoon has no location - exit
	if transportcount < 1 or not location then

		if not location then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." finds no platoon position")
            end
            
       		if transportcount > 0 then
                -- send all transports back into pool - which covers the specials (ie. UEF Gunships) 
                ForkThread( ReturnTransportsToPool, aiBrain, AvailableTransports, true )
            end
		end

		if transportcount < 1 then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." no transports available")
            end
            
            aiBrain.NeedTransports = true
        end

		platoon.UsingTransport = false
		
		return false, false, 0
	end

	
	-- Returns the number of slots the transport has available
	-- Originally, this function just counted the number of attachpoint bones of each size on the model
	-- however, this does not seem to work correctly - ie. UEF T3 Transport
	-- says it has 12 Large Attachpoints but will only carry 8 large units
	-- so I replaced that with some hardcoded values to improve performance, as each new transport
	-- unit comes into play, I'll cache those values on the brain so I never have to look them up again
	-- setup global table to contain Transport values - in this way we always have a reference to them
	-- without having to reread the bones or do all the EntityCategory checks from below
	local function GetNumTransportSlots( unit )
	
		if not aiBrain.TransportSlotTable then
			aiBrain.TransportSlotTable = {}
		end
	
		local id = unit.BlueprintID
	
		if aiBrain.TransportSlotTable[id] then
	
			return aiBrain.TransportSlotTable[id]
		
		else
	
			local EntityCategoryContains = EntityCategoryContains
	
			local bones = { Large = 0, Medium = 0, Small = 0,}
	
			if EntityCategoryContains( categories.xea0306, unit) then
				bones.Large = 8
				bones.Medium = 10
				bones.Small = 24

			elseif EntityCategoryContains( categories.uea0203, unit) then
				bones.Large = 0
				bones.Medium = 1
				bones.Small = 1
			
			elseif EntityCategoryContains( categories.uea0104, unit) then
				bones.Large = 3
				bones.Medium = 6
				bones.Small = 14
			
			elseif EntityCategoryContains( categories.uea0107, unit) then
				bones.Large = 1
				bones.Medium = 2
				bones.Small = 6
			
			elseif EntityCategoryContains( categories.uaa0107, unit) then
				bones.Large = 1
				bones.Medium = 3
				bones.Small = 6

			elseif EntityCategoryContains( categories.uaa0104, unit) then
				bones.Large = 3
				bones.Medium = 6
				bones.Small = 12
		
			elseif EntityCategoryContains( categories.ura0107, unit) then
				bones.Large = 1
				bones.Medium = 2
				bones.Small = 6

			elseif EntityCategoryContains( categories.ura0104, unit) then
				bones.Large = 2
				bones.Medium = 4
				bones.Small = 10
		
			elseif EntityCategoryContains( categories.xsa0107, unit) then
				bones.Large = 1
				bones.Medium = 4
				bones.Small = 8

			elseif EntityCategoryContains( categories.xsa0104, unit) then
				bones.Large = 4
				bones.Medium = 8
				bones.Small = 16
		
			-- BO Aeon transport
			elseif bones.Small == 0 and (categories.baa0309 and EntityCategoryContains( categories.baa0309, unit)) then
				bones.Large = 6
				bones.Medium = 10
				bones.Small = 16
		
			-- BO Cybran transport
			elseif bones.Small == 0 and (categories.bra0309 and EntityCategoryContains( categories.bra0309, unit)) then
				bones.Large = 3
				bones.Medium = 12
				bones.Small = 14
			
			-- BrewLan Cybran transport
			elseif bones.Small == 0 and (categories.sra0306 and EntityCategoryContains( categories.sra0306, unit)) then
				bones.Large = 4
				bones.Medium = 8
				bones.Small = 16
		
			-- Gargantua
			elseif bones.Small == 0 and (categories.bra0409 and EntityCategoryContains( categories.bra0409, unit)) then
				bones.Large = 20
				bones.Medium = 4
				bones.Small = 4
		
			-- BO Sera transport
			elseif bones.Small == 0 and (categories.bsa0309 and EntityCategoryContains( categories.bsa0309, unit)) then
				bones.Large = 8
				bones.Medium = 10
				bones.Small = 28

			-- BrewLAN Seraphim transport
			elseif bones.Small == 0 and (categories.ssa0306 and EntityCategoryContains( categories.ssa0306, unit)) then
				bones.Large = 7
				bones.Medium = 15
				bones.Small = 32
				
			end
		
			aiBrain.TransportSlotTable[id] = bones

			return bones
		end
	end
    

    -- ASSIGNMENT PHASE - assign transports to the task until the requirements are met
	
	-- we'll accumulate the slots from transports as we assign them
	-- this will allow us to save a bunch of effort if we simply dont have enough transport capacity

	local GetFuelRatio  = GetFuelRatio
	local GetPosition   = GetPosition
	local IsBeingBuilt  = IsBeingBuilt
    local IsUnitState   = IsUnitState	

    -- this flag signifies the end of the assignment phase when we have enough transports to do the job
    -- if we cannot fulfill a request for transports then the brain is marked as needing to build transport
	CanUseTransports = false

	local Collected         = { Large = 0, Medium = 0, Small = 0 }
    local counter           = 0
    local FuelRequired      = .5
    local HealthRequired    = .7
	local out_of_range      = false
    local transports        = {}			-- this will hold the data for all of the eligible transports    

    local id, range, unitPos

	-- loop thru all transports and filter out those that dont pass muster
	for k,transport in AvailableTransports do
    
        -- we have enough transport collected
        if CanUseTransports then
            break
        end
		
		if not transport.Dead then
            
			-- use only those that are not in use, not attached, not being built and have > 50% fuel and > 70% health
			if (not transport.InUse) and (not transport.Attached) and (not transport.Assigning) and (not IsBeingBuilt(transport)) and ( GetFuelRatio(transport) == -1 or GetFuelRatio(transport) > FuelRequired) and transport:GetHealthPercent() > HealthRequired  then
            
				-- use only those which are not already busy or are not loading already
				if (not IsUnitState( transport, 'Busy')) and (not IsUnitState( transport, 'TransportLoading')) then

					-- deny use of T1 transport to platoons needing more than 1 large transport
					if (not IsEngineer) and LOUDENTITY( categories.TECH1, transport ) and neededTable.Large > 1 then
					
						continue
						
					-- insert available transport into list of usable transports
					else
					
						unitPos = GetPosition(transport)
						range = VDist2( unitPos[1],unitPos[3], location[1], location[3] )

						-- limit to 12 km range if air ratio is low - 16 km if normal
                        -- this insures that transport wont expire before loading takes place as loading has a 120 second time limit --
						if range < 600 + ( 200 * (math.min( 1, aiBrain.AirRatio ))) then
                            
                            -- mark the transport as being assigned 
                            -- to prevent it from being picked up in another transport collection
                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..transport.EntityID.." marked for assignment")
                            end
                            
                            transport.Assigning = true
			
							id = transport.BlueprintID

                            -- add the transports slots to the collected table
							if not aiBrain.TransportSlotTable[id] then
								GetNumTransportSlots( transport )
							end

							counter = counter + 1
							transports[counter] = { Unit = transport, Distance = range, Slots = LOUDCOPY(aiBrain.TransportSlotTable[id]) }

							Collected.Large = Collected.Large + transports[counter].Slots.Large
							Collected.Medium = Collected.Medium + transports[counter].Slots.Medium
							Collected.Small = Collected.Small + transports[counter].Slots.Small

							-- if we have enough collected capacity for each type then CanUseTransports is true which will break us out of collection
							if Collected.Large >= neededTable.Large and Collected.Medium >= neededTable.Medium and Collected.Small >= neededTable.Small then
								CanUseTransports = true
							end

						else
                        
                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..transport.EntityID.." rejected - out of range at "..range.." maximum range is "..repr(600 + ( 200 * (math.min( 1, aiBrain.AirRatio )))) )
                            end
                            
							out_of_range = true
						end
					end
				end
                
			else
            
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..transport.EntityID.." rejected - Attached "..repr(transport.Attached).." - In Use "..repr(transport.InUse).." - Assigning "..repr(transport.Assigning).." - BeingBuilt "..repr(IsBeingBuilt(transport)).." - Low Fuel/Health "..GetFuelRatio(transport).."/"..transport:GetHealthPercent() )
                end
                
                if not transport.Dead then
                    ForkThread( ReturnTransportsToPool, aiBrain, {transport}, true )
                end

                AvailableTransports[k] = nil
            end
		end
        
	end

	if not CanUseTransports then
	
		if not out_of_range then

			-- let the brain know we couldn't fill a transport request by a ground platoon
			aiBrain.NeedTransports = true

		end
        
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." unable to locate enough transport")
        end
		
        AvailableTransports = aiBrain:RebuildTable(AvailableTransports)
        
		-- send all transports back into pool - which covers the specials (ie. UEF Gunships) 
		ForkThread( ReturnTransportsToPool, aiBrain, AvailableTransports, true )
		
		platoon.UsingTransport = false
		
        return false, false, 0
	end
	
	Collected = nil
	
	-- ASSIGNMENT PHASE -- 
	-- at this point we have a list of all the eligible transports in range in the TRANSPORTS table
	AvailableTransports = nil	-- we dont need this anymore
	
	local transportplatoon = false
    local transportplatoonairthreat = 0
	
    if CanUseTransports and counter > 0 then
	
		CanUseTransports = false
		counter = 0
		
		-- sort the available transports by range --
		LOUDSORT(transports, function(a,b) return a.Distance < b.Distance end )
        
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." assigning units to transports")
        end
		
        -- loop thru the transports and assess how many units of each size can be carried
		-- assign each transport to the transport platoon until the needs are filled
		-- after that, mark each remaining transport as not InUse
        for _,v in transports do
		
			local transport = v.Unit
			local AvailableSlots = v.Slots

			-- if we still need transport capacity and this transport is in the Transport or Army Pool
            if not transport.Dead and (not CanUseTransports) and (transport.PlatoonHandle == aiBrain.TransportPool or transport.PlatoonHandle == aiBrain.ArmyPool ) then
			
				-- mark the transport as InUse
				transport.InUse = true
			
				-- create a platoon for the transports
				if not transportplatoon then
				
					local ident = Random(10000,99999)
					transportplatoon = aiBrain:MakePlatoon('TransportPlatoon '..tostring(ident),'none')

					transportplatoon.PlanName = 'TransportUnits '..tostring(ident)
					transportplatoon.BuilderName = 'Load and Transport '..tostring(ident)
                    transportplatoon.UsingTransport = true      -- keep this platoon from being reviewed in a merge
                    
                    if TransportDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." "..transportplatoon.BuilderName.." created for service ")
                    end
				end
				
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." "..transportplatoon.BuilderName.." adds transport "..transport.EntityID)
                end
		
				-- count the number of transports used
				counter = counter + 1
                
				AssignUnitsToPlatoon( aiBrain, transportplatoon, {transport}, 'Support', 'BlockFormation')
                
                transportplatoonairthreat = transportplatoonairthreat + math.max( 4.2, __blueprints[transport.BlueprintID].Defense.AirThreatLevel or 1)

				IssueClearCommands({transport})
				
				--transport:SetCustomName(transportplatoon.PlanName)
				
				IssueMove( {transport}, location )

                while neededTable.Large >= 1 and AvailableSlots.Large >= 1 do
				
                    neededTable.Large = neededTable.Large - 1.0
					
                    AvailableSlots.Large = AvailableSlots.Large - 1.0
					AvailableSlots.Medium = AvailableSlots.Medium - 0.25
                    AvailableSlots.Small = AvailableSlots.Small - 0.34
				end
				
                while neededTable.Medium >= 1 and AvailableSlots.Medium >= 1 do
				
                    neededTable.Medium = neededTable.Medium - 1.0
					
                    AvailableSlots.Medium = AvailableSlots.Medium - 1.0
					AvailableSlots.Small = AvailableSlots.Small - 0.34
                end
				
                while neededTable.Small >= 1 and AvailableSlots.Small >= 1 do
				
                    neededTable.Small = neededTable.Small - 1.0
					
					if Special then
						AvailableSlots.Medium = AvailableSlots.Medium - .10 -- yes .1 so that UEF Gunship wont be able to carry more than 1 unit
					end
					
                    AvailableSlots.Small = AvailableSlots.Small - 1.0
                end
				
				-- if no more slots are needed signal that we have all the transport we require
                if neededTable.Small < 1 and neededTable.Medium < 1 and neededTable.Large < 1 then
                    CanUseTransports = true
                end
			end
            
            -- mark each transport (used or not) as no longer in Assignment
            transport.Assigning = false
        end
    end
    
    local location = false

	-- one last check for the validity of both unit and transport platoons
	if CanUseTransports and counter > 0 then

		if PlatoonExists(aiBrain, platoon) then
			
			for _,u in GetPlatoonUnits(platoon) do
			
				if not u.Dead then
                    location = LOUDCOPY(GetPlatoonPosition(platoon))
                    break
				end
			end

		end

		if not transportplatoon or not location then
		
            if TransportDialog then
            
                if not transportplatoon then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport platoon dead after assignmnet "..repr(transportplatoon))
                else
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." unit platoon dead after assignment ")
                end
            end
			
			CanUseTransports = false
		end
	end
	
	transports = nil
	
	-- if we need more transport then fail (I no longer permit partial transportation)
	-- or if some other situation (dead units) -- send the transports back to the pool
    -- otherwise assign 1 scout and upto 3 fighters per transport
    if not CanUseTransports or not location then

		if transportplatoon then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." cannot be serviced by "..transportplatoon.BuilderName.." returning transports to pool" )
            end
            
            for _,transport in GetPlatoonUnits(transportplatoon) do
                
                if not transport.Dead then
                    -- and return it to the transport pool
                    ForkTo( ReturnTransportsToPool, aiBrain, {transport}, true )
                end
            end
		end

		platoon.UsingTransport = false
		
        return false, false, 0
    else
		
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." "..transportplatoon.BuilderName.." authorized "..counter.." transports for use" )
        end
        
        if aiBrain.ArmyPool:PlatoonCategoryCount( categories.AIR * categories.SCOUT ) > 0 then
        
            for k,v in EntityCategoryFilterDown( categories.SCOUT, aiBrain.ArmyPool:GetPlatoonUnits() ) do
            
                if v:GetFractionComplete() == 1 and v.PlatoonHandle == aiBrain.ArmyPool and VDist3( GetPosition(v), location ) < 100 then
            
                    IssueGuard( {v}, location )

                    aiBrain:AssignUnitsToPlatoon( transportplatoon, {v}, 'Scout', 'none' )
		
                    if TransportDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." "..transportplatoon.BuilderName.." assigned a scout from pool")
                    end

                    break
                    
                end
                
            end

        end

        return counter, transportplatoon, transportplatoonairthreat
    end
	
end

-- whenever the AI cannot find enough transports to move a platoon it sets a value on the brain indicating that need
-- this function is run whenever a factory responds to that need and starts building them - clearing the need flag
function ResetBrainNeedsTransport( aiBrain )
    aiBrain.NeedTransports = nil
end

--  This routine should get transports on the way back to an existing base 
--  BEFORE marking them as not 'InUse' and adding them to the Transport Pool
function ReturnTransportsToPool( aiBrain, units, move )

    local TransportDialog = ScenarioInfo.TransportDialog or false
    
    local RandomLocation = import('/lua/ai/aiutilities.lua').RandomLocation

    local VDist3 = VDist3
    
    local unitcount = 0

    local baseposition, reason, returnpool, safepath, unitposition

    -- cycle thru the transports, insure unloaded and assign to correct pool
    for k,v in units do

        if IsBeingBuilt(v) then     -- ignore under construction
            units[v] = nil
            continue
        end

        if not v.Dead and TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." transport "..v.EntityID.." "..v:GetBlueprint().Description.." Returning to Pool  InUse is "..repr(v.InUse) )
        end
    
        if v.WatchLoadingThread then
            KillThread( v.WatchLoadingThread)
            v.WatchLoadingThread = nil
        end
        
        if v.WatchTravelThread then
            KillThread( v.WatchTravelThread)
            v.WatchTravelThread = nil
        end
        
        if v.WatchUnloadThread then
            KillThread( v.WatchUnloadThread)
            v.WatchUnloadThread = nil
        end
        
        if v.Dead then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." transport "..v.EntityID.." dead during Return to Pool")
            end
            
            units[v] = nil
            continue
        end
        
        unitcount = unitcount + 1

		-- unload any units it might have and process for repair/refuel
		if EntityCategoryContains( AIRTRANSPORTS + categories.uea0203, v ) then

            if LOUDGETN(v:GetCargo()) > 0 then

                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." transport "..v.EntityID.." has unloaded units")
                end
				
                local unloadedlist = v:GetCargo()
				
                IssueTransportUnload(v, v:GetPosition())
				
                WaitTicks(3)
				
                for _,unloadedunit in unloadedlist do
                    ForkTo( ReturnUnloadedUnitToPool, aiBrain, unloadedunit )
                end
            end

            v.InUse = false

            v.Assigning = nil

            -- if the transport needs refuel/repair - remove it from further processing
            if loudUtils.ProcessAirUnits( v, aiBrain) then
                units[k] = nil
            end
        end
        
    end

    -- process whats left, getting them moving, and assign back to correct pool
	if unitcount > 0 and move then

		units = aiBrain:RebuildTable(units)     -- remove those sent for repair/refuel 

		for k,v in units do
		
			if v and not v.Dead and (not v.InUse) and (not v.Assigning) then

                returnpool = aiBrain:MakePlatoon('TransportRTB'..tostring(v.EntityID), 'none')
                
                returnpool.BuilderName = 'TransportRTB'..tostring(v.EntityID)
                returnpool.PlanName = returnpool.BuilderName

                AssignUnitsToPlatoon( aiBrain, returnpool, {v}, 'Unassigned', '')
                
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..returnpool.BuilderName.." Transport "..v.EntityID.." assigned" )
                end

                v.PlatoonHandle = returnpool
                
                unitposition = v:GetPosition()

                baseposition = import('/lua/loudutilities.lua').AIFindClosestBuilderManagerPosition( aiBrain, unitposition)

                if baseposition then
                    x = baseposition[1]
                    z = baseposition[3]
                else
                    return
                end

                baseposition = RandomLocation(x,z)

                IssueClearCommands( {v} )

                if VDist3( baseposition, unitposition ) > 100 then

                    -- this requests a path for the transport with a threat allowance of 20 - which is kinda steep sometimes
                    safePath, reason = returnpool.PlatoonGenerateSafePathToLOUD(aiBrain, returnpool, 'Air', unitposition, baseposition, 20, 256)

                    if safePath then

                        if TransportDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..returnpool.BuilderName.." Transport "..v.EntityID.." gets RTB path of "..repr(safePath))
                        end

                        -- use path
                        for _,p in safePath do
                            IssueMove( {v}, p )
                        end
                    else
                        if TransportDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..returnpool.BuilderName.." Transport "..v.EntityID.." no safe path for RTB -- home -- after drop - going direct")
                        end

                        -- go direct -- possibly bad
                        IssueMove( {v}, baseposition )
                    end
                else
                    IssueMove( {v}, baseposition)
                end

				-- move the unit to the correct pool - pure transports to Transport Pool
				-- all others -- including temporary transports (UEF T2 gunship) to Army Pool
				if not v.Dead then
				
					if LOUDENTITY( AIRTRANSPORTS - categories.uea0203, v ) then
                    
                        if v.PlatoonHandle != aiBrain.TransportPool then
                            
                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..v.PlatoonHandle.BuilderName.." transport "..v.EntityID.." now in the Transport Pool  InUse is "..repr(v.InUse))
                            end

                            AssignUnitsToPlatoon( aiBrain, aiBrain.TransportPool, {v}, 'Support', '' )

                            v.PlatoonHandle = aiBrain.TransportPool
                            v.InUse = false
                            v.Assigning = false                            
                        end
					else
                    
                        if TransportDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..v.PlatoonHandle.BuilderName.." assigned unit "..v.EntityID.." attached "..repr(v.Attached).." to the Army Pool on tick "..GetGameTick() )
                        end
                        
                        if v.Attached then
                            v:DetachFrom()
                        end

						AssignUnitsToPlatoon( aiBrain, aiBrain.ArmyPool, {v}, 'Unassigned', '' )

						v.PlatoonHandle = aiBrain.ArmyPool
       					v.InUse = false
                        v.Assigning = false
					end
				end

			end

		end
	end
	
	if not aiBrain.CheckTransportPoolThread then
		aiBrain.CheckTransportPoolThread = ForkThread( CheckTransportPool, aiBrain )
	end
end

-- This gets called whenever a unit failed to unload properly - rare
-- Forces the unload & RTB the unit
function ReturnUnloadedUnitToPool( aiBrain, unit )

	local attached = true
	
	if not unit.Dead then
	
		IssueClearCommands( {unit} )

		local ident = Random(1,999999)
		local returnpool = aiBrain:MakePlatoon('ReturnToPool'..tostring(ident), 'none')

		AssignUnitsToPlatoon( aiBrain, returnpool, {unit}, 'Unassigned', 'None' )
		returnpool.PlanName = 'ReturnToBaseAI'
		returnpool.BuilderName = 'FailedUnload'

		while attached and not unit.Dead do
			attached = false
            
            unit:SetFireState(0)
	
			if IsUnitState( unit, 'Attached') then
				attached = true
                WaitTicks(20)
			end

		end

		returnpool:SetAIPlan('ReturnToBaseAI', aiBrain )
	end
	
	return
end

-- Find enough transports and move the platoon to its destination 
    -- destination - the destination location
    -- attempts - how many tries will be made to get transport
    -- bSkipLastMove - make drop at closest safe marker rather than at destination
    -- platoonpath - source platoon can optionally feed it's current travel path in order to provide additional alternate drop points if the destination is not good
function SendPlatoonWithTransportsLOUD( self, aiBrain, destination, attempts, bSkipLastMove, platoonpath, AtGoalDistance )

    -- destination must be in playable areas --
    if not import('/lua/loudutilities.lua').BaseInPlayableArea(aiBrain, destination) or aiBrain:GetNoRushTicks() > 100 then
        return false
    end

    local TransportDialog = ScenarioInfo.TransportDialog or false

    local MovementLayer = self.MovementLayer    

	if MovementLayer == 'Land' or MovementLayer == 'Amphibious' then
		
		local AIGetMarkersAroundLocation    = import('/lua/ai/aiutilities.lua').AIGetMarkersAroundLocation

        local GetPlatoonPosition            = GetPlatoonPosition
        local GetPlatoonUnits               = GetPlatoonUnits
        local GetSurfaceHeight              = GetSurfaceHeight
        local GetTerrainHeight              = GetTerrainHeight

        local CalculatePlatoonThreat    = moho.platoon_methods.CalculatePlatoonThreat
        local GetThreatAtPosition       = moho.aibrain_methods.GetThreatAtPosition
		local GetUnitsAroundPoint       = moho.aibrain_methods.GetUnitsAroundPoint
        local PlatoonCategoryCount      = moho.platoon_methods.PlatoonCategoryCount

        local PlatoonExists = PlatoonExists

        local LOUDCAT   = table.cat
        local LOUDCOPY  = LOUDCOPY
        local LOUDEQUAL = table.equal
        local LOUDFLOOR = LOUDFLOOR
        local LOUDLOG10 = math.log10
        local VDist2Sq  = VDist2Sq
        local VDist3    = VDist3
        local WaitTicks = WaitTicks

        local surthreat = 0
        local airthreat = 0
        local counter = 0
		local bUsedTransports = false
		local transportplatoon = false
        local transportplatoonairthreat = 0

		local PlatoonGenerateSafePathToLOUD = self.PlatoonGenerateSafePathToLOUD            

		local IsEngineer = PlatoonCategoryCount( self, ENGINEERS ) > 0
        local HasExperimentals = PlatoonCategoryCount( self, categories.EXPERIMENTAL ) > 0

        local ALLUNITS  = categories.ALLUNITS
        local TESTUNITS = ALLUNITS - categories.FACTORY - categories.ECONOMIC - categories.SHIELD - categories.WALL

		local airthreat, airthreatMax, Defense, markerrange, mythreat, path, reason, pathlength, surthreat, transportcount,units, transportLocation

		-- prohibit LAND platoons from traveling to water locations or trying to transport T4 units
		if MovementLayer == 'Land' then

			if HasExperimentals or GetTerrainHeight(destination[1], destination[3]) < GetSurfaceHeight(destination[1], destination[3]) - 1 then 

                if TransportDialog then	
                    LOG("*AI DEBUG "..aiBrain.Nickname.." SendPlatWTrans "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." trying to go to WATER destination "..repr(destination) )
                end

				return false
			end
		end

		-- make the requested number of attempts to get transports - 12 second delay between attempts
		for counter = 1, attempts do
			
			if PlatoonExists( aiBrain, self ) then

				-- check if we can get enough transport and how many transports we are using
				-- this call will return the # of units transported (true) or false, if true, the self holding the transports or false
				bUsedTransports, transportplatoon, transportplatoonairthreat = GetTransports( self, aiBrain )
			
				if bUsedTransports or counter == attempts then
					break 
				end

				WaitTicks(120)
			end
		end

		-- if we didnt use transports
		if (not bUsedTransports) then

			if transportplatoon then
				ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
			end

			return false
		end
			
		-- a local function to get the real surface and air threat at a position based on known units rather than using the threat map
		-- we also pull the value from the threat map so we can get an idea of how often it's a better value
		-- I'm thinking of mixing the two values so that it will error on the side of caution
		local GetRealThreatAtPosition = function( position, range )
            
            local IMAPblocks = ScenarioInfo.IMAPBlocks or 1

            local sfake = GetThreatAtPosition( aiBrain, position, IMAPblocks, true, 'AntiSurface' )
			local afake = GetThreatAtPosition( aiBrain, position, IMAPblocks, true, 'AntiAir' )

            airthreat = 0
            surthreat = 0
			
			local eunits = GetUnitsAroundPoint( aiBrain, TESTUNITS, position, range,  'Enemy')
			
			if eunits then

				for _,u in eunits do

					if not u.Dead then

                        Defense = __blueprints[u.BlueprintID].Defense

                        airthreat = airthreat + Defense.AirThreatLevel
						surthreat = surthreat + Defense.SurfaceThreatLevel
					end
				end
            end

            -- if there is IMAP threat and it's greater than what we actually see
            -- use the sum of both * .5
			if sfake > 0 and sfake > surthreat then
				surthreat = (surthreat + sfake) * .5
			end

			if afake > 0 and afake > airthreat then
				airthreat = (airthreat + afake) * .5
			end

            return surthreat, airthreat

		end

		-- a local function to find an alternate Drop point which satisfies both transports and self for threat and a path to the goal
		local FindSafeDropZoneWithPath = function( self, transportplatoon, markerTypes, markerrange, destination, threatMax, airthreatMax, threatType, layer)

			local markerlist = {}
            local atest, stest
            local landpath,  landpathlength, landreason, lastlocationtested, path, pathlength, reason
	
			-- locate the requested markers within markerrange of the supplied location	that the platoon can safely land at
			for _,v in markerTypes do
				markerlist = LOUDCAT( markerlist, AIGetMarkersAroundLocation(aiBrain, v, destination, markerrange, 0, threatMax, 0, 'AntiSurface') )
			end

			-- sort the markers by closest distance to final destination
			LOUDSORT( markerlist, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq( a.Position[1],a.Position[3], destination[1],destination[3] ) < VDist2Sq( b.Position[1],b.Position[3], destination[1],destination[3] )  end )

			-- loop thru each marker -- see if you can form a safe path on the surface 
			-- and a safe path for the transports to get there -- use the first one that satisfies both
			for _, v in markerlist do

                if lastlocationtested and LOUDEQUAL(lastlocationtested, v.Position) then
                    continue
                end

                lastlocationtested = LOUDCOPY( v.Position )

				-- test the real values for that position
				stest, atest = GetRealThreatAtPosition( lastlocationtested, 80 )
			
                if TransportDialog then                    
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..transportplatoon.BuilderName.." examines position "..repr(v.Name).." "..repr(lastlocationtested).."  Surface threat "..stest.." -- Air threat "..atest)
                end
		
                if stest <= threatMax and atest <= airthreatMax then

                    landpath = false
                    landpathlength = 0

                    -- can the platoon path safely from this marker to the final destination 
					landpath, landreason, landpathlength = PlatoonGenerateSafePathToLOUD(aiBrain, self, layer, destination, lastlocationtested, threatMax, 160 )
	
					-- can the transports get to that point from where the platoon is now ?
					if landpath then
                        
                        path = false
                        pathlength = 0

                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, transportplatoon, 'Air', lastlocationtested, GetPlatoonPosition(self), airthreatMax, 256 )
						
						if path then

                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." gets path to "..repr(destination).." from landing at "..repr(lastlocationtested).." path length is "..pathlength.." using threatmax of "..threatMax)
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." path reason "..landreason.." route is "..repr(landpath))
                            end

                            return lastlocationtested, v.Name

						else

                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." got transports but they cannot find a safe drop point - reason "..repr(reason) )
                            end

                            if platoonpath and TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." has a path of it's own ")
                            end

                        end
					end

                    if platoonpath then
                        
                        lastlocationtested = false
                        
                        for k,v in platoonpath do
                            
                            stest, atest = GetRealThreatAtPosition( v, 80 )

                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." tests "..repr(v).." Surface "..stest.." - Max "..threatMax.."  Air "..atest.." - Max "..airthreatMax)
                            end

                            if stest <= threatMax and atest <= airthreatMax then
                                
                                lastlocationtested = LOUDCOPY(v)
                                
                            end

                        end

                        if lastlocationtested then
                            
                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." using platoon path position "..repr(v) )
                            end
                            
                            return lastlocationtested, 'booga'

                        end
                    end
                end
			end

			return false, nil
        end
	

		-- FIND A DROP ZONE FOR THE TRANSPORTS
		-- this is based upon the enemy threat at the destination and the threat of the unit platoon and the transport platoon

		-- a threat value for the transports based upon the number of transports (but not the tier...hmmm).
		transportcount = LOUDGETN( GetSquadUnits( transportplatoon, 'Support'))
		airthreatMax = transportcount * 4.2
		airthreatMax = airthreatMax + ( airthreatMax * LOUDLOG10(transportcount))
        
        --airthreatMax = transportplatoonairthreat

        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..transportplatoon.BuilderName.." with "..transportcount.." transports. AirthreatMax = "..string.format("%.2f",transportcount * 4.2).." extra calc was "..string.format("%.2f",LOUDLOG10(transportcount)).." suggested "..string.format("%.2f",transportplatoonairthreat) )
        end

		-- this is the desired drop location
		transportLocation = LOUDCOPY(destination)

		-- the threat of the unit platoon
		mythreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS)

		if not mythreat or mythreat < 5 then 
			mythreat = 5
		end

		-- get the real known threat at the destination within 80 grids
		surthreat, airthreat = GetRealThreatAtPosition( destination, 80 )

		-- if the destination doesn't look good, use alternate or false
		if surthreat > mythreat or airthreat > airthreatMax then

            -- if mythreat is sort of competitive with whats at the target
            if (mythreat * 1.25) > surthreat then

                -- look for a safe drop at least 50% closer to the destination than we currently are
                markerrange = VDist3( GetPlatoonPosition(self), destination ) * .5

                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." carried by "..transportplatoon.BuilderName.." seeking alternate landing zone within "..string.format("%d",markerrange).." of destination "..repr(destination))
                end

                transportLocation = false

                -- locate the nearest movement marker that is safe
                if MovementLayer == 'Amphibious' then
                    transportLocation = FindSafeDropZoneWithPath( self, transportplatoon, {'Amphibious Path Node','Land Path Node','Transport Marker'}, markerrange, destination, mythreat, airthreatMax, 'AntiSurface', MovementLayer)
                else
                    transportLocation = FindSafeDropZoneWithPath( self, transportplatoon, {'Land Path Node','Transport Marker'}, markerrange, destination, mythreat, airthreatMax, 'AntiSurface', MovementLayer)
                end

                if transportLocation then

                    if TransportDialog then

                        if (mythreat * 1.25) > surthreat then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..transportplatoon.BuilderName.." finds alternate landing position at "..repr(transportLocation).." surthreat is "..string.format("%.2f",surthreat).." vs. mine "..string.format("%.2f",mythreat) )
                        else
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..transportplatoon.BuilderName.." finds alternate landing position at "..repr(transportLocation).." AIRthreat is "..string.format("%.2f",airthreat).." vs. my max of "..string.format("%.2f",airthreatMax) )
                        end

                        import('/lua/ai/altaiutilities.lua').AISendPing( transportLocation, 'warning', aiBrain.ArmyIndex )
                    end
                end

            else

                transportLocation = false

                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." says simply too much threat for me - "..surthreat.." vs "..mythreat.." - aborting transport call")
                end

            end
        end
--[[        
        if transportLocation and PlatoonExists(aiBrain,self) and PlatoonExists(aiBrain,transportplatoon) then

            local safePath = PlatoonGenerateSafePathToLOUD(aiBrain, transportplatoon, 'Air', GetPlatoonPosition(self), transportLocation, airthreatMax, 256)

            if not safePath then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." "..transportplatoon.BuilderName.." failed PRELIM path to "..repr(transportLocation).." on tick "..GetGameTick() )
                
                transportLocation = false
            end
        
        end
--]]
		-- if no alternate, or either self, or transports, have died, then abort transport operation
		if not transportLocation or (not PlatoonExists(aiBrain, self)) or (not PlatoonExists(aiBrain,transportplatoon)) then

			if PlatoonExists(aiBrain,transportplatoon) then

                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..transportplatoon.BuilderName.." cannot find safe transport position to "..repr(destination).." - "..MovementLayer.." - transport request denied")
                end

				ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
			end

            if PlatoonExists(aiBrain,self) then
                self.UsingTransport = false
            end

			return false
		end

		-- correct drop location for surface height
		transportLocation[2] = GetSurfaceHeight(transportLocation[1], transportLocation[3])

		if self.MoveThread then
			self:KillMoveThread()
		end

		-- LOAD THE TRANSPORTS AND DELIVER --
		-- we stay in this function until we load, move and arrive or die
		-- we'll get a false return if then entire unit platoon cannot be transported
		-- note how we pass the IsEngineer flag -- alters the behaviour of the transport
		bUsedTransports = UseTransports( aiBrain, transportplatoon, transportLocation, self, IsEngineer, AtGoalDistance )

		-- if self died or we couldn't use transports -- exit
		if (not self) or (not PlatoonExists(aiBrain, self)) or (not bUsedTransports) then
			
			-- if transports RTB them --
            -- this should also RTB scouts and fighters
			if PlatoonExists(aiBrain,transportplatoon) then
				ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
			end

			return false
		end

		-- PROCESS THE PLATOON AFTER LANDING --
		-- if we used transports then process any unlanded units
		-- seriously though - this should have been dealt with
		-- anyhow - forcibly detach the unit and re-enable standard conditions
		units = GetPlatoonUnits(self)

		for _,v in units do
			
			if not v.Dead then
            
                if IsUnitState( v, 'Attached' ) then
                    v:DetachFrom()
                    v:SetCanTakeDamage(true)
                    v:SetDoNotTarget(false)
                    v:SetReclaimable(true)
                    v:SetCapturable(true)
                    v:ShowBone(0, true)
                    v:MarkWeaponsOnTransport(v, false)
                end

                v:SetFireState(0)   -- set to normal firing state
            end
		end
		
		-- set path to destination if we landed anywhere else but the destination
		-- All platoons except engineers (which move themselves) get this behavior
		if (not IsEngineer) and GetPlatoonPosition(self) != destination then
		
			if not PlatoonExists( aiBrain, self ) or not GetPlatoonPosition(self) then
				return false
			end

			-- path from where we are to the destination - use inflated threat to get there --
			path = PlatoonGenerateSafePathToLOUD(aiBrain, self, MovementLayer, GetPlatoonPosition(self), destination, mythreat * 1.25, 160)

			if PlatoonExists( aiBrain, self ) then
				
				-- if no path then fail otherwise use it
				if not path and destination != nil then

					return false
				
				elseif path then

					self.MoveThread = self:ForkThread( self.MovePlatoon, path, 'AttackFormation', true )
				end
			end
		end

	end
    
	return PlatoonExists( aiBrain, self )
    
end

-- This function actually loads and moves units on transports using a safe path to the location desired
-- Just a personal note - this whole transport thing is a BITCH
-- This was one of the first tasks I tackled and years later I still find myself coming back to it again and again - argh
function UseTransports( aiBrain, transports, location, UnitPlatoon, IsEngineer, AtGoalDistance )

    local TransportDialog = ScenarioInfo.TransportDialog or false

    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." begins UseTransports on tick "..GetGameTick() )
    end    

	local LOUDCOPY      = LOUDCOPY
	local LOUDENTITY    = LOUDENTITY
	local LOUDGETN      = LOUDGETN
	local LOUDINSERT    = LOUDINSERT
	local WaitTicks     = WaitTicks
	
	local PlatoonExists         = PlatoonExists
	local GetBlueprint          = moho.entity_methods.GetBlueprint
    local GetPlatoonPosition    = GetPlatoonPosition
    local GetPlatoonUnits       = GetPlatoonUnits
    local GetSquadUnits         = moho.platoon_methods.GetSquadUnits

    local transportTable    = {}	
	local counter           = 0
	
	-- check the transport platoon and count - load the transport table
	-- process any toggles (stealth, etc.) the transport may have
	if PlatoonExists( aiBrain, transports ) then

		for _,v in EntityCategoryFilterDown( AIRTRANSPORTS, GetPlatoonUnits(transports)) do
		
			if not v.Dead then
			
				if v:TestToggleCaps('RULEUTC_StealthToggle') then
					v:SetScriptBit('RULEUTC_StealthToggle', false)
				end
				
				if v:TestToggleCaps('RULEUTC_CloakToggle') then
					v:SetScriptBit('RULEUTC_CloakToggle', false)
				end
				
				if v:TestToggleCaps('RULEUTC_IntelToggle') then
					v:SetScriptBit('RULEUTC_IntelToggle', false)
				end
			
				local slots = LOUDCOPY( aiBrain.TransportSlotTable[v.BlueprintID] )
		
				counter = counter + 1
				transportTable[counter] = {	Transport = v, LargeSlots = slots.Large, MediumSlots = slots.Medium, SmallSlots = slots.Small, Units = { ["Small"] = {}, ["Medium"] = {}, ["Large"] = {} } }

			end
		end
	end
	
	if counter < 1 then
    
        UnitPlatoon.UsingTransport = false
        
		return false
    end

	-- This routine allocates the units to specific transports
	-- Units are injected on a TransportClass basis ( 3 - 2 - 1 )
	-- As each unit is assigned - the transport has its remaining slot count
	-- reduced & the unit is added to the list assigned to that transport
	local function SortUnitsOnTransports( transportTable, unitTable )

		local leftoverUnits = {}
        local count = 0
	
		for num, unit in unitTable do
		
			local transSlotNum = 0
			local remainingLarge = 0
			local remainingMed = 0
			local remainingSml = 0
		
			local TransportClass = 	unit.TransportClass
			
			-- pick the transport with the greatest number of appropriate slots left
			for tNum, tData in transportTable do
			
				if tData.LargeSlots >= remainingLarge and TransportClass == 3 then
				
					transSlotNum = tNum
					remainingLarge = tData.LargeSlots
					remainingMed = tData.MediumSlots
					remainingSml = tData.SmallSlots
					
				elseif tData.MediumSlots >= remainingMed and TransportClass == 2 then
				
					transSlotNum = tNum
					remainingLarge = tData.LargeSlots
					remainingMed = tData.MediumSlots
					remainingSml = tData.SmallSlots
					
				elseif tData.SmallSlots >= remainingSml and TransportClass == 1 then
				
					transSlotNum = tNum
					remainingLarge = tData.LargeSlots
					remainingMed = tData.MediumSlots
					remainingSml = tData.SmallSlots
				end
			end
			
			if transSlotNum > 0 then

				-- assign the large units
				-- notice how we reduce the count of the lower slots as we use up larger ones
				-- and we do the same to larger slots as we use up smaller ones - this was not the 
				-- case before - and caused errors leaving units unassigned - or over-assigned
				if TransportClass == 3 and remainingLarge >= 1.0 then
				
					transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - 1.0
					transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 0.25
					transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 0.50
					
					-- add the unit to the Large list for this transport
					LOUDINSERT( transportTable[transSlotNum].Units.Large, unit )
					
				elseif TransportClass == 2 and remainingMed >= 1.0 then
				
					transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - 0.1
					transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 1.0
					transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 0.34
					
					-- add the unit to the Medium list for this transport
					LOUDINSERT( transportTable[transSlotNum].Units.Medium, unit )
					
				elseif TransportClass == 1 and remainingSml >= 1.0 then
				
					transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 0.1	-- yes .1 - for UEF T2 gunships
					transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 1
					
					-- add the unit to the list for this transport
					LOUDINSERT( transportTable[transSlotNum].Units.Small, unit )
				else
					count = count + 1
					leftoverUnits[count] = unit
				end
			else
                count = count + 1
				leftoverUnits[count] = unit
			end
		end

		return transportTable, leftoverUnits
	end	

	-- tables that hold those units which are NOT loaded yet
	-- broken down by their TransportClass size
    local remainingSize3 = {}
    local remainingSize2 = {}
    local remainingSize1 = {}
	
	counter = 0

	-- check the unit platoon, load the unit remaining tables, and count
	if PlatoonExists( aiBrain, UnitPlatoon) then
	
		-- load the unit remaining tables according to TransportClass size
		for k, v in GetPlatoonUnits(UnitPlatoon) do
	
			if v and not v.Dead then

				counter = counter + 1

				if v.TransportClass == 3 then
				
					LOUDINSERT( remainingSize3, v )
					
				elseif v.TransportClass == 2 then
				
					LOUDINSERT( remainingSize2, v )
					
				elseif v.TransportClass == 1 then
				
					LOUDINSERT( remainingSize1, v )
					
				else
				
					WARN("*AI DEBUG "..aiBrain.Nickname.." Cannot transport "..GetBlueprint(v).Description )
					counter = counter - 1  -- take it back
					
				end
			
				if IsUnitState( v, 'Attached') then
				
                    if ScenarioInfo.UnitDialog then
                        LOG("*AI DEBUG UNIT "..aiBrain.Nickname.." "..v.EntityID.." "..v:GetBlueprint().Description.." is attached at "..repr(v:GetPosition()))
                    end
                    
					v:DetachFrom()
					v:SetCanTakeDamage(true)
					v:SetDoNotTarget(false)
					v:SetReclaimable(true)
					v:SetCapturable(true)
					v:ShowBone(0, true)
					v:MarkWeaponsOnTransport(v, false)
				end
			end
		end
	end

	-- if units were assigned - sort them and tag them for specific transports
	if counter > 0 then
	
		-- flag the unit platoon as busy
		UnitPlatoon.UsingTransport = true
	
		local leftoverUnits = {}
		local currLeftovers = {}
        counter = 0
	
		-- assign the large units - note how we come back with leftoverunits here
		transportTable, leftoverUnits = SortUnitsOnTransports( transportTable, remainingSize3 )
		
		-- assign the medium units - but this time we come back with currleftovers
		transportTable, currLeftovers = SortUnitsOnTransports( transportTable, remainingSize2 )
	
		-- and we move any currleftovers into the leftoverunits table
		for k,v in currLeftovers do
		
			if not v.Dead then
                counter = counter + 1
				leftoverUnits[counter] = v
			end
		end
		
		currLeftovers = {}
	
		-- assign the small units - again coming back with currleftovers
		transportTable, currLeftovers = SortUnitsOnTransports( transportTable, remainingSize1 )
	
		-- again adding currleftovers to the leftoverunits table
		for k,v in currLeftovers do
		
			if not v.Dead then
                counter = counter + 1
				leftoverUnits[counter] = v
			end
		end
		
		currLeftovers = {}
	
		if leftoverUnits[1] then
			transportTable, currLeftovers = SortUnitsOnTransports( transportTable, leftoverUnits )
		end
	
		-- send any leftovers to RTB --
		if currLeftovers[1] then
		
			for _,v in currLeftovers do
				IssueClearCommands({v})
			end
	
			local ident = Random(1,999999)
			local returnpool = aiBrain:MakePlatoon('RTB - Excess in SortingOnTransport'..tostring(ident), 'none')
		
			AssignUnitsToPlatoon( aiBrain, returnpool, currLeftovers, 'Unassigned', 'None' )
			
			returnpool.PlanName = 'ReturnToBaseAI'
			returnpool.BuilderName = 'SortUnitsOnTransportsLeftovers'..tostring(ident)
			
			returnpool:SetAIPlan('ReturnToBaseAI',aiBrain)
		end

	end

	remainingSize3 = nil
    remainingSize2 = nil
    remainingSize1 = nil

	-- At this point all units should be assigned to a given transport or dismissed
	local loading = false
    local loadissued, Units, unitstoload, transport
    
    local SCOUTS, FIGHTERS, TRANSPORTS
	
	-- loop thru the transports and order the units to load onto them	
    for k, data in transportTable do
	
		loadissued = false
		unitstoload = false
        
        Units = data.Units
		
		counter = 0
		
		-- look for dead/missing units in this transports unit list
		-- and those that may somehow be attached already
        for size,unitlist in Units do
		
			for u,v in unitlist do
			
				if v and not v.Dead then

					if not unitstoload then
						unitstoload = {}
					end

					counter = counter + 1					
					unitstoload[counter] = v

				else
					Units[size][u] = nil
				end
			end
		end

		-- if units are assigned to this transport
        if Units["Large"][1] then
		
            IssueClearCommands( Units["Large"] )
			
			loadissued = true
		end
		
		if Units["Medium"][1] then
		
            IssueClearCommands( Units["Medium"] )
		
			loadissued = true
		end
		
		if Units["Small"][1] then
		
            IssueClearCommands( Units["Small"] )
			
			loadissued = true
		end
		
		if not loadissued or not unitstoload then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..repr(transports.BuilderName).." transport "..data.Transport.EntityID.." no load issued or units to load")
            end
		
			-- RTP any transport with nothing to load
			ForkTo( ReturnTransportsToPool, aiBrain, {data.Transport}, true )
		else
			transport = data.Transport
			
			transport.InUse = true
            transport.Assigning = false

			transport.WatchLoadingThread = transport:ForkThread( WatchUnitLoading, unitstoload, aiBrain, UnitPlatoon, IsEngineer )
			
			loading = true
		end
    end

    SCOUTS      = GetSquadUnits( transports,'Scout') or false
    FIGHTERS    = GetSquadUnits( transports,'Guard') or false
    TRANSPORTS  = GetSquadUnits( transports,'Support') or false
	
	-- if loading has been issued watch it here
	if loading then

        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." loadwatch begins on tick "..GetGameTick() )
        end    

		if UnitPlatoon.WaypointCallback then

			KillThread( UnitPlatoon.WaypointCallback )
			
			UnitPlatoon.WaypointCallback = nil
            
            if UnitPlatoon.MovingToWaypoint then
                --LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(UnitPlatoon.BuilderName).." "..repr(UnitPlatoon.BuilderInstance).." MOVINGTOWAYPOINT cleared by transport ")
                UnitPlatoon.MovingToWaypoint = nil
            end

		end
	
		local loadwatch = true	
	
		while loadwatch do

            WaitTicks(8)

            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." loadwatch cycles on tick "..GetGameTick() )
            end    
			
			loadwatch = false
			
			if PlatoonExists( aiBrain, transports) then
		
				for _,t in TRANSPORTS do
			
					if not t.Dead and t.Loading then

						loadwatch = true

					else

                        if t.WatchLoadingThread then
                            KillThread (t.WatchLoadingThread)
                            t.WatchLoadingThread = nil
                        end

                    end

				end

			end

		end

	end

    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." loadwatch complete on tick "..GetGameTick() )
	end
    
	if not PlatoonExists(aiBrain, transports) then
    
        UnitPlatoon.UsingTransport = false
        
		return false
	end

	-- Any units that failed to load send back to pool thru RTB
    -- this one really only occurs when an inbound transport is killed
	if PlatoonExists( aiBrain, UnitPlatoon ) then

		local returnpool = false

		for k,v in GetPlatoonUnits(UnitPlatoon) do
	
			if v and (not v.Dead) then
		
				if not IsUnitState( v, 'Attached') then

					if not returnpool then

						local ident = Random(100000,999999)
						returnpool = aiBrain:MakePlatoon('FailTransportLoad'..tostring(ident), 'none' )

						returnpool.PlanName = 'ReturnToBaseAI'

						if not string.find(UnitPlatoon.BuilderName, 'FailLoad') then
							returnpool.BuilderName = 'FailLoad '..UnitPlatoon.BuilderName
						else
							returnpool.BuilderName = UnitPlatoon.BuilderName
						end
					end

					IssueClearCommands( {v} )
                    
                    v:SetFireState(0)

					AssignUnitsToPlatoon( aiBrain, returnpool, {v}, 'Attack', 'None' )
				end
			end
		end

		if returnpool then
			returnpool:SetAIPlan('ReturnToBaseAI', aiBrain )
		end
	end

	counter = 0
	
	-- count number of loaded transports and send empty ones home
	if PlatoonExists( aiBrain, transports ) then
	
		for k,v in EntityCategoryFilterDown( AIRTRANSPORTS, GetPlatoonUnits(transports)) do
	
			if v and (not v.Dead) and LOUDGETN(v:GetCargo()) == 0 then

				ForkTo( ReturnTransportsToPool, aiBrain, {v}, true )

				transports[k] = nil
			else
				counter = counter + 1
			end
		end	
	end

	local airthreatMax = counter * 4.2

    airthreatMax = airthreatMax + ( airthreatMax * math.log10(counter))

    SCOUTS      = GetSquadUnits( transports,'Scout') or false
    FIGHTERS    = GetSquadUnits( transports,'Guard') or false
    TRANSPORTS  = GetSquadUnits( transports,'Support') or false

	-- plan the move and send them on their way
	if counter > 0 then

		local platpos = transports:GetSquadPosition('Support') or false
		
		if platpos then

            local safePath, reason, pathlength, pathcost = transports.PlatoonGenerateSafePathToLOUD(aiBrain, transports, 'Air', platpos, location, airthreatMax, 256)
            
            --if not safePath then

              --  TransportDialog = true

            --end

            if TransportDialog then
            
                if not safePath then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." no safe path to "..repr(location).." using threat of "..airthreatMax.." reason "..reason )
                else
                    
                    if GetFocusArmy() == aiBrain.ArmyIndex then
                        ForkTo ( import('/lua/loudutilities.lua').DrawPath, platpos, safePath, location )
                    end
                    
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." has path to "..repr(location).." - length "..repr(pathlength).." - reason "..reason.." - cost "..pathcost)

                end
            end
		
			if PlatoonExists( aiBrain, transports) then
		
                --- clear everyone
				IssueClearCommands( GetPlatoonUnits(transports) )
				--- order transports to platpos
				IssueMove( TRANSPORTS, platpos )

                if FIGHTERS[1] then

                    local fcount = 1
                    local count = 1

                    for k,v in FIGHTERS do
                        
                        if not TRANSPORTS[count] then 
                            count = 1
                        end

                        IssueGuard( {FIGHTERS[fcount]}, TRANSPORTS[count] )

                        fcount = fcount + 1
                        count = count + 1

                    end

                end

				if safePath then

                    -- this is here as a planning tool - for later consumption 
                    -- transports.MoveThread = transports:ForkThread( transports.MovePlatoon, safepath, false, false, 20 )

					local prevposition = GetPlatoonPosition(transports) or false
                    local Direction

					for _,p in safePath do
				
						if prevposition then

							Direction = import('/lua/utilities.lua').GetDirectionInDegrees( prevposition, p )

                            if SCOUTS[1] then
                                IssueFormMove( SCOUTS, p, 'BlockFormation', Direction)
                            end

                            if TRANSPORTS[1] then
                                IssueFormMove( TRANSPORTS, p, 'AttackFormation', Direction)
                            end

							prevposition = p
						end
					end
                    
				else
                
					if TransportDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." failed path - direct to "..repr(location).." on tick "..GetGameTick() )
                    end
                    
                    if SCOUTS[1] then
                        IssueFormMove( SCOUTS, location, 'BlockFormation', import('/lua/utilities.lua').GetDirectionInDegrees( GetPlatoonPosition(transports), location ))
                    end

					IssueFormMove( TRANSPORTS, location, 'AttackFormation', import('/lua/utilities.lua').GetDirectionInDegrees( GetPlatoonPosition(transports), location )) 

				end
                
                if SCOUTS[1] then
                    IssueGuard ( SCOUTS, location )
                end

				if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." starts travelwatch to "..repr(location))
                end
			
				for _,v in EntityCategoryFilterDown( AIRTRANSPORTS, GetPlatoonUnits(transports)) do
		
					if not v.Dead then
						v.WatchTravelThread = v:ForkThread(WatchTransportTravel, location, aiBrain, UnitPlatoon, AtGoalDistance )		
					end
                end
			end
            
		end
        
	else
    
        --LOG("*AI DEBUG NO TRANSPORTS TO MONITOR")
    
    end
	
	local transporters = EntityCategoryFilterDown( AIRTRANSPORTS, GetPlatoonUnits(transports)) or false
	
	-- if there are loaded, moving transports, watch them while traveling
	if transporters and LOUDGETN(transporters) != 0 then
	
		-- this sets up the transports platoon ability to call for help and to detect major threats to itself
		-- we'll also use it to signal an 'abort transport' capability using the DistressCall field
        -- threat value is calculated up above
		transports:ForkThread( transports.PlatoonCallForHelpAI, aiBrain, airthreatMax )
		
		transports.AtGoal = false -- flag to allow unpathed unload of the platoon
      
		local travelwatch = true
		
		-- loop here until all transports signal travel complete
		-- each transport should be running the WatchTravel thread
		-- until it dies, the units it is carrying die or it gets to target
		while travelwatch and PlatoonExists( aiBrain, transports ) do

			travelwatch = false

			WaitTicks(4)
            
			for _,t in transporters do
			
				if t.Travelling and not t.Dead then
				
					travelwatch = true
				end
			end

		end

        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." travelwatch complete")
        end
    end

	transporters = EntityCategoryFilterDown( AIRTRANSPORTS, GetPlatoonUnits(transports)) or false
	
	if not PlatoonExists(aiBrain, transports) then
        return false
    end

    SCOUTS      = GetSquadUnits( transports,'Scout') or false
    FIGHTERS    = GetSquadUnits( transports,'Guard') or false
    TRANSPORTS  = GetSquadUnits( transports,'Support') or false
	
	-- watch the transports until they signal unloaded or dead
	if PlatoonExists(aiBrain, transports) then
    
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." unloadwatch begins")
        end    
		
		local unloadwatch = true
        local unloadcount = 0 
	
		while unloadwatch and EntityCategoryCount(AIRTRANSPORTS, EntityCategoryFilterDown( AIRTRANSPORTS, GetPlatoonUnits(transports))) > 0  do
		
			WaitTicks(5)
            unloadcount = unloadcount + .4
			
			unloadwatch = false
		
			for _,t in transporters do
			
				if t.Unloading and not t.Dead then
				
					unloadwatch = true
                else
                    if t.WatchUnloadThread then
                        KillThread(t.WatchUnloadThread)
                        t.WatchUnloadThread = nil
                    end
				end
			end
		end

        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." unloadwatch complete after "..unloadcount.." seconds")
        end
        
        -- process ALL the units in the platoon (even fighters and scouts)
        for _,t in GetPlatoonUnits(transports) do

            ForkTo( ReturnTransportsToPool, aiBrain, {t}, true )

        end
    end
	
	if not PlatoonExists(aiBrain,UnitPlatoon) then
        return false
    end
	
	UnitPlatoon.UsingTransport = false

    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." Transport complete ")
    end
	
	return true
end

-- Ok -- this routine allowed me to get some control over the reliability of loading units onto transport
-- I have to say, the lack of a GETUNITSTATE function really made this tedious but here is the jist of what I've found
-- Some transports will randomly report false to TransportHasSpaceFor even when completely empty -- causing them to fail to load units
-- just to note, the same also seems to apply to AIRSTAGINGPLATFORMS

-- I was eventually able to determine that two states are most important in this process --
-- TransportLoading for the transports
-- WaitingForTransport for the units 

-- Essentially if the transport isn't Moving or TransportLoading then something is wrong
-- If a unit is not WaitingForTransport then it too has had loading interrupted 
-- however - I have noticed that transports will continue to report 'loading' even when all the units to be loaded are dead 
function WatchUnitLoading( transport, units, aiBrain, UnitPlatoon, IsEngineer)

    local TransportDialog = ScenarioInfo.TransportDialog or false
	
	local unitsdead = true
	local loading = false
	
	local reloads = 0
	local reissue = 0
	local newunits = LOUDCOPY(units)
	
	local GetPosition = GetPosition
	local watchcount = 0
    
    transport.Loading = true

	IssueStop( {transport} )
    
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." transport "..transport.EntityID.." moving to "..repr(units[1]:GetPosition()).." for pickup - distance "..VDist3( transport:GetPosition(), units[1]:GetPosition()))
    end
	
    -- At this point we really should safepath to the position
    -- and we should probably use a movement thread 
	IssueMove( {transport}, GetPosition(units[1]) )
	
	WaitTicks(5)
	
	for _,u in newunits do
	
		if not u.Dead then
		
			unitsdead = false
			loading = true
		
			-- here is where we issue the Load command to the transport --
			safecall(aiBrain.Nickname.." Unable to IssueTransportLoad units to "..table.getn(units).." units at "..repr(units[1]:GetPosition()), IssueTransportLoad, newunits, transport )
			
			break
		end
	end

	local tempunits = {}
	local counter = 0
	
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." begins loading on tick "..GetGameTick() )
    end
    
	-- loop here while the transport is alive and loading is underway
	-- there is another trigger (watchcount) which will force loading
	-- to false after 180 seconds
	while (not unitsdead) and loading do
	
		watchcount = watchcount + 1.3

		if watchcount > 180 or (reloads > 4 and IsEngineer) then
        
            WARN("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." ABORTING LOAD - watchcount "..watchcount.." on tick "..GetGameTick() )
            
			loading = false

            transport.Loading = nil
            
            ForkTo ( ReturnTransportsToPool, aiBrain, {transport}, true )

        else
		
            WaitTicks(14)
	
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." cycles loading on tick "..GetGameTick() )
            end
            
        end
 		
		tempunits = {}
		counter = 0

        -- check for death of transport - and verify that units are still awaiting load
		if (not transport.Dead) and transport.Loading and ( not IsUnitState(transport,'Moving') or IsUnitState(transport,'TransportLoading') ) then
		
			unitsdead = true
			loading = false
	
			-- loop thru the units and pick out those that are not yet 'attached'
			-- also detect if all units to be loaded are dead
			for _,u in newunits do
		
				if not u.Dead then
				
					-- we have some live units
					unitsdead = false
			
					if not IsUnitState( u, 'Attached') then
					
						loading = true
						counter = counter + 1
						tempunits[counter] = u
					end
				end
			end
		
			-- if all dead or all loaded or unit platoon no longer exists, RTB the transport
			if unitsdead or (not loading) or reloads > 20 then
			
				if unitsdead then

                    transport.Loading = nil

					ForkTo ( ReturnTransportsToPool, aiBrain, {transport}, true )
                    return
				end
				
				loading = false
			end
            
		end

		-- issue reloads to unloaded units if transport is not moving and not loading units
		if (not transport.Dead) and (loading and not (IsUnitState( transport, 'Moving') or IsUnitState( transport, 'TransportLoading'))) then

			reloads = reloads + 1
			reissue = reissue + 1
			newunits = false
			counter = 0
			
			for k,u in tempunits do
			
				if (not u.Dead) and not IsUnitState( u, 'Attached') then

					-- if the unit is not attached and the transport has space for it or it's a UEF Gunship (TransportHasSpaceFor command is unreliable)
					if (not transport.Dead) and transport:TransportHasSpaceFor(u) then
					
						IssueStop({u})
					
						if reissue > 1 then
						
                            if VDist3(u:GetPosition(),transport:GetPosition()) < 20 then

                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..u.EntityID.." warps to "..repr(GetPosition(transport)).." distance is "..VDist3(u:GetPosition(),transport:GetPosition()) )
                            
                                Warp( u, GetPosition(transport) )
                            
                                reissue = 0
                            
                            end
						end
						
						if not newunits then
							newunits = {}
						end
                        
						counter = counter + 1						
						newunits[counter] = u

					
					-- if the unit is not attached and the transport does NOT have space for it - turn off loading flag and clear the tempunits list
					elseif (not transport.Dead) and (not transport:TransportHasSpaceFor(u)) and (not EntityCategoryContains(categories.uea0203,transport)) then

						loading = false
						newunits = false
						break
			
					elseif (not transport.Dead) and EntityCategoryContains(categories.uea0203,transport) then

						loading = false
						newunits = false
						break
						
					end	
				end
			end
			
			if newunits and counter > 0 then
			
				if reloads > 2 then

                    if counter > 1 then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." Reloading "..counter.." units - reload "..reloads.." on tick "..GetGameTick() )
                    else
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." Reloading "..repr(newunits[1].BlueprintID).." - reload "..reloads.." Engineer "..repr(IsEngineer).." on tick "..GetGameTick() )                    
                    end
                    
                    local unit = newunits[1]
                    local count = 1
                    
                    for _,wep in __blueprints[unit.BlueprintID].Weapon do
                    
                        if wep.WeaponUnpackLocksMotion then
                        
                            local weapon = unit:GetWeapon(count)
                            
                            --LOG("*AI DEBUG weapon is "..repr(weapon) )
                            
                            weapon:OnLostTarget()
                            
                        end
                        
                    end

                    newunits[1]:SetFireState(1) -- set unit to hold fire

				end
			
				IssueStop( newunits )
				
				IssueStop( {transport} )
				
				local goload = safecall("Unable to IssueTransportLoad", IssueTransportLoad, newunits, transport )
				
				if goload then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." reloads is "..reloads.." goload is "..repr(goload).." for "..transport:GetBlueprint().Description)

				end
				
			else
			
				loading = false
			end
		end
        
	end

    if TransportDialog then
    
        if transport.Dead then
            -- at this point we should find a way to reprocess the units this transport was responsible for
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." Transport "..transport.EntityID.." dead during WatchLoading")
        else
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." completes load in "..watchcount)
        end
        
    end

    if transport.InUse then
    
        IssueStop( {transport} )
    
        if (not transport.Dead) then

            if not unitsdead then
            
                -- have the transport guard his loading spot until everyone else has loaded up
                IssueGuard( {transport}, GetPosition(transport) )
                
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." begins to loiter after load")
                end
                
            else
			
                transport.Loading = nil
                
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." aborts load - unitsdead is "..repr(unitsdead).." watchcount is "..watchcount)
                end

                ForkTo ( ReturnTransportsToPool, aiBrain, {transport}, true )
                return
            end
        end
        
    end
    
	transport.Loading = nil
end

function WatchTransportTravel( transport, destination, aiBrain, UnitPlatoon, AtGoalDistance )

    local TransportDialog = ScenarioInfo.TransportDialog or false	

    local GoalDistance = AtGoalDistance or 10000
    local currentposition = false
    local transportgunship = categories.uea0203
	local unitsdead = false
	local watchcount = 0
    
    
	
	local GetPosition = GetPosition
    
    local VDist3Sq = VDist3Sq
    
    local WaitTicks = WaitTicks
	
	transport.StuckCount = 0
	transport.LastPosition = {0,0,0}
    transport.Travelling = true
    
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." starts travelwatch")
    end
	
	while (not transport.Dead) and (not unitsdead) and transport.Travelling do

		-- major distress call -- 
		if transport.PlatoonHandle.DistressCall then
			
			-- reassign destination and exit
			-- this really needs to be sensitive to the platoons layer
			-- and find an appropriate marker to drop at -- 
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." DISTRESS ends travelwatch after "..watchcount)
            end

            destination = GetPosition(transport)
            
            IssueStop( {transport} )

            break
		end

		-- someone in transport platoon is close - begin the drop -
		if transport.PlatoonHandle.AtGoal then
            
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." signals ARRIVAL after "..watchcount)
            end
            
            break
		end
        
		unitsdead = true

		for _,u in transport:GetCargo() do
			
			if not u.Dead then
				
				unitsdead = false
				break
			end
		end

		-- if all dead except UEF Gunship RTB the transport
		if unitsdead and not EntityCategoryContains( transportgunship, transport ) then
			
			transport.StuckCount = nil
			transport.LastPosition = nil
			transport.Travelling = false

            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." UNITS DEAD ends travelwatch after "..watchcount)
            end

			ForkTo( ReturnTransportsToPool, aiBrain, {transport}, true )

            return
		end

        currentposition = GetPosition(transport)		

		-- is the transport still close to its last position bump the stuckcount
		if transport.LastPosition[1] != 0 then
			
			if VDist3Sq(transport.LastPosition, currentposition) < 9 then

				transport.StuckCount = transport.StuckCount + 0.5
			else
				transport.StuckCount = 0
			end
		end

		if ( IsIdleState(transport) or transport.StuckCount > 8 ) then
		
			if transport.StuckCount > 8 then
				
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." at "..repr(currentposition).." StuckCount "..transport.StuckCount.." in WatchTransportTravel to "..repr(destination) )				
                --LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." last position was "..repr(transport.LastPosition))

                transport.StuckCount = 0
			end

			IssueClearCommands( {transport} )
			IssueMove( {transport}, destination )
		end
		
		-- this needs some examination -- it should signal the entire transport platoon - not just itself --
		if VDist3Sq(currentposition, destination) < 10000 then
 			
			transport.PlatoonHandle.AtGoal = true

		end

        -- if were not there yet record the position
        if not transport.PlatoonHandle.AtGoal then

            transport.LastPosition[1] = currentposition[1]
            transport.LastPosition[2] = currentposition[2]
            transport.LastPosition[3] = currentposition[3]

            WaitTicks(14)

            watchcount = watchcount + 1.3

        end

	end

	if not transport.Dead then
	
		IssueClearCommands( {transport} )

		if not transport.Dead then
    
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." ends travelwatch ")
            end
		
			transport.StuckCount = nil
			transport.LastPosition = nil
			transport.Travelling = nil

			transport.WatchUnloadThread = transport:ForkThread( WatchUnitUnload, transport:GetCargo(), destination, aiBrain, UnitPlatoon )
		end
	end
	
end

function WatchUnitUnload( transport, unitlist, destination, aiBrain, UnitPlatoon )

    local TransportDialog = ScenarioInfo.TransportDialog or false
  
    local WaitTicks = WaitTicks
	
	local unitsdead = false
	local unloading = true

    transport.Unloading = true
    
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." unloadwatch begins at "..repr(destination) )
    end
	
	IssueTransportUnload( {transport}, destination)
    
    WaitTicks(4)
	
	local watchcount = 0.3

	while (not unitsdead) and unloading and (not transport.Dead) do
	
		unitsdead = true
		unloading = false
	
        if not transport.Dead then
		
			-- do we have loaded units
			for _,u in unitlist do
		
				if not u.Dead then
				
					unitsdead = false
				
					if IsUnitState( u, 'Attached') then
					
						unloading = true
						break
					end
				end
			end

            -- in this case unitsdead can mean that OR that we've unloaded - either way we're done
			if unitsdead or not unloading then

                if TransportDialog then
                    
                    if not transport.Dead then
                    
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." transport "..transport.EntityID.." UNITDEAD unloadwatch complete after "..watchcount.." seconds")
				
                        --transport.InUse = false
                        --transport.Unloading = nil
                        
                        --if not transport.EventCallbacks['OnTransportDetach'] then
                          --  ForkTo( ReturnTransportsToPool, aiBrain, {transport}, true )
                        --end
                        
                    else
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." transport "..transport.EntityID.." dead during unload")
                    end
                end

			end

            -- watch the count and try to force the unload
			if unloading and (not transport:IsUnitState('TransportUnloading')) then

				if watchcount >= 12 then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." transport "..transport.EntityID.." FAILS TO UNLOAD after "..watchcount.." seconds")
                    
					break			
					
				elseif watchcount >= 8 then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." transport "..transport.EntityID.." watched unload for "..watchcount.." seconds")
                    
					IssueTransportUnload( {transport}, GetPosition(transport))
					
				elseif watchcount > 4 then
				
					IssueTransportUnload( {transport}, GetPosition(transport))
				end
			end
		end
        
		WaitTicks(6)
        
		watchcount = watchcount + 0.5
    
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." unloadwatch cycles "..watchcount )
        end

	end
    
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." unloadwatch ends" )
    end
   
    transport.Unloading = nil

end

