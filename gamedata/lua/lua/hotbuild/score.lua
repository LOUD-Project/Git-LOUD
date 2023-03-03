-- File: score.lua 
local scoreData = {}
local LOUDDEEPCOPY = table.deepcopy 

function UpdateScoreData(newData) 
  scoreData = LOUDDEEPCOPY(newData) 
end 

function GetScoreData() 
  return scoreData 
end