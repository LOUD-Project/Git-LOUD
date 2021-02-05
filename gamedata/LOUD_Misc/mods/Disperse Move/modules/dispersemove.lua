
ShadowOrders = import('/lua/spreadattack.lua').ShadowOrders

-----------------------------------------
-- Function MakeShadowCopyOrders(command)
-----------------------------------------

-- Global variables needed for this function:

-- Some orders need to be changed for them to work when garbling orders.
-- Note that the Stop command is handled implicitly by the clear bit being set.

TranslatedOrder = {
    ["AggressiveMove"]     = "AggressiveMove",
    ["Attack"]             = "Attack",
    ["Capture"]            = "Capture",
    ["Guard"]              = "Guard",
    ["Move"]               = "Move",
    ["Nuke"]               = "Nuke",
    ["OverCharge"]         = "OverCharge",
    ["Patrol"]             = "Patrol",
    ["Reclaim"]            = "Reclaim",
    ["Repair"]             = "Repair",
    ["Tactical"]           = "Tactical",
    ["FormAggressiveMove"] = "AggressiveMove",      -- Form actions currently not supported
    ["FormAttack"]         = "Attack",              -- Form actions currently not supported
    ["FormMove"]           = "Move",                -- Form actions currently not supported
    ["FormPatrol"]         = "Patrol",              -- Form actions currently not supported
}

-- This function makes a shadow copy of the orders given to the units.
-- Due to it's use, only a subset of the orders will be kept.
function MakeShadowCopyOrders(command)

    -- If the order has the Clear bit set, then all previously issued orders will be removed first,
    -- even if the specific order will not be handled below.
    -- This conveniently also handles the Stop order (= clear all orders).
    if command.Clear == true then
        for _,unit in ipairs(command.Units) do
            ShadowOrders[unit:GetEntityId()] = {}
        end
    end

    -- Skip handling the order if it does not belong to the given subset.
    if not TranslatedOrder[command.CommandType] then
        return
    end

    local Order = {
        CommandType = TranslatedOrder[command.CommandType],
        Position = command.Target.Position,
        EntityId = nil,
    }
    if command.Target.Type == "Entity" then
        Order.EntityId = command.Target.EntityId
    end

    -- Add this order to each individual unit.
    for _,unit in ipairs(command.Units) do

        -- Initialise the orders table, if needed.
        if not ShadowOrders[unit:GetEntityId()]  then
            ShadowOrders[unit:GetEntityId()] = {}
        end
        table.insert(ShadowOrders[unit:GetEntityId()],Order)
    end

end -- function MakeShadowCopyorders(command)

---------------------------
-- Function FixOrders(unit)
---------------------------

