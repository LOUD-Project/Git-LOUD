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

        LOG("MOD Enhanced Static HP Multipler set to "..repr(modConfig['Multiplier']))

		if modConfig['Multiplier'] == '1.25' then
			for id, bp in all_blueprints.Unit do
				if (bp.Physics.MotionType or 'RULEUMT_None') == 'RULEUMT_None' then
					if type(bp.Defense.Health) == 'number' then
						bp.Defense.Health = bp.Defense.Health * 1.25
					end
					if type(bp.Defense.MaxHealth) == 'number' then
						bp.Defense.MaxHealth = bp.Defense.MaxHealth * 1.25
					end
					if type(bp.Defense.Shield.ShieldMaxHealth) == 'number' then
						bp.Defense.Shield.ShieldMaxHealth = bp.Defense.Shield.ShieldMaxHealth * 1.25
					end
				end
			end
		end

		if modConfig['Multiplier'] == '1.5' then
			for id, bp in all_blueprints.Unit do
				if (bp.Physics.MotionType or 'RULEUMT_None') == 'RULEUMT_None' then
					if type(bp.Defense.Health) == 'number' then
						bp.Defense.Health = bp.Defense.Health * 1.5
					end
					if type(bp.Defense.MaxHealth) == 'number' then
						bp.Defense.MaxHealth = bp.Defense.MaxHealth * 1.5
					end
					if type(bp.Defense.Shield.ShieldMaxHealth) == 'number' then
						bp.Defense.Shield.ShieldMaxHealth = bp.Defense.Shield.ShieldMaxHealth * 1.5
					end
				end
			end
		end
		
		if modConfig['Multiplier'] == '1.75' then
			for id, bp in all_blueprints.Unit do
				if (bp.Physics.MotionType or 'RULEUMT_None') == 'RULEUMT_None' then
					if type(bp.Defense.Health) == 'number' then
						bp.Defense.Health = bp.Defense.Health * 1.75
					end
					if type(bp.Defense.MaxHealth) == 'number' then
						bp.Defense.MaxHealth = bp.Defense.MaxHealth * 1.75
					end
					if type(bp.Defense.Shield.ShieldMaxHealth) == 'number' then
						bp.Defense.Shield.ShieldMaxHealth = bp.Defense.Shield.ShieldMaxHealth * 1.75
					end
				end
			end
		end
		
		if modConfig['Multiplier'] == '2.0' then
			for id, bp in all_blueprints.Unit do
				if (bp.Physics.MotionType or 'RULEUMT_None') == 'RULEUMT_None' then
					if type(bp.Defense.Health) == 'number' then
						bp.Defense.Health = bp.Defense.Health * 2
					end
					if type(bp.Defense.MaxHealth) == 'number' then
						bp.Defense.MaxHealth = bp.Defense.MaxHealth * 2
					end
					if type(bp.Defense.Shield.ShieldMaxHealth) == 'number' then
						bp.Defense.Shield.ShieldMaxHealth = bp.Defense.Shield.ShieldMaxHealth * 2
					end
				end
			end
		end		

		if modConfig['Multiplier'] == '2.5' then
			for id, bp in all_blueprints.Unit do
				if (bp.Physics.MotionType or 'RULEUMT_None') == 'RULEUMT_None' then
					if type(bp.Defense.Health) == 'number' then
						bp.Defense.Health = bp.Defense.Health * 2.5
					end
					if type(bp.Defense.MaxHealth) == 'number' then
						bp.Defense.MaxHealth = bp.Defense.MaxHealth * 2.5
					end
					if type(bp.Defense.Shield.ShieldMaxHealth) == 'number' then
						bp.Defense.Shield.ShieldMaxHealth = bp.Defense.Shield.ShieldMaxHealth * 2.5
					end
				end
			end
		end
	end
end
