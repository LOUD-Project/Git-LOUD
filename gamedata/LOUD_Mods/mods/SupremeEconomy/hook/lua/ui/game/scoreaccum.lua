local originalUpdateScoreData = UpdateScoreData
local modFolder = 'SupremeEconomy'

function UpdateScoreData(newData) 
  originalUpdateScoreData(newData)
  
  import('/mods/' .. modFolder .. '/modules/mciscore.lua').UpdateScoreData(newData)
end
