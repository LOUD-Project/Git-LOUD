
local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/Bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Prefs = import('/lua/user/prefs.lua')
local WrapText = import('/lua/maui/text.lua').WrapText
local Movie = import('/lua/maui/movie.lua').Movie
local GameMain = import('/lua/ui/game/gamemain.lua')
local subtitleThread = false

controls = {}

function SetLayout()
   if import('/lua/ui/game/gamemain.lua').IsNISMode() then
		LayoutHelpers.AtLeftTopIn(controls.movieBrackets, GetFrame(0), 20, 100)
		LayoutHelpers.AtLeftTopIn(controls.subtitles.text[1], GetFrame(0), 52, 340)
	else
		LayoutHelpers.AtLeftTopIn(controls.movieBrackets, GetFrame(0), 2, 147)
		LayoutHelpers.AtLeftTopIn(controls.subtitles.text[1], GetFrame(0), 30, 395)
	end
end

function OnGamePause(paused)
    if controls.movieBrackets then
        controls.movieBrackets:Pause(paused)
    end
end

function CloseMFDMovie(movie, Lengh)
   if controls.movieBrackets then
		ForkThread(function()
	
		local prefix = {Cybran = {texture = '/icons/comm_cybran.dds', cue = 'UI_Comm_CYB'},
			Aeon = {texture = '/icons/comm_aeon.dds', cue = 'UI_Comm_AEON'},
            Uef = {texture = '/icons/comm_uef.dds', cue = 'UI_Comm_UEF'},
            Seraphim = {texture = '/icons/comm_seraphim.dds', cue = 'UI_Comm_SER'},
            NONE = {texture = '/icons/comm_allied.dds', cue = 'UI_Comm_UEF'}
		}
			
		WaitSeconds(Lengh)		
		controls.movieBrackets.panel:SetNeedsFrameUpdate(true)
            controls.movieBrackets.panel.sound = PlaySound(Sound{Bank='Interface', Cue=prefix[movie[4]].cue..'_Out'})
            controls.subtitles:Contract()
            controls.movieBrackets.panel.OnFrame = function(self, delta)
                if controls.movieBrackets._paused then
                    return
                end
                local newAlpha = self:GetAlpha() - (delta * 1.5)
                if newAlpha < 0 then
                    self:SetNeedsFrameUpdate(false)
                    controls.movieBrackets:SetNeedsFrameUpdate(true)
                    controls.movieBrackets.movie:SetAlpha(0)
                    controls.movieBrackets.cover:SetAlpha(0)
                    self:SetAlpha(0)
                else
                    self:SetAlpha(newAlpha)
                    controls.movieBrackets.cover:SetAlpha(newAlpha)
                end
            end
            controls.movieBrackets.OnFrame = function(self, delta)
                if controls.movieBrackets._paused then
                    return
                end
                local finishedHeight = false
                local finishedWidth = false
                local newHeight = math.max(self.Height() - (delta * 800), 1)
                local newWidth = math.max(self.Width() - (delta * 800), 1)
                if newHeight == 1 then
                    finishedHeight = true
                end
                if newWidth == 1 then
                    finishedWidth = true
                end
                self.Height:Set(newHeight)
                self.Width:Set(newWidth)
                if finishedWidth and finishedHeight then
                    self:SetNeedsFrameUpdate(false)
                    controls.movieBrackets:Destroy()
                    controls.movieBrackets = false
				    SimCallback( { Func = "OnMFDMovieFinished", Args = movie[1]} )
                end
            end
	end)
   end
end

