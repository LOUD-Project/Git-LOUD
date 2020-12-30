local SelectionDeprioritizer = import('/mods/SelectionDeprioritizer/modules/SelectionDeprioritizer.lua')
local KeyMapper = import('/lua/keymap/keymapper.lua')
local Prefs = import('/lua/user/prefs.lua')

local orderCategory = "Mod: Selection Deprioritizer"
local prefsName = "SelectionDeprioritizerSettings"
local savedPrefs = nil


local exoticBlueprintIds = { 

	"xrl0302", -- fire beetle

	"ual0304", -- Serenity
	"url0304", -- Trebuchet
	"xsl0304", -- Suthanus
	"uel0304", -- Demolisher
	"dal0310", -- Absolver
	"xel0306", -- Spearhead

	"xal0305", -- Sprite Striker
	"xsl0305", -- Usha-Ah

	"dra0202", -- Corsair
	"daa0206", -- Mercy

	-- torp bombers
	"uaa0204", -- Skimmer
	"ura0204", -- Cormorant
	"xsa0204", -- Uosioz
	"uea0204", -- Stork
	"xaa0306", -- Solace

	-- strat bombers
	"uaa0304", -- Shocker
	"ura0304", -- Revenant
	"xsa0304", -- Sinntha
	"uea0304", -- Ambassador

	-- aircraft carriers
	"uas0303", -- Keefer Class
	"urs0303", -- Command Class
	"xss0303", -- Iavish

	-- strat subs
	"uas0304", -- Silencer
	"urs0304", -- Plan B
	"ues0304", -- Ace

	-- missile ship
	"xas0306", -- Torrent Class

	-- t3 sonar
	"uas0305", -- aeon
	"urs0305", -- Flood XR
	"ues0305" -- SP3 - 3000
}


local exoticAssistBlueprintIds = { 
    -- t1 scouts
	"ual0101", --Spirit
	"url0101", --Mole
	"xsl0101", --Selen
	"uel0101", --Snoop
	
    -- mobile shields
    "xsl0307", --Athanah
	"uel0307", --Parashield
	"ual0307", --Asylum
	
	"url0306" --Deceiver
}


local defaults = {
    { name = "General", settings = {
        { key="isEnabled", 			type="bool",	default=true, 	name="Mod is enabled", 		},
        { key="filterAssisters", 	type="bool",	default=true, 	name="Filter assisters", 	},
        { key="filterDomains", 		type="bool",	default=false, 	name="Filter domains", 		},
        { key="filterExotics", 		type="bool",	default=true, 	name="Filter exotics", 		},
    }},
    { name = "Filter", settings = {
        { key="Domains", 			type="choice",	default=1, 		name="Which domains to filter",	choices = {
			[1] = { key="NAVAL > LAND  > AIR", 		value = {"NAVAL", "LAND", "AIR"}},
			[2] = { key="NAVAL > AIR   > LAND", 	value = {"NAVAL", "AIR", "LAND"}},
			[3] = { key="LAND  > AIR   > NAVAL", 	value = {"LAND", "AIR", "NAVAL"}},
			[4] = { key="LAND  > NAVAL > AIR", 		value = {"LAND", "NAVAL", "AIR"}},
			[5] = { key="AIR   > LAND  > NAVAL", 	value = {"AIR", "LAND", "NAVAL"}},
			[6] = { key="AIR   > NAVAL > LAND", 	value = {"AIR", "NAVAL", "LAND"}},
		}},
    }},
}


function savePreferences()
    Prefs.SetToCurrentProfile(prefsName, savedPrefs)
    Prefs.SavePreferences()
	
	SelectionDeprioritizer.setSavedPrefs(savedPrefs)
	SelectionDeprioritizer.setExoticBlueprintIds(exoticBlueprintIds)
	SelectionDeprioritizer.setExoticAssistBlueprintIds(exoticAssistBlueprintIds)
	
	-- set current domains categories
	setting = getByKey(getByKey(defaults, "name", "Filter").settings, "key", "Domains")
	choice = setting.choices[savedPrefs["Filter"]["Domains"]]
	SelectionDeprioritizer.setDomainCategories(choice.value)
end


function addHotkey(name, fun_args, order)
	KeyMapper.SetUserKeyAction(name, {
		action = "UI_Lua import('/mods/SelectionDeprioritizer/modules/SelectionDeprioritizerConfig.lua')"..fun_args,
		category = orderCategory,
		order = order,
	})
end


function getByKey(tbl, key_name, key_value)
	for _, sub_tbl in tbl do
		if sub_tbl[key_name] == key_value then
			return sub_tbl
		end
	end
	return {}
end


-- for bool values
function toggleSetting(group_name, setting_key)
	savedPrefs[group_name][setting_key] = not savedPrefs[group_name][setting_key]
	savePreferences()
	group = getByKey(defaults, "name", group_name)
	setting = getByKey(group.settings, "key", setting_key)	
	print("Toggling ["..setting.name..'] to: '..repr(savedPrefs[group_name][setting_key]))
end


-- for choices
function cycleChoiceSetting(group_name, setting_key)
	setting = getByKey(getByKey(defaults, "name", group_name).settings, "key", setting_key)
	choice = setting.choices[savedPrefs[group_name][setting_key]]
	savedPrefs[group_name][setting_key] = 1 + (math.mod(savedPrefs[group_name][setting_key], table.getn(setting.choices)))
	savePreferences()
	print("Cycling ["..setting.name..'] to: '..repr(choice.key))
end


function setChoiceSetting(group_name, setting_key, choice_value)
	setting = getByKey(getByKey(defaults, "name", group_name).settings, "key", setting_key)
	choice = setting.choices[savedPrefs[group_name][setting_key]]
	savedPrefs[group_name][setting_key] = choice_value
	savePreferences()
	print("Setting ["..setting.name..'] to: '..repr(choice.key))
end


function setCurrentDomainCats()
	
end


function init()
    savedPrefs = Prefs.GetFromCurrentProfile(prefsName)

    -- create defaults prefs, add previously missing ones
    if not savedPrefs then
        savedPrefs = {}
    end

    for i, group in defaults do
        if not savedPrefs[group.name] then
            savedPrefs[group.name] = {}
        end
        for j, setting in group.settings do
            if (savedPrefs[group.name][setting.key] == nil) then
                savedPrefs[group.name][setting.key] = setting.default
            end
		
			-- add toggle hotkeys for bool values
			if setting.type == "bool" then
				addHotkey('Toggle: '..setting.name, ".toggleSetting('"..group.name.."','"..setting.key.."')", i*1000+j)
			end
			
			-- add set + cycle hotkeys for choices
			if setting.type == "choice" then
				addHotkey('Cycle: '..setting.name, ".cycleChoiceSetting('"..group.name.."','"..setting.key.."')", i*1000+j*100)
				for k, choice in setting.choices do
					addHotkey('Set: '..setting.name..' to: '..choice.key, ".setChoiceSetting('"..group.name.."','"..setting.key.."',"..k..")", i*1000+j*100+k)
				end
			end
        end
    end

    savePreferences()
end