-- This function tries to fix a unit's moved or deleted shadow orders
-- based on its current command queue.
-- It can only get ability names and positions of current orders,
-- so it can't retarget orders with a changed entity target.
local function FixOrders(unit)

    -- The factory exclusion is because GetCommandQueue doesn't work right for them.
    -- This means we can't fix orders for Fatboy, Megalith, Tempest, or carriers.
    if not unit or unit:IsInCategory("FACTORY") then
        return
    end

    local unitOrders = ShadowOrders[unit:GetEntityId()]
    if not unitOrders  or not unitOrders[1] then
        return
    end

    local queue = unit:GetCommandQueue()
    local filteredQueue = {}
    for _,command in ipairs(queue) do
        local Order = {
            CommandType = TranslatedOrder[command.type],
            Position = command.position,
        }
        if Order.CommandType then
            table.insert(filteredQueue, Order)
        end
    end

    local numOrders = table.getn(unitOrders)
	ordercount = numOrders

    -- We can't trust the shadow orders if commands were added without getting a copy.
    if numOrders < table.getn(filteredQueue) then
        WARN("Spreadattack: Command queue is longer than the shadow order list.")
        return
    end

    -- First check for entire blocks of orders that have been deleted.
    local orderIndex = 1
    local queueIndex = 1
    local orderType = false
    local lastBlockType = false
    while orderIndex <= numOrders do
        orderType = unitOrders[orderIndex].CommandType
        local nextOrderIndex = orderIndex + 1
        while unitOrders[nextOrderIndex].CommandType == orderType do
            nextOrderIndex = nextOrderIndex + 1
        end

        if orderType == lastBlockType then
            orderIndex = nextOrderIndex
            continue
        end

        local nextQueueIndex = queueIndex
        while filteredQueue[nextQueueIndex].CommandType == orderType do
            nextQueueIndex = nextQueueIndex + 1
        end

         if nextQueueIndex == queueIndex then
            -- Block not found.
            for i = nextOrderIndex - 1, orderIndex, -1 do
                table.remove(unitOrders, i)
                numOrders = numOrders - 1
            end
            nextOrderIndex = orderIndex
        else
            lastBlockType = orderType
        end

        orderIndex = nextOrderIndex
        queueIndex = nextQueueIndex
    end

    -- Now fix the orders within each block of the same type.
    orderIndex = 1
    queueIndex = 1
    while orderIndex <= numOrders do
        orderType = unitOrders[orderIndex].CommandType
        local nextOrderIndex = orderIndex + 1
        local numEntityTargets = 0
        while unitOrders[nextOrderIndex].CommandType == orderType do
            if unitOrders[nextOrderIndex].EntityId then
                numEntityTargets = numEntityTargets + 1
            end
            nextOrderIndex = nextOrderIndex + 1
        end

        local nextQueueIndex = queueIndex
        while filteredQueue[nextQueueIndex].CommandType == orderType do
            nextQueueIndex = nextQueueIndex + 1
        end

        -- Check if orders were removed from the queue and try to identify them.
        local numDeletedOrders = nextOrderIndex - orderIndex - (nextQueueIndex - queueIndex)
        if numDeletedOrders ~= 0 then

            if numEntityTargets == 0 then
                -- With only position targets it doesn't matter which orders we delete.
                while numDeletedOrders > 0 do
                    table.remove(unitOrders, nextOrderIndex - 1)
                    numOrders = numOrders - 1
                    nextOrderIndex = nextOrderIndex - 1
                    numDeletedOrders = numDeletedOrders - 1
                end
                -- Fix the positions of any moved orders.
                for i = 0, nextOrderIndex - orderIndex - 1, 1 do
                    if not unitOrders[i + orderIndex].EntityId then
                        unitOrders[i + orderIndex].Position = filteredQueue[i + queueIndex].Position
                    end
                end
            else
                -- This part is only for the most complex situations and shouldn't be needed often in practice.
                -- Here we go through the block of orders and try to determine which to remove. Priority for removal:
                -- 1. Entity targets with a valid current position that don't match any command position (could have changed target)
                -- 2. position targets that don't match any command position (could have moved)
                -- 3. Entity targets with unknown current position that don't match any command position (could have moved or changed)
                local Matches = {}
                local lastMatchIndex = 0
                local lastMatchQueueIndex = queueIndex - 1
                local lastMatchAlignment = orderIndex - queueIndex
                for i = orderIndex, nextOrderIndex - 1, 1 do
                    local match = false
                    local priority = 2
                    local position = unitOrders[i].Position
                    if unitOrders[i].EntityId then
                        priority = 3
                        local target = GetUnitById(unitOrders[i].EntityId)
                        if target then
                            position = target:GetPosition()
                            priority = 1
                        end
                    end
                    for j = lastMatchQueueIndex + 1, nextQueueIndex - 1, 1 do
                        if VDist3Sq(position, filteredQueue[j].Position) <= 0.0001 then
                            -- If the shadow orders and command queue have the same number of entries since the last match,
                            -- mark any mismatches in between as matches since no orders were removed.
                            if i - j == lastMatchAlignment and j > lastMatchQueueIndex + 1 then
                                for k = 1, j - lastMatchQueueIndex - 1, 1 do
                                    Matches[k + lastMatchIndex].Priority = false
                                    Matches[k + lastMatchIndex].Match = k + lastMatchQueueIndex
                                end
                            else
                                lastMatchAlignment = i - j
                            end
                            match = j
                            priority = false
                            lastMatchQueueIndex = j
                            lastMatchIndex = table.getn(Matches) + 1
                            break
                        end
                    end
                    table.insert(Matches, {Match = match, Priority = priority})
                end

                -- Delete unmatched commands by priority.
                for priority = 1, 3, 1 do
                    if numDeletedOrders <= 0 then
                        break
                    end
                    for i = table.getn(Matches), 1, -1 do
                        if Matches[i].Priority == priority then
                            table.remove(Matches, i)
                            table.remove(unitOrders, i + orderIndex - 1)
                            numOrders = numOrders - 1
                            nextOrderIndex = nextOrderIndex - 1
                            numDeletedOrders = numDeletedOrders - 1
                            if numDeletedOrders <= 0 then
                                break
                            end
                        end
                    end
                end

                -- Fix the positions of any moved orders.
                local positionIndex = Matches[1].Match or queueIndex
                for i = 0, nextOrderIndex - orderIndex - 1, 1 do
                    if not unitOrders[i + orderIndex].EntityId then
                        if not Matches[i + 1].Match then
                            Matches[i + 1].Match = positionIndex
                        end
                        unitOrders[i + orderIndex].Position = filteredQueue[Matches[i + 1].Match].Position
                    end
                    positionIndex = (Matches[i + 1].Match or positionIndex) + 1
                end
            end

        else
            -- No orders were deleted so just fix any moved orders with position targets.
            for i = 0, nextOrderIndex - orderIndex - 1, 1 do
                if not unitOrders[i + orderIndex].EntityId then
                    unitOrders[i + orderIndex].Position = filteredQueue[i + queueIndex].Position
                end
            end
        end

        orderIndex = nextOrderIndex
        queueIndex = nextQueueIndex
    end
