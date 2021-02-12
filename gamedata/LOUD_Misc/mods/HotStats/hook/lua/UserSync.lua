local OldOnSync = OnSync

function OnSync()
	OldOnSync()

	if not table.empty(Sync.Score) then
        import('/mods/hotstats/scoreaccum.lua').UpdateScoreData(Sync.Score)
    end
    
    if Sync.FullScoreSync then
        import('/mods/hotstats/scoreaccum.lua').OnFullSync()
    end
end