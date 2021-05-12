local KeyMapper = import('/lua/keymap/keymapper.lua')
local keyDescriptions = import('/lua/keymap/keydescriptions.lua').keyDescriptions
KeyMapper.SetUserKeyAction('disperse_move', {action = "UI_Lua import('/mods/Disperse Move/modules/dispersemove.lua').DisperseMove()", category = 'orders', order = 64})
keyDescriptions['disperse_move'] = "Disperse Move"
KeyMapper.SetUserKeyAction('shift_disperse_move', {action = "UI_Lua import('/mods/Disperse Move/modules/dispersemove.lua').DisperseMove()", category = 'orders', order = 65})
keyDescriptions['shift_disperse_move'] = "Shift Disperse Move"