function PlayMFDMovieMP(movie, text)
    if not controls.movieBrackets then
        local prefix = {
			Cybran = {texture = '/icons/comm_cybran.dds', cue = 'UI_Comm_CYB'},
            Aeon = {texture = '/icons/comm_aeon.dds', cue = 'UI_Comm_AEON'},
            Uef = {texture = '/icons/comm_uef.dds', cue = 'UI_Comm_UEF'},
            Seraphim = {texture = '/icons/comm_seraphim.dds', cue = 'UI_Comm_SER'},
            NONE = {texture = '/icons/comm_allied.dds', cue = 'UI_Comm_UEF'}}
        
        controls.movieBrackets = Bitmap(GetFrame(0), UIUtil.SkinnableFile('/game/transmission/video-brackets.dds'))
        controls.movieBrackets.Height:Set(1)
        controls.movieBrackets.Width:Set(1)
        controls.movieBrackets.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
        controls.movieBrackets:SetNeedsFrameUpdate(true)
        
        controls.movieBrackets.panel = Bitmap(controls.movieBrackets, UIUtil.SkinnableFile('/game/transmission/video-panel.dds'))
        LayoutHelpers.AtCenterIn(controls.movieBrackets.panel, controls.movieBrackets)
        controls.movieBrackets.panel:SetAlpha(0)
        
        controls.movieBrackets.cover = Bitmap(controls.movieBrackets, UIUtil.UIFile(prefix[movie[4]].texture))
        controls.movieBrackets.cover.Height:Set(190)
        controls.movieBrackets.cover.Width:Set(190)
        controls.movieBrackets.cover.Depth:Set(function() return controls.movieBrackets.panel.Depth() - 1 end)
        LayoutHelpers.AtCenterIn(controls.movieBrackets.cover, controls.movieBrackets.panel)
        controls.movieBrackets.cover:SetAlpha(0)
        
        controls.movieBrackets.movie = Movie(controls.movieBrackets, movie[1])
        controls.movieBrackets.movie.Height:Set(190)
        controls.movieBrackets.movie.Width:Set(190)
        controls.movieBrackets.movie.Depth:Set(function() return controls.movieBrackets.panel.Depth() - 1 end)
        LayoutHelpers.AtCenterIn(controls.movieBrackets.movie, controls.movieBrackets.panel)
        controls.movieBrackets.movie:SetAlpha(0)
        
        controls.subtitles = CreateSubtitles(controls.movieBrackets, text[1])
        
        controls.movieBrackets.movie.OnFinished = function(self)
            controls.movieBrackets.panel:SetNeedsFrameUpdate(true)
            controls.movieBrackets.panel.sound = PlaySound(Sound{Bank='Interface', Cue=prefix[movie[4]].cue..'_Out'})
            controls.subtitles:Contract()
            controls.movieBrackets.panel.OnFrame = function(self, delta)
                if controls.movieBrackets._paused then
                    return
                end
                local newAlpha = self:GetAlpha() - (delta * 1.5)
                if newAlpha < 0 then
                    self:SetNeedsFrameUpdate(false)
                    controls.movieBrackets:SetNeedsFrameUpdate(true)
                    controls.movieBrackets.movie:SetAlpha(0)
                    controls.movieBrackets.cover:SetAlpha(0)
                    self:SetAlpha(0)
                else
                    self:SetAlpha(newAlpha)
                    controls.movieBrackets.cover:SetAlpha(newAlpha)
                end
            end
            controls.movieBrackets.OnFrame = function(self, delta)
                if controls.movieBrackets._paused then
                    return
                end
                local finishedHeight = false
                local finishedWidth = false
                local newHeight = math.max(self.Height() - (delta * 800), 1)
                local newWidth = math.max(self.Width() - (delta * 800), 1)
                if newHeight == 1 then
                    finishedHeight = true
                end
                if newWidth == 1 then
                    finishedWidth = true
                end
                self.Height:Set(newHeight)
                self.Width:Set(newWidth)
                if finishedWidth and finishedHeight then
                    self:SetNeedsFrameUpdate(false)
                    controls.movieBrackets:Destroy()
                    controls.movieBrackets = false
				    SimCallback( { Func = "OnMFDMovieFinished", Args = movie[1] } )
                end
            end
        end
        
        controls.movieBrackets.OnFrame = function(self, delta)
            if controls.movieBrackets._paused then
                return
            end
            local finishedHeight = false
            local finishedWidth = false
            local newHeight = math.min(self.Height() + (delta * 600), self.BitmapHeight())
            local newWidth = math.min(self.Width() + (delta * 600), self.BitmapWidth())
            if newHeight == self.BitmapHeight() then
                finishedHeight = true
            end
            if newWidth == self.BitmapWidth() then
                finishedWidth = true
            end
            self.Height:Set(newHeight)
            self.Width:Set(newWidth)
            if finishedWidth and finishedHeight then
                self:SetNeedsFrameUpdate(false)
                controls.movieBrackets.panel:SetNeedsFrameUpdate(true)
                controls.movieBrackets.panel.sound = PlaySound(Sound{Bank='Interface', Cue=prefix[movie[4]].cue..'_In'})
                controls.subtitles:Expand()
            end
        end
        
        controls.movieBrackets.panel.OnFrame = function(self, delta)
            if controls.movieBrackets._paused then
                return
            end
            local newAlpha = self:GetAlpha() + (delta * 2)
            if newAlpha > 1 then
                self:SetNeedsFrameUpdate(false)
                controls.movieBrackets.movie:SetAlpha(1)
                controls.movieBrackets.cover:SetAlpha(0)
                self:SetAlpha(1)
                controls.movieBrackets.movie:Play()
				if movie[2] then 
					controls.movieBrackets.movie.sound = PlayVoice(Sound{Bank=movie[2], Cue=movie[3]}, true)
				end
            else
                self:SetAlpha(newAlpha)
                controls.movieBrackets.cover:SetAlpha(newAlpha)
            end
        end
        
        controls.movieBrackets.Pause = function(self, state)
            PauseVoice("VO", state)
            self._paused = state
            if state then
                self.movie:Stop()
            else
                self.movie:Play()
            end
        end
        
        controls.movieBrackets:DisableHitTest(true)
        SetLayout()
    end
