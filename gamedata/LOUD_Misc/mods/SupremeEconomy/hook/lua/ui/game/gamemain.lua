local originalCreateUI = CreateUI
local modFolder = 'SupremeEconomy'
local UpdateAllUnits = import('/mods/' .. modFolder .. '/modules/mciallunits.lua').UpdateAllUnits

function CreateUI(isReplay)

  originalCreateUI(isReplay)

  local parent = import('/lua/ui/game/borders.lua').GetMapGroup()

  AddBeatFunction(UpdateAllUnits)

  import('/mods/' .. modFolder .. '/modules/resourceusage.lua').CreateModUI(isReplay, parent)
  import('/mods/' .. modFolder .. '/modules/mexes.lua').CreateModUI(isReplay, parent)

end
