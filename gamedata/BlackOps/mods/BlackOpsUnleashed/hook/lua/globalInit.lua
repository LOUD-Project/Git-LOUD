do

local EXPreloadBadIconUnits = {
	'baa0001',
   'bab0001',
   'bab0003',
   'bab0004',
   'beb0001',
   'beb0003',
   'beb0004',
   'beb0005',
   'beb0006',
   'brb0005',
   'brb0006',
   'brb0007',
   'bsb0001',
   'bsb0002',
   'bsb0003',
   'bsb0006',
   'bsl0403',
   'bsl0404',
   'xea0005',
}

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

if BOGISCheck.name == 'BlackOps Global Icon Support Mod' then
   local BlackopsIcons = import('/mods/BlackopsSupport/lua/BlackopsIconSearch.lua')
   for i, v in EXPreloadBadIconUnits do
      local EXunitID = v
      BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
   end
end

end