end

function IsMfdPlaying()
    if controls.movieBrackets then
        return true
    else
        return false
    end
end

function CreateSubtitles(parent, text)
    local bg = Bitmap(parent, UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_m.dds'))
    
    bg.text = {}
    bg.text[1] = UIUtil.CreateText(bg, '', 12, UIUtil.bodyFont)
    
    bg.tl = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ul.dds'))
    bg.tm = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_horz_um.dds'))
    bg.tr = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ur.dds'))
    bg.ml = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_vert_l.dds'))
    bg.mr = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_vert_r.dds'))
    bg.bl = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ll.dds'))
    bg.bm = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_lm.dds'))
    bg.br = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_lr.dds'))
    
    bg.tl.Bottom:Set(bg.Top)
    bg.tl.Right:Set(bg.Left)
    bg.tr.Bottom:Set(bg.Top)
    bg.tr.Left:Set(bg.Right)
    bg.bl.Top:Set(bg.Bottom)
    bg.bl.Right:Set(bg.Left)
    bg.br.Top:Set(bg.Bottom)
    bg.br.Left:Set(bg.Right)
    bg.tm.Bottom:Set(bg.Top)
    bg.tm.Left:Set(bg.Left)
    bg.tm.Right:Set(bg.Right)
    bg.bm.Top:Set(bg.Bottom)
    bg.bm.Left:Set(bg.Left)
    bg.bm.Right:Set(bg.Right)
    bg.ml.Right:Set(bg.Left)
    bg.ml.Top:Set(bg.Top)
    bg.ml.Bottom:Set(bg.Bottom)
    bg.mr.Left:Set(bg.Right)
    bg.mr.Top:Set(bg.Top)
    bg.mr.Bottom:Set(bg.Bottom)
    
    local wrapped = import('/lua/maui/text.lua').WrapText(LOC(text), 300, 
        function(curText) return bg.text[1]:GetStringAdvance(curText) end)
        
    for index, line in wrapped do
        local i = index
        if not bg.text[i] then
            bg.text[i] = UIUtil.CreateText(bg.text[1], '', 12, UIUtil.bodyFont)
            LayoutHelpers.Below(bg.text[i], bg.text[i-1])
        end
        bg.text[i]:SetText(line)
    end
    
    bg.Top:Set(bg.text[1].Top)
    bg.Left:Set(bg.text[1].Left)
    bg.Width:Set(1)
    bg.Height:Set(function() return table.getsize(bg.text) * bg.text[1].Height() end)
    
    bg:SetAlpha(0, true)
    
    bg.Expand = function(control)
        control:SetAlpha(1, true)
        bg.text[1]:SetAlpha(0, true)
        control:SetNeedsFrameUpdate(true)
        control.OnFrame = function(self, delta)
            if parent._paused then
                return
            end
            local newWidth = self.Width() + (delta * 800)
            local finishedWidth = false
            if newWidth > 300 then
                newWidth = 300
                finishedWidth = true
            end
            if finishedWidth then
                bg.text[1]:SetNeedsFrameUpdate(true)
                self:SetNeedsFrameUpdate(false)
            end
            self.Width:Set(newWidth)
        end
        control.text[1].OnFrame = function(self, delta)
            if parent._paused then
                return
            end
            local newAlpha = self:GetAlpha() + (delta * 2)
            if newAlpha > 1 then
                newAlpha = 1
                self:SetNeedsFrameUpdate(false)
            end
            self:SetAlpha(newAlpha, true)
        end
    end
    
    bg.Contract = function(control)
        control.text[1]:SetNeedsFrameUpdate(true)
        control.OnFrame = function(self, delta)
            if parent._paused then
                return
            end
            local newWidth = self.Width() - (delta * 800)
            local finishedWidth = false
            if newWidth < 1 then
                newWidth = 1
                finishedWidth = true
            end
            if finishedWidth then
                self:SetAlpha(0, true)
                self:SetNeedsFrameUpdate(false)
            end
            self.Width:Set(newWidth)
        end
        control.text[1].OnFrame = function(self, delta)
            if parent._paused then
                return
            end
            local newAlpha = self:GetAlpha() - (delta * 2)
            if newAlpha < 0 then
                newAlpha = 0
                self:SetNeedsFrameUpdate(false)
                bg:SetNeedsFrameUpdate(true)
            end
            self:SetAlpha(newAlpha, true)
        end
    end
    
    return bg
end

function DisplaySubtitles(textControl,captions)
    subtitleThread = ForkThread(
        function()
            # Display subtitles
            local lastOff = 0
            for k,v in captions do
                WaitSeconds(v.offset - lastOff)
                textControl:DeleteAllItems()
                locText = LOC(v.text)
                #LOG("Wrap: ",locText)
                local lines = WrapText(locText, textControl.Width(), function(text) return textControl:GetStringAdvance(text) end)
                for i,line in lines do
                    textControl:AddItem(line)
                end
                textControl:ScrollToBottom()
                lastOff = v.offset
            end
            subtitleThread = false
        end
    )
end

--NOT USED---------------------------------------------------------------------------------------------------------------
local currentMovie = false
function PauseTransmission()
    if currentMovie then
        currentMovie:Stop()
    end
end

function ResumeTransmission()
    if currentMovie then
        currentMovie:Play()
    end
end

--NOT USED
local videoQueue = {}
function UpdateQueue()
    if table.getsize(videoQueue) > 0 then
        PlayMFDMovie({videoQueue[1][1], videoQueue[1][2], videoQueue[1][3], videoQueue[1][4]}, videoQueue[1][5])
        table.remove(videoQueue, 1)
    end
end
------------------------------------------------------------------------------------------------------------------------

