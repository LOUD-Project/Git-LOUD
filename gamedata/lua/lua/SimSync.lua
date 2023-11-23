LOG("*DEBUG Loading LOUD SimSync")

-- The global sync table is copied to the user layer every time the main and sim threads are
-- synchronized on the sim beat (which is like a tick but happens even when the game is paused)
Sync = {}

-- UnitData that has been synced. We keep a separate copy of this so when we change
-- focus army we can resync the data.
UnitData = {}

local SimData = { SimSpeed = 0 }


function ResetSyncTable()

    Sync = {
        CameraRequests = {},
        Sounds = {},
        Voice = {},
		AIChat = {},

        -- Table of army indices set to "victory" or "defeat".
        GameResult = {},
		
		-- track scores
		Score = {},
		
        -- Player to player queries that can affect the Sim
        PlayerQueries = {},
        QueryResults = {},

        -- Contain operation data when op is complete
        OperationComplete = nil,
        
        UnitData = {},
        ReleaseIds = {},
        
        -- from DMS --
        PlayMFDMovieMP = false,
        SetupMFDMovieMP = {},
    }

	Sync.SimData = SimData

end

-- from DMS --
function DoMFD(speaker, video, callback, critical)

--	local army = false
	
	--if speaker and not speaker:IsDead() then 
		--army = speaker:GetArmy()
	--end

	--if not army or army == GetFocusArmy() then
		--local video_setup = import('/mods/Domino_Mod_Support/lua/mfd_video/setup_video.lua')
		--video_setup.DialogueMP(speaker:GetEntityId(), video, callback, critical)
	--end
end

-- this function updates the SimSpeed field of SimData
function UpdateSimSpeed(data)

	--LOG("*AI DEBUG SIMSYNC UpdateSimSpeed "..repr(data))

	if data then
		SimData.SimSpeed = data
	end
end

-- this function will set a specific SimData field
function SetSimData(name, param)

    LOG("*AI DEBUG SIMSYNC SetSimData "..repr(name).." "..repr(param))
    
	SimData[name] = param
	
	SendSimData()
end

-- this function can be called to get a specific SimData field
function GetSimData(name)

	LOG("*AI DEBUG Sim GetSimData "..repr(name))
	
	if SimData[name] then
		return SimData[name]
	else
		return nil
	end
end

-- this puts the SimData into the Sync table
function SendSimData()

	LOG("*AI DEBUG SIMSYNC SendSimData "..repr(SimData) )
	
	Sync.SimData = SimData
end



-- I brought all this in from the SCHOOK version of SimSync
-- and eliminated the schook version
SimUnitEnhancements = {}

function AddUnitEnhancement(unit, enhancement, slot)
    if not slot then return end
    local id = unit:GetEntityId()
    local unitEnh = SimUnitEnhancements[id]
    if unitEnh then
        SimUnitEnhancements[id][slot] = enhancement
    else
        SimUnitEnhancements[id] = {}
        SimUnitEnhancements[id][slot] = enhancement
    end
    SyncUnitEnhancements()
end

function RemoveUnitEnhancement(unit, enhancement)
    if not unit or unit.Dead then
		return
	end
	
    local id = unit:GetEntityId()
    local slots = SimUnitEnhancements[id]
	
    if not slots then
		return
	end
	
    local key = nil
	
    for k, v in slots do
        if v == enhancement then
            key = k
        end
    end
	
    if SimUnitEnhancements[id][key] then
        SimUnitEnhancements[id][key] = nil
    end
    
    if table.empty(slots) then
        SimUnitEnhancements[id] = nil
    end
    
    SyncUnitEnhancements()
end

function RemoveAllUnitEnhancements(unit)
    local id = unit:GetEntityId()
    SimUnitEnhancements[id] = nil
    SyncUnitEnhancements()
end

function SyncUnitEnhancements()
    import('/lua/enhancementcommon.lua').SetEnhancementTable(SimUnitEnhancements)
    Sync.UserUnitEnhancements = SimUnitEnhancements
end

function DebugMoveCamera(x0,y0,x1,y1)
    local Camera = import('/lua/simcamera.lua').SimCamera
    local cam = Camera("WorldCamera")
--#    cam:ScaleMoveVelocity(0.02)
    cam:MoveTo(Rect(x0,y0,x1,y1),5.0)
end

function SyncPlayableRect(rect)
    local Camera = import('/lua/simcamera.lua').SimCamera
    local cam = Camera("WorldCamera")
    cam:SyncPlayableRect(rect)
end

function LockInput()
    Sync.LockInput = true
end

function UnlockInput()
    Sync.UnlockInput = true
end

function OnPostLoad()

    local focus = GetFocusArmy()
    
    for entityID, data in UnitData do 

        if data.OwnerArmy == focus then
            Sync.UnitData[entityID] = data.Data
        end
    end

    Sync.IsSavedGame = true
end

function NoteFocusArmyChanged(new, old)
    #LOG('NoteFocusArmyChanged(new=' .. repr(new) .. ', old=' .. repr(old) .. ')')
    import('/lua/simping.lua').OnArmyChange()
    for entityID, data in UnitData do 
        if data.OwnerArmy == old then
            Sync.ReleaseIds[entityID] = true
        elseif data.OwnerArmy == new then
            Sync.UnitData[entityID] = data.Data
        end
    end
    Sync.FocusArmyChanged = {new = new, old = old}
end

function FloatingEntityText(entityId, text)

	local unit = GetEntityById(entityId)
	
    if unit and not unit:BeenDestroyed() then
	
		if unit:GetArmy() == GetFocusArmy() or GetFocusArmy() == -1 then
		
			if not Sync.FloatingEntityText then
				Sync.FloatingEntityText = {}
			end
			table.insert(Sync.FloatingEntityText, {entity = entityId, text = text})
		end
    end
end

function StartCountdown(entityId)
    if not entityId then
        WARN('Trying to start countdown text with no entityId.')
        return false
    else
        if GetEntityById(entityId):GetArmy() == GetFocusArmy() then
            if not Sync.StartCountdown then Sync.StartCountdown = {} end
            table.insert(Sync.StartCountdown, {entity = entityId})
        end
    end
end

function CancelCountdown(entityId)
    if not entityId then
        WARN('Trying to Cancel Countdown text with no entityId.')
        return false
    else
        if GetEntityById(entityId):GetArmy() == GetFocusArmy() then
            if not Sync.CancelCountdown then Sync.CancelCountdown = {} end
            table.insert(Sync.CancelCountdown, {entity = entityId})
        end
    end
end

function HighlightUIPanel(panel)
    if not Sync.HighlightUIPanel then Sync.HighlightUIPanel = {} end
    table.insert(Sync.HighlightUIPanel, panel)
end

function ChangeCameraZoom(newMult)
    Sync.ChangeCameraZoom = newMult
end

function CreateCameraMarker(position)
    return import('/lua/simcameramarkers.lua').AddCameraMarker(position)
end

function PrintText(text, fontSize, fontColor, duration, location)
    if not text and location then
        WARN('Trying to print text with no string or no location.')
        return false
    else
        if not Sync.PrintText then Sync.PrintText = {} end
        table.insert(Sync.PrintText, {text = text, size = fontSize, color = fontColor, duration = duration, location = location})
    end
end

function CreateDialogue(text, buttonText, position)
    return import('/lua/simdialogue.lua').Create(text, buttonText, position)
end


LOG("*DEBUG LOUD SimSync complete")