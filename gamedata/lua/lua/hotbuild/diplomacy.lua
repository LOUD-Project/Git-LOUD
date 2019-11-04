local KeyMapper = import('/lua/keymap/keymapper.lua')

function initUserKeyActions()
    KeyMapper.SetUserKeyAction('give_units_to_ally', {action = "UI_LUA import('/lua/hotbuild/diplomacy.lua').mimc_giveSelectedUnitsToAlly(false)"})
	KeyMapper.SetUserKeyAction('give_all_units_to_ally', {action = "UI_LUA import('/lua/hotbuild/diplomacy.lua').mimc_giveSelectedUnitsToAlly(true)"})
	KeyMapper.SetUserKeyAction('give_mass_to_ally', {action = "UI_LUA import('/lua/hotbuild/diplomacy.lua').mimc_giveRessToAlly(50.0, 0.0)"})
	KeyMapper.SetUserKeyAction('give_energy_to_ally', {action = "UI_LUA import('/lua/hotbuild/diplomacy.lua').mimc_giveRessToAlly(0.0, 50.0)"})
end

function initDefaultKeyMap()
  initUserKeyActions()
  local defaultKeyMappings = import('/mods/mimc/defaultKeyMap.lua').mimcDefaultKeyMap
    for pattern, action in defaultKeyMappings do
    KeyMapper.SetUserKeyMapping(pattern, false, action)
  end
end

--function to give units to an allied player
function mimc_giveSelectedUnitsToAlly(giveAll)
	
	local allyIndex = getAllyIndex()
	if (allyIndex ~= -1) then
		if (giveAll) then

			SelectUnits(import('/mods/mimc/lib/units.lua').GetAllUnits())
			
	 	 	for index, id in getAllyIDs() do
				
				--Give Ressources to current mate.
				SimCallback( { Func="GiveResourcesToPlayer",
        	                   Args={ From=GetFocusArmy(),
                	                  To=id,
                        	          Mass= 100.0 / 100.0,
                                	  Energy= 100.0 / 100.0,
                                	}
                             	} )
                --Give Units to current mate.
				SimCallback({Func="GiveUnitsToPlayer", Args={ From=GetFocusArmy(), To=id},} , true)
			end

		else
			SimCallback({Func="GiveUnitsToPlayer", Args={ From=GetFocusArmy(), To=allyIndex},} , true)
		end
	end
end


function mimc_giveRessToAlly(massValue, energieValue)
	
	local allyIndex = getAllyIndex()
	if (allyIndex ~= -1) then
		SimCallback( { Func="GiveResourcesToPlayer",
                           Args={ From=GetFocusArmy(),
                                  To=allyIndex,
                                  Mass= massValue / 100.0,
                                  Energy= energieValue / 100.0,
                                }
                             }
                           )
	end
end


--function to get first allied id
function getAllyIndex()

    local armyIndex = -1
    local i = 1
    for index, playerInfo in GetArmiesTable().armiesTable do

        if IsAlly(GetFocusArmy(), index) and index ~= GetFocusArmy() then
		armyIndex = index
	        break
        end

        i = i + 1
    end

    return armyIndex
end


--function to get all allied ids
function getAllyIDs()

    local armyIndices = {}
    local i = 1
    local j = 0
    for index, playerInfo in GetArmiesTable().armiesTable do

        if IsAlly(GetFocusArmy(), index) and index ~= GetFocusArmy() then
		armyIndices[j] = index
		j = j + 1
        end

        i = i + 1
    end

    return armyIndices
end