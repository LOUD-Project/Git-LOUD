do

local EXPreloadBadIconUnits = {
	'opc1001',
	'opc1002',
	'opc2001',
	'opc5007',
	'opc5008',
	'ope2001',
	'ope2002',
	'ope6002',
	'ope6004',
	'ope6005',
	'ope6006',
	'uab5204',
	'uac1902',
	'ueb5204',
	'ueb5208',
	'urb3103',
	'urb5204',
	'urb5206',
	'uxl0021',
	'xac2301',
	'xac8001',
	'xac8002',
	'xac8003',
	'xac8101',
	'xac8102',
	'xac8103',
	'xec1908',
	'xec1909',
	'xec9001',
	'xec9002',
	'xec9003',
	'xec9004',
	'xec9005',
	'xec9006',
	'xec9007',
	'xec9008',
	'xec9009',
	'xec9010',
	'xec9011',
	'xrc2101',
	'xrc2301',
	'xrc2401',
	'xro4001',
	'xsc1601',
	'xsc1701',
	'xsc8013',
	'xsc8014',
	'xsc8015',
	'xsc8016',
	'xsc8017',
	'xsc8018',
	'xsc8019',
	'xsc8020',
	'xsc9010',
	'xsc9011',
}
--[[
local GetMyActiveMod = function( byName, byUID, byAuthor )

   for i, leMod in __active_mods do
   
      if (byName   and ( byName   == leMod.name   ))
      or (byUID    and ( byUID    == leMod.uid    ))
      or (byAuthor and ( byAuthor == leMod.author )) then
	  
         --LOG("MANIMAL\'s DEBUG: Mod infos = "..repr(leMod))
         return leMod
		 
      end
	  
   end
   
   WARN("MANIMAL\'s MOD FINDER:  Unable to get Mod Infos ! Either your mod is not installed or you have mistyped its name, UID or author.")
   
   return {}
   
end

local BOGISCheck = GetMyActiveMod( 'BlackOps Global Icon Support Mod', false, false )

--]]

--if BOGISCheck.name == 'BlackOps Global Icon Support Mod' then

	local BlackopsIcons = import('/mods/BlackopsSupport/lua/BlackopsIconSearch.lua')
	
	for i, v in EXPreloadBadIconUnits do
		local EXunitID = v
		BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
	end
	
--end

local BlackopsIcons = import('/mods/BlackopsSupport/lua/BlackopsIconSearch.lua')

BlackopsIcons.BlackopsBlueprintLocator()

end
