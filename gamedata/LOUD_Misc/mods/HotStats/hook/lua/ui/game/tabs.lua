table.insert(menus.main.singlePlayer,
    {
        action = 'ExitHotstats',
        label = 'Exit to Hotstats',
        tooltip = 'esc_stats',
    })

table.insert(menus.main.replay,
    {
        action = 'ExitHotstats',
        label = 'Exit to Hotstats',
        tooltip = 'esc_stats',
    })

table.insert(menus.main.lan,
    {
        action = 'ExitHotstats',
        label = 'Exit to Hotstats',
        tooltip = 'esc_stats',
    })

table.insert(menus.main.gpgnet,
    {
        action = 'ExitHotstats',
        label = 'Exit to Hotstats',
        tooltip = 'esc_stats',
    })


actions['ExitHotstats'] = function()
        UIUtil.QuickDialog(GetFrame(0), "<LOC EXITDLG_0003>Are you sure you'd like to exit?", 
            "<LOC _Yes>", function() import('/lua/ui/dialogs/score.lua').CreateDialog(false) end,
            "<LOC _No>", nil,
            nil, nil,
            true,
            {escapeButton = 2, enterButton = 1, worldCover = true})
    end