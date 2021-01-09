local UIP = import('/mods/UI-Party/modules/UI-Party.lua')


local oldCreateIdleTab = CreateIdleTab
function CreateIdleTab(unitData, id, expandFunc)
    local bg = oldCreateIdleTab(unitData, id, expandFunc)

	if (UIP.GetSetting("alertIdleFac")) then 

		if (id == "factory") then
			bg.overlay = Bitmap(bg)
			LayoutHelpers.AtLeftTopIn(bg.overlay, bg, 7, 8)
			bg.overlay:SetSolidColor('aaFF0000')
			bg.overlay.Width:Set(90)
			bg.overlay.Height:Set(34)
			bg.overlay:DisableHitTest()
			bg.overlay.dir = -1
			bg.overlay.cycles = 0
			bg.overlay.OnFrame = function(self, delta)
					local newAlpha = self:GetAlpha() + (delta * 3 * self.dir)
					if newAlpha > 1 then
						newAlpha = 1
						self.dir = -1
						self.cycles = self.cycles + 1
						if self.cycles >= 5 then
							self:SetNeedsFrameUpdate(false)
						end
					elseif newAlpha < 0 then
						newAlpha = 0
						self.dir = 1
					end
					self:SetAlpha(newAlpha)
				end
			bg.overlay:SetNeedsFrameUpdate(true)

			--ShowBigRedScreen()
		end

	end

	return bg
end


--local bigRed;

--function CreateBigRedScreen()

--	if (UIP.GetSetting("immersionAcuDamage")) then 

--		bigRed = Bitmap(GetFrame(0))
--		LayoutHelpers.AtLeftTopIn(bigRed, GetFrame(0), 7, 8)
--		bigRed.Left:Set(0)
--		bigRed.Top:Set(0)
--		bigRed:SetSolidColor('33FF0000')
--		bigRed.Width:Set(90)
--		bigRed.Height:Set(34)
--		bigRed.Width:Set(1920)
--		bigRed.Height:Set(1080)
--		bigRed:DisableHitTest()
--		bigRed:SetAlpha(0)
--		bigRed:SetNeedsFrameUpdate(false)

--	end
--end

--function ShowBigRedScreen()

--	if (UIP.GetSetting("immersionAcuDamage")) then 

--		bigRed:SetAlpha(1)
--		bigRed:SetNeedsFrameUpdate(true)

--		bigRed.OnFrame = function(self, delta)
--			local newAlpha = self:GetAlpha() - 0.005
--			if newAlpha >= 0 then -- some rare bug here
--				self:SetAlpha(newAlpha)

--				if newAlpha == 0 then
--					bigRed:SetNeedsFrameUpdate(false)
--				end
--			end
--		end
--	end
--end

--CreateBigRedScreen()
