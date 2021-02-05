local originalUpdateScoreData = UpdateScoreData
function UpdateScoreData(newData)
  	originalUpdateScoreData(newData)
	import('/mods/CommonModTools/score.lua').Update(newData)
end
