local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local Buff = import('/lua/sim/buff.lua')

SEB5381 = Class(TStructureUnit) {
    --When we're adjacent, try to all all the possible bonuses.
    OnAdjacentTo = function(self, adjacentUnit, triggerUnit)
        if self:IsBeingBuilt() then return end
		if adjacentUnit:IsBeingBuilt() then return end
		-- RAT: Don't apply to a unit with a beam weapon as per Sprouto
		-- RATODO: Ought to work on units with both beams and non-beam weapons.
		-- Maybe use damageMod instead.
		for i = 1, adjacentUnit:GetWeaponCount() do
			if adjacentUnit:GetWeapon(i):GetBlueprint().BeamCollisionDelay then
				return
			end
		end
        self:CalculateWeaponDamageBuff(adjacentUnit)
        TStructureUnit.OnAdjacentTo(self, adjacentUnit, triggerUnit)
    end,

    --When we're not adjacent, try to remove all the possible bonuses.
    OnNotAdjacentTo = function(self, adjacentUnit)
        self:CalculateWeaponDamageBuff(adjacentUnit, true)
        TStructureUnit.OnNotAdjacentTo(self, adjacentUnit)
    end,

	CalculateWeaponDamageBuff = function(self, adjacentUnit, remove)
		for _, v in import('/lua/sim/adjacencybuffs.lua')['T3WeaponBoosterDamageAdjacencyBuffs'] do
			if not remove then
				Buff.ApplyBuff(adjacentUnit, v, self)
			else
				Buff.RemoveBuff(adjacentUnit, v)
			end
		end
    end,
}

TypeClass = SEB5381
