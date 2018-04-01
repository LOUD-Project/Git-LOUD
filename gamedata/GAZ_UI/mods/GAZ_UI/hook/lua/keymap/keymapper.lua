do
	function SetUserKeyMapping(key, oldKey, action)
	    local newMap = GetCurrentKeyMap()
	    newMap[key] = action
	    newMap[oldKey] = nil
	    Prefs.SetToCurrentProfile("UserKeyMap", newMap)
		local debugKeyMap = import('defaultKeyMap.lua').debugKeyMap
	    Prefs.SetToCurrentProfile("UserDebugKeyMap", debugKeyMap)
	end
	local oldClearUserKeyActions = ClearUserKeyActions
	function ClearUserKeyActions()
		LOG('CLEARING USER ACTIONS')
		oldClearUserKeyActions()
	end
end
