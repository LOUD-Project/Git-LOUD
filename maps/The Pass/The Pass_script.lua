local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua') 

function OnPopulate()
	ScenarioUtils.InitializeArmies()


   local tblArmy = ListArmies() 
    
for index,army in tblArmy 
do 
   ScenarioFramework.RestrictEnhancements({'Teleporter'})
end 



--start of map script 
function OnStart(self) 
end 


--

end