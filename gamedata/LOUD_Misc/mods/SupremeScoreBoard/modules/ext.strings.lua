      
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
    locals['vc_unknown_info'] = 'Game has an unknown victory condition.'
    locals['vc_demoralization'] = 'Assassination'
    locals['vc_demoralization_info'] = 'A player is defeated when the Commander is destroyed.'	
	locals['vc_decapitation'] = 'Advanced Assassination'
    locals['vc_decapitation_info'] = 'A player is defeated when the Commander and all Support Commanders are destroyed.'	
    locals['vc_domination'] = 'Supremacy'
    locals['vc_domination_info'] = 'A player is defeated when all engineers, factories and any unit that can build an engineer are destroyed.'
    locals['vc_eradication'] = 'Annihilation'
    locals['vc_eradication_info'] = 'A player is defeated when all structures (except walls) and all units are destroyed.'
    locals['vc_sandbox'] = 'Sandbox'
    locals['vc_sandbox_info'] = 'No player can ever be defeated.'
    -- Unit Restrictions
    locals['ur'] = 'Unit Restrictions'
    locals['ur_NONE'] = 'None'
    locals['ur_NONE_info'] = 'No unit restrictions in this game.'
    locals['ur_T1']    = 'No Tech 1'
    locals['ur_T1_info'] = 'Players will not be able to build Tech 1 structures or units.'
    locals['ur_T2']    = 'No Tech 2'
    locals['ur_T2_info'] = 'Players will not be able to build Tech 2 structures or units.'
    locals['ur_T3']    = 'No Tech 3'
    locals['ur_T3_info'] = 'Players will not be able to build Tech 3 structures or units.'
    locals['ur_EXPERIMENTAL'] = 'No Experimental/Tech 4'
    locals['ur_EXPERIMENTAL_info'] = 'Players will not be able to build Experimental/Tech 4 structures or units.'
    locals['ur_NAVAL'] = 'No Naval'
    locals['ur_NAVAL_info'] = 'Players will not be able to build Naval structures or units.'
    locals['ur_LAND']  = 'No Land'
    locals['ur_LAND_info'] = 'Players will not be able to build Land structures or units.'
    locals['ur_AIRSCOUTS'] = 'No Air Scouts'
    locals['ur_AIRSCOUTS_info'] = 'Players will not be able to build decoy, recon, scout or spy planes.'
    locals['ur_AIRFIGHTERS'] = 'No Air Fighters'
    locals['ur_AIRFIGHTERS_info'] = 'Players will not be able to build interceptors or other Air-to-Air aircraft.'
    locals['ur_AIRBOMBERS'] = 'No Air Bombers'
    locals['ur_AIRBOMBERS_info'] = 'Players will not be able to build any bombers.'
    locals['ur_AIRTORPEDOBOMBERS'] = 'No Torpedo Bombers'
    locals['ur_AIRTORPEDOBOMBERS_info'] = 'Players will not be able to build any torpedo bombers.'
    locals['ur_AIRGUNSHIPS'] = 'No Air Gunships'
    locals['ur_AIRGUNSHIPS_info'] = 'Players will not be able to build any standard or experimental gunships.'
    locals['ur_AIRTRANSPORTS'] = 'No Air Transports'
    locals['ur_AIRTRANSPORTS_info'] = 'Players will not be able to build any standard or experimental transports.'
    locals['ur_AIREXPERIMENTALS'] = 'No Air Experimentals'
    locals['ur_AIREXPERIMENTALS_info'] = 'Players will not be able to build any air experimentals.'
    locals['ur_TACTICALMISSILELAUNCHERS'] = 'No TMLs'
    locals['ur_TACTICALMISSILELAUNCHERS_info'] = 'Players will not be able to build Tactical Missile Launchers.'
    locals['ur_TACTICALARTILLERY'] = 'No T3 Barrage Artillery'
    locals['ur_TACTICALARTILLERY_info'] = 'Players will not be able to build T3 Barrage Artillery.'
    locals['ur_STRATEGICARTILLERY'] = 'No T3 Strategic Artillery'
    locals['ur_STRATEGICARTILLERY_info'] = 'Players will not be able to build T3 Strategic Artillery.'
    locals['ur_EXPERIMENTALARTILLERY'] = 'No Experimental/T4 Artillery'
    locals['ur_EXPERIMENTALARTILLERY_info'] = 'Players will not be able to build Experimental/T4 Artillery.'
    locals['ur_NUKE'] = 'No Nukes'
    locals['ur_NUKE_info'] = 'Players will not be able to build nuke defences or launchers.'
    locals['ur_SHIELDS'] = 'No Dedicated Shield Generators'
    locals['ur_SHIELDS_info'] = 'Players will not be able to build mobile or stationary shield generators. Personal shields and shield enhancements are not affected.'
    locals['ur_SUPPORTCOMMANDERS'] = 'No Support Commanders (SACUs)'
    locals['ur_SUPPORTCOMMANDERS_info'] = 'Players will not be able to build Support Commanders. -- NOTE: THIS WILL PREVENT THE BUILDING OF ALMOST ALL EXPERIMENTAL UNITS'
    locals['ur_INTEL'] = 'No Intel Structures'
    locals['ur_INTEL_info'] = 'Players will not be able to build Radar, Omni, Sonar or special intel structures and units.'
    locals['ur_FABS'] = 'No Mass Fabrication'
    locals['ur_FABS_info'] = 'Players will not be able to build Mass Fabricators, including Experimental Resource Generators.'
    locals['ur_ALTAIR'] = 'T3 Alternative Air Production'
    locals['ur_ALTAIR_info'] = 'T3 air production is limited to spy planes, ASFs and torpedo bombers.'
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
  