end

--------------------------
-- Function SpreadMove()
--------------------------

-- This function rearranges all targeted orders randomly for every unit.
function DisperseMove()

    -- Get the currently selected units.
    local curSelection = GetSelectedUnits()

    if not curSelection then
        return
    end

	local created_distribution_table = false
	local ranonce = false
	local actiondif = 0
	local lostorders = 0
	-- Switch the orders for each unit.
    --for index,unit in ipairs(curSelection) do
	local index = 0
	while index < table.getn(curSelection) do
        index = index + 1
        local unit = curSelection[index]
        FixOrders(unit)
        local unitOrders = ShadowOrders[unit:GetEntityId()]

        -- Only mix orders if this unit has any orders to mix.
        if not unitOrders or not unitOrders[1] then
            continue
        end

        -- Find all consecutive mixable orders, and only mix those.
		local ordercount2 = table.getn(unitOrders)
        local beginAction,endAction,action,counter = nil,nil,nil,ordercount2
        local alwaysMix = {"AggressiveMove", "Guard", "Move", "Patrol", "Teleport"}

		local action2 = unitOrders[ordercount2].CommandType
        while unitOrders[counter].CommandType == action2 do
            endAction = nil
            -- Search for the first entry of a mixable order.
            while endAction == nil and unitOrders[counter] ~= nil do
                for _,v in ipairs(alwaysMix) do
                    if unitOrders[counter].CommandType == v then
						if unitOrders[counter].EntityId or unitOrders[counter].Target then
							break
						end

                        endAction = counter
                        action = unitOrders[counter].CommandType
                        actionAlwaysMixed = true
                        break
                    end
                end
                counter = counter - 1
            end

            beginAction = endAction
            -- Search for the last entry of a mixable order in this series.
            while unitOrders[counter] ~= nil do
                if unitOrders[counter].CommandType == action and not unitOrders[counter].EntityId and not unitOrders[counter].Target then
                    beginAction = counter
                    counter = counter - 1
                else
                    break
                end
            end

            -- Skip if there was no mixable order found, or only one order (can't swap one command).
            if endAction == nil or beginAction == endAction then
                break
            end

			if index == 1 and not ranonce then
				actiondif = endAction - beginAction
			end
			if endAction - beginAction > actiondif then
				actiondif = endAction - beginAction
			end
			local ahead = actiondif - (endAction - beginAction)

			lostorders = 0

			if created_distribution_table then
				if orderDistribution[index] - ahead > beginAction - 1 then -- if unit didnt already get to first order given by player (is not ahead), distribute normally
					unitOrders[beginAction], unitOrders[orderDistribution[index] - ahead] = unitOrders[orderDistribution[index] - ahead], unitOrders[beginAction]
				end
				if orderDistribution[index] - ahead <= beginAction - 1 then
					lostorders = 1
				end
			end

			if not created_distribution_table and ahead == 0 and ranonce then
				orderDistribution = {}
				for i = 0, table.getn(curSelection) do
					orderDistribution[i] = -1
				end
				created_distribution_table = true
				for i0 = 0, math.floor((table.getn(curSelection) / (actiondif + 1))) do
					for i = beginAction, endAction do -- For all orders find closest unit to them that isnt taken
						cunit = index
						cunitdis = 1000000000000000000000000

						oposition = unitOrders[i].Position
						for i2 = 1, table.getn(curSelection) do -- Run thru all the units looking for closest to order that isnt taken
							if orderDistribution[i2] == -1 and curSelection[i2].ahead < i - beginAction then -- Dont bother with units that are already taken, waste of cpu calculating distance
								position = curSelection[i2]:GetPosition()
								if curSelection[i2].unitOrders[beginAction - 1] ~= nil then -- If this unit has non move order queued prior to move orders, use that order's position to determine closest queued move order instead
									position = curSelection[i2].unitOrders[beginAction - 1].Position
								end
								cdis = VDist3Sq(position, oposition)
								if cdis < cunitdis then
										cunitdis = cdis
										cunit = i2
								end
							end
						end
						orderDistribution[cunit] = i
					end
				end
				index = 0
			end
			if index == table.getn(curSelection) and not ranonce then
				ranonce = true
				index = 0
			end

			--[[ Index based order distribution

			--Unit index is number describing which unit from select units is currently being given orders
			--For each unit use its index to select which order from order queue should be that unit's first order (rest get deleted afterwards), this completely evens out units between orders in queue
			--If there are more orders than units, the later in queue orders will be deleted afterwards and units will be distributed between first orders in queue until all units have at least 1 different order


			local indexorder = beginAction + index
			--If there are more units than orders, skip back to start of order queue once last order in order queue is given to a unit and select orders from start of order queue for next unit
            while indexorder > endAction do
                indexorder = indexorder - endAction
				indexorder = indexorder + beginAction - 1 -- + beginAction to not include all other orders queued prior to move orders, -1 to not mess up first move order given by player
            end

			unitOrders[beginAction]=unitOrders[indexorder]
			]]--

            -- Repeat this loop and search for more mixable order series.
        end

		--Remove all orders except first one, because this is disperse move not spread move
		if created_distribution_table then
			if lostorders == 0 then
				for i = beginAction + 1, endAction do
					table.remove(unitOrders,i)
				end
			end
			if lostorders == 1 then -- should delete all orders but apparently that does nothing and units just keep whole queue, so just randomize their orders instead
				local indexorder = beginAction + index
				--If there are more units than orders, skip back to start of order queue once last order in order queue is given to a unit and select orders from start of order queue for next unit
				while indexorder > endAction do
					indexorder = indexorder - endAction
					indexorder = indexorder + beginAction - 1 -- + beginAction to not include all other orders queued prior to move orders, -1 to not mess up first move order given by player
				end

				unitOrders[beginAction]=unitOrders[indexorder]
				for i = beginAction + 1, endAction do
					table.remove(unitOrders,i)
				end
			end
		end

		   		--[[
		   counter = endAction
		while counter > beginAction do
			table.remove(unitOrders, counter)
			counter = counter - 1
		end
		]]

        -- All targeted orders have been mixed, now it's time to reassign those orders.
        -- Since giving orders is a Sim-side command, use a SimCallback function.
        SimCallback( {
                Func = "GiveOrders",
                Args = {
                    unit_orders = unitOrders,
                    unit_id     = unit:GetEntityId(),
                    From = GetFocusArmy()
                }
            }, false)

        -- Handle the next unit.
    end
end
