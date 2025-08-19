do
	local OldModBlueprints = ModBlueprints

	function ModBlueprints(all_blueprints)

		local modConfig = {}

		for _, v in __active_mods do
			if v.uid == 'ffffffff-9d4e-11dc-8314-0800200c0600' then
				modConfig = v.config
				break
			end
		end
        
        if modConfig then
        
            local multiplier = tonumber(modConfig['Multiplier'] or 1.0)

            LOG("MOD Enhanced Static HP Multipler set to "..multiplier)

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

		OldModBlueprints(all_blueprints)
		
    end
end
