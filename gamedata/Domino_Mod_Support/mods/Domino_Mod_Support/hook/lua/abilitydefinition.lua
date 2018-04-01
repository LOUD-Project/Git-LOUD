#
# Ability Definitions
#

local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 

do

local Oldabilities = abilities

abilities = table.merged(Oldabilities, __DMSI.__DMod_Custom_Abilities)

end
