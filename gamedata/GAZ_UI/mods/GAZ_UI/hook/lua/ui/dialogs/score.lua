do
local Prefs = import('/lua/user/prefs.lua')
local profile = Prefs.GetFromCurrentProfile('Name') or 'Player'
local filename = 'Autosave' .. profile .. math.random(9999)
local si
local til = {}
local options = Prefs.GetFromCurrentProfile('options')
local sep1 = "."
local sep2 = "-"

if options.gui_auto_rename_replays != 0 and not SessionIsReplay() then

    function AutoRenameReplay()
        til = GetSpecialFileInfo(profile, LOC("<LOC Engine0030>") , 'Replay').WriteTime
        si = string.gsub(SessionGetScenarioInfo().name, "'" , "")
        if string.len(si) > 18 then
            filename = string.sub(si, 1,18 )
        else
            filename = si
        end
        for k,v in til do
            if string.len(til[k]) == 1 then
                til[k] = "0" .. til[k]
            end
        end
        til.year = string.sub(til.year ,3,4)

        CopyCurrentReplay(profile, til.year .. til.month .. til.mday .. sep2 .. til.hour .. til.minute .. " " .. filename)
    end

    local oldCreateDialog = CreateDialog
    function CreateDialog(victory, showCampaign, operationVictoryTable, midGame)
        oldCreateDialog()
        AutoRenameReplay()
    end
end
end