-- File: score.lua 
local scoreData = {} 

function UpdateScoreData(newData) 
  scoreData = table.deepcopy(newData) 
end 

-- return the table of all existing units 
function GetAllUnits() 
  local unitsList = {} 
  local newCount = 0 
  local unit = nil 
  local id = 0 
-- get unit count in the score data
  --if (GetFocusArmy() ~= -1) then
  --LOG('Army-ID: ', GetFocusArmy())
  	local curCount = scoreData[GetFocusArmy()].general.currentunits.count 

	-- loop until unit count reached 
  	while newCount < curCount do 
    		unit = GetUnitById(id) 
    		if unit != nil then 
      			unitsList[newCount] = unit 
      			newCount = newCount + 1 
    		end 
    		id = id + 1 
  	end

  --end
    --LOG('Units management: units list: ', repr(unitsList)) 
  return unitsList 
end