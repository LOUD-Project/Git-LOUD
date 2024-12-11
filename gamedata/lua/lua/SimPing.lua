local IsAIArmy = import('/lua/ai/sorianutilities.lua').IsAIArmy

local LOUDSIN = math.sin
local LOUDINSERT = table.insert
local ForkThread = ForkThread

-- max number of markers for EACH player
MaxPingMarkers = 50
-- table monitors lock of PING functions for EACH player
local PingLocked = {}
-- table holds all markers for each player
local PingMarkers = {}

--On first ping, send data to the user layer telling it the maximum allowable markers per player
Sync.MaxPingMarkers = MaxPingMarkers

function AnimatePingMesh(entity)
    local time = 0
    
    while entity do
        entity:SetScale(MATH_Lerp(LOUDSIN(time), -.5, 0.5, .3, .5))
        time = time + .3
        WaitSeconds(.001)
    end
end

-- initially this function used to be global and it would lock ALL ping functions for 1 second
-- every time a ping was issued (by anyone)

-- I've made it user specific now, and I've shortened the lock period to 1 tick from 1 full second
-- this should pretty much eliminate 'lost ping events' and missing markers but it's still possible
-- but only in the circumstance where the same user pings more than once in a tick -- the AI can do it
function SpawnPing(data)

    if not PingLocked[data.Owner] then
		
		-- if marker table is full
        if data.Marker and PingMarkers[data.Owner] and table.getsize(PingMarkers[data.Owner]) >= MaxPingMarkers then
			LOG("*AI DEBUG Marker table is full for "..PingMarkers[data.Owner] )
            return
			
		-- if no marker table create it
        elseif data.Marker and not PingMarkers[data.Owner] then
            PingMarkers[data.Owner] = {}
			PingLocked[data.Owner] = false
        end
		
		-- lock ping functions for this user
        PingLocked[data.Owner] = true
		
		local AvailableMarker = false
		
		local current_user = GetFocusArmy()

		-- If we're placing a marker --
        if data.Marker then
		
			-- get the first available index for this owner
			-- THIS SHOULD BE FALSE BY DEFAULT AND MOVED INSIDE THE PLACING MARKER BRANCH
			AvailableMarker = GetPingID(data.Owner)
		
			if AvailableMarker then
		
				-- remove any marker with same name at same position
				for v,q in PingMarkers[data.Owner] do

					if q.Name and q.Name == data.Name and q.Location[1] == data.Location[1] and q.Location[3] == data.Location[3] then
						PingMarkers[data.Owner][v] = nil
					end
				end
			
				-- store the index with the marker so it can be more easily removed if need be
				data.ID = AvailableMarker

				PingMarkers[data.Owner][AvailableMarker] = table.copy(data)
				
			end
			
		-- other ping events --
		else
		--[[
            local Entity = import('/lua/sim/Entity.lua').Entity
			
            data.Location[2] = data.Location[2]+2
			
            local ping = Entity( {Owner = data.Owner, Location = data.Location} )
			
            Warp(ping, Vector(data.Location[1], data.Location[2], data.Location[3]))
			
            ping:SetVizToFocusPlayer('Always')
            ping:SetVizToEnemies('Never')
            ping:SetVizToAllies('Always')
            ping:SetVizToNeutrals('Never')
            ping:SetMesh('/meshes/game/ping_'..data.Mesh)
			
            local animThread = ForkThread(AnimatePingMesh, ping)
			
            ForkThread(function() WaitSeconds(data.Lifetime) KillThread(animThread) ping:Destroy() end)
        --]]
        end
		

		if current_user != -1 then
			SendData( data, current_user )
		end

        for num,brain in ArmyBrains do
		
			-- if not the owner but an Ally of the owner
            if data.Owner + 1 ~= num and IsAlly( num, data.Owner + 1) then
			
                ArmyBrains[num]:DoPingCallbacks( data )
				
				-- if the owner of the message is human then process the ping
				
				-- this is where the Sorian AI responds to pings from human allies
				if not IsAIArmy(data.Owner + 1) then
					ArmyBrains[num]:DoAIPing( data )
				end
            end
        end
		
		-- this function will unlock Ping functions after 2 ticks
        ForkThread(function() WaitTicks(2) PingLocked[data.Owner] = false end)
		
		-- if we used a PingMarker entry then return the value
		if AvailableMarker then
			return AvailableMarker
		end
	else
        LOG("*AI DEBUG Ping Markers was locked for Owner "..repr(data.Owner) )
    end
end

-- this should give us the first available ID# for this owners pingmarker table
-- between 1 and the maximum number of Ping Markers (25)
function GetPingID(owner)
	
    for i = 1, MaxPingMarkers do
		
        if not PingMarkers[owner][i] then
            return i
        end
    end
	
    return false
end

function OnArmyDefeat(armyID)

    armyID = armyID - 1
	
    if PingMarkers[armyID] then
	
        for i, v in PingMarkers[armyID] do
            UpdateMarker({Action = 'delete', ID = i, Owner = v.Spec.Owner})
        end
		
    end
end

function OnArmyChange()

    Sync.MaxPingMarkers = MaxPingMarkers

    --Flush all of the current markers on the UI side
    if not Sync.Ping then
		Sync.Ping = {}
	end
	
    table.insert(Sync.Ping, {Action = 'flush'})
	
    --Add All of the relevant marker data on the next sync
	local current_user = GetFocusArmy()
	
    ForkThread(function()
	
		WaitTicks(2) -- this is here to insure that the flush has taken place first

        for ownerID, pingTable in PingMarkers do
			
            if current_user != -1 and IsAlly( ownerID+1, current_user ) then
		
                for pingID, ping in pingTable do
					
                    ping.Renew = true
                    SendData( ping, current_user )
                end
            end
        end
    end)

end

function OnAllianceChange()
    OnArmyChange()
end

function UpdateMarker(data)

    if PingMarkers[data.Owner][data.ID] or data.Action == 'renew' then
	
		local current_user = GetFocusArmy()
	
        if data.Action == 'delete' then 
            PingMarkers[data.Owner][data.ID] = nil
			
        elseif data.Action == 'move' then
            PingMarkers[data.Owner][data.ID].Location = data.Location
			
        elseif data.Action == 'rename' then
            PingMarkers[data.Owner][data.ID].Name = data.Name
			
        elseif data.Action == 'renew' then
		
            ForkThread(function()
				
                for ownerID, pingTable in PingMarkers do
					-- if Ally then renew ping 
                    if current_user != -1 and IsAlly( ownerID + 1, current_user) then
					
                        for pingID, ping in pingTable do
                            ping.Renew = true
                            SendData( ping, current_user )
                        end
                    end
                end
            end)
			
            return
        end
		
        SendData(data, current_user)
    end
end

function SendData(data, current_user)

	if current_user != -1 then
	
        if IsAlly( data.Owner+1, current_user) then
		
            if not Sync.Ping then
				Sync.Ping = {}
			end
			
            LOUDINSERT(Sync.Ping, data)
        end
    end
end