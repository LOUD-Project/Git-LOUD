--*****************************************************************************
--* File: lua/ui/game/zoompopper.lua
--* Author: III_Demon / Warma / PartyTime
--*****************************************************************************

-- WITH INITIALIZE
-- complication: changes to camera dont happen straight away so you have to forkThread(waitSeconds) before it will work
-- complication: moving to a coords centers on that coord whereas we want to keep the mouse cursor in the same position after zooming.
-- complication: the first time there is a flicker whilst we work out the relationship between WS and SS coords at the (zoompop) zoom level. subsequent pops we can just reuse this ratio without flicker

local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local wXperSx
local wYperSy
local pitch
local heading
local cam, wv
local lastCam

function Init()
	UIPLOG("Zoom pop - init cam")
	cam = GetCamera('WorldCamera')
	lastCam = cam
	wv = import('/lua/ui/game/worldview.lua').GetWorldViews()["WorldCamera"];
	popZoom = GetPopLevel()

	local p1 = GetMouseWorldPos()

	local settings = cam:SaveSettings()
	pitch = settings.Pitch
	heading = settings.Heading

	local hpr = Vector(settings.Heading, settings.Pitch, 0)
	cam:SnapTo(p1, hpr, popZoom)
	WaitSeconds(0)

	--3. measure the difference in ws to ss x/y
	local sp = GetMouseScreenPos()
	local p2 = UnProject(wv, sp)
	sp[1] = sp[1] + 1
	sp[2] = sp[2] + 1
	local p3 = UnProject(wv, sp)
	wXperSx = p3[1] - p2[1]
	wYperSy = p3[3] - p2[3]

	cam:RestoreSettings(settings)
end

function GetPopLevel()
	local popZoom = import('/lua/user/prefs.lua').GetFromCurrentProfile('options').gui_zoom_pop_distance
	if popZoom == nil then
		popZoom = 80
	end
	return popZoom
end

local oldToggleZoomPop = ToggleZoomPop
function ToggleZoomPop()

	if not UIP.GetSetting("zoomPopOverride") or not UIP.Enabled() then
		oldToggleZoomPop()
		return 0
	end

	cam = GetCamera('WorldCamera')
	popZoom = GetPopLevel()
	wv = import('/lua/ui/game/worldview.lua').GetWorldViews()["WorldCamera"];

	if math.abs(cam:GetZoom() - popZoom) > 1 then

		if lastCam ~= cam then

			ForkThread(function()

				Init()
				WaitSeconds(0)
				Pop()

			end)
		else
			Pop()
		end

	else
		cam:Reset()
	end
end

function Pop()

	local speed = UIP.GetSetting("zoomPopSpeed")
	local mp = GetMouseScreenPos()
	local center = { wv:Width()/2, wv:Height() /2 }
	local dstFromCenter = {  mp[1] - center[1], mp[2] -center[2]  }

	local hpr = Vector(heading, pitch, 0)
	local p1 = GetMouseWorldPos()
	p1[1] = p1[1] - (wXperSx * dstFromCenter[1])
	p1[3] = p1[3] - (wYperSy * dstFromCenter[2])
	cam:MoveTo(p1, hpr, popZoom, speed)
	ForkThread(function()
		WaitSeconds(0)
		cam:RevertRotation()
	end)

end
