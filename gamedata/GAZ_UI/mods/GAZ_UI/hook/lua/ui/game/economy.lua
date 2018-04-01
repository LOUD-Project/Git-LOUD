do
    local Prefs = import('/lua/user/prefs.lua')
    local options = Prefs.GetFromCurrentProfile('options')
        local reclaimedTotalsMass = false
        local reclaimedTotalsEnergy = false
        local TextLine02 = false
        local TextLine03 = false


    if options.gui_display_reclaim_totals == 1 then
        function _BeatFunction()
            local econData = GetEconomyTotals()
            local simFrequency = GetSimTicksPerSecond()
-- fetch & format reclaim values
            reclaimedTotalsMass = math.ceil(econData.reclaimed.MASS)
            reclaimedTotalsEnergy = math.ceil(econData.reclaimed.ENERGY)

            local function DisplayEconData(controls, tableID, viewPref)
                local function FormatRateString(RateVal, StoredVal, IncomeAvg, ActualAvg, RequestedAvg)
-- expanded display to 8 digits
                    local retRateStr = string.format('%+d', math.min(math.max(RateVal, -99999999), 99999999))
                    local retEffVal = 0
                    if RequestedAvg == 0 then
                        retEffVal = math.ceil(IncomeAvg) * 100
                    else
                        if StoredVal > 0.5 then
                            retEffVal = math.ceil( (IncomeAvg / ActualAvg) * 100 )
                        else
                            retEffVal = math.ceil( (IncomeAvg / RequestedAvg) * 100 )
                        end
                    end
                    return retRateStr, retEffVal
                end

                local maxStorageVal = econData["maxStorage"][tableID]
                local storedVal = econData["stored"][tableID]
                local incomeVal = econData["income"][tableID]
                local lastRequestedVal = econData["lastUseRequested"][tableID]
                local lastActualVal = econData["lastUseActual"][tableID]
-- expanded display to 8 digits
                local requestedAvg = math.min(lastRequestedVal * simFrequency, 99999999)
                local actualAvg = math.min(lastActualVal * simFrequency, 99999999)
                local incomeAvg = math.min(incomeVal * simFrequency, 99999999)

                controls.storageBar:SetRange(0, maxStorageVal)
                controls.storageBar:SetValue(storedVal)
                controls.curStorage:SetText(math.ceil(storedVal))
                controls.maxStorage:SetText(math.ceil(maxStorageVal))


                controls.income:SetText(string.format("+%d", math.ceil(incomeAvg)))
                if storedVal > 0.5 then
                    controls.expense:SetText(string.format("-%d", math.ceil(actualAvg)))
                else
                    controls.expense:SetText(string.format("-%d", math.ceil(requestedAvg)))
                end

                local rateVal = 0
                if storedVal > 0.5 then
                    rateVal = math.ceil(incomeAvg - actualAvg)
                else
                    rateVal = math.ceil(incomeAvg - requestedAvg)
                end

                local rateStr, effVal = FormatRateString(rateVal, storedVal, incomeAvg, actualAvg, requestedAvg)
                -- CHOOSE RATE or EFFICIENCY STRING
                if States[viewPref] == 2 then
                    controls.rate:SetText(string.format("%d%%", math.min(effVal, 100)))
                else
                    controls.rate:SetText(string.format("%+s", rateStr))
                end
                -- SET RATE/EFFICIENCY COLOR
                local rateColor
                if rateVal < 0 then
                    if storedVal > 0 then
                        rateColor = 'yellow'
                    else
                        rateColor = 'red'
                    end
                else
                    rateColor = 'ffb7e75f'
                end
                controls.rate:SetColor(rateColor)

                -- ECONOMY WARNINGS
                if Prefs.GetOption('econ_warnings') and UIState then
                    if storedVal / maxStorageVal < .2 then
                        if effVal < 25 then
                            controls.warningBG:SetToState('red')
                        elseif effVal < 75 then
                            controls.warningBG:SetToState('yellow')
                        elseif effVal > 100 then
                            controls.warningBG:SetToState('hide')
                        end
                    else
                        controls.warningBG:SetToState('hide')
                    end
                else
                    controls.warningBG:SetToState('hide')
                end
            end
            DisplayEconData(GUI.mass, 'MASS', 'massViewState')
            DisplayEconData(GUI.energy, 'ENERGY', 'energyViewState')

-- display reclaim values
            TextLine02:SetText(reclaimedTotalsMass)
            TextLine03:SetText(reclaimedTotalsEnergy)

        end

