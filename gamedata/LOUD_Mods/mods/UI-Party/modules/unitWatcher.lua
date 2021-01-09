-- With heavy inspiration from Idle Engineers by camelCase

local CommonUnits = import('/mods/CommonModTools/units.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UnitHelper = import('/mods/ui-party/modules/unitHelper.lua')
local trackers = {}
local enhancementQueue = {}
local hasNotify = exists('/mods/Notify/modules/notify.lua')
local notify = nil
if hasNotify then notify = import('/mods/Notify/modules/notify.lua') end

local idle1 = { val=16, img='/mods/ui-party/textures/idle_icon.dds', width=16, height=16 }
local idle2 = { val=14, img='/mods/ui-party/textures/idle_icon.dds', width=14, height=14 }
local idle3 = { val=12, img='/mods/ui-party/textures/idle_icon.dds', width=12, height=12 }
local idle4 = { val=8, img='/mods/ui-party/textures/idle_icon_small.dds', width=8, height=8 }
local idle5 = { val = false }
local sub1 = { val=16, img='/mods/ui-party/textures/down.dds', width=12, height=14 }
local sub2 = { val=16, img='/mods/ui-party/textures/up.dds', width=12, height=14 }
local sub3 = { val = false }
local silo1 = { val=16, img='/mods/ui-party/textures/loaded1.dds', width=16, height=24 }
local silo2 = { val=16, img='/mods/ui-party/textures/loaded1.dds', width=8, height=12 }
local silo3 = { val = false }
local locked1 = { val=12, img='/mods/ui-party/textures/lock_icon.dds', width=12, height=12 }
local locked2 = { val=8, img='/mods/ui-party/textures/lock_icon_small.dds', width=8, height=8 }
local locked3 = { val = false }
local upgrade1 = { val=7, img='/mods/ui-party/textures/upgrade.dds', width=8, height=8 }
local upgrade2 = { val=8, img='/mods/ui-party/textures/upgrade.dds', width=12, height=12 }
local upgrade3 = { val = false }
local assisted1 = { val=8, img='/mods/ui-party/textures/crown_icon_small.dds', width=8, height=8 }
local assisted2 = { val=8, img='/mods/ui-party/textures/crown_icon_small_grey.dds', width=8, height=8 }
local assisted3 = { val = false }
local master1 = { val=1, img='/mods/ui-party/textures/repeating_master_fac.dds', width=12, height=16 }
local master2 = { val=2, img='/mods/ui-party/textures/master_fac.dds', width=12, height=16 }
local master3 = { val=3, img='/mods/ui-party/textures/repeating_solo_fac.dds', width=12, height=16 }
local master4 = { val=4, img='/mods/ui-party/textures/solo_fac.dds', width=12, height=16 }
local master5 = { val = false }
local enhance1 = { val=8, img='/mods/ui-party/textures/upgrade.dds', width=12, height=12 }
local enhance2 = { val = false }

function SetIdle(u, idle)
	local changedOn = (not u.lastIsIdle) and idle

	if (UIP.GetSetting("alertIdleFac")) then
		if (changedOn and u:IsInCategory("FACTORY")) then
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Menu_Error_01'}))
		end
	end

	u.lastIsIdle = idle;
end

function Init()
	trackers = {
		{
			name="idle",
			testFn= function(u)
				if (u:IsInCategory("FACTORY") or u:IsInCategory("ENGINEER")) and u:IsIdle() and u:GetWorkProgress() == 0 then
					if u:IsInCategory("FACTORY") then
						if (u.assistedByF) then
							-- idle master fac is terrible
							SetIdle(u, true)
							return idle1
						elseif (u.assistedByE) then
							-- idle assistedByEng fac is bad
							SetIdle(u, true)
							return idle2
						else
							-- idle solo fac is bad
							SetIdle(u, true)
							return idle3
						end
					else
						-- idle engie is not bad
						SetIdle(u, true)
						return idle4
					end
				end
				SetIdle(u, false)
				return idle5
			end
		},
		{
			name="submerged",
			testFn= function(u)
				if u:IsInCategory("SUBMERSIBLE") then
					if u:IsInCategory("DESTROYER") then
						if GetIsSubmerged({u}) == -1 then
							-- submerged destroyer
							return sub1
						end
					else
						if GetIsSubmerged({u}) == 1 then
							-- surfaced sub
							return sub2
						end
					end
				end
				return sub3
			end
		},
		{
			name="loaded",
			testFn= function(u)
				if u:IsInCategory("SILO") then

					local mi = u:GetMissileInfo()
					if (mi) then
						if (mi.nukeSiloStorageCount > 0) then
							return silo1
						end
						if (mi.tacticalSiloStorageCount > 0) then
							return silo2
						end
					end

				end
				return silo3
			end
		},
		{
			name="locked",
			testFn= function(u)
				if u.locked then
					if u:IsInCategory("FACTORY") then return locked1 end
					return locked1
				end
				return locked3
			end,

		},
		{
			name="upgrade",
			testFn= function(u)
				if (u:IsInCategory("STRUCTURE")) then
					local queue = SetCurrentFactoryForQueueDisplay(u);
					if (queue ~= nil) then
						local firstItem = queue[1]
						local firstBp = __blueprints[firstItem.id]
						local firstIsStruct = from(firstBp.Categories).contains("STRUCTURE")
						if (firstIsStruct) then
							if GetIsPaused({ u }) then
								return upgrade1
							else
								return upgrade2
							end
						end
					end
				end
				return upgrade3
			end
		},
		{
			name="assisted",
			testFn= function(u)
				if (not u:IsInCategory("FACTORY")) then
					if u.assistedByE then return assisted1
					elseif u.assistedByU then return assisted2
					end
				end
				return assisted3
			end
		},
		{
			name="masterFactory",
			testFn= function(u)

				local repeating_master = master1
				local master = master2
				local repeating_solo = master3
				local solo = master4

				if (u:IsInCategory("FACTORY")) then
					local isGuarding = u:GetGuardedEntity() ~= nil
					local isRepeating = u:IsRepeatQueue()
					local hasQueue = SetCurrentFactoryForQueueDisplay(u) ~= nil
					local isMaster = u.assistedByF

					if (u.assistedByF) then

						if (isGuarding) then
							isMaster = hasQueue
						end

					end

					if (isMaster) then

						if isRepeating then
							return repeating_master
						else
							return master
						end

					else

						if hasQueue then
							-- its a solo

							if isRepeating then
								return repeating_solo
							else
								return solo
							end
						end

					end
				end
				return master5
			end
		}
	}

	if (hasNotify) then

		enhancementQueue = notify.getEnhancementQueue()

		table.insert(trackers,
			{
				name="enhance",
				testFn= function(u)

					if (u.isEnhancing) then
						return enhance1
					end
					return enhance2
				end
			});

	end
end

local adornmentsVisible = false

function OnBeat()

	if UIP.Enabled() then

		local selectedUnits = GetSelectedUnits()

		local units = CommonUnits.Get()

		from(units).foreach(function(k,v)
			if v.uip == nil then
				v.uip = true
				UnitFound(v)
			end

			v.lastIsUpgradee = v.isUpgradee
			v.lastIsEnhancing = v.isEnhancing

			v.assistedByF = false
			v.assistedByE = false
			v.assistedByU = false
			v.isUpgradee = false
			v.isUpgrader = false
			v.upgradingTo = nil
			v.upgradingFrom = nil

			if hasNotify then
				local unitQueue = enhancementQueue[v:GetEntityId()];
				v.isEnhancing = unitQueue ~= nil and table.getn(unitQueue) > 0
			end

		end)

		from(units).foreach(function(k,v)
			local e = v:GetGuardedEntity()
			if e ~= nil then
				if v:IsInCategory("FACTORY") then e.assistedByF = true
				elseif v:IsInCategory("ENGINEER") then e.assistedByE = true
				else e.assistedByU = true
				end
			end

			if v:IsInCategory("STRUCTURE") then
				local f = v:GetFocus()
				if f ~= nil and f:IsInCategory("STRUCTURE") then
				v.isUpgrader = true
				v.upgradingTo = f;
				f.isUpgradee = true
				f.upgradingFrom = v;
				end
			end
		end)

		if (UIP.GetSetting("alertUpgradeFinished")) then
			from(units).foreach(function(k,v)
				if v.lastIsUpgradee and not v.isUpgradee and not v:IsDead() then
					PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
					print(UnitHelper.GetUnitName(v) .. " complete")
				end
				if v.lastIsEnhancing and not v.isEnhancing and not v:IsDead() then
					PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
					print(UnitHelper.GetUnitName(v) .. " no longer upgrading") -- too hard to work out if complete/cancelled, we only know if there is an upgrade in the queue at al
				end
			end)
		end

		local newadornmentsVisible = UIP.GetSetting("showAdornments")
		if adornmentsVisible and not newadornmentsVisible then
			from(units).foreach(function(k,v)
				RemoveAllAdornments(v)
			end)
		end
		adornmentsVisible = newadornmentsVisible

		if adornmentsVisible then
			from(units).foreach(function(k,v)
				if not v.isUpgradee then -- the old fac is overlayed by new fac unit - we dont want to draw icons for new fac until old one dies
					UpdateUnit(v)
				end
			end)
		end

		if selectedUnits and table.getn(selectedUnits) == 1 then
			-- return the queue back the way it was. For some reasons this throws errors (without harm) until you deselect and reselect your acu
			SetCurrentFactoryForQueueDisplay(selectedUnits[1])
		else
			ClearCurrentFactoryForQueueDisplay()
		end

	end

end

function Shutdown()
	local units = CommonUnits.Get()
	from(units).foreach(function(k,v)
		RemoveAllAdornments(v)
	end)
end

function RemoveAllAdornments(u)
	local st = u.StateTracker
	from(trackers).foreach(function(k,v)
		local entry = st[v.name]
		if entry.overlay ~= nil then
			entry.overlay:Hide()
			entry.overlay:Destroy()
			entry.overlay = nil
		end
		entry.value = false
	end)

end

function UnitFound(u)
	if UIP.GetSetting("setGroundFireOnAttack") then
		ToggleFireState({ u }, 1)
	end
	if UIP.GetSetting("factoriesStartWithRepeatOn") then
		u:ProcessInfo('SetRepeatQueue', 'true')
	end

	if u.StateTracker == nil then

		local st = {}

		from(trackers).foreach(function(k,v)
			st[v.name] = { value = false }
		end)

		u.StateTracker = st
		st.group = Group(GetFrame(0))
		st.group.Width:Set(10)
		st.group.Height:Set(10)
		st.group.Top:Set(15)
		st.group.Left:Set(15)
		st.group:SetNeedsFrameUpdate(true)
		st.group.OnFrame = function(self, delta)
			UpdateUnitPos(u)
		end

	end

end

function UpdateUnit(u)
	local st = u.StateTracker
	local relayoutRequired = false

	from(trackers).foreach(function(k,v)
		local result = v.testFn(u)
		if result == nil then result = { val=false } end

		local entry = st[v.name]
		local changed = entry.value ~= result.val

		if changed then
			relayoutRequired = true
			entry.value = result.val

			if entry.overlay ~= nil then
				entry.overlay:Hide()
				entry.overlay:Destroy()
				entry.overlay = nil
			end

			if result.val ~= false then
				entry.overlay = Bitmap(st.group)
				--entry.overlay:SetAlpha(0.5, true)
				entry.overlay:SetTexture(result.img, 0)
				entry.overlay.Width:Set(result.width)
				entry.overlay.Height:Set(result.height)
			end
		end
	end)

	if relayoutRequired then
		local offset = 0
		from(trackers).foreach(function(k,v)
			local entry = st[v.name]
			if entry.value ~= false then
				LayoutHelpers.AtLeftTopIn(entry.overlay, st.group, offset, 0)
				offset = offset + entry.overlay.Width()
			end
		end)
	end

end

function UpdateUnitPos(u)
	local st = u.StateTracker
	if(not u:IsDead()) then
		local worldView = import('/lua/ui/game/worldview.lua').viewLeft
		local pos1 = u:GetPosition()
		local posA = worldView:Project(pos1)
		LayoutHelpers.AtLeftTopIn(st.group, worldView, posA.x + 3, posA.y)
	else
		DestroyTracker(u, st)
	end
end

function DestroyTracker(u, st)
	from(trackers).foreach(function(k,v)
		local entry = st[v.name]
		if entry.value then
			entry.overlay:Destroy()
		end
	end)
	st.group:Destroy()
end