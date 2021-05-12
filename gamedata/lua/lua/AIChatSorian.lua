---  File     :  /lua/modules/AIChatSorian.lua
---  Author(s): Mike Robbins aka Sorian
---  Summary  : AI Chat Functions

local Chat = import('/lua/ui/game/chat.lua')
local ChatTo = import('/lua/lazyvar.lua').Create()

function AIChat(group, text, sender)

	if text then
	
        if import('/lua/ui/game/taunt.lua').CheckForAndHandleTaunt(text, sender) then
           return
        end
		
		ChatTo:Set(group)
		msg = { to = ChatTo(), Chat = true }
		msg.text = text
		msg.aisender = sender
		
		local armynumber = GetArmyData(sender)
		
		if ChatTo() == 'allies' then
			AISendChatMessage(FindAllies(armynumber), msg)
			
		elseif ChatTo() == 'enemies' then
			AISendChatMessage(FindEnemies(armynumber), msg)
			
		elseif type(ChatTo()) == 'number' then
			AISendChatMessage({ChatTo()}, msg)
			
		else
			AISendChatMessage(nil, msg)
		end
	end
end

function FindAllies(army)

	local t = GetArmiesTable()

	local result = {}
	
	for k,v in t.armiesTable do
		
        if v.human and IsAlly(tonumber(k), tonumber(army)) and k != army then
			table.insert(result, k)
        end
	end

	return result
end

function FindEnemies(army)

	local t = GetArmiesTable()
	
	local result = {}
	
	for k,v in t.armiesTable do
	
        if IsEnemy(k, army) and v.human then
			table.insert(result, k)
        end
	end

	return result
end

function AISendChatMessage(towho, msg)
	
	local t = GetArmiesTable()
	local focus = t.focusArmy
	
	if msg.Chat then
	
		if towho then
		
			for k,v in towho do
			
				if v == focus then
					import('/lua/ui/game/chat.lua').ReceiveChat(msg.aisender, msg)
				end
				
			end
		else
			import('/lua/ui/game/chat.lua').ReceiveChat(msg.aisender, msg)
		end
		
	elseif msg.Taunt then
		import('/lua/ui/game/taunt.lua').RecieveAITaunt(msg.aisender, msg)
	end
end

function GetArmyData(army)

    local armies = GetArmiesTable()
	
    if type(army) == 'string' then
	
        for i, v in armies.armiesTable do
		
            if v.nickname == army then
                return i
            end
        end
    end
    return nil
end

-- Certain Text messages to AI Allies can trigger one of several AI responses
-- As follows
--		-- target at will	-- returns enemy selection back over to the AI if it was being overridden
--		-- target X			-- makes the AI select that player as his enemy 
--		-- focus
--		-- give me an engineer	-- The AI will donate an available engineer - if he has any
--		-- current focus	-- The AI will reply with who his current enemy is
--		-- current plan		-- The AI will begin drawing his current plan on the map
--		-- current status	-- The AI will begin reporting his current military ratio evaluations

function ProcessAIChat(to, from, text)

	local function trim(s)
		return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
	end

	local armies = GetArmiesTable()
	
	if (to == 'allies' or type(to) == 'number') then
	
		for i, v in armies.armiesTable do
			if not v.human and not v.civilian and IsAlly(i, from) and (to == 'allies' or to == i) then
			
				local testtext = string.gsub(text, '%s(.*)', '')
				local aftertext = string.gsub(text, '^%a+%s', '')
				
				aftertext = trim(aftertext)
				
				-- If "engi" appears in a whisper, it's almost certainly an engineer request
				if (to == i) and string.find(text, "engi") then
					SimCallback({Func = 'AIChat', Args = {Army = i, ToArmy = from, GiveEngineer = true}})

				elseif string.lower(testtext) == 'target' and aftertext != '' then
				
					if string.lower(aftertext) == 'at will' then
						SimCallback({Func = 'AIChat', Args = {Army = i, NewTarget = 'at will'}})
					else
						for x, z in armies.armiesTable do
							if trim(string.lower(string.gsub(z.nickname,'%b()', '' ))) == string.lower(aftertext) then
								SimCallback({Func = 'AIChat', Args = {Army = i, NewTarget = x}})
							end
						end
					end
					
				elseif string.lower(testtext) == 'focus' and aftertext != '' then
					local focus = trim(string.lower(aftertext))
					SimCallback({Func = 'AIChat', Args = {Army = i, NewFocus = focus}})
					
				elseif string.lower(testtext) == 'current' and aftertext == 'focus' then
					SimCallback({Func = 'AIChat', Args = {Army = i, CurrentFocus = true}})
					
				elseif string.lower(testtext) == 'current' and aftertext == 'plan' then
					SimCallback({Func = 'AIChat', Args = {Army = i, CurrentPlan = true}})
					
				elseif string.lower(testtext) == 'current' and aftertext == 'status' then
					SimCallback({Func = 'AIChat', Args = {Army = i, CurrentStatus = true}})				
					
				elseif string.lower(testtext) == 'command' and to == i then
					SimCallback({Func = 'AIChat', Args = {Army = i, ToArmy = from, Command = true, Text = aftertext}})
					
				elseif to == i then
					SimCallback({Func = 'AIChat', Args = {Army = i, ToArmy = from, Command = true, Text = ''}})
					
				end
			end
		end
	elseif to == 'all' then
		for i, v in armies.armiesTable do
			-- Sending one of the tokens below to all chat broadcasts a request
			-- for the AI to reply with its current cheat multiplier
			if not v.human and not v.civilian and 
			string.find(text, "aimult") or 
			string.find(text, "aicheat") or 
			string.find(text, "ailevel") then
				SimCallback({Func = 'AIChat', Args= {Army = i, ToArmy = from, PrintMult = true}})
				continue
			end
		end
	end		
end