--display additional ui
        function CreateExtraUI()
            ecostats = Bitmap(GetFrame(0))
            ecostats:SetTexture('/textures/ui/common/game/economic-overlay/econ_bmp_m.dds')
            ecostats.Depth:Set(99)
            LayoutHelpers.AtLeftTopIn(ecostats, GetFrame(0), 340, 8)
            ecostats.Height:Set(36)
            ecostats.Width:Set(80)
            ecostats:DisableHitTest(true)
            local TextLine01 = UIUtil.CreateText(ecostats, 'reclaimed', 10, UIUtil.bodyFont)
            LayoutHelpers.CenteredAbove(TextLine01, ecostats, -12)
            TextLine02 = UIUtil.CreateText(ecostats, '', 10, UIUtil.bodyFont)
            TextLine02:SetColor('FFB8F400')
            LayoutHelpers.AtRightTopIn(TextLine02, ecostats, 4, 10)
            TextLine03 = UIUtil.CreateText(ecostats, '', 10, UIUtil.bodyFont)
            TextLine03:SetColor('FFF8C000')
            TextLine01:DisableHitTest(true)
            TextLine02:DisableHitTest(true)
            TextLine03:DisableHitTest(true)
            LayoutHelpers.AtRightTopIn(TextLine03, ecostats, 4, 20)
        end

        local OldCreateUI = CreateUI
        function CreateUI()
            OldCreateUI()
            CreateExtraUI()
        end
    end



    if options.gui_smart_economy_indicators == 1 then


