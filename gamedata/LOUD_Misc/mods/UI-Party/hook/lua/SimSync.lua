local oldResetSyncTable = ResetSyncTable

ResetSyncTable = function()
    oldResetSyncTable()
    
	Sync.FixedEcoData = {}
end