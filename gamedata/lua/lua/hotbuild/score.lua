-- File: score.lua 
local scoreData = {} 

function UpdateScoreData(newData) 
  scoreData = table.deepcopy(newData) 
end 

function GetScoreData() 
  return scoreData 
end