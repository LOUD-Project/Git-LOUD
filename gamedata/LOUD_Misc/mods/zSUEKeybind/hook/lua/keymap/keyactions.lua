local KeyMapper = import('/lua/keymap/keymapper.lua')
local KeyDescriptions = import('/lua/keymap/keydescriptions.lua').keyDescriptions

if KeyDescriptions['sequentially_upgrading_extractors'] == nil then
        KeyDescriptions['sequentially_upgrading_extractors'] = 'Start Sequentially Upgrading Extractors function'
end


KeyMapper.SetUserKeyAction('sequentially_upgrading_extractors', {action = 'UI_Lua import("/mods/V2ExtractorUpgrades/modules/newstuff.lua").RunSeqUpgrades()', category = 'orders', order = 35,})