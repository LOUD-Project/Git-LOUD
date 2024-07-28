-- creates a button that sequentially upgrades mass extractors

local Button = import('/lua/maui/button.lua').Button
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

function CreateButton(parent)
   -- create the button
   local myButton = Button(parent, UIUtil.UIFile('/game/resources/mass_btn_up.dds'), UIUtil.UIFile('/game/resources/mass_btn_down.dds'), UIUtil.UIFile('/game/resources/mass_btn_over.dds'), UIUtil.UIFile('/game/resources/mass_btn_dis.dds'))
   LayoutHelpers.AtLeftTopIn(myButton, parent, 340)
   myButton.Depth:Set(4)
   Tooltip.AddButtonTooltip(myButton, 'seq_mex_upgrade')
   
   -- onclick handler
   myButton.OnClick = function()
      local myUnits = import('/lua/ui/game/gamemain.lua').GetSeqUpgradeList()
      if not table.empty(myUnits) then
         -- need to fork to the function because it uses WaitSeconds()
         ForkThread(UpgradeBuildings, myUnits)
      end
   end
end

local commandmode = import('/lua/ui/game/commandmode.lua')
isAutoSelection = false      -- set to true while modifying user selection to issue upgrade command

function UpgradeBuildings(units)
   for index, unit in ipairs(units) do
      if not unit:IsDead() then
         -- save current selection
         local selection = GetSelectedUnits()
         
         local currentCommand = commandmode.GetCommandMode()
         isAutoSelection = true
         
         -- select unit and issue upgrade command
         SelectUnits( {unit} )
         IssueBlueprintCommand("UNITCOMMAND_Upgrade", unit:GetBlueprint().General.UpgradesTo, 1, false)
         -- lua IssueUpgrade({unit}, unit:GetBlueprint().General.UpgradesTo)
         
         -- restore previous selection
         SelectUnits(selection)
         
         commandmode.StartCommandMode(currentCommand[1], currentCommand[2])
         isAutoSelection = false
         
         -- loop until unit is upgraded or dead (both are conveniently checked by IsDead())
         while not unit:IsDead() do
            -- return if upgrade was stopped
            if unit:IsIdle() then
               return
            end
            WaitSeconds(1)
         end
      end
   end
end 