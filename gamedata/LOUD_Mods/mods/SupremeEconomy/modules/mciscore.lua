local replayData = {}

function UpdateScoreData(newData)
	replayData = table.deepcopy(newData)
end

function GetScore()
	return replayData
end
