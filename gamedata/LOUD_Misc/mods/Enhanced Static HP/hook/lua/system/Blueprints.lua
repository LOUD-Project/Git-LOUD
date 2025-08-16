do
	local OldModBlueprints = ModBlueprints

	function ModBlueprints(all_blueprints)

		OldModBlueprints(all_blueprints)
		
		local modConfig = {}

		for _, v in __active_mods do
			if v.uid == 'b8d941e131multiplier' then
				modConfig = v.config
				break
			end
		end
        
        if modConfig then

            LOG("MOD Enhanced Static HP Multipler set to "..repr(modConfig['Multiplier']))
        
            local multiplier = tonumber(modConfig['Multiplier'])

            for id, bp in all_blueprints.Unit do

                if (bp.Physics.MotionType or 'RULEUMT_None') == 'RULEUMT_None' then

                    if type(bp.Defense.Health) == 'number' then
                        bp.Defense.Health = bp.Defense.Health * multiplier
                    end

                    if type(bp.Defense.MaxHealth) == 'number' then
                        bp.Defense.MaxHealth = bp.Defense.MaxHealth * multiplier
                    end

                end
            end
        end
    end
end
