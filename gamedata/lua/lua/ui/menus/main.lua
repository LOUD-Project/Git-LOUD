--* File: lua/modules/ui/menus/main.lua
--* Author: Chris Blackwell, Evan Pongress | Modified By Tanksy
--* Summary: Create's the main menu screen, minus animations, music, video and with LOUD buttons.

local Bitmap            = import('/lua/maui/bitmap.lua').Bitmap
local Button            = import('/lua/maui/button.lua').Button
local EffectHelpers     = import('/lua/maui/effecthelpers.lua')
local Group             = import('/lua/maui/group.lua').Group
local LayoutHelpers     = import('/lua/maui/layouthelpers.lua')
local Mods              = import('/lua/mods.lua')
local Prefs             = import('/lua/user/prefs.lua')
local Tooltip           = import('/lua/ui/game/tooltip.lua')
local UIUtil            = import('/lua/ui/uiutil.lua')

local TOOLTIP_DELAY = 1

local menuFontColor = 'feff77' 
local menuFontColorTitle = 'EEEEEE'
local menuFontColorAlt = 'feff77'

local initial = true
local animation_active = false

function CreateUI()

    UIUtil.SetCurrentSkin('uef')

    import('/lua/ui/game/gamemain.lua').supressExitDialog = false

    local mainMenu = {}

    -- this should be shown if there are no profiles
    if not GetPreference("profile.current") then
        profileDlg = import('/lua/ui/dialogs/profile.lua').CreateDialog(function()
           	CreateUI()
        end)
        return
    end

	local menuExtras = {
		title = 'Extras',
		{
			name = '<LOC OPTIONS_0073>Credits',
			tooltip = 'options_credits',
			action = function() ButtonCredits() end,
		},
		{
			name = '<LOC OPTIONS_0086>EULA',
			tooltip = 'options_eula',
			action = function() ButtonEULA() end,
			color = menuFontColorAlt,
		},
		{
            name = '<LOC _Mod_Manager>',
            tooltip = 'mainmenu_mod',
            action = function() ButtonMod() end,
            color = menuFontColorAlt,
        },
        {
            name = 'Unit Database',
            tooltip = 'mainmenu_unitdb',
            action = function() ButtonUnitDB() end,
            color = menuFontColorAlt,
        },
		{
			name = '',
			color = menuFontColorAlt,
		},
		{
			name = '',
			color = menuFontColorAlt,
		},
		{
			name = '<LOC _Back>',
			action = function() ButtonBack() end,
			color = menuFontColorAlt,
		},
	}

	local menuTop = {
		title = '<LOC main_menu_0000>Forged Alliance',
		{
			name = '<LOC _Skirmish>',
			tooltip = 'mainmenu_skirmish',
			action = function() ButtonSkirmish() end,
		},
		{
			name = 'Direct IP',
			tooltip = 'mainmenu_mp',
			action = function() ButtonLAN() end,
		},
		{
			name = '<LOC MAINMENU_STEAM_0001>Matchmaking',
			tooltip = 'mpselect_steam',
			action = function() ButtonMatchmaking() end,
		},
		{
			name = 'Replay',
			tooltip = 'mainmenu_replay',
			action = function() ButtonReplay() end,
			color = menuFontColorAlt,
		},
		{
			name = '<LOC _Options>Options',
			tooltip = 'mainmenu_options',
			action = function() ButtonOptions() end,
			color = menuFontColorAlt,
		},
		{
			name = '<LOC tooltipui0355>Extras',
			tooltip = 'mainmenu_extras',
			action = function() ButtonExtras() end,
			color = menuFontColorAlt,
		},
		{
			name = '<LOC _Exit>',
			tooltip = 'mainmenu_exit',
			action = function() ButtonExit() end,
		},
	}

	local largestMenu = menuTop
	local mainMenuSize = table.getn(largestMenu)

	-- BACKGROUND
	local parent = UIUtil.CreateScreenGroup(GetFrame(0), "Main Menu ScreenGroup")

    local backImage = Bitmap(parent, UIUtil.UIFile('/scx_menu/main-menu/background-ACUs-blue-black.dds'))
    LayoutHelpers.FillParent(backImage, parent)
    backImage.Bottom:Set(function() return parent.Width() * 0.5625 end)
    backImage.Depth:Set(10)

    local darker = Bitmap(parent)
    LayoutHelpers.FillParent(darker, parent)
    darker:SetSolidColor('200000')
    darker:SetAlpha(.5)
    darker:Hide()

    -- BORDER, LOGO and TEXT
    local border = Group(parent, "border")
    LayoutHelpers.FillParent(border, parent)

    -- SupCom logo resizes to current resolution
    local logo = Bitmap(border, UIUtil.UIFile('/scx_menu/logo/logo.dds'))
    LayoutHelpers.AtHorizontalCenterIn(logo, border)
    LayoutHelpers.AtTopIn(logo, border)
    logo.Depth:Set(60)

    -- Version text
    local gameVersionText = UIUtil.CreateText(border, "Game Version: "..GetVersion(), 14, UIUtil.bodyFont)
    gameVersionText:SetColor('677983')
    LayoutHelpers.AtLeftTopIn(gameVersionText, border, 0, 0)
    gameVersionText.Depth:Set(border.Depth() + 10)

    local loudVersion = import('/lua/AI/CustomAIs_v2/ExtrasAI.lua').AI.Version
    local loudVersionText = UIUtil.CreateText(border, "LOUD Version: "..loudVersion, 14, UIUtil.bodyFont)
    loudVersionText:SetColor('677983')
    LayoutHelpers.Below(loudVersionText, gameVersionText)
    loudVersionText.Depth:Set(border.Depth() + 11)

    -- Borders
    local topBorder = Bitmap(logo, UIUtil.UIFile('/scx_menu/main-menu/border-console-top_bmp.dds'))
    LayoutHelpers.AtHorizontalCenterIn(topBorder, border)
    LayoutHelpers.AtTopIn(topBorder, border)
    topBorder.Depth:Set(function() return logo.Depth() - 1 end)

    local botBorderLeft = Bitmap(logo, UIUtil.UIFile('/scx_menu/main-menu/border-bot-left.dds'))
    LayoutHelpers.AtLeftIn(botBorderLeft, border)
    LayoutHelpers.AtBottomIn(botBorderLeft, border)

    local botBorderRight = Bitmap(logo, UIUtil.UIFile('/scx_menu/main-menu/border-bot-right.dds'))
    LayoutHelpers.AtRightIn(botBorderRight, border)
    LayoutHelpers.AtBottomIn(botBorderRight, border)

    local botBorderMiddle = Bitmap(logo, UIUtil.UIFile('/scx_menu/main-menu/border-bot-mid.dds'))
    LayoutHelpers.AtBottomIn(botBorderMiddle, border)
    botBorderMiddle.Left:Set(botBorderLeft.Right)
    botBorderMiddle.Right:Set(botBorderRight.Left)

    local scrollingBG = Bitmap(botBorderLeft)
    scrollingBG:SetSolidColor('ff000000')
    scrollingBG.Left:Set(function() return botBorderLeft.Right() - 30 end)
    scrollingBG.Right:Set(function() return botBorderRight.Left() + 30 end)
    scrollingBG.Height:Set(20)
    LayoutHelpers.AtBottomIn(scrollingBG, border)

    -- legal text
    local legalText = UIUtil.CreateText(botBorderLeft, import('/lua/ui/help/eula.lua').LEGAL_TEXT, 9, UIUtil.bodyFont)
    legalText:SetColor('ffa5a5a5')
    legalText.Depth:Set(function() return botBorderLeft.Depth() - 1 end)
    scrollingBG.Depth:Set(function() return legalText.Depth() - 1 end)
    LayoutHelpers.AtBottomIn(legalText, border, 3)
    legalText.Left:Set(botBorderRight.Right)
    legalText:SetDropShadow(true)
    legalText:SetNeedsFrameUpdate(true)
    legalText.OnFrame = function(self, delta)
        local newLeft = math.floor(self.Left() - (delta * 50))
        if newLeft + self.Width() < botBorderLeft.Left() then
            newLeft = botBorderRight.Right()
        end
        self.Left:Set(newLeft)
    end

    parent.OnDestroy = function()
    end

    -- TOP-LEVEL GROUP TO PARENT ALL DYNAMIC CONTENT
    local topLevelGroup = Group(border, "topLevelGroup")
    LayoutHelpers.FillParent(topLevelGroup, border)
    topLevelGroup.Depth:Set(100)

    -- MAIN MENU
    local mainMenuGroup = Group(topLevelGroup, "mainMenuGroup")
    mainMenuGroup.Width:Set(0)
    mainMenuGroup.Height:Set(0)
    mainMenuGroup.Left:Set(0)
    mainMenuGroup.Top:Set(0)
    mainMenuGroup.Depth:Set(101)

    local menuBracketMiddle = Bitmap(mainMenuGroup, UIUtil.UIFile('/scx_menu/main-menu/bracket-tube-v_bmp.dds'))

    local menuBracketBar = Bitmap(mainMenuGroup, UIUtil.UIFile('/scx_menu/main-menu/bracket-tube-h_bmp.dds'))
    LayoutHelpers.AtCenterIn(menuBracketBar, menuBracketMiddle, 60)

	local menuBracketLeft = Bitmap(mainMenuGroup, UIUtil.UIFile('/scx_menu/main-menu/bracket-left_bmp.dds'))
    LayoutHelpers.AtCenterIn(menuBracketLeft, menuBracketMiddle, 200, -190)

    local menuBracketLeftGlow = Bitmap(mainMenuGroup, UIUtil.UIFile('/scx_menu/main-menu/bracket-left-energy_bmp.dds'))
    LayoutHelpers.AtCenterIn(menuBracketLeftGlow, menuBracketLeft, 0, 22)

    local menuBracketRight = Bitmap(mainMenuGroup, UIUtil.UIFile('/scx_menu/main-menu/bracket-right_bmp.dds'))
    LayoutHelpers.AtCenterIn(menuBracketRight, menuBracketMiddle, 200, 190)

    local menuBracketRightGlow = Bitmap(mainMenuGroup, UIUtil.UIFile('/scx_menu/main-menu/bracket-right-energy_bmp.dds'))
    LayoutHelpers.AtCenterIn(menuBracketRightGlow, menuBracketRight, 0, -22)

    menuBracketMiddle.Top:Set(function() return topBorder.Bottom() - menuBracketLeft.Height() end)
    LayoutHelpers.AtHorizontalCenterIn(menuBracketMiddle, border)

    menuBracketMiddle.Depth:Set(function() return topBorder.Depth() - 1 end)
    menuBracketBar.Depth:Set(function() return menuBracketMiddle.Depth() - 3 end)
    menuBracketLeft.Depth:Set(function() return topBorder.Depth() - 1 end)
    menuBracketRight.Depth:Set(function() return topBorder.Depth() - 1 end)
    menuBracketLeftGlow.Depth:Set(function() return menuBracketLeft.Depth() - 2 end)
    menuBracketRightGlow.Depth:Set(function() return menuBracketRight.Depth() - 2 end)

    menuBracketMiddle.Animate = function(control, animIn, callback)
        control:SetNeedsFrameUpdate(true)
        if animIn then
            control.mod = 1
        else
            control.mod = -1
        end
        control.OnFrame = function(self, delta)
            local newTop = self.Top() + (delta * 100000 * self.mod)
            if animIn then
                if newTop > topBorder.Bottom() then
                    newTop = topBorder.Bottom()
                    self:SetNeedsFrameUpdate(false)
                    if callback then
                        callback()
                    end
                end
            else
                if menuBracketLeft.Bottom() - (self.Top() - newTop) < topBorder.Bottom() then
                    newTop = topBorder.Bottom() - menuBracketLeft.Height()
                    self:SetNeedsFrameUpdate(false)
                    if callback then
                        callback()
                        animation_active = false
                    end
                end
            end
            self.Top:Set(newTop)
        end
    end

    -- debug FMV head button
    if HasCommandLineArg("/headtest") then
        local headTestBtn = UIUtil.CreateButtonStd(mainMenuGroup, '/scx_menu/small-btn/small', "Head Test", 12)
        LayoutHelpers.AtRightIn(headTestBtn, border)
        LayoutHelpers.AtBottomIn(headTestBtn, border, 50)
        headTestBtn.OnClick = function()
            parent:Destroy()
            --import('/lua/ui/campaign/_head_test.lua').CreateUI()
        end
    end

    -- TODO: don't destroy the whole menu. just destroy the buttons, then you only have to set the top once.
    function MenuBuild(menuTable, center)

        if menuTable == 'home' then
            menuTable = menuTop
        end

        -- title
        mainMenu.titleBack = Bitmap(mainMenuGroup, UIUtil.UIFile('/menus/main03/panel-top_bmp.dds'))
        LayoutHelpers.AtHorizontalCenterIn(mainMenu.titleBack, mainMenuGroup)
        LayoutHelpers.AtTopIn(mainMenu.titleBack, mainMenuGroup, 10)

        mainMenu.titleTxt = UIUtil.CreateText(mainMenu.titleBack, GetPreference("profile.current"), 26)
        LayoutHelpers.AtCenterIn(mainMenu.titleTxt, mainMenu.titleBack, 3)
        mainMenu.titleTxt:SetText(menuTable.title)
        mainMenu.titleTxt:SetNewColor(menuFontColorTitle)
        mainMenu.titleTxt:Hide()

        -- profile button

        local profileDlg = nil

        mainMenu.profile = UIUtil.CreateButtonStd(mainMenu.titleBack, '/menus/main02/profile-edit', "Change Profile", 12)
        LayoutHelpers.CenteredBelow(mainMenu.profile, mainMenu.titleBack, -25)
        mainMenu.profile.OnRolloverEvent = function(self, event)
            if event == 'exit' then
                self.label:SetColor(UIUtil.fontColor)
            else
                self.label:SetColor('ff000000')
            end
        end

        function SetNameToCurrentProfile()
            local currentProfile = GetPreference("profile.current")
            if currentProfile then
                local profiles = GetPreference("profile.profiles")
                if profiles[currentProfile] != nil then
                    mainMenu.titleTxt:SetFont(UIUtil.titleFont, 26)
                    mainMenu.titleTxt:SetText(profiles[currentProfile].Name)
                    ForkThread(function()
                        if mainMenu.titleTxt.Width() > mainMenu.titleBack.Width() - 40 then
                            mainMenu.titleTxt:SetFont(UIUtil.titleFont, 14)
                        else
                            mainMenu.titleTxt:SetFont(UIUtil.titleFont, 26)
                        end
                        mainMenu.titleTxt:Show()
                    end)
                else
                    SetPreference("profile.current", 0) -- if current profile is damaged, reset to 0
                end
            end
        end

        mainMenu.profile.HandleEvent = function(self, event)
            if animation_active then
                return true
            end
            if event.Type == 'MouseEnter' then
                Tooltip.CreateMouseoverDisplay(self, "profile", 5, true)
            elseif event.Type == 'MouseExit' then
                Tooltip.DestroyMouseoverDisplay()
            end
            Button.HandleEvent(self, event)
        end

        mainMenu.profile.leftBracket = Bitmap(mainMenu.profile, UIUtil.UIFile('/scx_menu/profile-brackets/bracket-lg_bmp_left.dds'))
        mainMenu.profile.leftBracket.Right:Set(function() return menuBracketLeft.Right() - 15 end)
        LayoutHelpers.AtTopIn(mainMenu.profile.leftBracket, mainMenu.profile, -52)
        mainMenu.profile.leftBracket.Depth:Set(function() return menuBracketLeft.Depth() - 1 end)
        mainMenu.profile.leftBracket:SetAlpha(0)

        mainMenu.profile.rightBracket = Bitmap(mainMenu.profile, UIUtil.UIFile('/scx_menu/profile-brackets/bracket-lg_bmp_right.dds'))
        mainMenu.profile.rightBracket.Left:Set(function() return menuBracketRight.Left() + 15 end)
        LayoutHelpers.AtTopIn(mainMenu.profile.rightBracket, mainMenu.profile, -52)
        mainMenu.profile.rightBracket.Depth:Set(function() return menuBracketRight.Depth() - 1 end)
        mainMenu.profile.rightBracket:SetAlpha(0)

        mainMenu.profile.SetItemAlpha = function(self, alpha)
            self:SetAlpha(alpha)
            self.label:SetAlpha(alpha)
            mainMenu.titleBack:SetAlpha(alpha)
            mainMenu.titleTxt:SetAlpha(alpha)
        end

        mainMenu.profile:SetItemAlpha(0)

        mainMenu.profile.FadeIn = function(control)
            if control.clickfunc then
                control:Enable()
            end
            control:DisableHitTest(true)
            control:SetNeedsFrameUpdate(true)
            control:SetTexture(UIUtil.UIFile('/menus/main02/profile-edit_btn_up.dds'))
            control.label:SetColor(UIUtil.fontColor)
            control.time = 0
            control.wait = 0
            control.first = true
            control.OnFrame = function(self, delta)
                self.time = 1.6
                if self.first then
                    self.leftBracket:SetAlpha(1)
                    self.rightBracket:SetAlpha(1)
                    self.first = false
                end
                local change = (delta * 200)
                local rightGoal = function() return self.Left() + 100 end
                local leftGoal = function() return self.Right() - 100 end
                if self.leftBracket.Right() < rightGoal() then
                    local newRight = self.leftBracket.Right() + change
                    if newRight > rightGoal() then
                        newRight = rightGoal
                    end
                    self.leftBracket.Right:Set(newRight)
                end
                if self.rightBracket.Left() > leftGoal() then
                    local newLeft = self.rightBracket.Left() - change
                    if newLeft < leftGoal() then
                        newLeft = leftGoal
                    end
                    self.rightBracket.Left:Set(newLeft)
                end

			self.leftBracket.Right:Set(rightGoal)
			self.rightBracket.Left:Set(leftGoal)
			self:SetItemAlpha(1)
			self:EnableHitTest()
			self:SetNeedsFrameUpdate(false)

            end
        end

        mainMenu.profile.FadeOut = function(control)
            control:DisableHitTest(true)
            control:SetNeedsFrameUpdate(true)
            Tooltip.DestroyMouseoverDisplay()
            control:SetTexture(UIUtil.UIFile('/menus/main02/profile-edit_btn_up.dds'))
            control.label:SetColor(UIUtil.fontColor)
            control.time = 0
            control.wait = 0
            control.OnFrame = function(self, delta)
                self.time = 1.6  --self.time + delta
                if self.time < 1 and self.time > self.wait then
                    local num = math.random(20, 80)/100
                    local waitRand = math.random(0, 3)/10
                    self.wait = 0
                    self:SetItemAlpha(num)
                end
                local rightGoal = function() return menuBracketLeft.Right() - 15 end
                local leftGoal = function() return menuBracketRight.Left() + 15 end
                if self.time >= 1 then
                    if self:GetAlpha() > 0 then
                        self:SetItemAlpha(0)
                    end
                    local change = (delta * 200)
                    if self.leftBracket.Right() > rightGoal() then
                        local newRight = self.leftBracket.Right() - change
                        if newRight < rightGoal() then
                            newRight = rightGoal
                            self.leftBracket:SetAlpha(0)
                        end
                        self.leftBracket.Right:Set(newRight)
                    end
                    if self.rightBracket.Left() < leftGoal() then
                        local newLeft = self.rightBracket.Left() + change
                        if newLeft > leftGoal() then
                            newLeft = leftGoal
                            self.rightBracket:SetAlpha(0)
                        end
                        self.rightBracket.Left:Set(newLeft)
                    end
                end
                if self.time > .1 then
                    self.leftBracket.Right:Set(rightGoal)
                    self.rightBracket.Left:Set(leftGoal)
                    self:SetNeedsFrameUpdate(false)
                end
            end
        end

        SetNameToCurrentProfile()

        mainMenu.profile.OnClick = function(self)
            MenuHide(function()
                if not profileDlg then
                    profileDlg = import('/lua/ui/dialogs/profile.lua').CreateDialog(function()
                       	SetNameToCurrentProfile()
                       	profileDlg = nil
                       	MenuShow()
                    end)
                end
            end)
        end

        -- menu buttons
        local buttonHeight = nil

        for k, v in menuTable do

            if k != 'title' then
                mainMenu[k] = {}
                if v.name then
                    mainMenu[k].btn = UIUtil.CreateButtonStd(mainMenuGroup, '/scx_menu/large-no-bracket-btn/large', v.name, 22, 2, 0, "UI_Menu_MouseDown", "UI_Menu_Rollover")
                elseif v.image then
                    mainMenu[k].btn = Button(mainMenuGroup,
                        UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_up.dds'),
                        UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_down.dds'),
                        UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_over.dds'),
                        UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_dis.dds'),
                        "UI_Menu_MouseDown", "UI_Menu_Rollover")
                    mainMenu[k].btn.img = Bitmap(mainMenu[k].btn, UIUtil.UIFile(v.image))
                    LayoutHelpers.AtCenterIn(mainMenu[k].btn.img, mainMenu[k].btn)
                    mainMenu[k].btn.img:DisableHitTest()
                end
                mainMenu[k].btn:UseAlphaHitTest(false)
                buttonHeight = mainMenu[k].btn.Height()
                if v.color and mainMenu[k].btn.label then
                    mainMenu[k].btn.label:SetColor(v.color)
                end
                if k == 1 then
                    LayoutHelpers.CenteredBelow(mainMenu[k].btn, mainMenu.profile)
                else
                    local lastBtn = k - 1
                    LayoutHelpers.CenteredBelow(mainMenu[k].btn, mainMenu[lastBtn].btn, -5)
                end
                if v.action then
                    mainMenu[k].btn.glow = Bitmap(mainMenu[k].btn, UIUtil.UIFile('/scx_menu/large-btn/large_btn_glow.dds'))
                    LayoutHelpers.AtCenterIn(mainMenu[k].btn.glow, mainMenu[k].btn)
                    mainMenu[k].btn.glow:SetAlpha(0)
                    mainMenu[k].btn.glow:DisableHitTest()
                    mainMenu[k].btn.rofunc = function(self, event)
                        if animation_active then
                            return true
                        end
                        if event == 'enter' then
                            EffectHelpers.FadeIn(self.glow, .025, 0, 1)
                            if self.label then
                                self.label:SetColor('black')
                            end
                        elseif event == 'down' then
                            if self.label then
                                self.label:SetColor('black')
                            end
                        else
                            EffectHelpers.FadeOut(self.glow, .04, 1, 0)
                            if self.label then
                                self.label:SetColor(menuFontColor)
                            end
                        end
                    end
                    mainMenu[k].btn.clickfunc = v.action
                    mainMenu[k].btn._enable = true
                    if v.tooltip then Tooltip.AddButtonTooltip(mainMenu[k].btn, v.tooltip, TOOLTIP_DELAY) end
                else
                    LOG('DISABLING MAIN MENU BUTTON')
                    mainMenu[k].btn:Disable()
                end

                mainMenu[k].btn.leftBracket = Bitmap(mainMenu[k].btn, UIUtil.UIFile('/scx_menu/main-menu/bracket_bmp_left.dds'))
                mainMenu[k].btn.leftBracket.Right:Set(function() return menuBracketLeft.Right() - 15 end)
                LayoutHelpers.AtTopIn(mainMenu[k].btn.leftBracket, mainMenu[k].btn, -6)
                mainMenu[k].btn.leftBracket.Depth:Set(function() return menuBracketLeft.Depth() - 1 end)

                mainMenu[k].btn.rightBracket = Bitmap(mainMenu[k].btn, UIUtil.UIFile('/scx_menu/main-menu/bracket_bmp_right.dds'))
                mainMenu[k].btn.rightBracket.Left:Set(function() return menuBracketRight.Left() + 15 end)
                LayoutHelpers.AtTopIn(mainMenu[k].btn.rightBracket, mainMenu[k].btn, -6)
                mainMenu[k].btn.rightBracket.Depth:Set(function() return menuBracketRight.Depth() - 1 end)

                mainMenu[k].btn:Disable()
                mainMenu[k].btn:SetAlpha(0, true)
                mainMenu[k].btn.SetItemAlpha = function(control, alpha)
                    control:SetAlpha(alpha)
                    if control.label then
                        control.label:SetAlpha(alpha)
                    elseif control.img then
                        control.img:SetAlpha(alpha)
                    end
                end
                mainMenu[k].btn.FadeIn = function(control)
                    if control.clickfunc then
                        control:Enable()
                        if control.label then
                            control.label:SetColor(menuFontColor)
                        end
                    end
                    control:DisableHitTest(true)
                    control.OnRolloverEvent = function() end
                    control.OnClick = function() end
                    control:SetNeedsFrameUpdate(true)
                    if control:IsDisabled() then
                        control:SetTexture(UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_dis.dds'))
                    end
                    control.time = 1
                    control.wait = 0
                    control.first = true
                    control.OnFrame = function(self, delta)
                        self.time = self.time + delta
                        if self.first then
                            self.leftBracket:SetAlpha(1)
                            self.rightBracket:SetAlpha(1)
                            self.first = false
                        end
                        if self.time > .05 and self.time > self.wait then
                            self.OnClick = self.clickfunc
                            local num = math.random(20, 70)/100
                            local waitRand = math.random(0, 3)/10
                            --self.wait = self.time + waitRand
							self.wait = 0
                            self:SetItemAlpha(num)
                        end
                        local change = (delta * 200)
                        local rightGoal = function() return self.Left() + 40 end
                        local leftGoal = function() return self.Right() - 38 end
                        if self.leftBracket.Right() < rightGoal() then
                            local newRight = self.leftBracket.Right() + change
                            if newRight > rightGoal() then
                                newRight = rightGoal
                            end
                            self.leftBracket.Right:Set(newRight)
                        end
                        if self.rightBracket.Left() > leftGoal() then
                            local newLeft = self.rightBracket.Left() - change
                            if newLeft < leftGoal() then
                                newLeft = leftGoal
                            end
                            self.rightBracket.Left:Set(newLeft)
                        end
                        if self.time > .1 then
                            self.leftBracket.Right:Set(rightGoal)
                            self.rightBracket.Left:Set(leftGoal)
                            self:SetItemAlpha(1)
                            if not control:IsDisabled() then
                                self:EnableHitTest()
                                self.OnRolloverEvent = self.rofunc
                            else
                                self:SetTexture(UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_dis.dds'))
                            end
                            self:SetNeedsFrameUpdate(false)
                        end
                    end
                end
                mainMenu[k].btn.FadeOut = function(control)
                    control:DisableHitTest(true)
                    control:SetNeedsFrameUpdate(true)
                    control.OnRolloverEvent = function() end
                    control.OnClick = function() end
                    control.time = 1
                    control.wait = 0
                    control.OnFrame = function(self, delta)
                        self.time = self.time + delta
                        if self.time < .1 and self.time > self.wait then
                            local num = math.random(20, 80)/100
                            local waitRand = math.random(0, 3)/10
                            self.wait = 0
                            self:SetItemAlpha(num)
                        end
                        local rightGoal = function() return menuBracketLeft.Right() - 15 end
                        local leftGoal = function() return menuBracketRight.Left() + 15 end
                        if self.time >= .1 then
                            if self:GetAlpha() > 0 then
                                self:SetItemAlpha(0)
                            end
                            local change = (delta * 200)
                            if self.leftBracket.Right() > rightGoal() then
                                local newRight = self.leftBracket.Right() - change
                                if newRight < rightGoal() then
                                    newRight = rightGoal
                                    self.leftBracket:SetAlpha(0)
                                end
                                self.leftBracket.Right:Set(newRight)
                            end
                            if self.rightBracket.Left() < leftGoal() then
                                local newLeft = self.rightBracket.Left() + change
                                if newLeft > leftGoal() then
                                    newLeft = leftGoal
                                    self.rightBracket:SetAlpha(0)
                                end
                                self.rightBracket.Left:Set(newLeft)
                            end
                        end
                        if self.time > .1 then
                            self.leftBracket.Right:Set(rightGoal)
                            self.rightBracket.Left:Set(leftGoal)
                            self:SetItemAlpha(0)
                            self:EnableHitTest()
                            self:SetNeedsFrameUpdate(false)
                        end
                    end
                end
            end
        end

        local numButtons = table.getn(mainMenu)
        local lastBtn = mainMenu[numButtons].btn

        if initial then
            ForkThread(function()
                MenuAnimation(true)
            end)
            initial = false
        else
            MenuAnimation(true)
        end

        -- set ESC key functionality depending on menu layer
        if menuTable == 'home' or menuTable == menuTop then
            SetEscapeHandle(ButtonExit)
        else
            SetEscapeHandle(ButtonBack)
        end

        -- set final dimensions/placement of mainMenuGroup
        mainMenuGroup.Height:Set(function() return (mainMenuSize * buttonHeight) + mainMenu.titleBack.Height() end)
        mainMenuGroup.Width:Set(mainMenu.titleBack.Width)
        LayoutHelpers.AtHorizontalCenterIn(mainMenuGroup, border)

        mainMenuGroup.Top:Set(function()
            return math.floor(logo.Bottom() - 18)
        end)
    end


    -- Animate the menu

    function MenuAnimation(fadeIn, callback, skipSlide)
		skipSlide = true
        animation_active = true
        local function ButtonFade(menuSlide)
			menuSlide = false
            ForkThread(function()
                for i, v in mainMenu do
                    if not v.btn then
                        continue
                    end
                    if fadeIn then
                        v.btn:FadeIn()
                    else
                        v.btn:FadeOut()
                    end
                end
                if fadeIn then
                    mainMenu.profile:FadeIn()
                else
                    mainMenu.profile:FadeOut()
                end
                if menuSlide then
                    menuBracketMiddle:Animate(fadeIn, callback)
                elseif callback then
                    callback()
                end
                if not menuSlide then
                    animation_active = false
                end
            end)
        end
        if fadeIn then
            menuBracketMiddle:Animate(fadeIn, ButtonFade)
        else
            ButtonFade(not skipSlide)
        end
    end

	function SetEscapeHandle(action)
		import('/lua/ui/uimain.lua').SetEscapeHandler(function() action() end)
	end

	function MenuHide(callback)
		MenuAnimation(false, function()
			EffectHelpers.FadeIn(darker, .1, 0, .4)
			mainMenuGroup:Hide()
			logo:Hide()
            backImage:Hide()
			mainMenuGroup.Depth:Set(50)        -- setting depth below topLayerGroup (100) to avoid the button glow persisting when overlays are up
			if callback then callback() end
		end)
	end

	function MenuShow()
		mainMenuGroup.Depth:Set(101)
		mainMenuGroup:Show()
		logo:Show()
        backImage:Show()
		legalText:Show()
		EffectHelpers.FadeOut(darker, .1, .4, 0)
		MenuAnimation(true)
	end

	function MenuDestroy(callback, skipSlide)
		MenuAnimation(false, function()
			for k, v in mainMenu do
				if v.btn then
					v.btn:Destroy()
				else
					v:Destroy()
				end
			end
			mainMenu = {}
			if callback then callback() end
		end, skipSlide)
	end

	function ButtonLAN()

		MenuHide(function()
			import('/lua/ui/lobby/gameselect.lua').CreateUI(topLevelGroup, function() MenuShow() SetEscapeHandle(ButtonExit) end, false)
		end)

	end

    function ButtonMatchmaking()

		if not IsSignedInToSteam() then

			UIUtil.ShowInfoDialog(parent, "<LOC SteamNotSignedIn>You must first sign into Steam to use Matchmaking", "<LOC _OK>")

		else

			MenuHide(function()
				import('/lua/ui/lobby/gameselect.lua').CreateUI(topLevelGroup, function() MenuShow() SetEscapeHandle(ButtonExit) end, true)
			end)
		end
    end

	function ButtonSkirmish()
		MenuHide(function()
			local function StartLobby(scenarioFileName)
				local playerName = Prefs.GetCurrentProfile().Name or "Unknown"
				local lobby = import('/lua/ui/lobby/lobby.lua')
				lobby.CreateLobby('None', 0, playerName, nil, nil, topLevelGroup, function() MenuShow() SetEscapeHandle(ButtonExit) end)
				lobby.HostGame(playerName .. "'s Skirmish", scenarioFileName, true)
			end
			local lastScenario = Prefs.GetFromCurrentProfile('LastScenario') or UIUtil.defaultScenario
			StartLobby(lastScenario)
		end)
    end

	function ButtonReplay()
		MenuHide(function()
			import('/lua/ui/dialogs/replay.lua').CreateDialog(topLevelGroup, true, function() MenuShow() SetEscapeHandle(ButtonBack) end)
		end)
	end

	function ButtonMod()
		MenuHide(function()
			local function OnOk(selectedmods)
				Mods.SetSelectedMods(selectedmods)
				MenuShow()
				SetEscapeHandle(ButtonBack)
			end
			import('/lua/ui/dialogs/modmanager.lua').CreateDialog(topLevelGroup, false, OnOk)
		end)
	end

	function ButtonOptions()
		MenuHide(function()
			import('/lua/ui/dialogs/options.lua').CreateDialog(topLevelGroup, function() MenuShow() SetEscapeHandle(ButtonExit) end)
		end)
	end

	function ButtonExtras()
		MenuDestroy(function()
			MenuBuild(menuExtras)
		end, true)
	end

	function ButtonCredits()
		parent:Destroy()
		import('/lua/ui/menus/credits.lua').CreateDialog(function() import('/lua/ui/menus/main.lua').CreateUI() end)
	end

	function ButtonEULA()
		MenuHide(function()
			import('/lua/ui/menus/eula.lua').CreateEULA(topLevelGroup, function() MenuShow() SetEscapeHandle(ButtonBack) end)
		end)
    end

    function ButtonUnitDB()
        MenuHide(function()
            local function Callback()
                MenuShow()
                SetEscapeHandle(ButtonBack)
            end
            import('/lua/ui/menus/unitdb.lua').CreateUnitDB(topLevelGroup, Callback)
        end)
    end

	function ButtonBack()
		MenuDestroy(function()
			ESC_handle = nil
			MenuBuild('home', true)
		end, true)
	end

	local exitDlg = nil

	function ButtonExit()
		if not exitDlg then
			exitDlg = UIUtil.QuickDialog(GetFrame(0), "Are you sure you'd like to exit?", "Yes", function() parent:Destroy() ExitApplication() end, "No", function() exitDlg = nil end, nil, nil, true, {worldCover = true, enterButton = 1, escapeButton = 2})
		end
	end

	-- START

	MenuBuild('home', true)
	FlushEvents()
end