--THYGRRR
--* CHANGES
--*
--* Rate display works differently now. Efficiency is "infinite" when consumption is zero.
--* Values greater than 100% are possible again.
--* Mass rate begins to flash bright white if stored mass is > 80% and rate is climbing
--* Energy rate begins to flash bright white if stored energy is < 20% and rate is sinking
--* Mass and energy bars are vertically exchanged (mass is heavier, thus it is below energy - TA style)
--* Mass bar, as well as income and store numbers, are gray - TA style
--ghaleon
--changed 6 digit display to 8 digits, max energy displayed is 99999999.
--added reclaim window 

        local filteredEnergy = 1
        local filteredMass = 1
        local fullFlag = false
        local emptyFlag = false

        function _BeatFunction()
            local econData = GetEconomyTotals()
            local simFrequency = GetSimTicksPerSecond()
            if options.gui_display_reclaim_totals == 1 then
                reclaimedTotalsMass = math.ceil(econData.reclaimed.MASS)
                reclaimedTotalsEnergy = math.ceil(econData.reclaimed.ENERGY)
            end


            local function DisplayEconData(controls, tableID, viewPref, filtered, warnfull)
                local maxStorageVal = econData["maxStorage"][tableID]
                local storedVal = econData["stored"][tableID]
                local incomeVal = econData["income"][tableID]
                local lastRequestedVal = econData["lastUseRequested"][tableID]
                local lastActualVal = econData["lastUseActual"][tableID]

                local requestedAvg = math.min(lastRequestedVal * simFrequency, 99999999)
                local actualAvg = math.min(lastActualVal * simFrequency, 99999999)
                local incomeAvg = math.min(incomeVal * simFrequency, 99999999)

                controls.storageBar:SetRange(0, maxStorageVal)
                controls.storageBar:SetValue(storedVal)
                controls.curStorage:SetText(math.ceil(storedVal))
                controls.maxStorage:SetText(math.ceil(maxStorageVal))

                controls.income:SetText(string.format("+%d", math.ceil(incomeAvg)))
                if (storedVal > 0.5) then
                    controls.expense:SetText(string.format("-%d", math.ceil(actualAvg)))
                else
                    controls.expense:SetText(string.format("-%d", math.ceil(requestedAvg)))
                end

                local rateVal = 0
                if storedVal > 0.5 then
                    rateVal = math.ceil(incomeAvg - actualAvg)
                else
                    rateVal = math.ceil(incomeAvg - requestedAvg)
                end


                -- CHANGED by THYGRRR: Effective value calculation and rate calculation separated.
                local rateStr = string.format('%+d', math.min(math.max(rateVal, -99999999), 99999999))
                local effVal = 0
                if (options.gui_smart_economy_indicators == 1) then
                    -- CHANGED BY THYGRRR: inlined local function to facilitate easier filtering
                    if (requestedAvg == 0) then
                        effVal = "infinite"
                    else
                        if (storedVal > 0.5) then
                            filtered = filtered * 0.95 + (incomeAvg / actualAvg) * 0.05
                            effVal = string.format("%d%%", math.ceil(filtered * 100))
                        else
                            filtered = filtered * 0.95 + (incomeAvg / requestedAvg) * 0.05
                            effVal = string.format("%d%%", math.ceil(filtered * 100))
                        end
                    end
                else
                    -- CHANGED BY THYGRRR: option turned off, normal behavior (re-coded though)
                    if (requestedAvg == 0) then
                        effVal = "100%"
                        filtered = 1.0
                    else
                        if (storedVal > 0.5) then
                            filtered = (incomeAvg / actualAvg)
                            effVal = string.format("%d%%", math.min(math.ceil(filtered * 100), 100))
                        else
                            filtered = (incomeAvg / requestedAvg)
                            effVal = string.format("%d%%", math.min(math.ceil(filtered * 100), 100))
                        end
                    end
                end

                -- CHOOSE RATE or EFFICIENCY STRING - CHANGED BY THYGRRR: Allow more than 100% - removed: math.min(effVal, 100)
                if States[viewPref] == 2 then
                    controls.rate:SetText(effVal)
                else
                    controls.rate:SetText(string.format("%+s", rateStr))
                end

                -- SET RATE/EFFICIENCY COLOR
                local rateColor
                if (rateVal < 0) then
                    if (options.gui_smart_economy_indicators == 1) and (not warnfull) and (storedVal / maxStorageVal < 0.2) then
                        --THYGRRR: display flashing gray-white if low on resource and warnfull is false ('warnempty')
                        if (emptyFlag) then
                            emptyFlag = false
                            rateColor = 'ff404040'
                        else
                            emptyFlag = true
                            rateColor = 'ffffffff'
                        end
                    else
                        -- SITUATION SPECIFIC COLOR CODE, modified to use filtered value and go red below 50%, and green above 80%
                        if (options.gui_smart_economy_indicators == 1) then
                            if (filtered > 0.8) and (warnfull) then
                                rateColor = 'ffb7e75f'
                            else
                                if (filtered > 0.5) then
                                    rateColor = 'yellow'
                                else
                                    rateColor = 'red'
                                end
                            end
                        else
                            -- OLD COLOR CODE
                            if (rateVal < 0) then
                                if (storedVal > 0) then
                                    rateColor = 'yellow'
                                else
                                    rateColor = 'red'
                                end
                            else
                                rateColor = 'ffb7e75f'
                            end
                        end
                    end
                else
                    if (options.gui_smart_economy_indicators == 1) and (warnfull) and (storedVal / maxStorageVal > 0.8) then
                        --THYGRRR: display flashing gray-white if high on resource and warnfull is true
                        if (fullFlag) then
                            fullFlag = false
                            rateColor = 'ff404040'
                        else
                            fullFlag = true
                            rateColor = 'ffffffff'
                        end
                    else
                        -- ORIGINAL COLOR CODE
                        rateColor = 'ffb7e75f'
                    end
                end
                controls.rate:SetColor(rateColor)

                -- ECONOMY WARNINGS
                -- CHANGED BY THYGRRR: Use the filtered value, which is cleaner
                if Prefs.GetOption('econ_warnings') and UIState then
                    if (warnfull) and (options.gui_smart_economy_indicators == 1) then
                        if (storedVal / maxStorageVal > 0.8) then
                            if (filtered > 2.0) then
                                controls.warningBG:SetToState('red')
                            elseif (filtered > 1.0) then
                                controls.warningBG:SetToState('yellow')
                            elseif (filtered < 1.0) then
                                controls.warningBG:SetToState('hide')
                            end
                        else
                            controls.warningBG:SetToState('hide')
                        end
                    else
                        -- original behavior
                        if (storedVal / maxStorageVal < 0.2) then
                            if (filtered < 0.25) then
                                controls.warningBG:SetToState('red')
                            elseif (filtered < 0.75) then
                                controls.warningBG:SetToState('yellow')
                            elseif (filtered > 1.0) then
                                controls.warningBG:SetToState('hide')
                            end
                        else
                            controls.warningBG:SetToState('hide')
                        end
                    end
                else
                    controls.warningBG:SetToState('hide')
                end

                return filtered
            end
            if options.gui_display_reclaim_totals == 1 then
                TextLine02:SetText(reclaimedTotalsMass)
                TextLine03:SetText(reclaimedTotalsEnergy)
            end
            filteredEnergy = DisplayEconData(GUI.energy, 'ENERGY', 'energyViewState', filteredEnergy, false)
            filteredMass = DisplayEconData(GUI.mass, 'MASS', 'massViewState', filteredMass, true)
        end

    end

end