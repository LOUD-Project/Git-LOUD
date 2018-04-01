do
    local Prefs = import('/lua/user/prefs.lua')
    local options = Prefs.GetFromCurrentProfile('options')

    if options.gui_detailed_unitview != 0 then
        local TV = import('/mods/GAZ_UI/modules/tvcheck.lua').Init()
        if TV == false then
            local OldSetLayout = SetLayout
            function SetLayout()
                OldSetLayout()
                local controls = import('/lua/ui/game/unitview.lua').controls
                LayoutHelpers.AtLeftTopIn(controls.healthBar, controls.bg, 66, 25)
                LayoutHelpers.Below(controls.shieldBar, controls.healthBar)
                controls.shieldBar.Height:Set(14)
                LayoutHelpers.CenteredBelow(controls.shieldText, controls.shieldBar,0)
                controls.shieldBar.Height:Set(2)
                LayoutHelpers.AtLeftTopIn(controls.statGroups[1].icon, controls.bg, 70, 55)
                LayoutHelpers.RightOf(controls.statGroups[1].value, controls.statGroups[1].icon, 5)
                LayoutHelpers.Below(controls.statGroups[2].icon, controls.statGroups[1].icon,0)
-- LayoutHelpers.AtRightTopIn(controls.StorageMass, controls.bg, 145, 55)
                LayoutHelpers.RightOf(controls.statGroups[2].value, controls.statGroups[2].icon, 5)
-- LayoutHelpers.AtRightTopIn(controls.StorageEnergy, controls.bg, 145, 73)
                LayoutHelpers.Below(controls.Buildrate, controls.statGroups[2].value,1)
            end
        end
    end
end