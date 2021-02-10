      
--[[
TODO:
-  add localize strings
-  add logic for loading strings based on local of the game
--]]

locals = {}

local modPath = '/mods/SupremeScoreBoard/'
local modTextures = modPath..'textures/'
local modScripts  = modPath..'modules/'
local log  = import(modScripts..'ext.logging.lua')
 
function initalize()
    locals['game_timer'] = 'Game Time'
    locals['game_timer_info'] = 'Elapsed game time or no rush timer'
    locals['game_quality'] = 'Game Balance'
    locals['game_quality_info'] = 'Game balance based on rating of players in teams \n >90% - good balance \n <90% - poor balance'
    locals['game_speed'] = 'Game Speed'
    locals['game_speed_info'] = 'Game speed set by an observer vs actual game speed'
    locals['game_speed_slider'] = 'Game Speed Slider'
    locals['game_speed_slider_info'] = 'Allows an observer to adjust game speed'
    
    locals['game_ranked'] = 'Game Ranking'
    locals['game_ranked_ladder'] = 'This game applies to Ladder Ranking but it will not affect your Global Ranking'
    locals['game_ranked_info'] = 'This game applies to Global FAF Ranking if all these conditions are met:'  
    locals['game_ranked_HasNoAI'] = ' no AI players' 
    locals['game_ranked_HasNoCheating'] = ' no cheating enabled' 
    locals['game_ranked_HasNoRushOff'] = ' no rush disabled'  
    locals['game_ranked_HasNoRestrictions'] = ' no unit restrictions'  
    locals['game_ranked_HasNoPrebuilt'] = ' no prebuilt units'  
    locals['game_ranked_HasNoSimMods'] = ' no sim mods'  
    locals['game_ranked_HasLockedTeams'] = ' locked teams'   
    locals['game_ranked_HasAssassination'] = ' assassination victory'  
    locals['game_ranked_HasShareUnits'] = ' sharing units til death'  
    locals['game_ranked_HasShareCaps'] = ' sharing cap with no one'  
    locals['game_ranked_HasNormalSpeed'] = ' normal speed'  
    locals['game_ranked_HasLowTimeouts'] = ' three timeouts' 
    locals['game_ranked_HasFogOfWar'] = ' fog of war explored' 
        
    locals['game_mods'] = 'Mods Sim/UI'
    locals['game_id']   = 'Replay ID in FAF vault'
   
    locals['share_units'] = 'Share Your Units '  
    locals['share_units_info'] = 'Transfer ownership of your units to this player. \n ' ..
    'LeftClick - selected units \n' ..
    'LeftClick+Shift - all units \n' ..
    'RightClick - request engineer \n \n' ..
    'Note that units will not be transferred if this player has reached units capacity'  
    
    locals['share_mass'] = 'Share Your Mass '  
    locals['share_mass_info'] = 'Transfer stored mass to this player. \n ' ..
    'LeftClick - sent 50% \n' ..
    'LeftClick+Shift - sent 100% \n' ..
    'RightClick - request mass\n \n' ..
    'Note that surplus of the transferred mass will be returned to you if this player has already full mass storage  '  
    
    locals['share_engy'] = 'Share Your Energy '  
    locals['share_engy_info'] = 'Transfer stored energy to this player. \n ' ..
    'LeftClick - sent 50% \n' ..
    'LeftClick+Shift - sent 100% \n' ..
    'RightClick - request energy\n \n' ..
    'Note that surplus of the transferred energy will be returned to you if this player has already full energy storage  ' 
    
    locals['units_count'] = 'Units Count'
    locals['units_count_info'] = 'Current and maximum units count. Observer will see cumulative units stats for all players. Switch to player\'s view to see unit count for that player'
    
    locals['army_teams'] = 'Faction/Team ID'
    locals['army_teams_info'] = 'Sort players and teams by their team number'
    locals['army_rating'] = 'Army Rating'
    locals['army_rating_info'] = 'Sort players and teams by their rating'
    --locals['army_nameshort'] = 'Army Name'
    --locals['army_nameshort_info'] = 'Sort players and teams by their names'
    locals['army_nameshort'] = 'Army Name and Clan'
    locals['army_nameshort_info'] = 'Sort players and teams by their names and clans (if present)'
    locals['army_namefull'] = 'Army Name and Clan'
    locals['army_namefull_info'] = 'Sort players and teams by their names and clans (if present)'
    locals['army_score'] = 'Army Score'
    locals['army_score_info'] = 'Sort players and teams by their score points that are calculated by income, kills, loses, units count'
    locals['army_status'] = 'Army Status'
    locals['army_status_info'] = 'Sort players and teams by their status'
    
    locals['team'] = 'TEAM'
    
    locals['ratio.killsToBuilt'] = 'Kills/Built Ratio'
    locals['ratio.killsToBuilt_info'] = 'Sort players by their kills-to-built ratio that is calculated using total cost of units killed by total cost of units built. ' ..
        'This ratio tells how much a player is killing vs. how much spending on units and eco upgrades' ..
        '\n Ratio > 0.25 (Pro) ' .. 
        '\n Ratio ~ 0.15 (Average) ' .. 
        '\n Ratio < 0.05 (Bad)'
    locals['ratio.killsToLoses'] = 'Kills/Loses Ratio'
    locals['ratio.killsToLoses_info'] = 'Sort players by their kills-to-loses ratio that is calculated using total cost of units killed by total cost of units lost. ' ..
        'This ratio tells how much a player is aggressive and how well is using his units to kill enemy units' ..
        '\n Ratio > 2.0 (Pro) ' .. 
        '\n Ratio ~ 1.0 (Average) ' .. 
        '\n Ratio < 0.5 (Bad)'
          
    locals['eco.massIncome'] = 'Current Mass Income'
    locals['eco.massIncome_info'] = 'Sort players and teams by their current mass income'
    locals['eco.massTotal'] = 'Total Mass Collected'
    locals['eco.massTotal_info'] = 'Sort players and teams by their total mass collected. This column includes mass reclaimed and mass produced by mass extractors'
    locals['eco.massReclaim'] = 'Total Mass Reclaimed'
    locals['eco.massReclaim_info'] = 'Sort players and teams by their total mass reclaim. \n\n NOTE: This works only in games played with FAF Beta patch'
    locals['eco.engyIncome'] = 'Current Energy Income'
    locals['eco.engyIncome_info'] = 'Sort players and teams by their current energy income'
    locals['eco.engyTotal'] = 'Total Energy Collected'
    locals['eco.engyTotal_info'] = 'Sort players and teams by their total energy collected. This column includes energy reclaim and energy produced by power generators'
    locals['eco.engyReclaim'] = 'Total Energy Reclaimed'
    locals['eco.engyReclaim_info'] = 'Sort players and teams by their total energy reclaim. \n\n NOTE: This works only in games played with FAF Beta patch'
   
    locals['kills.mass'] = 'Total Mass in Units Killed'
    locals['kills.mass_info'] = 'Sort players and teams by their total mass cost of killed units'
    locals['loses.mass'] = 'Total Mass in Units Lost'
    locals['loses.mass_info'] = 'Sort players and teams by their total mass cost of lost units'
    
    locals['units.air'] = 'Air Units'
    locals['units.air_info'] = 'Sort players and teams by their current count of land units.   '
    locals['units.land'] = 'Land Units'
    locals['units.land_info'] = 'Sort players and teams by their current count of land units.   '
    locals['units.navy'] = 'Naval Units'
    locals['units.navy_info'] = 'Sort players and teams by their current count of naval units.   '
    locals['units.total'] = 'All Units'
    locals['units.total_info'] = 'Sort players and teams by their current count of all units types.  '
    -- Victory Conditions
    locals['vc_unknown'] = 'VC UKNOWN'
    locals['vc_unknown_info'] = 'Game has unknown victory condition'
    locals['vc_demoralization'] = 'Assassination'
    locals['vc_demoralization_info'] = 'Game ends when you assassinate all enemy ACUs'
    locals['vc_domination'] = 'Supremacy'
    locals['vc_domination_info'] = 'Game ends when you kill all enemy structures and engineers'
    locals['vc_eradication'] = 'Annihilation'
    locals['vc_eradication_info'] = 'Game ends when you kill all enemy structures and units'
    locals['vc_sandbox'] = 'Sandbox'
    locals['vc_sandbox_info'] = 'Game never ends'
    -- Unit Restrictions
    locals['ur'] = 'Unit Restrictions'
    locals['ur_NONE'] = 'None'
    locals['ur_UEF'] = 'No UEF'
    locals['ur_AEON'] = 'No AEON'
    locals['ur_SERAPHIM'] = 'No SERAPHIM'
    locals['ur_CYBRAN'] = 'No CYBRAN'
    locals['ur_NOMADS'] = 'No NOMADS'
    locals['ur_NONE_info'] = 'No unit restrictions in this game'
    locals['ur_TELE'] = 'No Teleport Upgrades'
    locals['ur_TELE_info'] = 'Removes Teleport Upgrade on All ACUs and SCUs '
    locals['ur_PARAGON'] = 'No Paragon (AEON)'
    locals['ur_SATELLITE'] = 'No Satellites (UEF)'
    locals['ur_GAMEENDERS'] = 'No Game Enders'
    locals['ur_GAMEENDERS_info'] = 'ALL T3 Heavy Artillery \n AEON Paragom \n UEF Novax Satellite \n SERAPHIM Yolona Oss'
    locals['ur_SUPERGAMEENDERS'] = 'No Super Game Enders'
    locals['ur_SUPERGAMEENDERS_info'] = 'AEON Salvation \n UEF Mavor \n CYBRAN Scathis \n SERAPHIM Yolona Oss'
    locals['ur_BILLY'] = 'No Tactical Nuke Missiles (Billy)'
    locals['ur_BILLY_info'] = 'Removes Tactical Nuke Upgrade on UEF ACU'
    locals['ur_SALVAMAVOSCATH'] = 'No Super Artillery'
    locals['ur_SALVAMAVOSCATH_info'] = 'AEON Salvation \n CYBRAN Scathis '
    locals['ur_ENGISTATION'] = 'No Engineering Station'
    locals['ur_PRODFA'] = 'No FA Units'
    locals['ur_T1']    = 'No TECH 1 Units'
    locals['ur_T2']    = 'No TECH 2 Units'
    locals['ur_T3']    = 'No TECH 3 Units'
    locals['ur_T3AIR'] = 'No TECH 3 Air Units'
    locals['ur_EXPERIMENTAL'] = 'No TECH 4 Units (Exp)'
    locals['ur_T3MOBILEAA'] = 'No T3 Mobile Air Units'
    locals['ur_WALL'] = 'No Wall Structures'
    locals['ur_SUPPFAC'] = 'No Support Factories'
    locals['ur_NAVAL'] = 'No Naval Units'
    locals['ur_AIR']   = 'No Air Units'
    locals['ur_LAND']  = 'No Land Units'
    locals['ur_SUPCOM'] = 'No Support Commanders'
    locals['ur_EYE'] = 'No Super Intel'
    locals['ur_EYE_info'] = 'AEON Rhianne \n CYBRAN Soothsayer'
    locals['ur_INTEL'] = 'No Intel Structures'
    locals['ur_INTEL_info'] = 'No Sonars, Radars, Optical, Sensors'
    locals['ur_T3MOBILEAA'] = 'No TECH 3 Mobile Anti Air'
    locals['ur_BUBBLES'] = 'No Shield Structures'
    locals['ur_FABS'] = 'No Mass Fabricators'
    locals['ur_NUKE'] = 'No Nuke Missiles'
    locals['ur_NUKE_info'] = 'ALL Strategic Nuke Launchers \n ' .. 
                             'ALL Strategic Nuke Subs \n ' .. 
                             'SERAPHIM Battleships'
    -- Share Unit Cap
    locals['suc_none']   = 'Sharing cap with none'  
    locals['suc_all']    = 'Sharing cap with all'  
    locals['suc_allies'] = 'Sharing cap with allies'  
    -- Share Conditions
    locals['sc']          = 'Share Conditions'
    locals['sc_no']       = 'Sharing units after death (Full Share)'
    locals['sc_no_info']  = 'You can give units to your allies and they will not be destroyed when you die'
    locals['sc_yes']      = 'Sharing units until death'
    locals['sc_yes_info'] = 'All the units you gave to your allies will be destroyed when you die'
   
    locals['ai_info']   = 'AI Status'
    locals['ai_omni']   = 'Omni:   '
    locals['ai_build']  = 'Build:  '
    locals['ai_income'] = 'Income: '
      
