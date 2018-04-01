local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 
local DMSI_Skins = __DMSI.__DMod_Custom_Skins
do
local OldSkins = table.merged(skins, DMSI_Skins)
skins = OldSkins
end
