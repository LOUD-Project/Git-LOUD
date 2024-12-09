local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local oldCreateIdleTab = CreateIdleTab
function CreateIdleTab(unitData, id, expandFunc)
    local bg = oldCreateIdleTab(unitData, id, expandFunc)

	if (UIP.GetSetting("alertIdleFac")) then
		if (id == "factory") then
			bg.overlay = Bitmap(bg)
			LayoutHelpers.AtLeftTopIn(bg.overlay, bg, 7, 8)
			bg.overlay:SetSolidColor('66FF1111')
			LayoutHelpers.SetDimensions(bg.overlay, 34, 34)
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
		end
	end

	return bg
end
