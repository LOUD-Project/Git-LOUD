
local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 
local tablemerged = false

do

local OldLOC = LOC

function LOC(s)
		
    if not tablemerged then 
		local temp_table = table.merged(__DMSI.__DMod_LocLookUp[__language], loc_table)
		loc_table = temp_table
		tablemerged = true
	end
	
	return OldLOC(s)
end


end