end

initalize()
	
function loc(key)
    local text = locals[key]
    if text == nil then
       text = 'MISSING LOC ' .. key .. '' 
       log.Warning(text)
    end
    return text
end

-- get tooltip for pre-defined key 
function tooltip(key, textAppend, bodyAppend)
    textAppend = textAppend or ''
    bodyAppend = bodyAppend or ''
    return { text = loc(key)..textAppend, body = loc(key..'_info')..bodyAppend }
end 

-- change case of a string value to lower if it exists  
function lower(value)
    if value == nil then return '' end
    return string.lower(value)
end 
-- change case of a string value to upper if it exists  
function upper(value)
    if value == nil then return '' end
    return string.upper(value)
end 
  
function subs(str, strStart, strStops)
    --LOG('>>>> HUSSAR: GetStringFrom= ' .. str)
    if (str and strStart and strStops) then
        local start = string.find(str, strStart)
        local stops = string.find(str, strStops)
        if (start and start >= 0 and 
            stops and stops >= 0) then
            local ret = string.sub(str, start+1, stops-1) 
            --LOG('>>>> HUSSAR: GetStringFrom= ' .. ret)
            return ret
        end
    end
    return nil
end
 
function split(str, delimiter)
	--LOG('split'..' = '..str)
    local result = { }
	local from = 1
	local delim_from, delim_to = string.find( str, delimiter, from  )
	while delim_from do
        item = string.sub( str, from , delim_from-1 )
        --LOG('split '..'='..item)
		table.insert( result, item)
		from = delim_to + 1
		delim_from, delim_to = string.find( str, delimiter, from  )
	end
    item = string.sub( str, from  )
    --LOG('split '..'='..item)
	table.insert( result, item )
	return result
end
  