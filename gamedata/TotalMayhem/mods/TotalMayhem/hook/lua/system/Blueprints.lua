do
	function Check(all_blueprints, id)
		if all_blueprints.Unit[id]~=nil then
			return true;
		end
		return false;
	end

	local OldModBlueprints = ModBlueprints
	function ModBlueprints(all_blueprints)
		OldModBlueprints(all_blueprints)

		-- SERA: Increase Lambda Bot delay (original was 2)
		if Check(all_blueprints, 'bsb0005') then
			local BP = all_blueprints.Unit['bsb0005'];
			BP.Defense.SeraLambdaFieldDestroyer01.RedirectRateOfFire = 5;
		end

		-- UEF: Tweak Angry Ace
		if Check(all_blueprints, 'brnt2pd2') then
			all_blueprints.Unit.brnt2pd2.Weapon[1].DamageRadius = 2
			-- all_blueprints.Unit.brnt2pd2.Weapon[1].RateOfFire = 1
			all_blueprints.Unit.brnt2pd2.Weapon[1].FiringRandomness = 0.1
		end

		-- UEF: Amphibious Cougar
		if Check(all_blueprints, 'belk002') then
			table.insert(all_blueprints.Unit.belk002.Categories, 'AMPHIBIOUS')
		end
	end
end
