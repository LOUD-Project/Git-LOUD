do
   
   -- when this script loads, get the original CreateUI function
   local originalCreateUI = CreateUI
   
   function CreateUI(isReplay)
      -- call the original function first to set up the rest of the game UI
      originalCreateUI(isReplay)
      
      -- get the map group control to attach my new panel to
      local parent = import('/lua/ui/game/economy.lua').GUI.bg
      
      -- create the button, note that imports are not hooked, so we need to specify the location of our file in the mod 
      import('/Mods/V2ExtractorUpgrades/modules/newstuff.lua').CreateButton(parent)
   end
   
   local oldOnSelectionChanged = OnSelectionChanged
   local seqUpgradeList = {}
   local listStarted = false
   
   function OnSelectionChanged(oldSelection, newSelection, added, removed)
      if not import('/Mods/V2ExtractorUpgrades/modules/newstuff.lua').isAutoSelection then
         -- original function
         oldOnSelectionChanged(oldSelection, newSelection, added, removed)
         
         if table.getn(added) == 1 and added[1]:GetBlueprint().General.UpgradesTo ~= "" then
            -- keep a list of upgradeable units
            -- added one by one to selection
            if table.getn(newSelection) == 1 then
               seqUpgradeList = newSelection
               listStarted = true
            elseif listStarted then
               table.insert(seqUpgradeList, added[1])
            end
         elseif listStarted then
            -- check if stored units were deselected
            for i, unit in removed do
               local index = table.find(seqUpgradeList, unit)
               if index then
                  table.remove(seqUpgradeList, index)
               end
            end
            if table.empty(seqUpgradeList) then
               listStarted = false
            end
         end
      end
      
      -- logs
      --[[local listById = {}
      for i, unit in seqUpgradeList do
         if not unit:IsDead() then
            table.insert(listById, unit:GetEntityId())
         end
      end
      LOG(repr(listById))]]
   end
   
   function GetSeqUpgradeList()
      local selection = GetSelectedUnits() or {}
      
      -- if selected and saved units are not the same
      -- they will be upgraded in random order
      if table.getn(selection) ~= table.getn(seqUpgradeList) then
         return selection
      --[[else
         for i, unit in seqUpgradeList do
            if not table.find(selection, unit) then
               return selection
            end
         end]]
      end
      
      -- otherwise upgrade by order of selection
      local curUpgradeList = table.copy(seqUpgradeList)
      return curUpgradeList
   end
   
end 