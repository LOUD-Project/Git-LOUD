local originalUpdateScoreData = UpdateScoreData
local modFolder = 'SupremeEconomy'
local SEUpdateScoreData = import('/mods/' .. modFolder .. '/modules/mciscore.lua').UpdateScoreData

function UpdateScoreData(newData)

  originalUpdateScoreData(newData)

  SEUpdateScoreData(newData)
end
