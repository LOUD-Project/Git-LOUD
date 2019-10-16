local original_UpdateScoreData = UpdateScoreData 

function UpdateScoreData(newData) 
  original_UpdateScoreData(newData) 
  
  import('/mods/hotbuild/allunits.lua').UpdateScoreData(newData) 
end